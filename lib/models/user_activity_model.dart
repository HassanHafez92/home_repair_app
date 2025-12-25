// File: lib/models/user_activity_model.dart
// Purpose: Model for tracking user activity for personalized recommendations.

import 'package:equatable/equatable.dart';

/// Model representing user activity for recommendations
class UserActivityModel extends Equatable {
  /// User ID
  final String userId;

  /// List of viewed service IDs (most recent first)
  final List<ViewedService> viewedServices;

  /// List of booked service IDs
  final List<String> bookedServices;

  /// Category interest scores (category -> score)
  final Map<String, double> categoryInterest;

  /// Last active timestamp
  final DateTime lastActive;

  /// Search queries made by the user
  final List<String> searchQueries;

  /// Favorite service IDs
  final List<String> favoriteServiceIds;

  const UserActivityModel({
    required this.userId,
    this.viewedServices = const [],
    this.bookedServices = const [],
    this.categoryInterest = const {},
    required this.lastActive,
    this.searchQueries = const [],
    this.favoriteServiceIds = const [],
  });

  /// Get top categories by interest score
  List<String> get topCategories {
    final sorted = categoryInterest.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  /// Get recently viewed service IDs (last 10)
  List<String> get recentlyViewedIds =>
      viewedServices.take(10).map((e) => e.serviceId).toList();

  /// Check if user has shown interest in a category
  bool hasInterestIn(String category) =>
      categoryInterest.containsKey(category) && categoryInterest[category]! > 0;

  /// Create a copy with updated values
  UserActivityModel copyWith({
    String? userId,
    List<ViewedService>? viewedServices,
    List<String>? bookedServices,
    Map<String, double>? categoryInterest,
    DateTime? lastActive,
    List<String>? searchQueries,
    List<String>? favoriteServiceIds,
  }) {
    return UserActivityModel(
      userId: userId ?? this.userId,
      viewedServices: viewedServices ?? this.viewedServices,
      bookedServices: bookedServices ?? this.bookedServices,
      categoryInterest: categoryInterest ?? this.categoryInterest,
      lastActive: lastActive ?? this.lastActive,
      searchQueries: searchQueries ?? this.searchQueries,
      favoriteServiceIds: favoriteServiceIds ?? this.favoriteServiceIds,
    );
  }

  /// Add a viewed service
  UserActivityModel addViewedService(String serviceId, String category) {
    final newView = ViewedService(
      serviceId: serviceId,
      category: category,
      viewedAt: DateTime.now(),
    );

    // Update category interest
    final newInterest = Map<String, double>.from(categoryInterest);
    newInterest[category] = (newInterest[category] ?? 0) + 1;

    // Remove duplicates and keep recent
    final updatedViews = [
      newView,
      ...viewedServices.where((v) => v.serviceId != serviceId),
    ].take(50).toList();

    return copyWith(
      viewedServices: updatedViews,
      categoryInterest: newInterest,
      lastActive: DateTime.now(),
    );
  }

  /// Add a booked service
  UserActivityModel addBookedService(String serviceId, String category) {
    // Boost category interest for bookings (worth 5 views)
    final newInterest = Map<String, double>.from(categoryInterest);
    newInterest[category] = (newInterest[category] ?? 0) + 5;

    return copyWith(
      bookedServices: [serviceId, ...bookedServices].take(100).toList(),
      categoryInterest: newInterest,
      lastActive: DateTime.now(),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'viewedServices': viewedServices.map((v) => v.toJson()).toList(),
      'bookedServices': bookedServices,
      'categoryInterest': categoryInterest,
      'lastActive': lastActive.toIso8601String(),
      'searchQueries': searchQueries,
      'favoriteServiceIds': favoriteServiceIds,
    };
  }

  /// Create from JSON (from Firestore)
  factory UserActivityModel.fromJson(Map<String, dynamic> json) {
    return UserActivityModel(
      userId: json['userId'] as String,
      viewedServices:
          (json['viewedServices'] as List<dynamic>?)
              ?.map((v) => ViewedService.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      bookedServices:
          (json['bookedServices'] as List<dynamic>?)?.cast<String>() ?? [],
      categoryInterest:
          (json['categoryInterest'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'] as String)
          : DateTime.now(),
      searchQueries:
          (json['searchQueries'] as List<dynamic>?)?.cast<String>() ?? [],
      favoriteServiceIds:
          (json['favoriteServiceIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Create empty activity for new user
  factory UserActivityModel.empty(String userId) {
    return UserActivityModel(userId: userId, lastActive: DateTime.now());
  }

  @override
  List<Object?> get props => [
    userId,
    viewedServices,
    bookedServices,
    categoryInterest,
    lastActive,
    searchQueries,
    favoriteServiceIds,
  ];
}

/// Model for a viewed service entry
class ViewedService extends Equatable {
  final String serviceId;
  final String category;
  final DateTime viewedAt;

  const ViewedService({
    required this.serviceId,
    required this.category,
    required this.viewedAt,
  });

  Map<String, dynamic> toJson() => {
    'serviceId': serviceId,
    'category': category,
    'viewedAt': viewedAt.toIso8601String(),
  };

  factory ViewedService.fromJson(Map<String, dynamic> json) {
    return ViewedService(
      serviceId: json['serviceId'] as String,
      category: json['category'] as String,
      viewedAt: DateTime.parse(json['viewedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [serviceId, category, viewedAt];
}
