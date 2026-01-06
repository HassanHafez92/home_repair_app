/// Service Initializer
///
/// This file provides centralized service initialization with proper
/// dependency management and error handling.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'logging_service.dart';
import 'logger_service.dart' hide LogLevel;
import 'api_service.dart';
import 'error_handling_service.dart';
import 'performance_monitoring_service.dart';
import 'optimized_image_service.dart';

/// Service initialization status
enum ServiceStatus { notInitialized, initializing, initialized, failed }

/// Service metadata
class ServiceMetadata {
  final String name;
  final ServiceStatus status;
  final String? errorMessage;
  final DateTime? initializedAt;

  ServiceMetadata({
    required this.name,
    required this.status,
    this.errorMessage,
    this.initializedAt,
  });

  ServiceMetadata copyWith({
    String? name,
    ServiceStatus? status,
    String? errorMessage,
    DateTime? initializedAt,
  }) {
    return ServiceMetadata(
      name: name ?? this.name,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      initializedAt: initializedAt ?? this.initializedAt,
    );
  }
}

/// Service initializer
class ServiceInitializer {
  // Singleton pattern
  static final ServiceInitializer _instance = ServiceInitializer._internal();
  factory ServiceInitializer() => _instance;
  ServiceInitializer._internal();

  final Map<String, ServiceMetadata> _services = {};
  final LoggingService _logger = LoggingService();
  final LoggerService _simpleLogger = LoggerService();
  final ErrorHandlingService _errorHandler = ErrorHandlingService();

  /// Get service metadata
  ServiceMetadata? getServiceMetadata(String name) {
    return _services[name];
  }

  /// Get all service metadata
  List<ServiceMetadata> getAllServices() {
    return _services.values.toList();
  }

  /// Get initialized services
  List<ServiceMetadata> getInitializedServices() {
    return _services.values
        .where((service) => service.status == ServiceStatus.initialized)
        .toList();
  }

  /// Get failed services
  List<ServiceMetadata> getFailedServices() {
    return _services.values
        .where((service) => service.status == ServiceStatus.failed)
        .toList();
  }

