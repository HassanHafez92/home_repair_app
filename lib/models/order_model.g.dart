// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['id'] as String,
  customerId: json['customerId'] as String,
  technicianId: json['technicianId'] as String?,
  serviceId: json['serviceId'] as String,
  description: json['description'] as String,
  photoUrls:
      (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  location: json['location'] as Map<String, dynamic>,
  address: json['address'] as String,
  dateRequested: _timestampFromJson(json['dateRequested']),
  dateScheduled: _nullableTimestampFromJson(json['dateScheduled']),
  status:
      $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
      OrderStatus.pending,
  initialEstimate: (json['initialEstimate'] as num?)?.toDouble(),
  finalPrice: (json['finalPrice'] as num?)?.toDouble(),
  visitFee: (json['visitFee'] as num).toDouble(),
  vat: (json['vat'] as num).toDouble(),
  paymentMethod: json['paymentMethod'] as String,
  paymentStatus: json['paymentStatus'] as String? ?? 'pending',
  notes: json['notes'] as String?,
  serviceName: json['serviceName'] as String?,
  customerName: json['customerName'] as String?,
  customerPhoneNumber: json['customerPhoneNumber'] as String?,
  createdAt: _timestampFromJson(json['createdAt']),
  updatedAt: _timestampFromJson(json['updatedAt']),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'technicianId': instance.technicianId,
      'serviceId': instance.serviceId,
      'description': instance.description,
      'photoUrls': instance.photoUrls,
      'location': instance.location,
      'address': instance.address,
      'dateRequested': _timestampToJson(instance.dateRequested),
      'dateScheduled': _nullableTimestampToJson(instance.dateScheduled),
      'status': _$OrderStatusEnumMap[instance.status]!,
      'initialEstimate': instance.initialEstimate,
      'finalPrice': instance.finalPrice,
      'visitFee': instance.visitFee,
      'vat': instance.vat,
      'paymentMethod': instance.paymentMethod,
      'paymentStatus': instance.paymentStatus,
      'notes': instance.notes,
      'serviceName': instance.serviceName,
      'customerName': instance.customerName,
      'customerPhoneNumber': instance.customerPhoneNumber,
      'createdAt': _timestampToJson(instance.createdAt),
      'updatedAt': _timestampToJson(instance.updatedAt),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.accepted: 'accepted',
  OrderStatus.traveling: 'traveling',
  OrderStatus.arrived: 'arrived',
  OrderStatus.working: 'working',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
};
