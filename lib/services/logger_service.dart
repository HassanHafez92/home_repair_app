// File: lib/services/logger_service.dart
// Purpose: Centralized logging service for consistent and configurable logging

import 'package:flutter/foundation.dart';

/// Log level enumeration
enum LogLevel { debug, info, warning, error }

/// Centralized logging service
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();

  /// Current log level (can be configured)
  LogLevel _logLevel = kDebugMode ? LogLevel.debug : LogLevel.warning;

  LoggerService._internal();

  factory LoggerService() {
    return _instance;
  }

  /// Set the log level
  void setLogLevel(LogLevel level) {
    _logLevel = level;
  }

  /// Check if a log level should be logged
  bool _shouldLog(LogLevel level) {
    return level.index >= _logLevel.index;
  }

  /// Log debug message
  void debug(String tag, String message) {
    if (_shouldLog(LogLevel.debug)) {
      debugPrint('[DEBUG] [$tag] $message');
    }
  }

  /// Log info message
  void info(String tag, String message) {
    if (_shouldLog(LogLevel.info)) {
      debugPrint('[INFO] [$tag] $message');
    }
  }

  /// Log warning message
  void warning(String tag, String message) {
    if (_shouldLog(LogLevel.warning)) {
      debugPrint('[WARNING] [$tag] $message');
    }
  }

  /// Log error message
  void error(
    String tag,
    String message, {
    dynamic exception,
    StackTrace? stackTrace,
  }) {
    if (_shouldLog(LogLevel.error)) {
      debugPrint('[ERROR] [$tag] $message');
      if (exception != null) {
        debugPrint('[ERROR] Exception: $exception');
      }
      if (stackTrace != null) {
        debugPrint('[ERROR] Stack: $stackTrace');
      }
    }
  }
}
