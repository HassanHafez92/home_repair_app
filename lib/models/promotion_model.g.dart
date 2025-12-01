// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromotionModel _$PromotionModelFromJson(Map<String, dynamic> json) =>
    PromotionModel(
      id: json['id'] as String,
      code: json['code'] as String,
      discountType: $enumDecode(_$DiscountTypeEnumMap, json['discountType']),
      discountValue: (json['discountValue'] as num).toDouble(),
      validFrom: _timestampFromJson(json['validFrom']),
      validUntil: _timestampFromJson(json['validUntil']),
      usageLimit: (json['usageLimit'] as num).toInt(),
      usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$PromotionModelToJson(PromotionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'discountType': _$DiscountTypeEnumMap[instance.discountType]!,
      'discountValue': instance.discountValue,
      'validFrom': _timestampToJson(instance.validFrom),
      'validUntil': _timestampToJson(instance.validUntil),
      'usageLimit': instance.usageLimit,
      'usedCount': instance.usedCount,
      'isActive': instance.isActive,
    };

const _$DiscountTypeEnumMap = {
  DiscountType.percentage: 'percentage',
  DiscountType.fixed: 'fixed',
};
