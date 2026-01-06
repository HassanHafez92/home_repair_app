// File: lib/services/user_segmentation_service.dart
// Purpose: User segmentation for targeted marketing and push notifications

import 'package:cloud_firestore/cloud_firestore.dart';

/// User segments for targeted marketing campaigns
enum UserSegment {
  /// New user: < 7 days, no completed orders
  newUser,

  /// Active user: Completed order in last 30 days
  activeUser,

  /// Churning user: No order in 30-60 days
  churningUser,

  /// Lost user: No order in 60+ days
  lostUser,

  /// VIP user: 10+ completed orders
  vipUser,
}

/// Service for segmenting users for targeted marketing
class UserSegmentationService {
  final FirebaseFirestore _firestore;

  UserSegmentationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get the segment for a specific user
  Future<UserSegment> getUserSegment(String userId) async {
    try {
      // Get user document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return UserSegment.newUser;

      final userData = userDoc.data()!;
      final createdAt = (userData['createdAt'] as Timestamp?)?.toDate();

      // Check if new user (< 7 days)
      if (createdAt != null) {
        final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
        if (daysSinceCreation < 7) {
          return UserSegment.newUser;
        }
      }

      // Get user's orders
      final ordersQuery = await _firestore
          .collection('orders')
          .where('customerId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .orderBy('completedAt', descending: true)
          .limit(1)
          .get();

      // Check total completed orders for VIP status
      final orderCountQuery = await _firestore
          .collection('orders')
          .where('customerId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .count()
          .get();

      final completedOrders = orderCountQuery.count ?? 0;

      // VIP if 10+ orders
      if (completedOrders >= 10) {
        return UserSegment.vipUser;
      }

      // No completed orders
      if (ordersQuery.docs.isEmpty) {
        return UserSegment.newUser;
      }

      // Check last order date
      final lastOrder = ordersQuery.docs.first;
      final completedAt = (lastOrder.data()['completedAt'] as Timestamp?)
          ?.toDate();

      if (completedAt == null) {
        return UserSegment.churningUser;
      }

      final daysSinceLastOrder = DateTime.now().difference(completedAt).inDays;

      if (daysSinceLastOrder <= 30) {
        return UserSegment.activeUser;
      } else if (daysSinceLastOrder <= 60) {
        return UserSegment.churningUser;
      } else {
        return UserSegment.lostUser;
      }
    } catch (e) {
      // Default to new user on error
      return UserSegment.newUser;
    }
  }

  /// Get segment display name for UI
  String getSegmentDisplayName(UserSegment segment) {
    switch (segment) {
      case UserSegment.newUser:
        return 'New Customer';
      case UserSegment.activeUser:
        return 'Active Customer';
      case UserSegment.churningUser:
        return 'Returning Customer';
      case UserSegment.lostUser:
        return 'Win-back Customer';
      case UserSegment.vipUser:
        return 'VIP Customer';
    }
  }

  /// Get recommended message for each segment
  String getRecommendedNotification(UserSegment segment) {
    switch (segment) {
      case UserSegment.newUser:
        return 'Welcome! Get 20% off your first service with code WELCOME20';
      case UserSegment.activeUser:
        return 'Thanks for being a loyal customer! Check out our new services';
      case UserSegment.churningUser:
        return "We miss you! Here's 15% off your next booking";
      case UserSegment.lostUser:
        return "It's been a while! Come back with 25% off any service";
      case UserSegment.vipUser:
        return 'VIP exclusive: Priority booking now available for you!';
    }
  }

  /// Get users in a specific segment (for batch notifications)
  Future<List<String>> getUsersInSegment(
    UserSegment segment, {
    int limit = 100,
  }) async {
    // This would need to be implemented with a Cloud Function for efficiency
    // as it requires querying many documents

    // Placeholder implementation
    return [];
  }
}
