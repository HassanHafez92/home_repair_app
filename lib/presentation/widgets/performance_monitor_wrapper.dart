/// Performance Monitor Wrapper
///
/// This widget provides automatic performance monitoring for screens
/// and widgets, tracking load times and frame rates.
library;

import 'package:flutter/material.dart';
import 'package:home_repair_app/services/performance_monitoring_service.dart';

/// Performance monitor wrapper widget
class PerformanceMonitorWrapper extends StatefulWidget {
  final String screenName;
  final Widget child;
  final bool trackFrameRate;
  final bool trackLoadTime;
  final void Function(PerformanceMetrics)? onMetricsCollected;

  const PerformanceMonitorWrapper({
    super.key,
    required this.screenName,
    required this.child,
    this.trackFrameRate = true,
    this.trackLoadTime = true,
    this.onMetricsCollected,
  });

  @override
  State<PerformanceMonitorWrapper> createState() =>
      _PerformanceMonitorWrapperState();
}

class _PerformanceMonitorWrapperState extends State<PerformanceMonitorWrapper> {
  final PerformanceMonitoringService _monitoringService =
      PerformanceMonitoringService();
  DateTime? _loadStartTime;
  int _frameCount = 0;
  DateTime? _frameRateStartTime;

  @override
  void initState() {
    super.initState();
    if (widget.trackLoadTime) {
      _loadStartTime = DateTime.now();
      _monitoringService.startScreenLoad(widget.screenName);
    }
    if (widget.trackFrameRate) {
      _startFrameRateTracking();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Track when dependencies are loaded
    if (widget.trackLoadTime && _loadStartTime != null) {
      DateTime.now().difference(_loadStartTime!);
      _monitoringService.endScreenLoad(widget.screenName);
    }
  }

  @override
  void dispose() {
    if (widget.trackLoadTime) {
      _monitoringService.endScreenLoad(widget.screenName);
    }
    if (widget.trackFrameRate) {
      _stopFrameRateTracking();
    }
    super.dispose();
  }

  void _startFrameRateTracking() {
    _frameCount = 0;
    _frameRateStartTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _stopFrameRateTracking() {
    if (_frameRateStartTime != null) {
      final duration = DateTime.now().difference(_frameRateStartTime!);
      final fps = _frameCount / duration.inSeconds;
      // Frame rate is tracked internally by the service

      final metrics = PerformanceMetrics(
        screenName: widget.screenName,
        loadTime: _loadStartTime != null
            ? DateTime.now().difference(_loadStartTime!)
            : null,
        frameRate: fps,
        frameCount: _frameCount,
      );

      widget.onMetricsCollected?.call(metrics);
    }
  }

  void _onFrame(_) {
    if (mounted) {
      _frameCount++;
      WidgetsBinding.instance.addPostFrameCallback(_onFrame);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Performance metrics data class
class PerformanceMetrics {
  final String screenName;
  final Duration? loadTime;
  final double frameRate;
  final int frameCount;

  PerformanceMetrics({
    required this.screenName,
    this.loadTime,
    required this.frameRate,
    required this.frameCount,
  });

  @override
  String toString() {
    return 'PerformanceMetrics(screenName: $screenName, '
        'loadTime: ${loadTime?.inMilliseconds}ms, '
        'frameRate: ${frameRate.toStringAsFixed(1)}fps, '
        'frameCount: $frameCount)';
  }

  /// Check if performance is good
  bool get isGoodPerformance =>
      (loadTime == null || loadTime!.inMilliseconds < 500) && frameRate >= 55;

  /// Check if performance is acceptable
  bool get isAcceptablePerformance =>
      (loadTime == null || loadTime!.inMilliseconds < 1000) && frameRate >= 45;

  /// Get performance rating
  PerformanceRating get rating {
    if (isGoodPerformance) return PerformanceRating.excellent;
    if (isAcceptablePerformance) return PerformanceRating.good;
    if (frameRate >= 30) return PerformanceRating.fair;
    return PerformanceRating.poor;
  }
}

/// Performance rating
enum PerformanceRating { excellent, good, fair, poor }

/// Performance rating extension
extension PerformanceRatingExtension on PerformanceRating {
  String get label {
    switch (this) {
      case PerformanceRating.excellent:
        return 'Excellent';
      case PerformanceRating.good:
        return 'Good';
      case PerformanceRating.fair:
        return 'Fair';
      case PerformanceRating.poor:
        return 'Poor';
    }
  }

  Color get color {
    switch (this) {
      case PerformanceRating.excellent:
        return Colors.green;
      case PerformanceRating.good:
        return Colors.lightGreen;
      case PerformanceRating.fair:
        return Colors.orange;
      case PerformanceRating.poor:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case PerformanceRating.excellent:
        return Icons.sentiment_very_satisfied;
      case PerformanceRating.good:
        return Icons.sentiment_satisfied;
      case PerformanceRating.fair:
        return Icons.sentiment_neutral;
      case PerformanceRating.poor:
        return Icons.sentiment_dissatisfied;
    }
  }
}

/// Performance metrics display widget
class PerformanceMetricsDisplay extends StatelessWidget {
  final PerformanceMetrics metrics;

  const PerformanceMetricsDisplay({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  metrics.rating.icon,
                  color: metrics.rating.color,
                  size: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  'Performance: ${metrics.rating.label}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: metrics.rating.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow(context, 'Screen', metrics.screenName),
            if (metrics.loadTime != null)
              _buildMetricRow(
                context,
                'Load Time',
                '${metrics.loadTime!.inMilliseconds}ms',
              ),
            _buildMetricRow(
              context,
              'Frame Rate',
              '${metrics.frameRate.toStringAsFixed(1)}fps',
            ),
            _buildMetricRow(context, 'Frame Count', '${metrics.frameCount}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
