/// Domain entity representing a customer user.

import 'package:equatable/equatable.dart';
import 'user_entity.dart';

/// Customer-specific user entity with additional customer fields.
class CustomerEntity extends Equatable {
  final String id;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final String? profilePhoto;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActive;
  final bool? emailVerified;
  final List<String> savedAddresses;
  final List<String> savedPaymentMethods;

  const CustomerEntity({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    this.profilePhoto,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActive,
    this.emailVerified,
    this.savedAddresses = const [],
    this.savedPaymentMethods = const [],
  });

  UserRole get role => UserRole.customer;

  @override
  List<Object?> get props => [
    id,
    email,
    phoneNumber,
    fullName,
    profilePhoto,
    createdAt,
    updatedAt,
    lastActive,
    emailVerified,
    savedAddresses,
    savedPaymentMethods,
  ];

  /// Convert to base UserEntity for polymorphic use.
  UserEntity toUserEntity() => UserEntity(
    id: id,
    email: email,
    phoneNumber: phoneNumber,
    fullName: fullName,
    profilePhoto: profilePhoto,
    role: UserRole.customer,
    createdAt: createdAt,
    updatedAt: updatedAt,
    lastActive: lastActive,
    emailVerified: emailVerified,
  );

  CustomerEntity copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? fullName,
    String? profilePhoto,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActive,
    bool? emailVerified,
    List<String>? savedAddresses,
    List<String>? savedPaymentMethods,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActive: lastActive ?? this.lastActive,
      emailVerified: emailVerified ?? this.emailVerified,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      savedPaymentMethods: savedPaymentMethods ?? this.savedPaymentMethods,
    );
  }
}
