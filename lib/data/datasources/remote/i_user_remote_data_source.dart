// User remote data source interface.
//
// Defines the contract for user data operations with Firestore.
// Throws [ServerException] on errors.

import '../../../models/user_model.dart';

/// Interface for remote user data operations.
///
/// Implementations should interact with Firestore and throw appropriate
/// exceptions from `core/error/exceptions.dart`.
abstract class IUserRemoteDataSource {
  /// Gets user data by ID from Firestore.
  ///
  /// Throws [ServerException] on Firestore errors.
  /// Throws [NotFoundException] if user doesn't exist.
  Future<UserModel> getUser(String userId);

  /// Creates a new user document in Firestore.
  ///
  /// Throws [ServerException] on Firestore errors.
  Future<void> createUser(UserModel user);

  /// Updates user fields in Firestore.
  ///
  /// Throws [ServerException] on Firestore errors.
  Future<void> updateUser(String userId, Map<String, dynamic> data);

  /// Deletes a user document from Firestore.
  ///
  /// Throws [ServerException] on Firestore errors.
  Future<void> deleteUser(String userId);

  /// Updates the user's last active timestamp.
  ///
  /// Throws [ServerException] on Firestore errors.
  Future<void> updateLastActive(String userId);

  /// Stream of user document changes.
  Stream<UserModel?> watchUser(String userId);
}
