/// Logging Service
///
/// This service provides comprehensive logging capabilities with different
/// log levels, filtering, and remote logging integration.
library;

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Log levels
enum LogLevel { verbose, debug, info, warning, error, fatal }

/// Log entry
class LogEntry {
  final LogLevel level;
  final String message;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic>? extra;

  LogEntry({
    required this.level,
    required this.message,
    this.tag,
    this.error,
    this.stackTrace,
    required this.timestamp,
    this.extra,
  });
}

/// Logging service
class LoggingService {
  // Singleton pattern
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  // Configuration
  LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  bool _enableRemoteLogging = true;
  bool _enableConsoleLogging = true;
  final List<LogEntry> _logs = [];
  final int _maxLogs = 1000;

  /// Initialize logging service
  void initialize({
    LogLevel minLevel = LogLevel.debug,
    bool enableRemoteLogging = true,
    bool enableConsoleLogging = true,
  }) {
    _minLevel = minLevel;
    _enableRemoteLogging = enableRemoteLogging;
    _enableConsoleLogging = enableConsoleLogging;

    developer.log('Logging service initialized', name: 'LoggingService');
  }

  /// Set minimum log level
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Enable/disable remote logging
  void setRemoteLogging(bool enabled) {
    _enableRemoteLogging = enabled;
  }

  /// Enable/disable console logging
  void setConsoleLogging(bool enabled) {
    _enableConsoleLogging = enabled;
  }

  /// Log verbose message
  void v(String message, {String? tag, Map<String, dynamic>? extra}) {
    _log(LogLevel.verbose, message, tag: tag, extra: extra);
  }

  /// Log debug message
  void d(String message, {String? tag, Map<String, dynamic>? extra}) {
    _log(LogLevel.debug, message, tag: tag, extra: extra);
  }

  /// Log info message
  void i(String message, {String? tag, Map<String, dynamic>? extra}) {
    _log(LogLevel.info, message, tag: tag, extra: extra);
  }

  /// Log warning message
  void w(String message, {String? tag, Map<String, dynamic>? extra}) {
    _log(LogLevel.warning, message, tag: tag, extra: extra);
  }

  /// Log error message
  void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }

  /// Log fatal error
  void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.fatal,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }

  /// Internal logging method
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    // Check if level is enabled
    if (level.index < _minLevel.index) {
      return;
    }

    // Create log entry
    final entry = LogEntry(
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      extra: extra,
    );

    // Store log entry
    _addLogEntry(entry);

    // Console logging
    if (_enableConsoleLogging) {
      _logToConsole(entry);
    }

    // Remote logging
    if (_enableRemoteLogging) {
      _logToRemote(entry);
    }
  }

  /// Add log entry to storage
  void _addLogEntry(LogEntry entry) {
    _logs.add(entry);

    // Remove old logs if exceeding max
    if (_logs.length > _maxLogs) {
      _logs.removeRange(0, _logs.length - _maxLogs);
    }
  }

  /// Log to console
  void _logToConsole(LogEntry entry) {
    entry.level.name.toUpperCase();
    final tag = entry.tag ?? 'App';
    entry.timestamp.toIso8601String();

    developer.log(
      entry.message,
      name: tag,
      level: _getDeveloperLogLevel(entry.level),
      time: entry.timestamp,
      error: entry.error,
      stackTrace: entry.stackTrace,
    );
  }

  /// Get developer log level
  int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return 500;
      case LogLevel.debug:
        return 700;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }

  /// Log to remote service
  Future<void> _logToRemote(LogEntry entry) async {
    try {
      // Log to Crashlytics for errors and fatal
      if (entry.level == LogLevel.error || entry.level == LogLevel.fatal) {
        await FirebaseCrashlytics.instance.log(
          '[${entry.tag ?? 'App'}] ${entry.message}',
        );

        if (entry.error != null) {
          await FirebaseCrashlytics.instance.recordError(
            entry.error,
            entry.stackTrace,
            fatal: entry.level == LogLevel.fatal,
          );
        }
      }
    } catch (e) {
      developer.log('Failed to log to remote: $e', name: 'LoggingService');
    }
  }

  /// Get all logs
  List<LogEntry> getLogs() {
    return List.from(_logs);
  }

  /// Get logs by level
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// Get logs by tag
  List<LogEntry> getLogsByTag(String tag) {
    return _logs.where((log) => log.tag == tag).toList();
  }

  /// Get logs in time range
  List<LogEntry> getLogsInTimeRange(DateTime start, DateTime end) {
    return _logs.where((log) {
      return log.timestamp.isAfter(start) && log.timestamp.isBefore(end);
    }).toList();
  }

  /// Clear all logs
  void clearLogs() {
    _logs.clear();
  }

  /// Export logs to string
  String exportLogs() {
    final buffer = StringBuffer();

    for (final log in _logs) {
      buffer.writeln(
        '[${log.timestamp.toIso8601String()}] '
        '[${log.level.name.toUpperCase()}] '
        '[${log.tag ?? 'App'}] '
        '${log.message}',
      );

      if (log.error != null) {
        buffer.writeln('Error: ${log.error}');
      }

      if (log.stackTrace != null) {
        buffer.writeln('Stack trace:\n${log.stackTrace}');
      }

      if (log.extra != null && log.extra!.isNotEmpty) {
        buffer.writeln('Extra: ${log.extra}');
      }

      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Export logs to JSON
  String exportLogsToJson() {
    final logsJson = _logs
        .map(
          (log) => {
            'level': log.level.name,
            'message': log.message,
            'tag': log.tag,
            'error': log.error?.toString(),
            'stackTrace': log.stackTrace?.toString(),
            'timestamp': log.timestamp.toIso8601String(),
            'extra': log.extra,
          },
        )
        .toList();

    return jsonEncode(logsJson);
  }
}

/// Extension for easy logging
extension LoggingExtension on Object {
  void logVerbose(String message, {String? tag}) {
    LoggingService().v(message, tag: tag ?? runtimeType.toString());
  }

  void logDebug(String message, {String? tag}) {
    LoggingService().d(message, tag: tag ?? runtimeType.toString());
  }

  void logInfo(String message, {String? tag}) {
    LoggingService().i(message, tag: tag ?? runtimeType.toString());
  }

  void logWarning(String message, {String? tag}) {
    LoggingService().w(message, tag: tag ?? runtimeType.toString());
  }

  void logError(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    LoggingService().e(
      message,
      tag: tag ?? runtimeType.toString(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void logFatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    LoggingService().fatal(
      message,
      tag: tag ?? runtimeType.toString(),
      error: error,
      stackTrace: stackTrace,
    );
  }
}
