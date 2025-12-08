// File: lib/services/user_firestore_service.dart
// Purpose: Handles all user-related Firestore operations.
// Extracted from FirestoreService for better separation of concerns.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/customer_model.dart';
import '../models/technician_model.dart';

/// Service class that handles all user-related Firestore operations.
///
/// This service provides methods for:
/// - User CRUD operations (create, read, update)
/// - Technician status and availability management
/// - Admin operations for technician approval
///
/// ## Usage Example
///
/// ```dart
/// final userService = UserFirestoreService();
///
/// // Get a user by ID
/// final user = await userService.getUser('user123');
/// if (user != null) {
///   print('Found user: ${user.name}');
/// }
/// ```
class UserFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== User CRUD Operations ==========

  /// Creates a new user document in Firestore.
  ///
  /// **Parameters:**
  /// - [user]: The user model containing all user data.
  ///
  /// **Throws:** Firestore exception if write fails.
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toJson());
  }

  /// Retrieves a user by their unique ID.
  ///
  /// Automatically detects the user type (Customer, Technician, or generic User)
  /// based on the `role` field and returns the appropriate model.
  ///
  /// **Parameters:**
  /// - [uid]: The unique identifier of the user.
  ///
  /// **Returns:** The user model, or `null` if not found.
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;

      // Determine user role to parse into correct model
      final roleStr = data['role'] as String?;

      // Handle missing role field
      if (roleStr == null) {
        debugPrint(
          'UserFirestoreService: User document missing role field for uid: $uid',
        );
        return null;
      }

      if (roleStr == 'UserRole.customer' || roleStr == 'customer') {
        return CustomerModel.fromJson(data);
      } else if (roleStr == 'UserRole.technician' || roleStr == 'technician') {
        return TechnicianModel.fromJson(data);
      } else {
        return UserModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('UserFirestoreService: Error loading user $uid: $e');
      return null;
    }
  }

  /// Updates an existing user document.
  ///
  /// **Parameters:**
  /// - [user]: The user model with updated data.
  ///
  /// **Throws:** Firestore exception if user doesn't exist.
  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toJson());
  }

  /// Updates specific fields of a user document.
  ///
  /// Use this method when you only need to update a few fields
  /// rather than the entire user document.
  ///
  /// **Parameters:**
  /// - [uid]: The user's unique identifier.
  /// - [fields]: A map of field names to their new values.
  ///
  /// **Example:**
  /// ```dart
  /// await userService.updateUserFields('user123', {
  ///   'name': 'New Name',
  ///   'phoneNumber': '+1234567890',
  /// });
  /// ```
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    await _db.collection('users').doc(uid).update(fields);
  }

  /// Gets the raw Firestore document for a user.
  ///
  /// Useful when you need access to document metadata or
  /// want to check existence before operations.
  ///
  /// **Parameters:**
  /// - [uid]: The user's unique identifier.
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // ========== Technician Management ==========

  /// Streams a list of technicians pending approval.
  ///
  /// Used by admin dashboard to show technicians awaiting review.
  ///
  /// **Returns:** A stream that emits list of pending technicians.
  Stream<List<TechnicianModel>> streamPendingTechnicians() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'technician')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TechnicianModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Updates a technician's approval status.
  ///
  /// **Parameters:**
  /// - [uid]: The technician's unique identifier.
  /// - [status]: The new status (approved, rejected, suspended, etc.).
  Future<void> updateTechnicianStatus(
    String uid,
    TechnicianStatus status,
  ) async {
    await _db.collection('users').doc(uid).update({
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates a technician's availability for accepting new orders.
  ///
  /// **Parameters:**
  /// - [uid]: The technician's unique identifier.
  /// - [isAvailable]: Whether the technician is available.
  Future<void> updateTechnicianAvailability(
    String uid,
    bool isAvailable,
  ) async {
    await _db.collection('users').doc(uid).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Streams a technician's availability status in real-time.
  ///
  /// **Parameters:**
  /// - [uid]: The technician's unique identifier.
  ///
  /// **Returns:** A stream emitting `true` when available.
  Stream<bool> streamTechnicianAvailability(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return false;
      return snapshot.data()!['isAvailable'] as bool? ?? false;
    });
  }

  // ========== Utility Methods ==========

  /// Generates a unique Firestore document ID.
  ///
  /// Useful when you need to know the ID before creating the document.
  String generateId() => _db.collection('users').doc().id;
}
