// Use case for getting technician reviews.

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/review_entity.dart';
import '../../repositories/i_review_repository.dart';

class GetTechnicianReviews implements UseCase<List<ReviewEntity>, String> {
  final IReviewRepository repository;

  GetTechnicianReviews(this.repository);

  @override
  Future<Either<Failure, List<ReviewEntity>>> call(String technicianId) async {
    return repository.getTechnicianReviews(technicianId);
  }
}
