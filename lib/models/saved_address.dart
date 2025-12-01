// File: lib/models/saved_address.dart
// Purpose: Data model for user's saved addresses with coordinates

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'saved_address.g.dart';

@JsonSerializable(explicitToJson: true)
class SavedAddress extends Equatable {
  final String id;
  final String userId;
  final String label; // e.g., 'Home', 'Work', 'Office'
  final String address; // Full formatted address
  final Map<String, dynamic> location; // GeoPoint as Map
  final bool isDefault;

  // Optional detailed address components
  final String? street;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? city;

  // Usage tracking
  final int usageCount;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime lastUsed;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  const SavedAddress({
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

  factory SavedAddress.fromJson(Map<String, dynamic> json) =>
      _$SavedAddressFromJson(json);

  Map<String, dynamic> toJson() => _$SavedAddressToJson(this);

  SavedAddress copyWith({
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
    return SavedAddress(
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
}

// Timestamp conversion helpers
DateTime _timestampFromJson(dynamic timestamp) {
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  } else if (timestamp is String) {
    return DateTime.parse(timestamp);
  } else {
    return DateTime.now();
  }
}

dynamic _timestampToJson(DateTime date) => Timestamp.fromDate(date);
