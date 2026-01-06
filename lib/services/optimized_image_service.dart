/// Optimized Image Service
///
/// This service provides optimized image loading, caching, and compression
/// to improve app performance and reduce memory usage.
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class OptimizedImageService {
  // Singleton pattern
  static final OptimizedImageService _instance =
      OptimizedImageService._internal();
  factory OptimizedImageService() => _instance;
  OptimizedImageService._internal();

  // Image quality settings
  static const int defaultQuality = 85;
  static const int thumbnailQuality = 60;
  static const int avatarQuality = 75;

  // Image size constraints
  static const int maxImageWidth = 1920;
  static const int maxThumbnailWidth = 300;
  static const int maxAvatarWidth = 400;

  // Cache settings
  static const int maxMemoryCacheSize = 100 * 1024 * 1024; // 100MB
  static const int maxDiskCacheSize = 500 * 1024 * 1024; // 500MB

  /// Initialize the image cache with optimized settings
  Future<void> initialize() async {
    // Configure memory cache
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = maxMemoryCacheSize;
  }

  /// Compress an image file
  Future<File?> compressImage(
    File imageFile, {
    int quality = defaultQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth ?? 0,
        minHeight: maxHeight ?? 0,
        format: CompressFormat.jpeg,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Compress image for thumbnail
  Future<File?> compressThumbnail(File imageFile) async {
    return compressImage(
      imageFile,
      quality: thumbnailQuality,
      maxWidth: maxThumbnailWidth,
      maxHeight: maxThumbnailWidth,
    );
  }

  /// Compress image for avatar
  Future<File?> compressAvatar(File imageFile) async {
    return compressImage(
      imageFile,
      quality: avatarQuality,
      maxWidth: maxAvatarWidth,
      maxHeight: maxAvatarWidth,
    );
  }

  /// Load an optimized network image widget
  Widget loadOptimizedNetworkImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    bool useThumbnail = false,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          ),
      memCacheWidth: useThumbnail ? maxThumbnailWidth : maxImageWidth,
      memCacheHeight: useThumbnail ? maxThumbnailWidth : null,
    );
  }

  /// Clear image cache
  Future<void> clearCache() async {
    // Clear memory cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Get cache size
  Future<int> getCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync(recursive: true);

      int totalSize = 0;
      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error getting cache size: $e');
      return 0;
    }
  }

  /// Format cache size to human readable string
  String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Resize image to specific dimensions
  Future<Uint8List?> resizeImage(
    Uint8List imageBytes, {
    required int width,
    required int height,
  }) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: width,
        minHeight: height,
        quality: defaultQuality,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (e) {
      debugPrint('Error resizing image: $e');
      return null;
    }
  }

  /// Get image dimensions
  Future<Size?> getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);
      return Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );
    } catch (e) {
      debugPrint('Error getting image dimensions: $e');
      return null;
    }
  }
}
