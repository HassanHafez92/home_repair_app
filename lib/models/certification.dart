// File: lib/models/certification.dart
// Purpose: Model for certifications with expiration date support.

import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'certification.g.dart';

@JsonSerializable()
class CertificationModel {
  final String url;
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  final DateTime? expirationDate;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime uploadedAt;

  CertificationModel({
    required this.url,
    this.expirationDate,
    required this.uploadedAt,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) =>
      _$CertificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$CertificationModelToJson(this);

  bool get isExpired =>
      expirationDate != null && expirationDate!.isBefore(DateTime.now());

  bool get isExpiringSoon {
    if (expirationDate == null) return false;
    final daysUntilExpiration = expirationDate!
        .difference(DateTime.now())
        .inDays;
    return daysUntilExpiration > 0 && daysUntilExpiration <= 30;
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

DateTime? _timestampFromJsonNullable(dynamic timestamp) {
  if (timestamp == null) return null;
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  } else if (timestamp is String) {
    return DateTime.parse(timestamp);
  }
  return null;
}

dynamic _timestampToJson(DateTime date) => Timestamp.fromDate(date);

dynamic _timestampToJsonNullable(DateTime? date) =>
    date != null ? Timestamp.fromDate(date) : null;
