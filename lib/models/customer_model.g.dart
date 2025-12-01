// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) =>
    CustomerModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      fullName: json['fullName'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      createdAt: _timestampFromJson(json['createdAt']),
      updatedAt: _timestampFromJson(json['updatedAt']),
      lastActive: _timestampFromJson(json['lastActive']),
      savedAddresses:
          (json['savedAddresses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      savedPaymentMethods:
          (json['savedPaymentMethods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CustomerModelToJson(CustomerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'fullName': instance.fullName,
      'profilePhoto': instance.profilePhoto,
      'createdAt': _timestampToJson(instance.createdAt),
      'updatedAt': _timestampToJson(instance.updatedAt),
      'lastActive': _timestampToJson(instance.lastActive),
      'savedAddresses': instance.savedAddresses,
      'savedPaymentMethods': instance.savedPaymentMethods,
    };
