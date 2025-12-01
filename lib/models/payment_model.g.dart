// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  customerId: json['customerId'] as String,
  amount: (json['amount'] as num).toDouble(),
  method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
  status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
  transactionId: json['transactionId'] as String?,
  receiptUrl: json['receiptUrl'] as String?,
  timestamp: _timestampFromJson(json['timestamp']),
);

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'customerId': instance.customerId,
      'amount': instance.amount,
      'method': _$PaymentMethodEnumMap[instance.method]!,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'transactionId': instance.transactionId,
      'receiptUrl': instance.receiptUrl,
      'timestamp': _timestampToJson(instance.timestamp),
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.wallet: 'wallet',
  PaymentMethod.card: 'card',
  PaymentMethod.fawry: 'fawry',
  PaymentMethod.cash: 'cash',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.completed: 'completed',
  PaymentStatus.failed: 'failed',
};
