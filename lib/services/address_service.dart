// File: lib/services/address_service.dart
// Purpose: Firestore service for managing user's saved addresses

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/saved_address.dart';
import '../utils/map_utils.dart';

class AddressService {
  final FirebaseFirestore _firestore;

  AddressService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get reference to user's saved addresses collection
  CollectionReference<Map<String, dynamic>> _addressesCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_addresses');
  }

  /// Save a new address for the user
  Future<SavedAddress> saveAddress({
    required String userId,
    required String label,
    required String address,
    required LatLng location,
    bool isDefault = false,
    String? street,
    String? building,
    String? floor,
    String? apartment,
    String? city,
  }) async {
    final now = DateTime.now();
    final docRef = _addressesCollection(userId).doc();

    final savedAddress = SavedAddress(
      id: docRef.id,
      userId: userId,
      label: label,
      address: address,
      location: MapUtils.latLngToGeoPoint(location),
      isDefault: isDefault,
      street: street,
      building: building,
      floor: floor,
      apartment: apartment,
      city: city,
      usageCount: 0,
      lastUsed: now,
      createdAt: now,
    );

    await docRef.set(savedAddress.toJson());

    // If this is set as default, unset all other defaults
    if (isDefault) {
      await _unsetOtherDefaults(userId, docRef.id);
    }

    return savedAddress;
  }

  /// Get all saved addresses for a user
  Future<List<SavedAddress>> getUserAddresses(String userId) async {
    final snapshot = await _addressesCollection(
      userId,
    ).orderBy('lastUsed', descending: true).get();

    return snapshot.docs
        .map((doc) => SavedAddress.fromJson(doc.data()))
        .toList();
  }

  /// Get user's saved addresses as a stream
  Stream<List<SavedAddress>> watchUserAddresses(String userId) {
    return _addressesCollection(userId)
        .orderBy('lastUsed', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SavedAddress.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get default address for user
  Future<SavedAddress?> getDefaultAddress(String userId) async {
    final snapshot = await _addressesCollection(
      userId,
    ).where('isDefault', isEqualTo: true).limit(1).get();

    if (snapshot.docs.isEmpty) return null;

    return SavedAddress.fromJson(snapshot.docs.first.data());
  }

  /// Update an existing address
  Future<void> updateAddress({
    required String userId,
    required String addressId,
    String? label,
    String? address,
    LatLng? location,
    bool? isDefault,
    String? street,
    String? building,
    String? floor,
    String? apartment,
    String? city,
  }) async {
    final Map<String, dynamic> updateData = {};

    if (label != null) updateData['label'] = label;
    if (address != null) updateData['address'] = address;
    if (location != null) {
      updateData['location'] = MapUtils.latLngToGeoPoint(location);
    }
    if (street != null) updateData['street'] = street;
    if (building != null) updateData['building'] = building;
    if (floor != null) updateData['floor'] = floor;
    if (apartment != null) updateData['apartment'] = apartment;
    if (city != null) updateData['city'] = city;
    if (isDefault != null) {
      updateData['isDefault'] = isDefault;
      if (isDefault) {
        await _unsetOtherDefaults(userId, addressId);
      }
    }

    if (updateData.isNotEmpty) {
      await _addressesCollection(userId).doc(addressId).update(updateData);
    }
  }

  /// Delete a saved address
  Future<void> deleteAddress(String userId, String addressId) async {
    await _addressesCollection(userId).doc(addressId).delete();
  }

  /// Set an address as default
  Future<void> setAsDefault(String userId, String addressId) async {
    await _unsetOtherDefaults(userId, addressId);
    await _addressesCollection(
      userId,
    ).doc(addressId).update({'isDefault': true});
  }

  /// Increment usage count and update last used timestamp
  Future<void> incrementUsage(String userId, String addressId) async {
    await _addressesCollection(userId).doc(addressId).update({
      'usageCount': FieldValue.increment(1),
      'lastUsed': FieldValue.serverTimestamp(),
    });
  }

  /// Unset isDefault for all addresses except the specified one
  Future<void> _unsetOtherDefaults(
    String userId,
    String exceptAddressId,
  ) async {
    final snapshot = await _addressesCollection(
      userId,
    ).where('isDefault', isEqualTo: true).get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      if (doc.id != exceptAddressId) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }
    await batch.commit();
  }

  /// Get frequently used addresses (top 3 by usage count)
  Future<List<SavedAddress>> getFrequentAddresses(
    String userId, {
    int limit = 3,
  }) async {
    final snapshot = await _addressesCollection(
      userId,
    ).orderBy('usageCount', descending: true).limit(limit).get();

    return snapshot.docs
        .map((doc) => SavedAddress.fromJson(doc.data()))
        .toList();
  }
}
