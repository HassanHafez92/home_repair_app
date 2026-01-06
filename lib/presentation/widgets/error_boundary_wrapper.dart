/// Error Boundary Wrapper
///
/// This widget provides error boundary functionality to catch and handle
/// errors in widget trees, preventing app crashes and providing
/// user-friendly error messages.
library;

import 'package:flutter/material.dart';
import 'package:home_repair_app/services/error_handling_service.dart';
import 'package:home_repair_app/services/logging_service.dart';

/// Error boundary wrapper widget
class ErrorBoundaryWrapper extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;
  final String? fallbackTitle;
  final String? fallbackMessage;
  final VoidCallback? onRetry;

  const ErrorBoundaryWrapper({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.fallbackTitle,
    this.fallbackMessage,
    this.onRetry,
  });

  @override
  State<ErrorBoundaryWrapper> createState() => _ErrorBoundaryWrapperState();
}

class _ErrorBoundaryWrapperState extends State<ErrorBoundaryWrapper> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    ErrorHandlingService().registerHandler(
      'ErrorBoundary_${widget.key}',
      _handleError,
    );
  }

  @override
  void dispose() {
    ErrorHandlingService().unregisterHandler(
      'ErrorBoundary_${widget.key}',
      _handleError,
    );
    super.dispose();
  }

  void _handleError(AppError error) {
    if (mounted) {
      setState(() {
        _error = error.originalError ?? error;
        _stackTrace = error.stackTrace;
      });
    }

    widget.onError?.call(_error!, _stackTrace);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          _defaultErrorBuilder(_error!, _stackTrace);
    }

    return widget.child;
  }

  Widget _defaultErrorBuilder(Object error, StackTrace? stackTrace) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  widget.fallbackTitle ?? 'Something went wrong',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.fallbackMessage ??
                      'An unexpected error occurred. Please try again.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (widget.onRetry != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _stackTrace = null;
                      });
                      widget.onRetry?.call();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    LoggingService().e(
                      'Error details',
                      error: error,
                      stackTrace: stackTrace,
                    );
                    _showErrorDetails(context, error, stackTrace);
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('View Details'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDetails(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Error:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              if (stackTrace != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Stack Trace:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  stackTrace.toString(),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Async error boundary wrapper for async operations
class AsyncErrorBoundaryWrapper extends StatefulWidget {
  final Future<void> Function() operation;
  final Widget Function(BuildContext context, bool isLoading) builder;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;
  final VoidCallback? onRetry;

  const AsyncErrorBoundaryWrapper({
    super.key,
    required this.operation,
    required this.builder,
    this.errorBuilder,
    this.onError,
    this.onRetry,
  });

  @override
  State<AsyncErrorBoundaryWrapper> createState() =>
      _AsyncErrorBoundaryWrapperState();
}

class _AsyncErrorBoundaryWrapperState extends State<AsyncErrorBoundaryWrapper> {
  bool _isLoading = false;
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    _executeOperation();
  }

  Future<void> _executeOperation() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _stackTrace = null;
    });

    try {
      await widget.operation();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e;
          _stackTrace = stackTrace;
        });
      }

      widget.onError?.call(e, stackTrace);
      await ErrorHandlingService().handleError(
        e,
        stackTrace: stackTrace,
        showErrorDialog: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          _defaultErrorBuilder(_error!, _stackTrace);
    }

    return widget.builder(context, _isLoading);
  }

  Widget _defaultErrorBuilder(Object error, StackTrace? stackTrace) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Operation Failed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _stackTrace = null;
                  });
                  _executeOperation();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error boundary wrapper extension for easy use
extension ErrorBoundaryExtension on Widget {
  /// Wrap widget with error boundary
  Widget withErrorBoundary({
    Widget Function(Object error, StackTrace? stackTrace)? errorBuilder,
    void Function(Object error, StackTrace? stackTrace)? onError,
    String? fallbackTitle,
    String? fallbackMessage,
    VoidCallback? onRetry,
  }) {
    return ErrorBoundaryWrapper(
      errorBuilder: errorBuilder,
      onError: onError,
      fallbackTitle: fallbackTitle,
      fallbackMessage: fallbackMessage,
      onRetry: onRetry,
      child: this,
    );
  }
}
