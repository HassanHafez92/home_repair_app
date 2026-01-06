/// Performance Monitoring Service
///
/// This service monitors and tracks various performance metrics throughout
/// the application, including app startup time, screen load times, and
/// animation frame rates.
library;

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class PerformanceMonitoringService {
  // Singleton pattern
  static final PerformanceMonitoringService _instance =
      PerformanceMonitoringService._internal();
  factory PerformanceMonitoringService() => _instance;
  PerformanceMonitoringService._internal();

  // Performance metrics
  DateTime? _appStartTime;
  DateTime? _firstFrameTime;
  DateTime? _appReadyTime;
  final Map<String, DateTime> _screenLoadStartTimes = {};
  final Map<String, Duration> _screenLoadTimes = {};
  final Map<String, int> _screenLoadCounts = {};

  // Frame rate monitoring
  int _frameCount = 0;
  DateTime? _frameRateStartTime;
  double? _currentFrameRate;
  Timer? _frameRateTimer;

  // Analytics
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Initialize performance monitoring
  Future<void> initialize() async {
    _appStartTime = DateTime.now();
    developer.log('Performance monitoring initialized at $_appStartTime');

    // Monitor first frame
    SchedulerBinding.instance.addTimingsCallback(_onFirstFrame);

    // Start frame rate monitoring
    _startFrameRateMonitoring();
  }

  /// Called when first frame is rendered
  void _onFirstFrame(List<FrameTiming> timings) {
    if (_firstFrameTime == null && timings.isNotEmpty) {
      _firstFrameTime = DateTime.now();
      final timeToFirstFrame = _firstFrameTime!.difference(_appStartTime!);

      developer.log(
        'Time to first frame: ${timeToFirstFrame.inMilliseconds}ms',
      );

      // Log to Firebase
      _analytics.logEvent(
        name: 'performance_time_to_first_frame',
        parameters: {'duration_ms': timeToFirstFrame.inMilliseconds},
      );

      // Remove callback after first frame
      SchedulerBinding.instance.removeTimingsCallback(_onFirstFrame);
    }
  }

  /// Mark app as ready (after initialization complete)
  void markAppReady() {
    if (_appReadyTime == null) {
      _appReadyTime = DateTime.now();
      final timeToAppReady = _appReadyTime!.difference(_appStartTime!);

      developer.log('Time to app ready: ${timeToAppReady.inMilliseconds}ms');

      // Log to Firebase
      _analytics.logEvent(
        name: 'performance_time_to_app_ready',
        parameters: {'duration_ms': timeToAppReady.inMilliseconds},
      );
    }
  }

  /// Start tracking screen load time
  void startScreenLoad(String screenName) {
    _screenLoadStartTimes[screenName] = DateTime.now();
    developer.log('Started tracking screen load: $screenName');
  }

  /// End tracking screen load time
  void endScreenLoad(String screenName) {
    final startTime = _screenLoadStartTimes[screenName];
    if (startTime != null) {
      final endTime = DateTime.now();
      final loadTime = endTime.difference(startTime);

      // Store metrics
      _screenLoadTimes[screenName] = loadTime;
      _screenLoadCounts[screenName] = (_screenLoadCounts[screenName] ?? 0) + 1;

      developer.log(
        'Screen $screenName loaded in ${loadTime.inMilliseconds}ms',
      );

      // Log to Firebase
      _analytics.logEvent(
        name: 'performance_screen_load_time',
        parameters: {
          'screen_name': screenName,
          'duration_ms': loadTime.inMilliseconds,
        },
      );

      // Remove start time
      _screenLoadStartTimes.remove(screenName);

      // Alert if load time is too slow (> 2 seconds)
      if (loadTime.inMilliseconds > 2000) {
        _reportSlowScreenLoad(screenName, loadTime);
      }
    }
  }

  /// Report slow screen load
  void _reportSlowScreenLoad(String screenName, Duration loadTime) {
    final message =
        'Slow screen load detected: $screenName took ${loadTime.inMilliseconds}ms';
    developer.log(message, level: 900); // WARNING level

    // Log to Crashlytics as non-fatal
    FirebaseCrashlytics.instance.log(message);
    FirebaseCrashlytics.instance.recordError(
      Exception(message),
      StackTrace.current,
      fatal: false,
    );
  }

  /// Start frame rate monitoring
  void _startFrameRateMonitoring() {
    _frameRateStartTime = DateTime.now();
    _frameCount = 0;

    _frameRateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now();
      final duration = currentTime.difference(_frameRateStartTime!);
      _currentFrameRate =
          (_frameCount / duration.inSeconds) * 60; // Normalize to 60fps

      developer.log(
        'Current frame rate: ${_currentFrameRate!.toStringAsFixed(1)} fps',
      );

      // Log low frame rates
      if (_currentFrameRate! < 45) {
        _reportLowFrameRate(_currentFrameRate!);
      }

      // Reset counters
      _frameRateStartTime = currentTime;
      _frameCount = 0;
    });

    // Monitor frame updates
    SchedulerBinding.instance.addPersistentFrameCallback((_) {
      _frameCount++;
    });
  }

  /// Report low frame rate
  void _reportLowFrameRate(double frameRate) {
    final message =
        'Low frame rate detected: ${frameRate.toStringAsFixed(1)} fps';
    developer.log(message, level: 900); // WARNING level

    FirebaseCrashlytics.instance.log(message);
  }

  /// Get current frame rate
  double? get currentFrameRate => _currentFrameRate;

  /// Get screen load time statistics
  Map<String, dynamic> getScreenLoadStats() {
    return {
      'screen_load_times': _screenLoadTimes.map(
        (key, value) => MapEntry(key, value.inMilliseconds),
      ),
      'screen_load_counts': _screenLoadCounts,
    };
  }

  /// Get average screen load time for a specific screen
  double? getAverageScreenLoadTime(String screenName) {
    final loadTime = _screenLoadTimes[screenName];
    final count = _screenLoadCounts[screenName];
    if (loadTime != null && count != null && count > 0) {
      return loadTime.inMilliseconds / count;
    }
    return null;
  }

  /// Track custom performance metric
  Future<void> trackCustomMetric(
    String name,
    Duration duration, {
    Map<String, dynamic>? parameters,
  }) async {
    developer.log('Custom metric $name: ${duration.inMilliseconds}ms');

    await _analytics.logEvent(
      name: 'performance_custom_metric',
      parameters: {
        'metric_name': name,
        'duration_ms': duration.inMilliseconds,
        ...?parameters,
      },
    );
  }

  /// Dispose resources
  void dispose() {
    _frameRateTimer?.cancel();
    SchedulerBinding.instance.removeTimingsCallback(_onFirstFrame);
  }
}

/// Helper widget to automatically track screen load times
class PerformanceScreenTracker extends StatefulWidget {
  final String screenName;
  final Widget child;

  const PerformanceScreenTracker({
    super.key,
    required this.screenName,
    required this.child,
  });

  @override
  State<PerformanceScreenTracker> createState() =>
      _PerformanceScreenTrackerState();
}

class _PerformanceScreenTrackerState extends State<PerformanceScreenTracker> {
  @override
  void initState() {
    super.initState();
    PerformanceMonitoringService().startScreenLoad(widget.screenName);

    // Schedule end of tracking after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerformanceMonitoringService().endScreenLoad(widget.screenName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
