// File: lib/widgets/loading_states.dart
// Purpose: Reusable loading, error, and empty state widgets

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Color constants for loading widgets
class _LoadingColors {
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}

/// Constant widget and dimension values to reduce allocations
class _LoadingConstants {
  static const defaultBorderRadius = 8.0;
  static const defaultSpacing = 16.0;
  static const defaultItemHeight = 80.0;
  static const defaultGridItemHeight = 150.0;
  static const defaultIconSize = 80.0;
  static const defaultPadding = EdgeInsets.all(16);
  static const defaultGridPadding = EdgeInsets.all(16);
  static const neverScrollPhysics = NeverScrollableScrollPhysics();
  static const defaultGridAspectRatio = 1.0;
  static const progressStrokeWidth = 3.0;
}

/// Generic loading shimmer widget
class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const LoadingShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _LoadingColors.shimmerBase,
      highlightColor: _LoadingColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              borderRadius ??
              BorderRadius.circular(_LoadingConstants.defaultBorderRadius),
        ),
      ),
    );
  }
}

/// Loading list with multiple shimmer items
class LoadingListShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;
  final EdgeInsets padding;

  const LoadingListShimmer({
    super.key,
    this.itemCount = 5,
    this.itemHeight = _LoadingConstants.defaultItemHeight,
    this.spacing = _LoadingConstants.defaultSpacing,
    this.padding = _LoadingConstants.defaultPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: _LoadingConstants.neverScrollPhysics,
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) => LoadingShimmer(height: itemHeight),
    );
  }
}

/// Loading grid with multiple shimmer items
class LoadingGridShimmer extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double itemHeight;
  final double spacing;
  final EdgeInsets padding;

  const LoadingGridShimmer({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.itemHeight = _LoadingConstants.defaultGridItemHeight,
    this.spacing = _LoadingConstants.defaultSpacing,
    this.padding = _LoadingConstants.defaultGridPadding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: _LoadingConstants.neverScrollPhysics,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: _LoadingConstants.defaultGridAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => LoadingShimmer(height: itemHeight),
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final double iconSize;
  final Color iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.iconSize = _LoadingConstants.defaultIconSize,
    this.iconColor = const Color(0xFFBDBDBD),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(onPressed: onRetry, child: Text(retryLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state widget
class ErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData icon;

  const ErrorState({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: icon,
      title: title,
      subtitle: message,
      onRetry: onRetry,
      retryLabel: retryLabel,
      iconColor: Colors.red[300] ?? Colors.red,
    );
  }
}

/// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color backgroundColor;
  final double opacity;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor = Colors.black,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: backgroundColor.withValues(alpha: opacity),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Adaptive loading indicator
class AdaptiveLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AdaptiveLoadingIndicator({super.key, this.size = 50, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: _LoadingConstants.progressStrokeWidth,
      ),
    );
  }
}

/// Skeleton card for loading state
class SkeletonCard extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;

  const SkeletonCard({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LoadingShimmer(
        width: width,
        height: height,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
    );
  }
}
