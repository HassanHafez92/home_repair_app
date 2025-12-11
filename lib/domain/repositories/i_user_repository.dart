// User repository interface for Clean Architecture.

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../entities/technician_entity.dart';
import '../usecases/user/get_technician_stats.dart';

/// Repository interface for user operations.
abstract class IUserRepository {
  /// Creates a new user.
  Future<Either<Failure, void>> createUser(UserEntity user);

  /// Gets a user by their ID.
  Future<Either<Failure, UserEntity?>> getUser(String uid);

  /// Gets a technician by their ID.
  Future<Either<Failure, TechnicianEntity?>> getTechnician(String uid);

  /// Updates a user.
  Future<Either<Failure, void>> updateUser(UserEntity user);

  /// Updates specific fields of a user.
  Future<Either<Failure, void>> updateUserFields(
    String uid,
    Map<String, dynamic> fields,
  );

  /// Streams pending technicians awaiting approval.
  Stream<List<TechnicianEntity>> streamPendingTechnicians();

  /// Updates technician approval status.
  Future<Either<Failure, void>> updateTechnicianStatus(
    String uid,
    TechnicianStatus status,
  );

  /// Updates technician availability.
  Future<Either<Failure, void>> updateTechnicianAvailability(
    String uid,
    bool isAvailable,
  );

  /// Streams technician availability.
  Stream<bool> streamTechnicianAvailability(String uid);

  /// Gets technician statistics.
  Future<Either<Failure, TechnicianStatsEntity>> getTechnicianStats(
    String technicianId,
  );

  /// Streams technician statistics.
  Stream<TechnicianStatsEntity> streamTechnicianStats(String technicianId);
}
