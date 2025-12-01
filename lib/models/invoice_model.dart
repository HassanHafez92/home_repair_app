// File: lib/models/invoice_model.dart
// Purpose: Model representing an invoice for a completed order.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invoice_model.g.dart';

@JsonSerializable(explicitToJson: true)
class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class InvoiceModel {
  final String id;
  final String orderId;
  final String customerId;
  final String technicianId;
  final List<InvoiceItem> items;
  final double subtotal;
  final double vat;
  final double totalAmount;
  final String paymentMethod;
  final String? transactionId;
  final String receiptNumber;
  final String? egInvoiceId; // For Egypt Tax Authority
  
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime timestamp;

  InvoiceModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.technicianId,
    required this.items,
    required this.subtotal,
    required this.vat,
    required this.totalAmount,
    required this.paymentMethod,
    this.transactionId,
    required this.receiptNumber,
    this.egInvoiceId,
    required this.timestamp,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => _$InvoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceModelToJson(this);
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
