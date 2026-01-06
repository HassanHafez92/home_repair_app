// File: lib/presentation/widgets/lottie_empty_states.dart
// Purpose: Reusable Lottie animation widgets for empty states

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/design_tokens.dart';

/// Reusable Lottie empty state widget with customizable animation and message
class LottieEmptyState extends StatelessWidget {
  final String animationAsset;
  final String title;
  final String? subtitle;
  final Widget? action;
  final double animationSize;

  const LottieEmptyState({
    super.key,
    required this.animationAsset,
    required this.title,
    this.subtitle,
    this.action,
    this.animationSize = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              animationAsset,
              width: animationSize,
              height: animationSize,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to icon if animation fails
                return Icon(
                  Icons.inbox_outlined,
                  size: animationSize * 0.5,
                  color: DesignTokens.neutral400,
                );
              },
            ),
            const SizedBox(height: DesignTokens.spaceMD),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: DesignTokens.fontWeightSemiBold,
                color: DesignTokens.neutral700,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: DesignTokens.spaceXS),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: DesignTokens.neutral500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: DesignTokens.spaceLG),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for no orders
class EmptyOrdersState extends StatelessWidget {
  final VoidCallback? onBrowseServices;

  const EmptyOrdersState({super.key, this.onBrowseServices});

  @override
  Widget build(BuildContext context) {
    return LottieEmptyState(
      animationAsset: 'assets/animations/empty_orders.json',
      title: 'No Orders Yet',
      subtitle: 'Book your first service to get started',
      action: onBrowseServices != null
          ? FilledButton.icon(
              onPressed: onBrowseServices,
              icon: const Icon(Icons.search),
              label: const Text('Browse Services'),
            )
          : null,
    );
  }
}

/// Empty state for no search results
class EmptySearchState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const EmptySearchState({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return LottieEmptyState(
      animationAsset: 'assets/animations/empty_search.json',
      title: 'No Results Found',
      subtitle: 'No services match "$searchQuery"',
      action: onClearSearch != null
          ? TextButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
            )
          : null,
    );
  }
}

/// Empty state for no reviews
class EmptyReviewsState extends StatelessWidget {
  const EmptyReviewsState({super.key});

  @override
  Widget build(BuildContext context) {
    return const LottieEmptyState(
      animationAsset: 'assets/animations/empty_reviews.json',
      title: 'No Reviews Yet',
      subtitle: 'Be the first to leave a review!',
    );
  }
}

/// Success state animation (for order completion, etc.)
class SuccessAnimation extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const SuccessAnimation({super.key, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/success.json',
            width: 150,
            height: 150,
            repeat: false,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              );
            },
          ),
          const SizedBox(height: DesignTokens.spaceMD),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: DesignTokens.fontWeightSemiBold,
            ),
            textAlign: TextAlign.center,
          ),
          if (onDismiss != null) ...[
            const SizedBox(height: DesignTokens.spaceLG),
            FilledButton(onPressed: onDismiss, child: const Text('Continue')),
          ],
        ],
      ),
    );
  }
}

/// Loading state with Lottie animation
class LottieLoadingState extends StatelessWidget {
  final String? message;

  const LottieLoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/loading.json',
            width: 100,
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return const CircularProgressIndicator();
            },
          ),
          if (message != null) ...[
            const SizedBox(height: DesignTokens.spaceMD),
            Text(
              message!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: DesignTokens.neutral600),
            ),
          ],
        ],
      ),
    );
  }
}
