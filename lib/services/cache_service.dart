import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for caching data locally for offline access
class CacheService {
  static const String _categoriesKey = 'categories_cache';
  static const String _categoriesTimestampKey = 'categories_timestamp';
  static const String _servicesKey = 'services_cache';
  static const String _servicesTimestampKey = 'services_timestamp';
  static const Duration _cacheDuration = Duration(hours: 24);

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // ==================== CATEGORIES ====================

  /// Cache categories for offline access
  Future<void> cacheCategories(List<Map<String, dynamic>> categories) async {
    final prefs = await _prefs;
    final jsonString = jsonEncode(categories);
    await prefs.setString(_categoriesKey, jsonString);
    await prefs.setInt(
      _categoriesTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Get cached categories if not expired
  Future<List<Map<String, dynamic>>?> getCachedCategories() async {
    final prefs = await _prefs;
    final timestamp = prefs.getInt(_categoriesTimestampKey);

    if (timestamp == null) return null;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (DateTime.now().difference(cachedTime) > _cacheDuration) {
      // Cache expired
      await prefs.remove(_categoriesKey);
      await prefs.remove(_categoriesTimestampKey);
      return null;
    }

    final jsonString = prefs.getString(_categoriesKey);
    if (jsonString == null) return null;

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  // ==================== SERVICES ====================

  /// Cache services for offline access
  Future<void> cacheServices(List<Map<String, dynamic>> services) async {
    final prefs = await _prefs;
    final jsonString = jsonEncode(services);
    await prefs.setString(_servicesKey, jsonString);
    await prefs.setInt(
      _servicesTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Get cached services if not expired
  Future<List<Map<String, dynamic>>?> getCachedServices() async {
    final prefs = await _prefs;
    final timestamp = prefs.getInt(_servicesTimestampKey);

    if (timestamp == null) return null;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (DateTime.now().difference(cachedTime) > _cacheDuration) {
      // Cache expired
      await prefs.remove(_servicesKey);
      await prefs.remove(_servicesTimestampKey);
      return null;
    }

    final jsonString = prefs.getString(_servicesKey);
    if (jsonString == null) return null;

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  /// Check if services cache is valid (not expired)
  Future<bool> hasValidServicesCache() async {
    final prefs = await _prefs;
    final timestamp = prefs.getInt(_servicesTimestampKey);
    if (timestamp == null) return false;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cachedTime) <= _cacheDuration;
  }

  // ==================== GENERAL ====================

  /// Clear all cached data
  Future<void> clearCache() async {
    final prefs = await _prefs;
    await prefs.remove(_categoriesKey);
    await prefs.remove(_categoriesTimestampKey);
    await prefs.remove(_servicesKey);
    await prefs.remove(_servicesTimestampKey);
  }

  /// Clear only services cache
  Future<void> clearServicesCache() async {
    final prefs = await _prefs;
    await prefs.remove(_servicesKey);
    await prefs.remove(_servicesTimestampKey);
  }
}
