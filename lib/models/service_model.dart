// File: lib/models/service_model.dart
// Purpose: Model representing a service offered in the marketplace.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'service_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ServiceModel extends Equatable {
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

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  const ServiceModel({
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

  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);

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
}

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
