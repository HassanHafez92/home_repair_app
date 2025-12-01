// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'technician_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TechnicianModel _$TechnicianModelFromJson(Map<String, dynamic> json) =>
    TechnicianModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      fullName: json['fullName'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      createdAt: _timestampFromJson(json['createdAt']),
      updatedAt: _timestampFromJson(json['updatedAt']),
      lastActive: _timestampFromJson(json['lastActive']),
      nationalId: json['nationalId'] as String?,
      specializations:
          (json['specializations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      portfolioUrls:
          (json['portfolioUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      yearsOfExperience: (json['yearsOfExperience'] as num?)?.toInt() ?? 0,
      status:
          $enumDecodeNullable(_$TechnicianStatusEnumMap, json['status']) ??
          TechnicianStatus.pending,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      completedJobs: (json['completedJobs'] as num?)?.toInt() ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? false,
      location: json['location'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TechnicianModelToJson(TechnicianModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'fullName': instance.fullName,
      'profilePhoto': instance.profilePhoto,
      'createdAt': _timestampToJson(instance.createdAt),
      'updatedAt': _timestampToJson(instance.updatedAt),
      'lastActive': _timestampToJson(instance.lastActive),
      'nationalId': instance.nationalId,
      'specializations': instance.specializations,
      'portfolioUrls': instance.portfolioUrls,
      'yearsOfExperience': instance.yearsOfExperience,
      'status': _$TechnicianStatusEnumMap[instance.status]!,
      'rating': instance.rating,
      'completedJobs': instance.completedJobs,
      'isAvailable': instance.isAvailable,
      'location': instance.location,
    };

const _$TechnicianStatusEnumMap = {
  TechnicianStatus.pending: 'pending',
  TechnicianStatus.approved: 'approved',
  TechnicianStatus.rejected: 'rejected',
  TechnicianStatus.suspended: 'suspended',
};
