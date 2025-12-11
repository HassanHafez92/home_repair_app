// User local data source implementation using SharedPreferences.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../models/user_model.dart';
import 'i_user_local_data_source.dart';

/// Implementation of [IUserLocalDataSource] using SharedPreferences.
class UserLocalDataSource implements IUserLocalDataSource {
  final SharedPreferences _prefs;

  static const String _cacheTimestampKey = 'user_cache_timestamp';

  UserLocalDataSource(this._prefs);

  @override
  Future<UserModel> getCachedUser() async {
    try {
      final jsonString = _prefs.getString(CacheConstants.userCacheKey);
      if (jsonString == null) {
        throw const CacheException('No cached user data found');
      }

      // Check if cache is expired
      final cacheTimestamp = _prefs.getInt(_cacheTimestampKey) ?? 0;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);
      final now = DateTime.now();

      if (now.difference(cacheTime) > CacheConstants.cacheTtl) {
        throw const CacheException('Cached user data has expired');
      }

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return UserModel.fromJson(jsonMap);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to read cached user: $e');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await _prefs.setString(CacheConstants.userCacheKey, jsonString);
      await _prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(CacheConstants.userCacheKey);
    await _prefs.remove(_cacheTimestampKey);
  }

  @override
  Future<bool> hasCachedUser() async {
    final jsonString = _prefs.getString(CacheConstants.userCacheKey);
    if (jsonString == null) return false;

    final cacheTimestamp = _prefs.getInt(_cacheTimestampKey) ?? 0;
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);
    final now = DateTime.now();

    return now.difference(cacheTime) <= CacheConstants.cacheTtl;
  }
}
