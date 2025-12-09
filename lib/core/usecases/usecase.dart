/// Base use case class for Clean Architecture.
library usecases;

import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all use cases.
///
/// Use cases encapsulate single business operations. They take parameters
/// and return an Either type with a Failure on the left or the result on the right.
///
/// Type parameters:
/// - [Type]: The success return type
/// - [Params]: The parameters required for the use case
///
/// Example:
/// ```dart
/// class GetUser implements UseCase<UserEntity, GetUserParams> {
///   final IUserRepository repository;
///
///   GetUser(this.repository);
///
///   @override
///   Future<Either<Failure, UserEntity>> call(GetUserParams params) {
///     return repository.getUser(params.userId);
///   }
/// }
/// ```
abstract class UseCase<Success, Params> {
  Future<Either<Failure, Success>> call(Params params);
}

/// Use this when a use case doesn't require any parameters.
class NoParams {
  const NoParams();
}
