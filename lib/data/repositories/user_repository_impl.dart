/// User repository implementation using Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/technician_entity.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../domain/usecases/user/get_technician_stats.dart';
import '../../models/order_model.dart';

/// Implementation of [IUserRepository] using Firestore.
class UserRepositoryImpl implements IUserRepository {
  final FirebaseFirestore _db;

  UserRepositoryImpl({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, void>> createUser(UserEntity user) async {
    try {
      final data = _userEntityToMap(user);
      await _db.collection('users').doc(user.id).set(data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to create user: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return const Right(null);
      }

      final data = doc.data()!;
      final entity = _mapToUserEntity(uid, data);
      return Right(entity);
    } catch (e) {
      debugPrint('UserRepository: Error loading user $uid: $e');
      return Left(ServerFailure('Failed to get user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(UserEntity user) async {
    try {
      final data = _userEntityToMap(user);
      await _db.collection('users').doc(user.id).update(data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserFields(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    try {
      await _db.collection('users').doc(uid).update(fields);
      return const Right(null);
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
    try {
      await _db.collection('users').doc(uid).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update technician status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTechnicianAvailability(
    String uid,
    bool isAvailable,
  ) async {
    try {
      await _db.collection('users').doc(uid).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update availability: $e'));
    }
  }

  @override
  Stream<bool> streamTechnicianAvailability(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return false;
      return snapshot.data()!['isAvailable'] as bool? ?? false;
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
  UserEntity _mapToUserEntity(String uid, Map<String, dynamic> data) {
    final roleStr = data['role'] as String?;

    if (roleStr == 'technician' || roleStr == 'UserRole.technician') {
      return _mapToTechnicianEntity(uid, data).toUserEntity();
    }

    return UserEntity(
      id: uid,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      fullName: data['fullName'] ?? '',
      profilePhoto: data['profilePhoto'],
      role: _parseRole(roleStr),
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      lastActive: _parseTimestamp(data['lastActive']),
      emailVerified: data['emailVerified'],
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
      'createdAt': Timestamp.fromDate(user.createdAt),
      'updatedAt': Timestamp.fromDate(user.updatedAt),
      'lastActive': Timestamp.fromDate(user.lastActive),
      'emailVerified': user.emailVerified,
    };
  }

  UserRole _parseRole(String? role) {
    if (role == null) return UserRole.customer;
    switch (role) {
      case 'admin':
      case 'UserRole.admin':
        return UserRole.admin;
      case 'technician':
      case 'UserRole.technician':
        return UserRole.technician;
      default:
        return UserRole.customer;
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
}
