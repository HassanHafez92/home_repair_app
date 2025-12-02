// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CertificationModel _$CertificationModelFromJson(Map<String, dynamic> json) =>
    CertificationModel(
      url: json['url'] as String,
      expirationDate: _timestampFromJsonNullable(json['expirationDate']),
      uploadedAt: _timestampFromJson(json['uploadedAt']),
    );

Map<String, dynamic> _$CertificationModelToJson(CertificationModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'expirationDate': _timestampToJsonNullable(instance.expirationDate),
      'uploadedAt': _timestampToJson(instance.uploadedAt),
    };
