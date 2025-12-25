// File: lib/models/service_addon_model.dart
// Purpose: Model representing an optional add-on for a service.

import 'package:equatable/equatable.dart';

/// Model for service add-ons that customers can select during booking
class ServiceAddOnModel extends Equatable {
  /// Unique identifier for the add-on
  final String id;

  /// Display name of the add-on
  final String name;

  /// Description of what the add-on includes
  final String? description;

  /// Price of the add-on in EGP
  final double price;

  /// Icon name for display (material icon name)
  final String? iconName;

  /// Whether this add-on is selected
  final bool isSelected;

  /// Category of the add-on (e.g., 'parts', 'labor', 'warranty')
  final String? category;

  const ServiceAddOnModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.iconName,
    this.isSelected = false,
    this.category,
  });

  /// Create a copy with updated selection state
  ServiceAddOnModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? iconName,
    bool? isSelected,
    String? category,
  }) {
    return ServiceAddOnModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      iconName: iconName ?? this.iconName,
      isSelected: isSelected ?? this.isSelected,
      category: category ?? this.category,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'iconName': iconName,
      'category': category,
    };
  }

  /// Create from JSON (from Firestore)
  factory ServiceAddOnModel.fromJson(Map<String, dynamic> json) {
    return ServiceAddOnModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      iconName: json['iconName'] as String?,
      category: json['category'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    iconName,
    isSelected,
    category,
  ];
}
