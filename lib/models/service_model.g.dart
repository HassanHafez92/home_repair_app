// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) => ServiceModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  iconUrl: json['iconUrl'] as String,
  category: json['category'] as String,
  avgPrice: (json['avgPrice'] as num).toDouble(),
  minPrice: (json['minPrice'] as num).toDouble(),
  maxPrice: (json['maxPrice'] as num).toDouble(),
  visitFee: (json['visitFee'] as num).toDouble(),
  avgCompletionTimeMinutes: (json['avgCompletionTimeMinutes'] as num).toInt(),
  isActive: json['isActive'] as bool? ?? true,
  createdAt: _timestampFromJson(json['createdAt']),
);

Map<String, dynamic> _$ServiceModelToJson(ServiceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'category': instance.category,
      'avgPrice': instance.avgPrice,
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'visitFee': instance.visitFee,
      'avgCompletionTimeMinutes': instance.avgCompletionTimeMinutes,
      'isActive': instance.isActive,
      'createdAt': _timestampToJson(instance.createdAt),
    };
