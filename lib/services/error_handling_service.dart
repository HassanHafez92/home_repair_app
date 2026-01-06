/// Error Handling Service
///
/// This service provides centralized error handling with custom error types,
/// error recovery strategies, and user-friendly error messages.
library;

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'logging_service.dart';

/// Custom error types
class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final ErrorSeverity severity;

  AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
    this.severity = ErrorSeverity.medium,
  });

  @override
  String toString() => 'AppError: $message (code: $code)';
}

/// Error severity levels
enum ErrorSeverity { low, medium, high, critical }

/// Network error types
class NetworkError extends AppError {
  NetworkError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super(severity: ErrorSeverity.high);
}

/// Authentication error types
class AuthError extends AppError {
  AuthError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super(severity: ErrorSeverity.high);
}

/// Validation error types
class ValidationError extends AppError {
  ValidationError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super(severity: ErrorSeverity.low);
}

/// Business logic error types
class BusinessError extends AppError {
  BusinessError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super(severity: ErrorSeverity.medium);
}

/// Error handling service
class ErrorHandlingService {
  // Singleton pattern
  static final ErrorHandlingService _instance =
      ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  final LoggingService _logger = LoggingService();
  final Map<String, List<ErrorHandler>> _handlers = {};

  /// Initialize error handling service
  void initialize() {
    // Set up global error handlers
    FlutterError.onError = _handleFlutterError;
    PlatformDispatcher.instance.onError = _handlePlatformError;

    _logger.i('Error handling service initialized');
  }

  /// Handle Flutter error
  void _handleFlutterError(FlutterErrorDetails details) {
    _logger.e('Flutter error: ${details.exception}', stackTrace: details.stack);

    // Record to Crashlytics
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  }

  /// Handle platform error
  bool _handlePlatformError(Object error, StackTrace stack) {
    _logger.e('Platform error: $error', stackTrace: stack);

    // Record to Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

    return true;
  }

  /// Handle error with recovery strategy
  Future<void> handleError(
    Object error, {
    StackTrace? stackTrace,
    BuildContext? context,
    ErrorRecoveryStrategy? recoveryStrategy,
    bool showErrorDialog = true,
  }) async {
    // Log error
    _logger.e('Error occurred: $error', stackTrace: stackTrace);

    // Convert to AppError
    final appError = _convertToAppError(error, stackTrace);

    // Record to Crashlytics if critical
    if (appError.severity == ErrorSeverity.critical) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: true,
      );
    }

    // Show error dialog if context provided
    if (context != null && showErrorDialog && context.mounted) {
      await _showErrorDialog(context, appError);
    }

    // Execute recovery strategy
    if (recoveryStrategy != null) {
      await recoveryStrategy(appError);
    }

    // Notify registered handlers
    _notifyHandlers(appError);
  }

  /// Convert error to AppError
  AppError _convertToAppError(Object error, StackTrace? stackTrace) {
    if (error is AppError) {
      return error;
    }

    if (error is SocketException) {
      return NetworkError(
        message: 'Network connection failed',
        code: 'NETWORK_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is HttpException) {
      return NetworkError(
        message: 'HTTP request failed',
        code: 'HTTP_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is FormatException) {
      return ValidationError(
        message: 'Invalid data format',
        code: 'FORMAT_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    return AppError(
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
      severity: ErrorSeverity.medium,
    );
  }

  /// Show error dialog
  Future<void> _showErrorDialog(BuildContext context, AppError error) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getErrorTitle(error)),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Get error title based on severity
  String _getErrorTitle(AppError error) {
    switch (error.severity) {
      case ErrorSeverity.low:
        return 'Notice';
      case ErrorSeverity.medium:
        return 'Warning';
      case ErrorSeverity.high:
        return 'Error';
      case ErrorSeverity.critical:
        return 'Critical Error';
    }
  }

  /// Register error handler
  void registerHandler(String key, ErrorHandler handler) {
    _handlers[key] ??= [];
    _handlers[key]!.add(handler);
  }

  /// Unregister error handler
  void unregisterHandler(String key, ErrorHandler handler) {
    _handlers[key]?.remove(handler);
    if (_handlers[key]?.isEmpty ?? false) {
      _handlers.remove(key);
    }
  }

  /// Notify all registered handlers
  void _notifyHandlers(AppError error) {
    for (final handlers in _handlers.values) {
      for (final handler in handlers) {
        try {
          handler(error);
        } catch (e) {
          _logger.e('Error in error handler: $e');
        }
      }
    }
  }

  /// Show error snackbar
  void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info snackbar
  void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Error handler type
typedef ErrorHandler = void Function(AppError error);

/// Error recovery strategy
typedef ErrorRecoveryStrategy = Future<void> Function(AppError error);

/// Common error recovery strategies
class ErrorRecoveryStrategies {
  /// Retry operation
  static ErrorRecoveryStrategy retry(VoidCallback onRetry) {
    return (error) async {
      onRetry();
    };
  }

  /// Navigate to home
  static ErrorRecoveryStrategy navigateToHome(BuildContext context) {
    return (error) async {
      Navigator.of(context).popUntil((route) => route.isFirst);
    };
  }

  /// Navigate to login
  static ErrorRecoveryStrategy navigateToLogin(BuildContext context) {
    return (error) async {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    };
  }

  /// Show custom dialog
  static ErrorRecoveryStrategy showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return (error) async {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    };
  }
}

/// Error boundary widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
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
        _error = error.originalError;
        _stackTrace = error.stackTrace;
      });
    }

    widget.onError?.call(error.originalError ?? error, error.stackTrace);
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _stackTrace = null;
                  });
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
