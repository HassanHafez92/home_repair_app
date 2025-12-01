// File: lib/models/technician_model.dart
// Purpose: Technician-specific user model with professional details.

import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

part 'technician_model.g.dart';

enum TechnicianStatus { pending, approved, rejected, suspended }

@JsonSerializable(explicitToJson: true)
class TechnicianModel extends UserModel {
  final String? nationalId;
  final List<String> specializations;
  final List<String> portfolioUrls;
  final int yearsOfExperience;
  final TechnicianStatus status;
  final double rating;
  final int completedJobs;
  final bool isAvailable;
  final Map<String, dynamic>? location; // GeoPoint can be handled here

  TechnicianModel({
    required super.id,
    required super.email,
    super.phoneNumber,
    required super.fullName,
    super.profilePhoto,
    required super.createdAt,
    required super.updatedAt,
    required super.lastActive,
    this.nationalId,
    this.specializations = const [],
    this.portfolioUrls = const [],
    this.yearsOfExperience = 0,
    this.status = TechnicianStatus.pending,
    this.rating = 0.0,
    this.completedJobs = 0,
    this.isAvailable = false,
    this.location,
  }) : super(role: UserRole.technician);

  factory TechnicianModel.fromJson(Map<String, dynamic> json) =>
      _$TechnicianModelFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final json = _$TechnicianModelToJson(this);
    // Manually add parent class fields
    json['role'] = role.name; // Convert enum to string
    return json;
  }
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
