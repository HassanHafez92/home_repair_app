// File: lib/utils/image_compression_helper.dart
// Purpose: Helper functions for compressing images before upload.

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageCompressionHelper {
  /// Compresses an image file to reduce size
  /// Target: max 1MB, quality 85%, max width 1920px
  static Future<File?> compressImage(File file) async {
    try {
      // Get file size
      final fileSize = await file.length();

      // Skip compression if already small enough (< 500KB)
      if (fileSize < 500 * 1024) {
        return file;
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        '${DateTime.now().millisecondsSinceEpoch}_compressed${path.extension(file.path)}',
      );

      // Compress the image
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 1920,
        minHeight: 1920,
      );

      if (result == null) {
        return file; // Return original if compression fails
      }

      return File(result.path);
    } catch (e) {
      print('Error compressing image: $e');
      return file; // Return original on error
    }
  }

  /// Compresses an image for profile photo (smaller size)
  /// Target: max 500KB, quality 90%, max width 800px
  static Future<File?> compressProfilePhoto(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        '${DateTime.now().millisecondsSinceEpoch}_profile${path.extension(file.path)}',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 90,
        minWidth: 800,
        minHeight: 800,
      );

      if (result == null) {
        return file;
      }

      return File(result.path);
    } catch (e) {
      print('Error compressing profile photo: $e');
      return file;
    }
  }
}
