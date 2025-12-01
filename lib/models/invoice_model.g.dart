// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => InvoiceItem(
  description: json['description'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
  total: (json['total'] as num).toDouble(),
);

Map<String, dynamic> _$InvoiceItemToJson(InvoiceItem instance) =>
    <String, dynamic>{
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'total': instance.total,
    };

InvoiceModel _$InvoiceModelFromJson(Map<String, dynamic> json) => InvoiceModel(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  customerId: json['customerId'] as String,
  technicianId: json['technicianId'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  subtotal: (json['subtotal'] as num).toDouble(),
  vat: (json['vat'] as num).toDouble(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  paymentMethod: json['paymentMethod'] as String,
  transactionId: json['transactionId'] as String?,
  receiptNumber: json['receiptNumber'] as String,
  egInvoiceId: json['egInvoiceId'] as String?,
  timestamp: _timestampFromJson(json['timestamp']),
);

Map<String, dynamic> _$InvoiceModelToJson(InvoiceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'customerId': instance.customerId,
      'technicianId': instance.technicianId,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'subtotal': instance.subtotal,
      'vat': instance.vat,
      'totalAmount': instance.totalAmount,
      'paymentMethod': instance.paymentMethod,
      'transactionId': instance.transactionId,
      'receiptNumber': instance.receiptNumber,
      'egInvoiceId': instance.egInvoiceId,
      'timestamp': _timestampToJson(instance.timestamp),
    };
