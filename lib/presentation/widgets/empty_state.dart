// File: lib/widgets/empty_state.dart
// Purpose: Standardized empty or error state display.
// @deprecated Use EmptyState from loading_states.dart instead.

import 'package:flutter/material.dart';
import 'custom_button.dart';

/// A widget for displaying empty or error states.
///
/// @deprecated Use [EmptyState] from `loading_states.dart` instead.
/// This widget is a duplicate and will be removed in a future version.
@Deprecated(
  'Use EmptyState from loading_states.dart instead. This duplicate will be removed.',
)
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              CustomButton(text: actionText!, onPressed: onAction!, width: 200),
            ],
          ],
        ),
      ),
    );
  }
}

// Re-export the original class name for backwards compatibility
// ignore: deprecated_member_use_from_same_package
typedef EmptyState = EmptyStateWidget;



