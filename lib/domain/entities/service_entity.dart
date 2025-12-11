// Domain entity representing a service.

import 'package:equatable/equatable.dart';

/// Service entity - pure Dart class.
class ServiceEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String category;
  final double avgPrice;
  final double minPrice;
  final double maxPrice;
  final double visitFee;
  final int avgCompletionTimeMinutes;
  final bool isActive;
  final DateTime createdAt;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.avgPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.visitFee,
    required this.avgCompletionTimeMinutes,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    iconUrl,
    category,
    avgPrice,
    minPrice,
    maxPrice,
    visitFee,
    avgCompletionTimeMinutes,
    isActive,
    createdAt,
  ];

  ServiceEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    String? category,
    double? avgPrice,
    double? minPrice,
    double? maxPrice,
    double? visitFee,
    int? avgCompletionTimeMinutes,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ServiceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      category: category ?? this.category,
      avgPrice: avgPrice ?? this.avgPrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      visitFee: visitFee ?? this.visitFee,
      avgCompletionTimeMinutes:
          avgCompletionTimeMinutes ?? this.avgCompletionTimeMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
