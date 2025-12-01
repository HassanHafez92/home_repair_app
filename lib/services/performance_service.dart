// File: lib/services/performance_service.dart
// Purpose: Performance monitoring and analytics service

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'logger_service.dart';

/// Service for monitoring and tracking performance metrics
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  static const String _tag = 'PerformanceService';

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final LoggerService _logger = LoggerService();
  final Map<String, Stopwatch> _activeOperations = {};

  PerformanceService._internal();

  factory PerformanceService() {
    return _instance;
  }

  /// Start tracking an operation
  void startOperation(String operationName) {
    if (operationName.isEmpty) {
      _logger.warning(_tag, 'Operation name cannot be empty');
      return;
    }

    if (_activeOperations.containsKey(operationName)) {
      _logger.warning(_tag, 'Operation "$operationName" already running');
      return;
    }

    _activeOperations[operationName] = Stopwatch()..start();
    _logger.debug(_tag, 'Started operation "$operationName"');
  }

  /// End tracking an operation and log metrics
  Future<int> endOperation(
    String operationName, {
    Map<String, dynamic>? metadata,
  }) async {
    final stopwatch = _activeOperations.remove(operationName);

    if (stopwatch == null) {
      _logger.warning(_tag, 'Operation "$operationName" not found');
      return 0;
    }

    stopwatch.stop();
    final durationMs = stopwatch.elapsedMilliseconds;

    // Log to analytics
    await logPerformanceMetric(
      operationName: operationName,
      durationMs: durationMs,
      metadata: metadata,
    );

    _logger.debug(
      _tag,
      'Operation "$operationName" completed in ${durationMs}ms',
    );

    return durationMs;
  }

  /// Track an operation with automatic timing
  Future<T> trackOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    startOperation(operationName);
    try {
      final result = await operation();
      await endOperation(operationName, metadata: metadata);
      return result;
    } catch (e) {
      await endOperation(
        operationName,
        metadata: {...?metadata, 'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Log a performance metric
  Future<void> logPerformanceMetric({
    required String operationName,
    required int durationMs,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'performance_metric',
        parameters: {
          'operation': operationName,
          'duration_ms': durationMs,
          ...?metadata,
        },
      );
    } catch (e) {
      _logger.error(_tag, 'Failed to log metric', exception: e);
    }
  }

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      _logger.error(_tag, 'Failed to log screen view', exception: e);
    }
  }

  /// Log custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      _logger.error(_tag, 'Failed to log event', exception: e);
    }
  }

  /// Log user action
  Future<void> logUserAction({
    required String action,
    required String category,
    String? value,
  }) async {
    await logEvent(
      name: 'user_action',
      parameters: {
        'action': action,
        'category': category,
        if (value != null) 'value': value,
      },
    );
  }

  /// Set user properties for analytics
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      _logger.error(_tag, 'Failed to set user property', exception: e);
    }
  }

  /// Record a non-fatal error
  void recordError(dynamic exception, StackTrace stackTrace, {String? reason}) {
    try {
      _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: false,
      );
    } catch (e) {
      _logger.error(_tag, 'Failed to record error', exception: e);
    }
  }

  /// Record a fatal error
  void recordFatalError(
    dynamic exception,
    StackTrace stackTrace, {
    String? reason,
  }) {
    try {
      _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: true,
      );
    } catch (e) {
      _logger.error(_tag, 'Failed to record fatal error', exception: e);
    }
  }

  /// Add breadcrumb for crash debugging
  void addBreadcrumb(String message) {
    try {
      _crashlytics.log(message);
    } catch (e) {
      _logger.error(_tag, 'Failed to add breadcrumb', exception: e);
    }
  }

  /// Get list of active operations
  List<String> getActiveOperations() {
    return _activeOperations.keys.toList();
  }

  /// Clear all active operations
  void clearActiveOperations() {
    _activeOperations.clear();
  }
}
