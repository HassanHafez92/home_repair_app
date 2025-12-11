// Update user fields use case.

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/i_user_repository.dart';

/// Use case for updating specific user fields.
class UpdateUserFields implements UseCase<void, UpdateUserFieldsParams> {
  final IUserRepository repository;

  UpdateUserFields(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserFieldsParams params) {
    return repository.updateUserFields(params.userId, params.fields);
  }
}

/// Parameters for updating user fields.
class UpdateUserFieldsParams {
  final String userId;
  final Map<String, dynamic> fields;

  const UpdateUserFieldsParams({required this.userId, required this.fields});
}
