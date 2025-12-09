/// Send password reset email use case.

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/i_auth_repository.dart';

/// Use case for sending password reset email.
class SendPasswordResetEmail implements UseCase<void, SendPasswordResetParams> {
  final IAuthRepository repository;

  SendPasswordResetEmail(this.repository);

  @override
  Future<Either<Failure, void>> call(SendPasswordResetParams params) {
    return repository.sendPasswordResetEmail(params.email);
  }
}

/// Parameters for password reset.
class SendPasswordResetParams {
  final String email;

  const SendPasswordResetParams({required this.email});
}
