// File: lib/utils/image_optimization.dart
// Purpose: Image optimization and caching utilities for better performance

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Color constants used throughout image optimization
class _ImageColors {
  static const Color placeholder = Color(0xFFE0E0E0);
  static const Color placeholderHighlight = Color(0xFFF5F5F5);
  static const Color errorBackground = Color(0xFFEEEEEE);
  static const Color errorIcon = Color(0xFFBDBDBD);
}

/// Utility class for optimized image loading with caching
class ImageOptimization {
  /// Private constructor to prevent instantiation
  ImageOptimization._();

  /// Default cache duration (7 days)
  static const Duration defaultCacheDuration = Duration(days: 7);

  /// Build an optimized network image with caching and loading state
  static Widget buildOptimizedImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Duration cacheDuration = defaultCacheDuration,
    Widget? errorWidget,
    bool showShimmer = true,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheKey: _getCacheKey(imageUrl),
      memCacheWidth: _getMemCacheWidth(width),
      memCacheHeight: _getMemCacheHeight(height),
      maxHeightDiskCache: (_getMemCacheHeight(height) * 1.5).toInt(),
      maxWidthDiskCache: (_getMemCacheWidth(width) * 1.5).toInt(),
      progressIndicatorBuilder: (context, url, progress) => showShimmer
          ? _buildShimmerPlaceholder(width, height, borderRadius)
          : _buildSimpleProgress(width, height, borderRadius),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildErrorWidget(width, height, borderRadius),
      placeholder: (context, url) => showShimmer
          ? _buildShimmerPlaceholder(width, height, borderRadius)
          : _buildPlaceholderWidget(width, height, borderRadius),
    );
  }

  /// Build a network image with fallback to asset
  static Widget buildNetworkImageWithFallback({
    required String networkUrl,
    required String assetFallback,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return CachedNetworkImage(
      imageUrl: networkUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          Image.asset(assetFallback, width: width, height: height, fit: fit),
      errorWidget: (context, url, error) =>
          Image.asset(assetFallback, width: width, height: height, fit: fit),
    );
  }

  /// Build a circular avatar with caching
  static Widget buildCachedAvatar({
    required String imageUrl,
    required double radius,
    String? initials,
    Color backgroundColor = const Color(0xFFE0E0E0),
  }) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: Text(
              initials ?? '?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Center(
            child: Text(
              initials ?? '?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build a background image with gradient overlay
  static Widget buildBackgroundImage({
    required String imageUrl,
    required Widget child,
    Gradient? overlay,
    Duration cacheDuration = defaultCacheDuration,
  }) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            imageUrl,
            cacheKey: _getCacheKey(imageUrl),
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: overlay != null
          ? Container(
              decoration: BoxDecoration(gradient: overlay),
              child: child,
            )
          : child,
    );
  }

  /// Get optimized cache key from URL
  static String _getCacheKey(String url) {
    // Use filename as cache key for better performance
    final uri = Uri.parse(url);
    return uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : url.hashCode.toString();
  }

  /// Get memory cache width based on device width
  static int _getMemCacheWidth(double width) {
    // Store 2x resolution for better quality on high-DPI devices
    return (width * 2).toInt();
  }

  /// Get memory cache height based on device height
  static int _getMemCacheHeight(double height) {
    return (height * 2).toInt();
  }

  /// Build shimmer loading placeholder
  static Widget _buildShimmerPlaceholder(
    double width,
    double height,
    BorderRadius? borderRadius,
  ) {
    return Shimmer.fromColors(
      baseColor: _ImageColors.placeholder,
      highlightColor: _ImageColors.placeholderHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  /// Build simple placeholder widget
  static Widget _buildPlaceholderWidget(
    double width,
    double height,
    BorderRadius? borderRadius,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _ImageColors.placeholder,
        borderRadius: borderRadius,
      ),
    );
  }

  /// Build progress indicator
  static Widget _buildSimpleProgress(
    double width,
    double height,
    BorderRadius? borderRadius,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _ImageColors.placeholder,
        borderRadius: borderRadius,
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  /// Build error widget
  static Widget _buildErrorWidget(
    double width,
    double height,
    BorderRadius? borderRadius,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _ImageColors.errorBackground,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: _ImageColors.errorIcon,
          size: 48,
        ),
      ),
    );
  }

  /// Preload an image into cache
  static Future<void> preloadImage(BuildContext context, String imageUrl) {
    return precacheImage(CachedNetworkImageProvider(imageUrl), context);
  }

  /// Preload multiple images
  static Future<void> preloadImages(
    BuildContext context,
    List<String> imageUrls,
  ) {
    return Future.wait(imageUrls.map((url) => preloadImage(context, url)));
  }
}
