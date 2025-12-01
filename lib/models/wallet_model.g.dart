// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletTransaction _$WalletTransactionFromJson(Map<String, dynamic> json) =>
    WalletTransaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      timestamp: _timestampFromJson(json['timestamp']),
    );

Map<String, dynamic> _$WalletTransactionToJson(WalletTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'description': instance.description,
      'timestamp': _timestampToJson(instance.timestamp),
    };

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => WalletModel(
  userId: json['userId'] as String,
  balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  totalDeposits: (json['totalDeposits'] as num?)?.toDouble() ?? 0.0,
  totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$WalletModelToJson(WalletModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'balance': instance.balance,
      'totalDeposits': instance.totalDeposits,
      'totalSpent': instance.totalSpent,
    };
