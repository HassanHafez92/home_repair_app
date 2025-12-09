/// Sign up use case - handles new user registration.

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';

/// Use case for signing up a new user with email and password.
class SignUpWithEmail implements UseCase<UserEntity, SignUpParams> {
  final IAuthRepository repository;

  SignUpWithEmail(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) {
    return repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      phoneNumber: params.phoneNumber,
    );
  }
}

/// Parameters for sign up.
class SignUpParams {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
  });
}
