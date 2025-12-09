/// Use case for creating a review.

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/review_entity.dart';
import '../../repositories/i_review_repository.dart';

class CreateReview implements UseCase<ReviewEntity, CreateReviewParams> {
  final IReviewRepository repository;

  CreateReview(this.repository);

  @override
  Future<Either<Failure, ReviewEntity>> call(CreateReviewParams params) async {
    return repository.createReview(
      orderId: params.orderId,
      technicianId: params.technicianId,
      customerId: params.customerId,
      rating: params.rating,
      categories: params.categories,
      comment: params.comment,
      photoUrls: params.photoUrls,
    );
  }
}

class CreateReviewParams {
  final String orderId;
  final String technicianId;
  final String customerId;
  final int rating;
  final Map<String, int> categories;
  final String? comment;
  final List<String>? photoUrls;

  const CreateReviewParams({
    required this.orderId,
    required this.technicianId,
    required this.customerId,
    required this.rating,
    required this.categories,
    this.comment,
    this.photoUrls,
  });
}
