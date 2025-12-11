// Auth repository implementation using data sources.
//
// This implementation delegates to data sources and handles
// exception-to-failure conversion for Clean Architecture.

import 'package:dartz/dartz.dart';

import 'package:flutter/foundation.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../models/user_model.dart' as models;
import '../datasources/remote/i_auth_remote_data_source.dart';
import '../datasources/remote/i_user_remote_data_source.dart';

/// Implementation of [IAuthRepository] using data sources.
class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _authRemoteDataSource;
  final IUserRemoteDataSource _userRemoteDataSource;
  final INetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required IAuthRemoteDataSource authRemoteDataSource,
    required IUserRemoteDataSource userRemoteDataSource,
    required INetworkInfo networkInfo,
  }) : _authRemoteDataSource = authRemoteDataSource,
       _userRemoteDataSource = userRemoteDataSource,
       _networkInfo = networkInfo;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authRemoteDataSource.authStateChanges.asyncMap((uid) async {
      if (uid == null) return null;
      try {
        final userModel = await _userRemoteDataSource.getUser(uid);
        return _mapToUserEntity(userModel);
      } catch (e) {
        debugPrint('Error fetching user entity: $e');
        return null;
      }
    });
  }

  @override
  UserEntity? get currentUser {
    final uid = _authRemoteDataSource.currentUserId;
    if (uid == null) return null;
    // Return minimal entity - full data loaded async via authStateChanges
    return UserEntity(
      id: uid,
      email: '',
      fullName: '',
      role: UserRole.customer,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastActive: DateTime.now(),
      emailVerified: _authRemoteDataSource.isEmailVerified,
    );
  }

  @override
  bool get isEmailVerified => _authRemoteDataSource.isEmailVerified;

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      // Create auth account
      final authData = await _authRemoteDataSource.signUpWithEmail(
        email: email,
        password: password,
      );

      final uid = authData['uid'] as String;
      final now = DateTime.now();

      // Create user document in Firestore
      final userEntity = UserEntity(
        id: uid,
        email: email,
        phoneNumber: phoneNumber,
        fullName: fullName,
        role: UserRole.customer,
        createdAt: now,
        updatedAt: now,
        lastActive: now,
        emailVerified: false,
      );

      await _createUserDocument(uid, userEntity, phoneNumber);

      return Right(userEntity);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(AuthFailure('An error occurred during sign up: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final uid = await _authRemoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );

      final userModel = await _userRemoteDataSource.getUser(uid);
      return Right(_mapToUserEntity(userModel));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(AuthFailure('An error occurred during sign in: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> signInWithGoogle() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final authData = await _authRemoteDataSource.signInWithGoogle();
      if (authData == null) {
        return const Right(null); // User cancelled
      }

      final uid = authData['uid'] as String;
      final isNewUser = authData['isNewUser'] as bool? ?? false;

      if (isNewUser) {
        // Create new user document
        final now = DateTime.now();
        final userEntity = UserEntity(
          id: uid,
          email: authData['email'] as String? ?? '',
          fullName: authData['displayName'] as String? ?? '',
          profilePhoto: authData['photoURL'] as String?,
          role: UserRole.customer,
          createdAt: now,
          updatedAt: now,
          lastActive: now,
          emailVerified: authData['emailVerified'] as bool? ?? false,
        );

        await _createUserDocument(uid, userEntity, null);
        return Right(userEntity);
      }

      // Existing user - fetch from Firestore
      final userModel = await _userRemoteDataSource.getUser(uid);
      return Right(_mapToUserEntity(userModel));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on NotFoundException {
      // User exists in auth but not in Firestore - rare edge case
      return const Left(NotFoundFailure('User data not found'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      if (kDebugMode) print('Google Sign In Error: $e');
      return Left(AuthFailure('Google Sign In failed: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> signInWithFacebook() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final authData = await _authRemoteDataSource.signInWithFacebook();
      if (authData == null) {
        return const Right(null); // User cancelled
      }

      final uid = authData['uid'] as String;
      final isNewUser = authData['isNewUser'] as bool? ?? false;

      if (isNewUser) {
        final now = DateTime.now();
        final userEntity = UserEntity(
          id: uid,
          email: authData['email'] as String? ?? '',
          fullName: authData['displayName'] as String? ?? '',
          profilePhoto: authData['photoURL'] as String?,
          role: UserRole.customer,
          createdAt: now,
          updatedAt: now,
          lastActive: now,
          emailVerified: authData['emailVerified'] as bool? ?? false,
        );

        await _createUserDocument(uid, userEntity, null);
        return Right(userEntity);
      }

      final userModel = await _userRemoteDataSource.getUser(uid);
      return Right(_mapToUserEntity(userModel));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on NotFoundException {
      return const Left(NotFoundFailure('User data not found'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      if (kDebugMode) print('Facebook Sign In Error: $e');
      return Left(AuthFailure('Facebook Sign In failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _authRemoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } catch (e) {
      return Left(AuthFailure('Error signing out: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _authRemoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } catch (e) {
      return Left(AuthFailure('Error sending password reset email: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await _authRemoteDataSource.sendEmailVerification();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } catch (e) {
      return Left(AuthFailure('Error sending email verification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> reloadUser() async {
    try {
      await _authRemoteDataSource.reloadUser();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } catch (e) {
      if (kDebugMode) print('Error reloading user: $e');
      return Left(AuthFailure('Error reloading user: $e'));
    }
  }

  // Helper methods

  Future<void> _createUserDocument(
    String uid,
    UserEntity entity,
    String? phoneNumber,
  ) async {
    final userModel = models.UserModel(
      id: uid,
      email: entity.email,
      fullName: entity.fullName,
      phoneNumber: phoneNumber,
      profilePhoto: entity.profilePhoto,
      role: models.UserRole.customer,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastActive: entity.lastActive,
      emailVerified: entity.emailVerified,
    );

    await _userRemoteDataSource.createUser(userModel);
  }

  UserEntity _mapToUserEntity(dynamic userModel) {
    return UserEntity(
      id: userModel.id,
      email: userModel.email,
      phoneNumber: userModel.phoneNumber,
      fullName: userModel.fullName,
      profilePhoto: userModel.profilePhoto,
      role: _parseRole(userModel.role),
      createdAt: userModel.createdAt,
      updatedAt: userModel.updatedAt,
      lastActive: userModel.lastActive,
      emailVerified: userModel.emailVerified,
    );
  }

  UserRole _parseRole(dynamic role) {
    if (role == null) return UserRole.customer;
    final roleName = role.toString().split('.').last;
    switch (roleName) {
      case 'admin':
        return UserRole.admin;
      case 'technician':
        return UserRole.technician;
      default:
        return UserRole.customer;
    }
  }
}
