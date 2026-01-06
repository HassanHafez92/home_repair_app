/// Service Integration
///
/// This file provides centralized integration of all Phase 1 services
/// with the existing application architecture.
library;

import 'package:flutter/material.dart';
import 'package:home_repair_app/services/service_initializer.dart';

/// Service integration manager
class ServiceIntegration {
  // Singleton pattern
  static final ServiceIntegration _instance = ServiceIntegration._internal();
  factory ServiceIntegration() => _instance;
  ServiceIntegration._internal();

  bool _isInitialized = false;
  final ServiceInitializer _initializer = ServiceInitializer();

  /// Check if services are initialized
  bool get isInitialized => _isInitialized;

  /// Initialize all Phase 1 services
  Future<bool> initialize({
    bool continueOnError = false,
    void Function(String serviceName, ServiceStatus status)? onProgress,
  }) async {
    if (_isInitialized) {
      debugPrint('Services already initialized');
      return true;
    }

    try {
      // Initialize all services through service initializer
      final success = await _initializer.initializeAll(
        continueOnError: continueOnError,
        onProgress: onProgress,
      );

      if (success) {
        _isInitialized = true;
        debugPrint('All Phase 1 services initialized successfully');
      } else {
        debugPrint('Some services failed to initialize');
      }

      return success;
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize services: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Initialize specific service
  Future<bool> initializeService(
    String name,
    Future<void> Function() initializer,
  ) async {
    return await _initializer.initializeService(name, initializer);
  }

  /// Get service status
  ServiceStatus getServiceStatus(String name) {
    return _initializer.getServiceStatus(name);
  }

  /// Check if all services are initialized
  bool areAllServicesInitialized() {
    return _initializer.areAllServicesInitialized();
  }

  /// Get initialization summary
  Map<String, dynamic> getInitializationSummary() {
    return _initializer.getInitializationSummary();
  }

  /// Show initialization status dialog
  Future<void> showStatusDialog(BuildContext context) async {
    await _initializer.showInitializationStatus(context);
  }

  /// Reset all services
  Future<void> resetAll() async {
    await _initializer.resetAll();
    _isInitialized = false;
  }

  /// Reset specific service
  Future<void> resetService(String name) async {
    await _initializer.resetService(name);
  }

  /// Get initialized services
  List<ServiceMetadata> getInitializedServices() {
    return _initializer.getInitializedServices();
  }

  /// Get failed services
  List<ServiceMetadata> getFailedServices() {
    return _initializer.getFailedServices();
  }
}

/// Service integration extension for easy access
extension ServiceIntegrationExtension on BuildContext {
  /// Get service integration
  ServiceIntegration get serviceIntegration => ServiceIntegration();

  /// Check if services are initialized
  bool get servicesInitialized => ServiceIntegration().isInitialized;
}

/// Service initialization widget
class ServiceInitializationWrapper extends StatefulWidget {
  final Widget Function(BuildContext, bool initialized) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final List<String> requiredServices;

  const ServiceInitializationWrapper({
    super.key,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
    required this.requiredServices,
  });

  @override
  State<ServiceInitializationWrapper> createState() =>
      _ServiceInitializationWrapperState();
}

class _ServiceInitializationWrapperState
    extends State<ServiceInitializationWrapper> {
  bool _initialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      final success = await ServiceIntegration().initialize(
        onProgress: (serviceName, status) {
          if (status == ServiceStatus.failed) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Failed to initialize $serviceName';
            });
          }
        },
      );

      if (success) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Service Initialization Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage ?? 'Unknown error',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _errorMessage = null;
                      });
                      _initializeServices();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
    }

    if (!_initialized) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    return widget.builder(context, _initialized);
  }
}
