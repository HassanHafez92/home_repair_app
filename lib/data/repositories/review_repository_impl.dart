// Implementation of IReviewRepository using ReviewService as data source.
//
// Wraps the existing ReviewService and returns Either types for error handling.

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/i_review_repository.dart';
import '../../services/review_service.dart';
import '../../models/review_model.dart';

class ReviewRepositoryImpl implements IReviewRepository {
  final ReviewService _reviewService;

  ReviewRepositoryImpl({ReviewService? reviewService})
    : _reviewService = reviewService ?? ReviewService();

  @override
  Future<Either<Failure, List<ReviewEntity>>> getTechnicianReviews(
    String technicianId,
  ) async {
    try {
      final reviews = await _reviewService.getReviewsForTechnician(
        technicianId,
      );
      return Right(reviews.map(_mapReviewModelToEntity).toList());
    } catch (e) {
      return Left(ServerFailure('Failed to get technician reviews: $e'));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity?>> getOrderReview(String orderId) async {
    try {
      final review = await _reviewService.getReviewForOrder(orderId);
      if (review == null) return const Right(null);
      return Right(_mapReviewModelToEntity(review));
    } catch (e) {
      return Left(ServerFailure('Failed to get order review: $e'));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> createReview({
    required String orderId,
    required String technicianId,
    required String customerId,
    required int rating,
    required Map<String, int> categories,
    String? comment,
    List<String>? photoUrls,
  }) async {
    try {
      final reviewId = const Uuid().v4();
      final now = DateTime.now();

      final reviewModel = ReviewModel(
        id: reviewId,
        orderId: orderId,
        technicianId: technicianId,
        customerId: customerId,
        rating: rating,
        categories: categories,
        comment: comment,
        photoUrls: photoUrls ?? [],
        timestamp: now,
      );

      await _reviewService.addReview(reviewModel);

      return Right(
        ReviewEntity(
          id: reviewId,
          orderId: orderId,
          technicianId: technicianId,
          customerId: customerId,
          rating: rating,
          categories: categories,
          comment: comment,
          photoUrls: photoUrls ?? [],
          timestamp: now,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to create review: $e'));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> updateReview({
    required String reviewId,
    int? rating,
    Map<String, int>? categories,
    String? comment,
    List<String>? photoUrls,
  }) async {
    // ReviewService doesn't have update method - would need to add
    return const Left(ServerFailure('updateReview not yet implemented'));
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    // ReviewService doesn't have delete method - would need to add
    return const Left(ServerFailure('deleteReview not yet implemented'));
  }

  @override
  Future<Either<Failure, double>> getTechnicianAverageRating(
    String technicianId,
  ) async {
    try {
      final avgRating = await _reviewService.getAverageRating(technicianId);
      return Right(avgRating);
    } catch (e) {
      return Left(ServerFailure('Failed to get average rating: $e'));
    }
  }

  // Helper method for mapping
  ReviewEntity _mapReviewModelToEntity(ReviewModel model) {
    return ReviewEntity(
      id: model.id,
      orderId: model.orderId,
      technicianId: model.technicianId,
      customerId: model.customerId,
      rating: model.rating,
      categories: Map<String, int>.from(model.categories),
      comment: model.comment,
      photoUrls: List<String>.from(model.photoUrls),
      timestamp: model.timestamp,
    );
  }
}
