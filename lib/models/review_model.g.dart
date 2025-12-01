// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  technicianId: json['technicianId'] as String,
  customerId: json['customerId'] as String,
  rating: (json['rating'] as num).toInt(),
  categories: Map<String, int>.from(json['categories'] as Map),
  comment: json['comment'] as String?,
  photoUrls:
      (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  timestamp: _timestampFromJson(json['timestamp']),
);

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'technicianId': instance.technicianId,
      'customerId': instance.customerId,
      'rating': instance.rating,
      'categories': instance.categories,
      'comment': instance.comment,
      'photoUrls': instance.photoUrls,
      'timestamp': _timestampToJson(instance.timestamp),
    };
