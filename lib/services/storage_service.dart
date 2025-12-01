// File: lib/services/storage_service.dart
// Purpose: Handle Firebase Storage operations for file uploads

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a profile picture to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    try {
      // Create a unique filename using the user ID and original file extension
      final String fileName =
          'profile_$userId${path.extension(imageFile.path)}';

      // Create a reference to the storage location
      final Reference storageRef = _storage.ref().child(
        'profile_pictures/$fileName',
      );

      // Set metadata for the image
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Delete a profile picture from Firebase Storage
  Future<void> deleteProfilePicture(String imageUrl) async {
    try {
      // Get reference from URL
      final Reference storageRef = _storage.refFromURL(imageUrl);

      // Delete the file
      await storageRef.delete();
    } catch (e) {
      // If the file doesn't exist, we can ignore the error
      if (!e.toString().contains('object-not-found')) {
        throw Exception('Failed to delete profile picture: $e');
      }
    }
  }

  /// Upload any file to a specific path in Firebase Storage
  Future<String> uploadFile(String storagePath, File file) async {
    try {
      final Reference storageRef = _storage.ref().child(storagePath);
      final UploadTask uploadTask = storageRef.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Delete a file from Firebase Storage using its URL
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference storageRef = _storage.refFromURL(fileUrl);
      await storageRef.delete();
    } catch (e) {
      if (!e.toString().contains('object-not-found')) {
        throw Exception('Failed to delete file: $e');
      }
    }
  }
}
