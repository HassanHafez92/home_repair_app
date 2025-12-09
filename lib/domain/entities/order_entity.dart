/// Domain entity representing an order.

import 'package:equatable/equatable.dart';

/// Order status enum.
enum OrderStatus {
  pending,
  accepted,
  traveling,
  arrived,
  working,
  completed,
  cancelled,
}

/// Order entity - pure Dart class with no framework dependencies.
class OrderEntity extends Equatable {
  final String id;
  final String customerId;
  final String? technicianId;
  final String serviceId;
  final String description;
  final List<String> photoUrls;
  final Map<String, dynamic> location;
  final String address;
  final DateTime dateRequested;
  final DateTime? dateScheduled;
  final OrderStatus status;
  final double? initialEstimate;
  final double? finalPrice;
  final double visitFee;
  final double vat;
  final String paymentMethod;
  final String paymentStatus;
  final String? notes;
  final String? serviceName;
  final String? customerName;
  final String? customerPhoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
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

  /// Helper getter for total price.
  double get totalPrice => finalPrice ?? initialEstimate ?? 0.0;

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

  OrderEntity copyWith({
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
    return OrderEntity(
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
}
