/// Google sign in use case.

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';

/// Use case for signing in a user with Google.
class SignInWithGoogle implements UseCase<UserEntity?, NoParams> {
  final IAuthRepository repository;

  SignInWithGoogle(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) {
    return repository.signInWithGoogle();
  }
}