  /// Initialize all services
  Future<bool> initializeAll({
    bool continueOnError = false,
    void Function(String serviceName, ServiceStatus status)? onProgress,
  }) async {
    _logger.i('Starting service initialization');

    try {
      // Initialize core services first
      await _initializeCoreServices(onProgress);

      // Initialize feature services
      await _initializeFeatureServices(onProgress);

      // Check if all services initialized successfully
      final failedServices = getFailedServices();
      if (failedServices.isNotEmpty) {
        _logger.w(
          'Some services failed to initialize: '
          '${failedServices.map((s) => s.name).join(', ')}',
        );

        if (!continueOnError) {
          return false;
        }
      }

      _logger.i('All services initialized successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize services', stackTrace: stackTrace);
      await _errorHandler.handleError(e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Initialize core services
  Future<void> _initializeCoreServices(
    void Function(String, ServiceStatus)? onProgress,
  ) async {
    _logger.i('Initializing core services');

    // Initialize logging service
    await _initializeService('LoggingService', () async {
      _logger.initialize(
        minLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
        enableRemoteLogging: !kDebugMode,
        enableConsoleLogging: true,
      );
    }, onProgress: onProgress);

    // Initialize error handling service
    await _initializeService(
      'ErrorHandlingService',
      () async => _errorHandler.initialize(),
      onProgress: onProgress,
    );

    // Initialize performance monitoring
    await _initializeService(
      'PerformanceMonitoringService',
      () async => PerformanceMonitoringService().initialize(),
      onProgress: onProgress,
    );

    // Initialize API service
    await _initializeService('ApiService', () async {
      // Initialize the ApiService singleton
      final apiService = ApiService();
      apiService.setDefaultHeader('X-App-Version', '1.0.0');
      _simpleLogger.info('ServiceInitializer', 'API service initialized');
    }, onProgress: onProgress);
  }

  /// Initialize feature services
  Future<void> _initializeFeatureServices(
    void Function(String, ServiceStatus)? onProgress,
  ) async {
    _logger.i('Initializing feature services');

    // Initialize image optimization service
    await _initializeService(
      'OptimizedImageService',
      () async => OptimizedImageService().initialize(),
      onProgress: onProgress,
    );

    // Initialize lazy loading service
    await _initializeService(
      'LazyLoadingService',
      () async {},
      onProgress: onProgress,
    );
  }

  /// Initialize single service
  Future<void> _initializeService(
    String name,
    Future<void> Function() initializer, {
    void Function(String, ServiceStatus)? onProgress,
  }) async {
    // Update status to initializing
    _services[name] = ServiceMetadata(
      name: name,
      status: ServiceStatus.initializing,
    );
    onProgress?.call(name, ServiceStatus.initializing);

    try {
      _logger.i('Initializing service: $name');
      await initializer();

      // Update status to initialized
      _services[name] = ServiceMetadata(
        name: name,
        status: ServiceStatus.initialized,
        initializedAt: DateTime.now(),
      );
      onProgress?.call(name, ServiceStatus.initialized);

      _logger.i('Service initialized: $name');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize service: $name', stackTrace: stackTrace);

      // Update status to failed
      _services[name] = ServiceMetadata(
        name: name,
        status: ServiceStatus.failed,
        errorMessage: e.toString(),
      );
      onProgress?.call(name, ServiceStatus.failed);

      rethrow;
    }
  }

  /// Initialize specific service
  Future<bool> initializeService(
    String name,
    Future<void> Function() initializer,
  ) async {
    try {
      await _initializeService(name, initializer);
      return true;
    } catch (e) {
      _logger.e('Failed to initialize service: $name');
      return false;
    }
  }

  /// Reset all services
  Future<void> resetAll() async {
    _logger.i('Resetting all services');

    for (final service in _services.values) {
      await resetService(service.name);
    }

    _services.clear();
  }

  /// Reset specific service
  Future<void> resetService(String name) async {
    _logger.i('Resetting service: $name');
    _services.remove(name);
  }

  /// Get service status
  ServiceStatus getServiceStatus(String name) {
    return _services[name]?.status ?? ServiceStatus.notInitialized;
  }

  /// Check if all services are initialized
  bool areAllServicesInitialized() {
    return _services.values.every(
      (service) => service.status == ServiceStatus.initialized,
    );
  }

  /// Check if any service failed
  bool hasFailedServices() {
    return _services.values.any(
      (service) => service.status == ServiceStatus.failed,
    );
  }

  /// Get initialization summary
  Map<String, dynamic> getInitializationSummary() {
    return {
      'total': _services.length,
      'initialized': getInitializedServices().length,
      'failed': getFailedServices().length,
      'services': _services.values
          .map(
            (service) => {
              'name': service.name,
              'status': service.status.name,
              'error': service.errorMessage,
              'initializedAt': service.initializedAt?.toIso8601String(),
            },
          )
          .toList(),
    };
  }

  /// Show initialization status dialog
  Future<void> showInitializationStatus(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service Status'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services.values.elementAt(index);
              return ListTile(
                leading: _getStatusIcon(service.status),
                title: Text(service.name),
                subtitle: service.errorMessage != null
                    ? Text(
                        service.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      )
                    : null,
                trailing: service.initializedAt != null
                    ? Text(
                        _formatDuration(
                          DateTime.now().difference(service.initializedAt!),
                        ),
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
              );
            },
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

  /// Get status icon
  Widget _getStatusIcon(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.notInitialized:
        return const Icon(Icons.circle_outlined, color: Colors.grey);
      case ServiceStatus.initializing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case ServiceStatus.initialized:
        return const Icon(Icons.check_circle, color: Colors.green);
      case ServiceStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
    }
  }

  /// Format duration
  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inSeconds > 0) {
      return '${duration.inSeconds}s ago';
    } else {
      return 'just now';
    }
  }
}

/// Service initialization widget
class ServiceInitializationWidget extends StatefulWidget {
  final Widget Function(BuildContext, bool initialized) builder;
  final List<String> requiredServices;

  const ServiceInitializationWidget({
    super.key,
    required this.builder,
    required this.requiredServices,
  });

  @override
  State<ServiceInitializationWidget> createState() =>
      _ServiceInitializationWidgetState();
}

class _ServiceInitializationWidgetState
    extends State<ServiceInitializationWidget> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkServices();
  }

  Future<void> _checkServices() async {
    final initializer = ServiceInitializer();
    final allInitialized = widget.requiredServices.every(
      (service) =>
          initializer.getServiceStatus(service) == ServiceStatus.initialized,
    );

    if (allInitialized) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _initialized);
  }
}
