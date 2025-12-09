/// Sign out use case - handles user sign out.

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/i_auth_repository.dart';

/// Use case for signing out the current user.
class SignOut implements UseCase<void, NoParams> {
  final IAuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.signOut();
  }
}
