// File: lib/models/withdrawal_model.dart
// Purpose: Model for technician withdrawal requests.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'withdrawal_model.g.dart';

/// Status of a withdrawal request
enum WithdrawalStatus { pending, processing, completed, failed, cancelled }

/// Bank account details for withdrawal
@JsonSerializable()
class BankDetails {
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String? iban;
  final String? swiftCode;

  const BankDetails({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    this.iban,
    this.swiftCode,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) =>
      _$BankDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$BankDetailsToJson(this);

  @override
  String toString() =>
      'BankDetails(bankName: $bankName, accountNumber: ***${accountNumber.substring(accountNumber.length - 4)})';
}

/// Model representing a withdrawal request
@JsonSerializable()
class WithdrawalModel {
  final String id;
  final String technicianId;
  final String technicianName;
  final double amount;
  final WithdrawalStatus status;
  final BankDetails bankDetails;

  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;

  @JsonKey(
    fromJson: _timestampToDateTimeNullable,
    toJson: _dateTimeToTimestampNullable,
  )
  final DateTime? processedAt;

  final String? failureReason;
  final String? transactionReference;

  const WithdrawalModel({
    required this.id,
    required this.technicianId,
    required this.technicianName,
    required this.amount,
    required this.status,
    required this.bankDetails,
    required this.createdAt,
    this.processedAt,
    this.failureReason,
    this.transactionReference,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalModelFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawalModelToJson(this);

  WithdrawalModel copyWith({
    String? id,
    String? technicianId,
    String? technicianName,
    double? amount,
    WithdrawalStatus? status,
    BankDetails? bankDetails,
    DateTime? createdAt,
    DateTime? processedAt,
    String? failureReason,
    String? transactionReference,
  }) {
    return WithdrawalModel(
      id: id ?? this.id,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      bankDetails: bankDetails ?? this.bankDetails,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      failureReason: failureReason ?? this.failureReason,
      transactionReference: transactionReference ?? this.transactionReference,
    );
  }
}

// Helper functions for Timestamp conversion
DateTime _timestampToDateTime(Timestamp timestamp) => timestamp.toDate();

DateTime? _timestampToDateTimeNullable(Timestamp? timestamp) =>
    timestamp?.toDate();

Timestamp _dateTimeToTimestamp(DateTime dateTime) =>
    Timestamp.fromDate(dateTime);

Timestamp? _dateTimeToTimestampNullable(DateTime? dateTime) =>
    dateTime != null ? Timestamp.fromDate(dateTime) : null;
