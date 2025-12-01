// File: lib/models/promotion_model.dart
// Purpose: Model representing a promotion or coupon code.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'promotion_model.g.dart';

enum DiscountType {
  percentage,
  fixed,
}

@JsonSerializable(explicitToJson: true)
class PromotionModel {
  final String id;
  final String code;
  final DiscountType discountType;
  final double discountValue;
  
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime validFrom;
  
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime validUntil;
  
  final int usageLimit;
  final int usedCount;
  final bool isActive;

  PromotionModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.validFrom,
    required this.validUntil,
    required this.usageLimit,
    this.usedCount = 0,
    this.isActive = true,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) => _$PromotionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionModelToJson(this);
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

dynamic _timestampToJson(DateTime date) => Timestamp.fromDate(date);
