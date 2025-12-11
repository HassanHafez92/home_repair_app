// Service local data source implementation for caching.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../models/service_model.dart';

/// Interface for local service caching.
abstract class IServiceLocalDataSource {
  /// Gets all cached services.
  Future<List<ServiceModel>> getCachedServices();

  /// Caches services locally.
  Future<void> cacheServices(List<ServiceModel> services);

  /// Clears the services cache.
  Future<void> clearCache();

  /// Whether cached services exist and are not expired.
  Future<bool> hasCachedServices();
}

/// Implementation using SharedPreferences.
class ServiceLocalDataSource implements IServiceLocalDataSource {
  final SharedPreferences _prefs;

  static const String _cacheTimestampKey = 'services_cache_timestamp';

  ServiceLocalDataSource(this._prefs);

  @override
  Future<List<ServiceModel>> getCachedServices() async {
    try {
      final jsonString = _prefs.getString(CacheConstants.servicesCacheKey);
      if (jsonString == null) {
        throw const CacheException('No cached services found');
      }

      // Check if cache is expired
      final cacheTimestamp = _prefs.getInt(_cacheTimestampKey) ?? 0;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);
      final now = DateTime.now();

      if (now.difference(cacheTime) > CacheConstants.cacheTtl) {
        throw const CacheException('Cached services have expired');
      }

      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to read cached services: $e');
    }
  }

  @override
  Future<void> cacheServices(List<ServiceModel> services) async {
    try {
      final jsonList = services.map((s) => s.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await _prefs.setString(CacheConstants.servicesCacheKey, jsonString);
      await _prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException('Failed to cache services: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(CacheConstants.servicesCacheKey);
    await _prefs.remove(_cacheTimestampKey);
  }

  @override
  Future<bool> hasCachedServices() async {
    final jsonString = _prefs.getString(CacheConstants.servicesCacheKey);
    if (jsonString == null) return false;

    final cacheTimestamp = _prefs.getInt(_cacheTimestampKey) ?? 0;
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);
    final now = DateTime.now();

    return now.difference(cacheTime) <= CacheConstants.cacheTtl;
  }
}
