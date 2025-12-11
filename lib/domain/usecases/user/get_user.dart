// Get user use case - retrieves a user by ID.

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/i_user_repository.dart';

/// Use case for getting a user by their ID.
class GetUser implements UseCase<UserEntity?, GetUserParams> {
  final IUserRepository repository;

  GetUser(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(GetUserParams params) {
    return repository.getUser(params.userId);
  }
}

/// Parameters for getting a user.
class GetUserParams {
  final String userId;

  const GetUserParams({required this.userId});
}
