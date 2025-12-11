// User local data source interface.
//
// Defines the contract for local caching of user data.

import '../../../models/user_model.dart';

/// Interface for local user data caching.
///
/// Implementations should use SharedPreferences or similar local storage.
abstract class IUserLocalDataSource {
  /// Gets the cached user data.
  ///
  /// Throws [CacheException] if no cached data is available.
  Future<UserModel> getCachedUser();

  /// Caches user data locally.
  ///
  /// Throws [CacheException] on cache write failures.
  Future<void> cacheUser(UserModel user);

  /// Clears the cached user data.
  Future<void> clearCache();

  /// Whether cached user data exists and is not expired.
  Future<bool> hasCachedUser();
}
