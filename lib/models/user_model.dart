// File: lib/models/user_model.dart
// Purpose: Base user model containing common fields for all user types.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole { customer, technician, admin }

@JsonSerializable(explicitToJson: true)
class UserModel {
  final String id;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final String? profilePhoto;
  final UserRole role;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime lastActive;

  final bool? emailVerified;

  UserModel({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    this.profilePhoto,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActive,
    this.emailVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
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
