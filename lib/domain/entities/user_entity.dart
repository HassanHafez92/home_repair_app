// Domain entity representing a user in the system.
//
// This is a pure Dart class with no framework dependencies.
// Use DTOs in the data layer for JSON serialization.

import 'package:equatable/equatable.dart';

/// Enum representing user roles in the system.
enum UserRole { customer, technician, admin }

/// Base user entity containing common fields for all user types.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final String? profilePhoto;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActive;
  final bool? emailVerified;

  const UserEntity({
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

  @override
  List<Object?> get props => [
    id,
    email,
    phoneNumber,
    fullName,
    profilePhoto,
    role,
    createdAt,
    updatedAt,
    lastActive,
    emailVerified,
  ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? fullName,
    String? profilePhoto,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActive,
    bool? emailVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActive: lastActive ?? this.lastActive,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
