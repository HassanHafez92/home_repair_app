// File: lib/services/recommendation_service.dart
// Purpose: Service for generating personalized service recommendations.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import 'package:home_repair_app/models/user_activity_model.dart';

/// Service for generating personalized recommendations
class RecommendationService {
  final FirebaseFirestore _firestore;

  RecommendationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get personalized recommendations for a user
  Future<List<RecommendedService>> getRecommendations({
    required String userId,
    required List<ServiceEntity> allServices,
    int limit = 6,
  }) async {
    try {
      // Fetch user activity
      final activity = await _getUserActivity(userId);

      if (activity == null) {
        // New user - return popular services
        return _getPopularServices(allServices, limit);
      }

      final recommendations = <RecommendedService>[];

      // 1. Add services from top categories
      for (final category in activity.topCategories) {
        final categoryServices = allServices
            .where(
              (s) =>
                  s.category.toLowerCase() == category.toLowerCase() &&
                  !activity.bookedServices.contains(s.id),
            )
            .take(2)
            .map(
              (s) => RecommendedService(
                service: s,
                reason: RecommendationReason.categoryInterest,
                score: activity.categoryInterest[category] ?? 0,
              ),
            );
        recommendations.addAll(categoryServices);
      }

      // 2. Add "Customers also booked" suggestions
      if (activity.bookedServices.isNotEmpty) {
        final alsoBooked = await _getCustomersAlsoBooked(
          activity.bookedServices.first,
          allServices,
        );
        recommendations.addAll(
          alsoBooked
              .where((r) => !activity.bookedServices.contains(r.service.id))
              .take(2),
        );
      }

      // 3. Add seasonal suggestions
      final seasonal = _getSeasonalSuggestions(allServices);
      recommendations.addAll(
        seasonal
            .where(
              (r) =>
                  !activity.bookedServices.contains(r.service.id) &&
                  !recommendations.any((e) => e.service.id == r.service.id),
            )
            .take(2),
      );

      // Remove duplicates and limit
      final uniqueRecommendations = <String, RecommendedService>{};
      for (final rec in recommendations) {
        if (!uniqueRecommendations.containsKey(rec.service.id)) {
          uniqueRecommendations[rec.service.id] = rec;
        }
      }

      // Sort by score and limit
      final sortedList = uniqueRecommendations.values.toList()
        ..sort((a, b) => b.score.compareTo(a.score));

      return sortedList.take(limit).toList();
    } catch (e) {
      // Fallback to popular services on error
      return _getPopularServices(allServices, limit);
    }
  }

