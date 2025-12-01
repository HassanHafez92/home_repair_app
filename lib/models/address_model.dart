// File: lib/models/address_model.dart
// Purpose: Data model for user addresses.

class Address {
  final String id;
  final String label; // e.g., 'Home', 'Work', 'Other'
  final String street;
  final String city;
  final String? building;
  final String? floor;
  final String? apartment;
  final bool isDefault;

  // Location coordinates for map
  final double? latitude;
  final double? longitude;

  Address({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    this.building,
    this.floor,
    this.apartment,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'street': street,
      'city': city,
      'building': building,
      'floor': floor,
      'apartment': apartment,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Create from Firestore JSON
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      label: json['label'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      apartment: json['apartment'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  // Create a copy with modified fields
  Address copyWith({
    String? id,
    String? label,
    String? street,
    String? city,
    String? building,
    String? floor,
    String? apartment,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      street: street ?? this.street,
      city: city ?? this.city,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // Get formatted address string
  String get formattedAddress {
    final parts = <String>[street];
    if (building != null && building!.isNotEmpty) {
      parts.add('Building $building');
    }
    if (floor != null && floor!.isNotEmpty) {
      parts.add('Floor $floor');
    }
    if (apartment != null && apartment!.isNotEmpty) {
      parts.add('Apt $apartment');
    }
    parts.add(city);
    return parts.join(', ');
  }
}
