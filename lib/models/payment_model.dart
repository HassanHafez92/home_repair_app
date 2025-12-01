// File: lib/models/payment_model.dart
// Purpose: Model representing a payment transaction.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

enum PaymentMethod {
  wallet,
  card,
  fawry,
  cash,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
}

@JsonSerializable(explicitToJson: true)
class PaymentModel {
  final String id;
  final String orderId;
  final String customerId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final String? receiptUrl;
  
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime timestamp;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    this.receiptUrl,
    required this.timestamp,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
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
