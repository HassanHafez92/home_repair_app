// File: lib/services/social_service.dart
// Purpose: Social features - reviews, ratings, sharing

import 'package:cloud_firestore/cloud_firestore.dart';

/// Review data model
class Review {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final List<String>? images;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int helpfulCount;
  final List<String> helpfulBy;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    this.images,
    required this.createdAt,
    this.updatedAt,
    this.helpfulCount = 0,
    this.helpfulBy = const [],
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userAvatar: json['userAvatar'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      images: List<String>.from(json['images'] as List<dynamic>? ?? []),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      helpfulBy: List<String>.from(json['helpfulBy'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'helpfulCount': helpfulCount,
      'helpfulBy': helpfulBy,
    };
  }
}

/// Service for handling social features
class SocialService {
  static final SocialService _instance = SocialService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SocialService._internal();

  factory SocialService() {
    return _instance;
  }

  /// Add a review to an item
  Future<void> addReview({
    required String collectionName,
    required String itemId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
    String? userAvatar,
    List<String>? imageUrls,
  }) async {
    try {
      final reviewRef = _firestore.collection('reviews').doc();
      final now = DateTime.now();

      final review = {
        'id': reviewRef.id,
        'collectionName': collectionName,
        'itemId': itemId,
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'rating': rating,
        'comment': comment,
        'images': imageUrls ?? [],
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'helpfulCount': 0,
        'helpfulBy': [],
      };

      await reviewRef.set(review);

      // Update item rating aggregate
      await _updateItemRating(collectionName, itemId);
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  /// Get reviews for an item
  Future<List<Review>> getReviews(
    String collectionName,
    String itemId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('collectionName', isEqualTo: collectionName)
          .where('itemId', isEqualTo: itemId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  /// Get reviews by user
  Future<List<Review>> getUserReviews(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to fetch user reviews: $e');
    }
  }

  /// Update a review
  Future<void> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
    List<String>? imageUrls,
  }) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'rating': rating,
        'comment': comment,
        'images': imageUrls,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  /// Delete a review
  Future<void> deleteReview({
    required String reviewId,
    required String collectionName,
    required String itemId,
  }) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();

      // Update item rating aggregate
      await _updateItemRating(collectionName, itemId);
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  /// Mark review as helpful
  Future<void> markHelpful({
    required String reviewId,
    required String userId,
  }) async {
    try {
      final reviewRef = _firestore.collection('reviews').doc(reviewId);
      final review = await reviewRef.get();

      if (!review.exists) {
        throw Exception('Review not found');
      }

      final helpfulBy = List<String>.from(review['helpfulBy'] as List? ?? []);

      if (!helpfulBy.contains(userId)) {
        helpfulBy.add(userId);
        final newCount = (review['helpfulCount'] as int) + 1;
        await reviewRef.update({
          'helpfulCount': newCount,
          'helpfulBy': helpfulBy,
        });
      }
    } catch (e) {
      throw Exception('Failed to mark review as helpful: $e');
    }
  }

  /// Unmark review as helpful
  Future<void> unmarkHelpful({
    required String reviewId,
    required String userId,
  }) async {
    try {
      final reviewRef = _firestore.collection('reviews').doc(reviewId);
      final review = await reviewRef.get();

      if (!review.exists) {
        throw Exception('Review not found');
      }

      final helpfulBy = List<String>.from(review['helpfulBy'] as List? ?? []);

      if (helpfulBy.contains(userId)) {
        helpfulBy.remove(userId);
        final newCount = ((review['helpfulCount'] as int) - 1).clamp(0, 999999);
        await reviewRef.update({
          'helpfulCount': newCount,
          'helpfulBy': helpfulBy,
        });
      }
    } catch (e) {
      throw Exception('Failed to unmark review as helpful: $e');
    }
  }

  /// Get average rating for an item
  Future<double> getAverageRating(String collectionName, String itemId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('collectionName', isEqualTo: collectionName)
          .where('itemId', isEqualTo: itemId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      final totalRating = snapshot.docs.fold<double>(
        0.0,
        (currentSum, doc) => currentSum + (doc['rating'] as num).toDouble(),
      );

      return totalRating / snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get average rating: $e');
    }
  }

  /// Get review statistics
  Future<Map<String, dynamic>> getReviewStats(
    String collectionName,
    String itemId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('collectionName', isEqualTo: collectionName)
          .where('itemId', isEqualTo: itemId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'totalReviews': 0,
          'averageRating': 0.0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      final reviews = snapshot.docs;
      final ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      double totalRating = 0;

      for (final review in reviews) {
        final rating = (review['rating'] as num).toInt();
        ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;
        totalRating += (review['rating'] as num).toDouble();
      }

      return {
        'totalReviews': reviews.length,
        'averageRating': totalRating / reviews.length,
        'ratingDistribution': ratingDistribution,
      };
    } catch (e) {
      throw Exception('Failed to get review statistics: $e');
    }
  }

  /// Report a review as inappropriate
  Future<void> reportReview({
    required String reviewId,
    required String reporterId,
    required String reason,
  }) async {
    try {
      await _firestore.collection('reportedReviews').add({
        'reviewId': reviewId,
        'reporterId': reporterId,
        'reason': reason,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'status': 'pending', // pending, reviewed, resolved
      });
    } catch (e) {
      throw Exception('Failed to report review: $e');
    }
  }

  /// Update item rating aggregate in main collection
  Future<void> _updateItemRating(String collectionName, String itemId) async {
    try {
      final avgRating = await getAverageRating(collectionName, itemId);

      await _firestore
          .collection(collectionName)
          .doc(itemId)
          .update({'rating': avgRating})
          .catchError((e) {
            // Document might not have rating field, silently ignore
            return null;
          });
    } catch (e) {
      // Non-critical operation, log and continue
      debugPrint('Failed to update item rating: $e');
    }
  }
}

/// Debug print helper
void debugPrint(String message) {
  // In Flutter, use: import 'package:flutter/foundation.dart';
  // For now, just ignore
}
