// File: lib/models/order_model.dart
// Purpose: Model representing a service order.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart' as entity;

part 'order_model.g.dart';

enum OrderStatus {
  pending,
  accepted,
  traveling,
  arrived,
  working,
  completed,
  cancelled,
}

@JsonSerializable(explicitToJson: true)
class OrderModel extends Equatable {
  final String id;
  final String customerId;
  final String? technicianId;
  final String serviceId;
  final String description;
  final List<String> photoUrls;
  final Map<String, dynamic> location; // GeoPoint as Map
  final String address;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime dateRequested;

  @JsonKey(
    fromJson: _nullableTimestampFromJson,
    toJson: _nullableTimestampToJson,
  )
  final DateTime? dateScheduled;

  final OrderStatus status;
  final double? initialEstimate;
  final double? finalPrice;
  final double visitFee;
  final double vat;
  final String paymentMethod;
  final String paymentStatus; // pending, paid, failed
  final String? notes;

  // Denormalized fields (stored in Firestore for performance)
  final String? serviceName;
  final String? customerName;
  final String? customerPhoneNumber;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    this.technicianId,
    required this.serviceId,
    required this.description,
    this.photoUrls = const [],
    required this.location,
    required this.address,
    required this.dateRequested,
    this.dateScheduled,
    this.status = OrderStatus.pending,
    this.initialEstimate,
    this.finalPrice,
    required this.visitFee,
    required this.vat,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    this.notes,
    this.serviceName,
    this.customerName,
    this.customerPhoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? technicianId,
    String? serviceId,
    String? description,
    List<String>? photoUrls,
    Map<String, dynamic>? location,
    String? address,
    DateTime? dateRequested,
    DateTime? dateScheduled,
    OrderStatus? status,
    double? initialEstimate,
    double? finalPrice,
    double? visitFee,
    double? vat,
    String? paymentMethod,
    String? paymentStatus,
    String? notes,
    String? serviceName,
    String? customerName,
    String? customerPhoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      technicianId: technicianId ?? this.technicianId,
      serviceId: serviceId ?? this.serviceId,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      location: location ?? this.location,
      address: address ?? this.address,
      dateRequested: dateRequested ?? this.dateRequested,
      dateScheduled: dateScheduled ?? this.dateScheduled,
      status: status ?? this.status,
      initialEstimate: initialEstimate ?? this.initialEstimate,
      finalPrice: finalPrice ?? this.finalPrice,
      visitFee: visitFee ?? this.visitFee,
      vat: vat ?? this.vat,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      serviceName: serviceName ?? this.serviceName,
      customerName: customerName ?? this.customerName,
      customerPhoneNumber: customerPhoneNumber ?? this.customerPhoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    technicianId,
    serviceId,
    description,
    photoUrls,
    location,
    address,
    dateRequested,
    dateScheduled,
    status,
    initialEstimate,
    finalPrice,
    visitFee,
    vat,
    paymentMethod,
    paymentStatus,
    notes,
    serviceName,
    customerName,
    customerPhoneNumber,
    createdAt,
    updatedAt,
  ];

  // Helper getters for UI display
  double get totalPrice => finalPrice ?? initialEstimate ?? 0.0;

  /// Convert to OrderEntity for use in presentation layer
  entity.OrderEntity toEntity() {
    return entity.OrderEntity(
      id: id,
      customerId: customerId,
      technicianId: technicianId,
      serviceId: serviceId,
      description: description,
      photoUrls: photoUrls,
      location: location,
      address: address,
      dateRequested: dateRequested,
      dateScheduled: dateScheduled,
      status: entity.OrderStatus.values.firstWhere(
        (e) => e.name == status.name,
        orElse: () => entity.OrderStatus.pending,
      ),
      initialEstimate: initialEstimate,
      finalPrice: finalPrice,
      visitFee: visitFee,
      vat: vat,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      notes: notes,
      serviceName: serviceName,
      customerName: customerName,
      customerPhoneNumber: customerPhoneNumber,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
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

DateTime? _nullableTimestampFromJson(dynamic timestamp) {
  if (timestamp == null) return null;
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  } else if (timestamp is String) {
    return DateTime.parse(timestamp);
  } else {
    return null;
  }
}

dynamic _nullableTimestampToJson(DateTime? date) =>
    date != null ? Timestamp.fromDate(date) : null;
