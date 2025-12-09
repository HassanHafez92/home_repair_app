/// Sign in use case - handles user authentication.

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';

/// Use case for signing in a user with email and password.
class SignInWithEmail implements UseCase<UserEntity, SignInParams> {
  final IAuthRepository repository;

  SignInWithEmail(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) {
    return repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parameters for sign in.
class SignInParams {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});
}
