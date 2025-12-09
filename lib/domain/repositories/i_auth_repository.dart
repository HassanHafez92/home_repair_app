/// Auth repository interface for Clean Architecture.
///
/// This interface defines the contract for authentication operations.
/// Implementations should handle Firebase Auth and return Either types
/// for error handling.

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Repository interface for authentication operations.
abstract class IAuthRepository {
  /// Stream of authentication state changes.
  Stream<UserEntity?> get authStateChanges;

  /// The currently authenticated user, if any.
  UserEntity? get currentUser;

  /// Whether the current user's email is verified.
  bool get isEmailVerified;

  /// Signs up a new user with email and password.
  ///
  /// Returns [Right] with the created [UserEntity] on success,
  /// or [Left] with an [AuthFailure] on failure.
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  });

  /// Signs in a user with email and password.
  ///
  /// Returns [Right] with the [UserEntity] on success,
  /// or [Left] with an [AuthFailure] on failure.
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Signs in a user with their Google account.
  ///
  /// Returns [Right] with the [UserEntity] on success,
  /// [Right] with null if cancelled,
  /// or [Left] with an [AuthFailure] on failure.
  Future<Either<Failure, UserEntity?>> signInWithGoogle();

  /// Signs in a user with their Facebook account.
  ///
  /// Returns [Right] with the [UserEntity] on success,
  /// [Right] with null if cancelled,
  /// or [Left] with an [AuthFailure] on failure.
  Future<Either<Failure, UserEntity?>> signInWithFacebook();

  /// Signs out the current user.
  ///
  /// Returns [Right] with void on success,
  /// or [Left] with an [AuthFailure] on failure.
  Future<Either<Failure, void>> signOut();

  /// Sends a password reset email.
  ///
  /// Returns [Right] with void on success,
  /// or [Left] with an [AuthFailure] on failure.
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Sends an email verification link to the current user.
  ///
  /// Returns [Right] with void on success,
  /// or [Left] with an [AuthFailure] on failure.
  Future<Either<Failure, void>> sendEmailVerification();

  /// Reloads the current user's data from Firebase.
  ///
  /// Returns [Right] with void on success,
  /// or [Left] with an [AuthFailure] on failure.
  Future<Either<Failure, void>> reloadUser();
}
