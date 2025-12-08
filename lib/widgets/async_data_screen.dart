// File: lib/widgets/async_data_screen.dart
// Purpose: Generic wrapper for screens that load async data with consistent
// loading, error, and success state handling.

import 'package:flutter/material.dart';

/// A generic widget that wraps screens requiring async data loading.
///
/// Handles three states consistently:
/// - **Loading**: Shows a centered [CircularProgressIndicator]
/// - **Error**: Shows an error screen with customizable title and message
/// - **Success**: Calls [builder] with the loaded data
///
/// ## Usage Example
///
/// ```dart
/// AsyncDataScreen<OrderModel>(
///   future: firestoreService.getOrder(orderId),
///   builder: (order) => OrderDetailsScreen(order: order),
///   errorTitle: 'Error',
///   errorMessage: 'Order not found',
/// )
/// ```
///
/// ## Type Parameter
/// - [T]: The type of data being loaded. Must be non-null when passed to [builder].
class AsyncDataScreen<T> extends StatelessWidget {
  /// The future that loads the data.
  final Future<T?> future;

  /// Builder called when data is successfully loaded.
  /// Receives non-null data of type [T].
  final Widget Function(T data) builder;

  /// Title shown on the error screen's AppBar.
  final String errorTitle;

  /// Message shown in the error screen body.
  final String errorMessage;

  /// Optional custom loading widget.
  /// Defaults to a centered [CircularProgressIndicator].
  final Widget? loadingWidget;

  /// Optional custom error widget builder.
  /// If provided, overrides the default error screen.
  final Widget Function(Object? error)? errorBuilder;

  /// Creates an [AsyncDataScreen] widget.
  ///
  /// All parameters except [loadingWidget] and [errorBuilder] are required.
  const AsyncDataScreen({
    super.key,
    required this.future,
    required this.builder,
    this.errorTitle = 'Error',
    this.errorMessage = 'Data not found',
    this.loadingWidget,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T?>(
      future: future,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Error state (either has error or no data)
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          if (errorBuilder != null) {
            return errorBuilder!(snapshot.error);
          }
          return Scaffold(
            appBar: AppBar(title: Text(errorTitle)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        // Success state - data is guaranteed non-null here
        return builder(snapshot.data as T);
      },
    );
  }
}
