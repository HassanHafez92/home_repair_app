import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _categoriesKey = 'categories_cache';
  static const String _categoriesTimestampKey = 'categories_timestamp';
  static const Duration _cacheDuration = Duration(hours: 24);

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Cache Categories
  Future<void> cacheCategories(List<Map<String, dynamic>> categories) async {
    final prefs = await _prefs;
    final jsonString = jsonEncode(categories);
    await prefs.setString(_categoriesKey, jsonString);
    await prefs.setInt(
      _categoriesTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Get Cached Categories
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

  // Clear Cache
  Future<void> clearCache() async {
    final prefs = await _prefs;
    await prefs.remove(_categoriesKey);
    await prefs.remove(_categoriesTimestampKey);
  }
}
