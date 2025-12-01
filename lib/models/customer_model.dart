// File: lib/models/customer_model.dart
// Purpose: Customer-specific user model.

import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

part 'customer_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CustomerModel extends UserModel {
  final List<String> savedAddresses;
  final List<String> savedPaymentMethods;

  CustomerModel({
    required super.id,
    required super.email,
    super.phoneNumber,
    required super.fullName,
    super.profilePhoto,
    required super.createdAt,
    required super.updatedAt,
    required super.lastActive,
    this.savedAddresses = const [],
    this.savedPaymentMethods = const [],
  }) : super(role: UserRole.customer);

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final json = _$CustomerModelToJson(this);
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
