// User repository implementation using data sources.
//
// Implements offline-first pattern: check cache first, fall back to network,
// and sync cache with server responses.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/technician_entity.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../domain/usecases/user/get_technician_stats.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart' as models;
import '../datasources/local/i_user_local_data_source.dart';
import '../datasources/remote/i_user_remote_data_source.dart';

/// Implementation of [IUserRepository] using data sources with offline-first pattern.
class UserRepositoryImpl implements IUserRepository {
  final IUserRemoteDataSource _remoteDataSource;
  final IUserLocalDataSource _localDataSource;
  final INetworkInfo _networkInfo;
  final FirebaseFirestore _db;

  UserRepositoryImpl({
    required IUserRemoteDataSource remoteDataSource,
    required IUserLocalDataSource localDataSource,
    required INetworkInfo networkInfo,
    FirebaseFirestore? db,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _db = db ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, void>> createUser(UserEntity user) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final userModel = _userEntityToModel(user);
      await _remoteDataSource.createUser(userModel);
      await _localDataSource.cacheUser(userModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to create user: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUser(String uid) async {
    // Offline-first: try cache first when offline
    if (!await _networkInfo.isConnected) {
      try {
        final cachedUser = await _localDataSource.getCachedUser();
        if (cachedUser.id == uid) {
          return Right(_modelToUserEntity(cachedUser));
        }
      } on CacheException {
        // No valid cache, return failure
        return const Left(NetworkFailure('No cached data available offline'));
      }
    }

    // Online: fetch from remote and update cache
    try {
      final userModel = await _remoteDataSource.getUser(uid);
      await _localDataSource.cacheUser(userModel);
      return Right(_modelToUserEntity(userModel));
    } on NotFoundException {
      return const Right(null);
    } on ServerException catch (e) {
      // Try cache as fallback
      try {
        final cachedUser = await _localDataSource.getCachedUser();
        if (cachedUser.id == uid) {
          return Right(_modelToUserEntity(cachedUser));
        }
      } catch (_) {}
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      debugPrint('UserRepository: Error loading user $uid: $e');
      return Left(ServerFailure('Failed to get user: $e'));
    }
  }

  @override
  Future<Either<Failure, TechnicianEntity?>> getTechnician(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return const Right(null);

      final data = doc.data()!;
      if (data['role'] != 'technician') return const Right(null);

      return Right(_firestoreDataToTechnicianEntity(uid, data));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firestore error', e.code));
    } catch (e) {
      debugPrint('UserRepository: Error loading technician $uid: $e');
      return Left(ServerFailure('Failed to get technician: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(UserEntity user) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = _userEntityToMap(user);
      await _remoteDataSource.updateUser(user.id, data);

      // Update cache
      final userModel = _userEntityToModel(user);
      await _localDataSource.cacheUser(userModel);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to update user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserFields(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.updateUser(uid, fields);
      // Invalidate cache since partial update
      await _localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to update user fields: $e'));
    }
  }

  @override
  Stream<List<TechnicianEntity>> streamPendingTechnicians() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'technician')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _mapToTechnicianEntity(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<Either<Failure, void>> updateTechnicianStatus(
    String uid,
    TechnicianStatus status,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.updateUser(uid, {
        'status': status.toString().split('.').last,
      });
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to update technician status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTechnicianAvailability(
    String uid,
    bool isAvailable,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.updateUser(uid, {'isAvailable': isAvailable});
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to update availability: $e'));
    }
  }

  @override
  Stream<bool> streamTechnicianAvailability(String uid) {
    return _remoteDataSource.watchUser(uid).map((user) {
      // Access isAvailable from the underlying model data
      return false; // Will need proper TechnicianModel for this
    });
  }

  @override
  Future<Either<Failure, TechnicianStatsEntity>> getTechnicianStats(
    String technicianId,
  ) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final userDoc = await _db.collection('users').doc(technicianId).get();
      final rating = userDoc.data()?['rating'] as double? ?? 0.0;

      final completedJobsTotalSnapshot = await _db
          .collection('orders')
          .where('technicianId', isEqualTo: technicianId)
          .where('status', isEqualTo: 'completed')
          .count()
          .get();

      final todayCompletedOrders = await _db
          .collection('orders')
          .where('technicianId', isEqualTo: technicianId)
          .where('status', isEqualTo: 'completed')
          .where(
            'updatedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
          )
          .where('updatedAt', isLessThan: Timestamp.fromDate(todayEnd))
          .get();

      double totalEarnings = 0.0;
      for (var doc in todayCompletedOrders.docs) {
        final order = OrderModel.fromJson(doc.data());
        totalEarnings += order.finalPrice ?? order.initialEstimate ?? 0.0;
      }

      // Get pending and active jobs counts
      final pendingOrdersSnapshot = await _db
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      final activeJobsSnapshot = await _db
          .collection('orders')
          .where('technicianId', isEqualTo: technicianId)
          .where(
            'status',
            whereIn: ['accepted', 'traveling', 'arrived', 'working'],
          )
          .count()
          .get();

      return Right(
        TechnicianStatsEntity(
          todayEarnings: totalEarnings,
          completedJobsToday: todayCompletedOrders.docs.length,
          completedJobsTotal: completedJobsTotalSnapshot.count ?? 0,
          rating: rating,
          pendingOrders: pendingOrdersSnapshot.count ?? 0,
          activeJobs: activeJobsSnapshot.count ?? 0,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('Error fetching technician stats: $e');
      return Left(ServerFailure('Failed to get technician stats: $e'));
    }
  }

  @override
  Stream<TechnicianStatsEntity> streamTechnicianStats(
    String technicianId,
  ) async* {
    final result = await getTechnicianStats(technicianId);
    yield result.fold(
      (failure) => TechnicianStatsEntity.empty(),
      (stats) => stats,
    );
    await for (final _
        in _db
            .collection('orders')
            .where('technicianId', isEqualTo: technicianId)
            .snapshots()) {
      final result = await getTechnicianStats(technicianId);
      yield result.fold(
        (failure) => TechnicianStatsEntity.empty(),
        (stats) => stats,
      );
    }
  }

  // Helper methods for entity mapping
  UserEntity _modelToUserEntity(models.UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      phoneNumber: model.phoneNumber,
      fullName: model.fullName,
      profilePhoto: model.profilePhoto,
      role: _parseModelRole(model.role),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      lastActive: model.lastActive,
      emailVerified: model.emailVerified,
    );
  }

  models.UserModel _userEntityToModel(UserEntity entity) {
    return models.UserModel(
      id: entity.id,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      fullName: entity.fullName,
      profilePhoto: entity.profilePhoto,
      role: _entityRoleToModelRole(entity.role),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastActive: entity.lastActive,
      emailVerified: entity.emailVerified,
    );
  }

  TechnicianEntity _mapToTechnicianEntity(
    String uid,
    Map<String, dynamic> data,
  ) {
    return TechnicianEntity(
      id: uid,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      fullName: data['fullName'] ?? '',
      profilePhoto: data['profilePhoto'],
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      lastActive: _parseTimestamp(data['lastActive']),
      emailVerified: data['emailVerified'],
      nationalId: data['nationalId'],
      specializations: List<String>.from(data['specializations'] ?? []),
      portfolioUrls: List<String>.from(data['portfolioUrls'] ?? []),
      serviceAreas: List<String>.from(data['serviceAreas'] ?? []),
      certifications: List<String>.from(data['certifications'] ?? []),
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble(),
      status: _parseTechnicianStatus(data['status']),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      completedJobs: data['completedJobs'] ?? 0,
      isAvailable: data['isAvailable'] ?? false,
      location: data['location'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> _userEntityToMap(UserEntity user) {
    return {
      'id': user.id,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'fullName': user.fullName,
      'profilePhoto': user.profilePhoto,
      'role': user.role.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
      'emailVerified': user.emailVerified,
    };
  }

  UserRole _parseModelRole(models.UserRole role) {
    switch (role) {
      case models.UserRole.admin:
        return UserRole.admin;
      case models.UserRole.technician:
        return UserRole.technician;
      case models.UserRole.customer:
        return UserRole.customer;
    }
  }

  models.UserRole _entityRoleToModelRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return models.UserRole.admin;
      case UserRole.technician:
        return models.UserRole.technician;
      case UserRole.customer:
        return models.UserRole.customer;
    }
  }

  TechnicianStatus _parseTechnicianStatus(String? status) {
    if (status == null) return TechnicianStatus.pending;
    switch (status) {
      case 'approved':
        return TechnicianStatus.approved;
      case 'rejected':
        return TechnicianStatus.rejected;
      case 'suspended':
        return TechnicianStatus.suspended;
      default:
        return TechnicianStatus.pending;
    }
  }

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    }
    return DateTime.now();
  }

  TechnicianEntity _firestoreDataToTechnicianEntity(
    String id,
    Map<String, dynamic> data,
  ) {
    return TechnicianEntity(
      id: id,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      fullName: data['fullName'] ?? data['name'] ?? '',
      profilePhoto: data['profileImageUrl'],
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      lastActive: _parseTimestamp(data['lastActive']),
      emailVerified: data['emailVerified'],
      nationalId: data['nationalId'],
      specializations: List<String>.from(data['specializations'] ?? []),
      portfolioUrls: List<String>.from(data['portfolioUrls'] ?? []),
      serviceAreas: List<String>.from(data['serviceAreas'] ?? []),
      certifications: List<String>.from(data['certifications'] ?? []),
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble(),
      status: _parseTechnicianStatus(data['status']),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      completedJobs: data['completedJobs'] ?? 0,
      isAvailable: data['isAvailable'] ?? false,
      location: data['location'] as Map<String, dynamic>?,
    );
  }
}
