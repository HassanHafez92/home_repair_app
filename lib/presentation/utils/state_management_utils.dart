/// State Management Utilities
///
/// This file provides utilities for efficient state management using BLoC pattern,
/// including state persistence, error handling, and state composition.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'validation_utils.dart' show ValidationResult;

/// State persistence utilities
class StatePersistence {
  /// Save state to persistent storage
  static Future<void> saveState<T>(String key, T state) async {
    // Implementation would use shared_preferences or hive
    // This is a placeholder for the actual implementation
    debugPrint('Saving state for $key: $state');
  }

  /// Load state from persistent storage
  static Future<T?> loadState<T>(String key) async {
    // Implementation would use shared_preferences or hive
    // This is a placeholder for the actual implementation
    debugPrint('Loading state for $key');
    return null;
  }

  /// Clear all persisted state
  static Future<void> clearAll() async {
    // Implementation would clear all persisted state
    debugPrint('Clearing all persisted state');
  }

  /// Clear specific state
  static Future<void> clearState(String key) async {
    // Implementation would clear specific state
    debugPrint('Clearing state for $key');
  }
}

/// Error handling utilities
class StateErrorHandler {
  /// Handle error in state
  static void handleError(
    BuildContext context,
    Object error, {
    StackTrace? stackTrace,
    String? customMessage,
    bool showErrorDialog = true,
  }) {
    debugPrint('Error occurred: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }

    if (showErrorDialog) {
      _showErrorDialog(context, error, customMessage);
    }
  }

  /// Show error dialog
  static void _showErrorDialog(
    BuildContext context,
    Object error,
    String? customMessage,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(customMessage ?? error.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.green,
      ),
    );
  }
}

/// BLoC utilities
class BlocUtils {
  /// Create a BLoC provider with error handling
  static BlocProvider<B> createBlocProvider<B extends BlocBase>(
    B bloc, {
    Key? key,
  }) {
    return BlocProvider<B>.value(key: key, value: bloc);
  }

  /// Create a cubit provider with error handling
  static BlocProvider<C> createCubitProvider<C extends Cubit>(
    C cubit, {
    Key? key,
  }) {
    return BlocProvider<C>.value(key: key, value: cubit);
  }

  /// Get BLoC from context with error handling
  static B getBloc<B extends BlocBase>(BuildContext context) {
    try {
      return context.read<B>();
    } catch (e) {
      throw StateError('Could not find BLoC of type $B in the widget tree');
    }
  }

  /// Get cubit from context with error handling
  static C getCubit<C extends Cubit>(BuildContext context) {
    try {
      return context.read<C>();
    } catch (e) {
      throw StateError('Could not find Cubit of type $C in the widget tree');
    }
  }

  /// Listen to BLoC with error handling
  static void listenToBloc<B extends BlocBase<S>, S>(
    BuildContext context, {
    required void Function(S state) listener,
    B? bloc,
  }) {
    final effectiveBloc = bloc ?? context.read<B>();
    effectiveBloc.stream.listen(
      (state) {
        try {
          listener(state);
        } catch (e) {
          debugPrint('Error in BLoC listener: $e');
        }
      },
      onError: (error, stackTrace) {
        debugPrint('BLoC error: $error');
        debugPrint('Stack trace: $stackTrace');
      },
    );
  }
}

/// State composition utilities
class StateComposer {
  /// Combine multiple BLoCs into a single stream
  static Stream<List<dynamic>> combineBlocs(List<BlocBase> blocs) {
    final streams = blocs.map((bloc) => bloc.stream).toList();
    return CombineLatestStream.list(streams);
  }

  /// Create a widget that rebuilds when any of multiple BLoCs change
  static Widget buildWhenAnyBlocChanges<B extends BlocBase>(
    BuildContext context,
    List<B> blocs,
    Widget Function(BuildContext) builder,
  ) {
    return BlocBuilder<B, dynamic>(
      bloc: blocs.first,
      builder: (context, state) {
        return builder(context);
      },
      buildWhen: (previous, current) {
        return blocs.any((bloc) => bloc.state != previous);
      },
    );
  }
}

/// State hydration utilities
class StateHydration {
  /// Hydrate state from storage
  static Future<T?> hydrate<T>(String key) async {
    return await StatePersistence.loadState<T>(key);
  }

  /// Dehydrate state to storage
  static Future<void> dehydrate<T>(String key, T state) async {
    await StatePersistence.saveState(key, state);
  }

  /// Clear hydrated state
  static Future<void> clear(String key) async {
    await StatePersistence.clearState(key);
  }
}

/// State debouncing utilities
class StateDebouncer {
  final Duration delay;
  Timer? _timer;

  StateDebouncer({required this.delay});

  /// Debounce a function call
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel pending debounce
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose debouncer
  void dispose() {
    _timer?.cancel();
  }
}

/// State throttling utilities
class StateThrottler {
  final Duration interval;
  DateTime? _lastRun;

  StateThrottler({required this.interval});

  /// Throttle a function call
  void call(VoidCallback action) {
    final now = DateTime.now();
    if (_lastRun == null || now.difference(_lastRun!) >= interval) {
      action();
      _lastRun = now;
    }
  }

  /// Reset throttle timer
  void reset() {
    _lastRun = null;
  }
}

/// State caching utilities
class StateCache<T> {
  final Duration ttl;
  final Map<String, _CacheEntry<T>> _cache = {};

  StateCache({this.ttl = const Duration(minutes: 5)});

  /// Get cached value
  T? get(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.value;
    }
    _cache.remove(key);
    return null;
  }

  /// Set cached value
  void set(String key, T value) {
    _cache[key] = _CacheEntry(value, DateTime.now().add(ttl));
  }

  /// Clear cache
  void clear() {
    _cache.clear();
  }

  /// Clear expired entries
  void clearExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => entry.isExpiredAt(now));
  }

  /// Check if key exists in cache
  bool containsKey(String key) {
    final entry = _cache[key];
    return entry != null && !entry.isExpired;
  }

  /// Get all keys
  List<String> get keys => _cache.keys.toList();

  /// Get cache size
  int get size => _cache.length;
}

/// Internal cache entry
class _CacheEntry<T> {
  final T value;
  final DateTime expiryTime;

  _CacheEntry(this.value, this.expiryTime);

  bool get isExpired => DateTime.now().isAfter(expiryTime);
  bool isExpiredAt(DateTime time) => time.isAfter(expiryTime);
}

/// State validation utilities
class StateValidator<T> {
  final List<StateValidationRule<T>> rules;

  StateValidator(this.rules);

  /// Validate value
  ValidationResult validate(T value) {
    for (final rule in rules) {
      final result = rule.validate(value);
      if (!result.isValid) {
        return result;
      }
    }
    return ValidationResult.valid();
  }
}

/// Validation rule
class StateValidationRule<T> {
  final String message;
  final bool Function(T value) validator;

  StateValidationRule(this.message, this.validator);

  ValidationResult validate(T value) {
    if (validator(value)) {
      return ValidationResult.valid();
    }
    return ValidationResult.invalid(message);
  }
}


