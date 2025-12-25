// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankDetails _$BankDetailsFromJson(Map<String, dynamic> json) => BankDetails(
  bankName: json['bankName'] as String,
  accountNumber: json['accountNumber'] as String,
  accountHolderName: json['accountHolderName'] as String,
  iban: json['iban'] as String?,
  swiftCode: json['swiftCode'] as String?,
);

Map<String, dynamic> _$BankDetailsToJson(BankDetails instance) =>
    <String, dynamic>{
      'bankName': instance.bankName,
      'accountNumber': instance.accountNumber,
      'accountHolderName': instance.accountHolderName,
      'iban': instance.iban,
      'swiftCode': instance.swiftCode,
    };

WithdrawalModel _$WithdrawalModelFromJson(Map<String, dynamic> json) =>
    WithdrawalModel(
      id: json['id'] as String,
      technicianId: json['technicianId'] as String,
      technicianName: json['technicianName'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: $enumDecode(_$WithdrawalStatusEnumMap, json['status']),
      bankDetails: BankDetails.fromJson(
        json['bankDetails'] as Map<String, dynamic>,
      ),
      createdAt: _timestampToDateTime(json['createdAt'] as Timestamp),
      processedAt: _timestampToDateTimeNullable(
        json['processedAt'] as Timestamp?,
      ),
      failureReason: json['failureReason'] as String?,
      transactionReference: json['transactionReference'] as String?,
    );

Map<String, dynamic> _$WithdrawalModelToJson(WithdrawalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'technicianId': instance.technicianId,
      'technicianName': instance.technicianName,
      'amount': instance.amount,
      'status': _$WithdrawalStatusEnumMap[instance.status]!,
      'bankDetails': instance.bankDetails,
      'createdAt': _dateTimeToTimestamp(instance.createdAt),
      'processedAt': _dateTimeToTimestampNullable(instance.processedAt),
      'failureReason': instance.failureReason,
      'transactionReference': instance.transactionReference,
    };

const _$WithdrawalStatusEnumMap = {
  WithdrawalStatus.pending: 'pending',
  WithdrawalStatus.processing: 'processing',
  WithdrawalStatus.completed: 'completed',
  WithdrawalStatus.failed: 'failed',
  WithdrawalStatus.cancelled: 'cancelled',
};
