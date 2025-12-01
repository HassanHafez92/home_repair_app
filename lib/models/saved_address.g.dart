// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedAddress _$SavedAddressFromJson(Map<String, dynamic> json) => SavedAddress(
  id: json['id'] as String,
  userId: json['userId'] as String,
  label: json['label'] as String,
  address: json['address'] as String,
  location: json['location'] as Map<String, dynamic>,
  isDefault: json['isDefault'] as bool? ?? false,
  street: json['street'] as String?,
  building: json['building'] as String?,
  floor: json['floor'] as String?,
  apartment: json['apartment'] as String?,
  city: json['city'] as String?,
  usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
  lastUsed: _timestampFromJson(json['lastUsed']),
  createdAt: _timestampFromJson(json['createdAt']),
);

Map<String, dynamic> _$SavedAddressToJson(SavedAddress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'label': instance.label,
      'address': instance.address,
      'location': instance.location,
      'isDefault': instance.isDefault,
      'street': instance.street,
      'building': instance.building,
      'floor': instance.floor,
      'apartment': instance.apartment,
      'city': instance.city,
      'usageCount': instance.usageCount,
      'lastUsed': _timestampToJson(instance.lastUsed),
      'createdAt': _timestampToJson(instance.createdAt),
    };
