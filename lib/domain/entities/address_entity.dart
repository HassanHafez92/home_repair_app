// Domain entity representing a saved address.
//
// This is a pure Dart class with no framework dependencies.
// Use models in the data layer for Firestore/JSON serialization.

import 'package:equatable/equatable.dart';

/// Entity representing a user's saved address.
class AddressEntity extends Equatable {
  final String id;
  final String userId;
  final String label; // e.g., 'Home', 'Work', 'Office'
  final String address; // Full formatted address
  final Map<String, dynamic> location; // {latitude, longitude}
  final bool isDefault;

  // Optional detailed address components
  final String? street;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? city;

  // Usage tracking
  final int usageCount;
  final DateTime lastUsed;
  final DateTime createdAt;

  const AddressEntity({
    required this.id,
    required this.userId,
    required this.label,
    required this.address,
    required this.location,
    this.isDefault = false,
    this.street,
    this.building,
    this.floor,
    this.apartment,
    this.city,
    this.usageCount = 0,
    required this.lastUsed,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    label,
    address,
    location,
    isDefault,
    street,
    building,
    floor,
    apartment,
    city,
    usageCount,
    lastUsed,
    createdAt,
  ];

  AddressEntity copyWith({
    String? id,
    String? userId,
    String? label,
    String? address,
    Map<String, dynamic>? location,
    bool? isDefault,
    String? street,
    String? building,
    String? floor,
    String? apartment,
    String? city,
    int? usageCount,
    DateTime? lastUsed,
    DateTime? createdAt,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      address: address ?? this.address,
      location: location ?? this.location,
      isDefault: isDefault ?? this.isDefault,
      street: street ?? this.street,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      city: city ?? this.city,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
