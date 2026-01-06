/// Lazy Loading Service
///
/// This service provides utilities for lazy loading routes, deferring heavy
/// operations, and optimizing app initialization.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LazyLoadingService {
  // Singleton pattern
  static final LazyLoadingService _instance = LazyLoadingService._internal();
  factory LazyLoadingService() => _instance;
  LazyLoadingService._internal();

  // Track initialization status
  final Map<String, bool> _initializedModules = {};
  final Map<String, Future<void>> _pendingInitializations = {};

  /// Initialize a module lazily
  Future<void> initializeModule(
    String moduleName,
    Future<void> Function() initialization,
  ) async {
    // Return existing future if already initializing
    if (_pendingInitializations.containsKey(moduleName)) {
      return _pendingInitializations[moduleName]!;
    }

    // Skip if already initialized
    if (_initializedModules[moduleName] ?? false) {
      return;
    }

    // Create and store initialization future
    final initFuture = initialization();
    _pendingInitializations[moduleName] = initFuture;

    try {
      await initFuture;
      _initializedModules[moduleName] = true;
      debugPrint('Module $moduleName initialized successfully');
    } catch (e) {
      debugPrint('Error initializing module $moduleName: $e');
      rethrow;
    } finally {
      _pendingInitializations.remove(moduleName);
    }
  }

  /// Check if a module is initialized
  bool isModuleInitialized(String moduleName) {
    return _initializedModules[moduleName] ?? false;
  }

  /// Defer an operation until after the first frame
  Future<T> deferAfterFirstFrame<T>(Future<T> Function() operation) async {
    final completer = Completer<T>();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        final result = await operation();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  /// Defer an operation until the app is idle
  Future<T> deferUntilIdle<T>(Future<T> Function() operation) async {
    final completer = Completer<T>();

    SchedulerBinding.instance.scheduleTask(() async {
      try {
        final result = await operation();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    }, Priority.idle);

    return completer.future;
  }

  /// Batch multiple operations and execute them during idle time
  Future<void> batchOperations(List<Future<void> Function()> operations) async {
    for (final operation in operations) {
      await deferUntilIdle(operation);
    }
  }

  /// Create a lazy-loaded widget builder
  WidgetBuilder createLazyBuilder(
    String moduleName,
    Future<void> Function() initialization,
    WidgetBuilder builder,
  ) {
    return (BuildContext context) {
      return FutureBuilder<void>(
        future: initializeModule(moduleName, initialization),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error!);
            }
            return builder(context);
          }
          return _buildLoadingWidget();
        },
      );
    };
  }

  /// Build loading widget for lazy-loaded content
  Widget _buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  /// Build error widget for failed lazy-loading
  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load content',
              style: Theme.of(Get.context!).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(Get.context!).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Get initialization status of all modules
  Map<String, bool> getInitializationStatus() {
    return Map.from(_initializedModules);
  }

  /// Reset all module initialization states (useful for testing)
  void reset() {
    _initializedModules.clear();
    _pendingInitializations.clear();
  }
}

/// Helper to get context in static methods
class Get {
  static BuildContext? context;
}

/// Lazy-loaded screen widget
class LazyLoadedScreen extends StatefulWidget {
  final String moduleName;
  final Future<void> Function() initialization;
  final Widget Function(BuildContext) builder;

  const LazyLoadedScreen({
    super.key,
    required this.moduleName,
    required this.initialization,
    required this.builder,
  });

  @override
  State<LazyLoadedScreen> createState() => _LazyLoadedScreenState();
}

class _LazyLoadedScreenState extends State<LazyLoadedScreen> {
  @override
  void initState() {
    super.initState();
    Get.context = context;
    LazyLoadingService().initializeModule(
      widget.moduleName,
      widget.initialization,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: LazyLoadingService().initializeModule(
        widget.moduleName,
        widget.initialization,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error!);
          }
          return widget.builder(context);
        }
        return _buildLoadingWidget();
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load screen',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