  /// Get "Customers also booked" suggestions based on a service
  Future<List<RecommendedService>> _getCustomersAlsoBooked(
    String serviceId,
    List<ServiceEntity> allServices,
  ) async {
    try {
      // Query orders that contain this service
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('serviceId', isEqualTo: serviceId)
          .where('status', isEqualTo: 'completed')
          .limit(50)
          .get();

      // Get customer IDs who booked this service
      final customerIds = ordersSnapshot.docs
          .map((doc) => doc.data()['customerId'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet();

      if (customerIds.isEmpty) return [];

      // Find other services these customers booked
      final serviceFrequency = <String, int>{};

      for (final customerId in customerIds.take(20)) {
        final customerOrders = await _firestore
            .collection('orders')
            .where('customerId', isEqualTo: customerId)
            .where('status', isEqualTo: 'completed')
            .limit(10)
            .get();

        for (final order in customerOrders.docs) {
          final orderedServiceId = order.data()['serviceId'] as String?;
          if (orderedServiceId != null && orderedServiceId != serviceId) {
            serviceFrequency[orderedServiceId] =
                (serviceFrequency[orderedServiceId] ?? 0) + 1;
          }
        }
      }

      // Sort by frequency and return top results
      final sortedServices = serviceFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedServices.take(4).map((entry) {
        final service = allServices.firstWhere(
          (s) => s.id == entry.key,
          orElse: () => allServices.first,
        );
        return RecommendedService(
          service: service,
          reason: RecommendationReason.customersAlsoBooked,
          score: entry.value.toDouble(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get seasonal service suggestions
  List<RecommendedService> _getSeasonalSuggestions(
    List<ServiceEntity> allServices,
  ) {
    final now = DateTime.now();
    final month = now.month;

    // Define seasonal service keywords
    Map<String, List<String>> seasonalKeywords;

    if (month >= 6 && month <= 8) {
      // Summer - AC, cooling, pest control
      seasonalKeywords = {
        'summer': ['ac', 'مكيف', 'تكييف', 'cooling', 'تبريد', 'pest', 'حشرات'],
      };
    } else if (month >= 12 || month <= 2) {
      // Winter - heating, plumbing (frozen pipes)
      seasonalKeywords = {
        'winter': ['heat', 'تدفئة', 'plumb', 'سباكة', 'water', 'مياه'],
      };
    } else if (month >= 3 && month <= 5) {
      // Spring - cleaning, painting
      seasonalKeywords = {
        'spring': ['clean', 'نظافة', 'paint', 'دهان', 'تنظيف'],
      };
    } else {
      // Fall - maintenance, inspection
      seasonalKeywords = {
        'fall': ['maintenance', 'صيانة', 'inspect', 'فحص'],
      };
    }

    final keywords = seasonalKeywords.values.first;
    final seasonName = seasonalKeywords.keys.first;

    return allServices
        .where((s) {
          final name = s.name.toLowerCase();
          final desc = s.description.toLowerCase();
          final cat = s.category.toLowerCase();
          return keywords.any(
            (k) => name.contains(k) || desc.contains(k) || cat.contains(k),
          );
        })
        .map(
          (s) => RecommendedService(
            service: s,
            reason: RecommendationReason.seasonal,
            score: 3,
            seasonName: seasonName,
          ),
        )
        .toList();
  }

  /// Get popular services for new users
  List<RecommendedService> _getPopularServices(
    List<ServiceEntity> allServices,
    int limit,
  ) {
    // For now, just return active services
    // In production, this would query order counts
    return allServices
        .where((s) => s.isActive)
        .take(limit)
        .map(
          (s) => RecommendedService(
            service: s,
            reason: RecommendationReason.popular,
            score: 1,
          ),
        )
        .toList();
  }

  /// Get user activity from Firestore
  Future<UserActivityModel?> _getUserActivity(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_activity')
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      return UserActivityModel.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  /// Track a service view
  Future<void> trackServiceView({
    required String userId,
    required String serviceId,
    required String category,
  }) async {
    try {
      final docRef = _firestore.collection('user_activity').doc(userId);
      final doc = await docRef.get();

      UserActivityModel activity;
      if (doc.exists) {
        activity = UserActivityModel.fromJson(doc.data()!);
      } else {
        activity = UserActivityModel.empty(userId);
      }

      final updatedActivity = activity.addViewedService(serviceId, category);
      await docRef.set(updatedActivity.toJson());
    } catch (e) {
      // Silently fail - tracking should not break the app
    }
  }

  /// Track a service booking
  Future<void> trackServiceBooking({
    required String userId,
    required String serviceId,
    required String category,
  }) async {
    try {
      final docRef = _firestore.collection('user_activity').doc(userId);
      final doc = await docRef.get();

      UserActivityModel activity;
      if (doc.exists) {
        activity = UserActivityModel.fromJson(doc.data()!);
      } else {
        activity = UserActivityModel.empty(userId);
      }

      final updatedActivity = activity.addBookedService(serviceId, category);
      await docRef.set(updatedActivity.toJson());
    } catch (e) {
      // Silently fail - tracking should not break the app
    }
  }
}

/// Model for a recommended service with reason and score
class RecommendedService {
  final ServiceEntity service;
  final RecommendationReason reason;
  final double score;
  final String? seasonName;

  const RecommendedService({
    required this.service,
    required this.reason,
    required this.score,
    this.seasonName,
  });

  /// Get display text for the recommendation reason
  String getReasonText() {
    switch (reason) {
      case RecommendationReason.categoryInterest:
        return 'Based on your interests';
      case RecommendationReason.customersAlsoBooked:
        return 'Customers also booked';
      case RecommendationReason.seasonal:
        return 'Popular this season';
      case RecommendationReason.popular:
        return 'Popular service';
      case RecommendationReason.recentlyViewed:
        return 'Recently viewed';
    }
  }
}

/// Reason for recommending a service
enum RecommendationReason {
  /// Based on user's category interest
  categoryInterest,

  /// Other customers who booked similar services also booked this
  customersAlsoBooked,

  /// Seasonal suggestion
  seasonal,

  /// Generally popular service
  popular,

  /// User recently viewed this
  recentlyViewed,
}
