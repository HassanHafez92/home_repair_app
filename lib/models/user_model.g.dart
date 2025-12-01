// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  fullName: json['fullName'] as String,
  profilePhoto: json['profilePhoto'] as String?,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  createdAt: _timestampFromJson(json['createdAt']),
  updatedAt: _timestampFromJson(json['updatedAt']),
  lastActive: _timestampFromJson(json['lastActive']),
  emailVerified: json['emailVerified'] as bool?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'fullName': instance.fullName,
  'profilePhoto': instance.profilePhoto,
  'role': _$UserRoleEnumMap[instance.role]!,
  'createdAt': _timestampToJson(instance.createdAt),
  'updatedAt': _timestampToJson(instance.updatedAt),
  'lastActive': _timestampToJson(instance.lastActive),
  'emailVerified': instance.emailVerified,
};

const _$UserRoleEnumMap = {
  UserRole.customer: 'customer',
  UserRole.technician: 'technician',
  UserRole.admin: 'admin',
};
