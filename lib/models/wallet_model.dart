// File: lib/models/wallet_model.dart
// Purpose: Model representing a user's wallet.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WalletTransaction {
  final String id;
  final String type; // deposit, withdrawal, payment, refund
  final double amount;
  final String description;
  
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime timestamp;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => _$WalletTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$WalletTransactionToJson(this);
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

@JsonSerializable(explicitToJson: true)
class WalletModel {
  final String userId;
  final double balance;
  final double totalDeposits;
  final double totalSpent;
  
  // Transactions are usually a subcollection, but we can keep a recent list here if needed.
  // For scalability, it's better to fetch them separately, but for the model definition we can include a list placeholder.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<WalletTransaction> recentTransactions;

  WalletModel({
    required this.userId,
    this.balance = 0.0,
    this.totalDeposits = 0.0,
    this.totalSpent = 0.0,
    this.recentTransactions = const [],
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);
}
