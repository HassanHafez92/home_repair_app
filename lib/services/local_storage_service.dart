/// Local Storage Service
///
/// This service provides unified data persistence across different storage
/// mechanisms including local storage and secure storage.
library;

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logging_service.dart';

/// Storage types
enum StorageType { local, secure, cloud }

/// Storage key prefix
class StorageKeys {
  static const String user = 'user_';
  static const String settings = 'settings_';
  static const String cache = 'cache_';
  static const String auth = 'auth_';
  static const String temp = 'temp_';
}

/// Local storage service
class LocalStorageService {
  // Singleton pattern
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final LoggingService _logger = LoggingService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _preferences;

  /// Initialize storage service
  Future<void> initialize() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      _logger.i('Local storage service initialized');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize local storage service',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Save string to local storage
  Future<bool> saveString(String key, String value) async {
    try {
      final success = await _preferences?.setString(key, value) ?? false;
      if (success) {
        _logger.d('Saved string to local storage: $key');
      }
      return success;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to save string to local storage: $key',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get string from local storage
  String? getString(String key) {
    try {
      return _preferences?.getString(key);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get string from local storage: $key',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Save string to secure storage
  Future<void> saveSecureString(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      _logger.d('Saved string to secure storage: $key');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to save string to secure storage: $key',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get string from secure storage
  Future<String?> getSecureString(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get string from secure storage: $key',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Save JSON object to local storage
  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await saveString(key, jsonString);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to save JSON to local storage: $key',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get JSON object from local storage
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get JSON from local storage: $key',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Save JSON object to secure storage
  Future<void> saveSecureJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      await saveSecureString(key, jsonString);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to save JSON to secure storage: $key',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get JSON object from secure storage
  Future<Map<String, dynamic>?> getSecureJson(String key) async {
    try {
      final jsonString = await getSecureString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get JSON from secure storage: $key',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Save boolean to local storage
  Future<bool> saveBool(String key, bool value) async {
    try {
      final success = await _preferences?.setBool(key, value) ?? false;
      if (success) {
        _logger.d('Saved boolean to local storage: $key');
      }
      return success;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to save boolean to local storage: $key',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get boolean from local storage
  bool? getBool(String key) {
    try {
      return _preferences?.getBool(key);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get boolean from local storage: $key',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Save integer to local storage
  Future<bool> saveInt(String key, int value) async {
    try {
      final success = await _preferences?.setInt(key, value) ?? false;
      if (success) {
        _logger.d('Saved integer to local storage: $key');
      }
      return success;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to save integer to local storage: $key',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get integer from local storage
  int? getInt(String key) {
    try {
      return _preferences?.getInt(key);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get integer from local storage: $key',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Save double to local storage
  Future<bool> saveDouble(String key, double value) async {
    try {
      final success = await _preferences?.setDouble(key, value) ?? false;
      if (success) {
        _logger.d('Saved double to local storage: $key');
      }
      return success;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to save double to local storage: $key',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get double from local storage
  double? getDouble(String key) {
    try {
      return _preferences?.getDouble(key);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get double from local storage: $key',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Save string list to local storage
  Future<bool> saveStringList(String key, List<String> value) async {
    try {
      final success = await _preferences?.setStringList(key, value) ?? false;
      if (success) {
        _logger.d('Saved string list to local storage: $key');
      }
      return success;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to save string list to local storage: $key',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get string list from local storage
  List<String>? getStringList(String key) {
    try {
      return _preferences?.getStringList(key);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get string list from local storage: $key',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Remove value from local storage
  Future<bool> remove(String key) async {
    try {
      final success = await _preferences?.remove(key) ?? false;
      if (success) {
        _logger.d('Removed value from local storage: $key');
      }
      return success;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to remove value from local storage: $key',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Remove value from secure storage
  Future<void> removeSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
      _logger.d('Removed value from secure storage: $key');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to remove value from secure storage: $key',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if key exists in local storage
  bool containsKey(String key) {
    try {
      return _preferences?.containsKey(key) ?? false;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to check if key exists in local storage: $key',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Check if key exists in secure storage
  Future<bool> containsSecureKey(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to check if key exists in secure storage: $key',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Clear all local storage
  Future<bool> clear() async {
    try {
      final success = await _preferences?.clear() ?? false;
      if (success) {
        _logger.d('Cleared all local storage');
      }
      return success;
    } catch (e, stackTrace) {
      _logger.e('Failed to clear local storage', stackTrace: stackTrace);
      return false;
    }
  }

  /// Clear all secure storage
  Future<void> clearSecure() async {
    try {
      await _secureStorage.deleteAll();
      _logger.d('Cleared all secure storage');
    } catch (e, stackTrace) {
      _logger.e('Failed to clear secure storage', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get all keys from local storage
  Set<String> getAllKeys() {
    try {
      return _preferences?.getKeys() ?? {};
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get all keys from local storage',
        stackTrace: stackTrace,
      );
      return {};
    }
  }

  /// Get all keys with prefix
  Set<String> getKeysWithPrefix(String prefix) {
    try {
      final allKeys = getAllKeys();
      return allKeys.where((key) => key.startsWith(prefix)).toSet();
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get keys with prefix: $prefix',
        stackTrace: stackTrace,
      );
      return {};
    }
  }

  /// Clear all keys with prefix
  Future<void> clearKeysWithPrefix(String prefix) async {
    try {
      final keys = getKeysWithPrefix(prefix);
      for (final key in keys) {
        await remove(key);
      }
      _logger.d('Cleared all keys with prefix: $prefix');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to clear keys with prefix: $prefix',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
