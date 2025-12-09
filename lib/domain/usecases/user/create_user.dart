/// Create user use case - creates a new user.

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/i_user_repository.dart';

/// Use case for creating a new user.
class CreateUser implements UseCase<void, CreateUserParams> {
  final IUserRepository repository;

  CreateUser(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateUserParams params) {
    return repository.createUser(params.user);
  }
}

/// Parameters for creating a user.
class CreateUserParams {
  final UserEntity user;

  const CreateUserParams({required this.user});
}
