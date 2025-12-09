/// Repository interface for review operations.
///
/// Defines the contract for review-related data access.
/// Implementations handle Firestore/remote data sources.

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/review_entity.dart';

abstract class IReviewRepository {
  /// Get reviews for a technician.
  Future<Either<Failure, List<ReviewEntity>>> getTechnicianReviews(
    String technicianId,
  );

  /// Get a review for a specific order.
  Future<Either<Failure, ReviewEntity?>> getOrderReview(String orderId);

  /// Create a new review.
  Future<Either<Failure, ReviewEntity>> createReview({
    required String orderId,
    required String technicianId,
    required String customerId,
    required int rating,
    required Map<String, int> categories,
    String? comment,
    List<String>? photoUrls,
  });

  /// Update an existing review.
  Future<Either<Failure, ReviewEntity>> updateReview({
    required String reviewId,
    int? rating,
    Map<String, int>? categories,
    String? comment,
    List<String>? photoUrls,
  });

  /// Delete a review.
  Future<Either<Failure, void>> deleteReview(String reviewId);

  /// Get average rating for a technician.
  Future<Either<Failure, double>> getTechnicianAverageRating(
    String technicianId,
  );
}
