// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortfolioItem _$PortfolioItemFromJson(Map<String, dynamic> json) =>
    PortfolioItem(
      url: json['url'] as String,
      caption: json['caption'] as String?,
      uploadedAt: _timestampFromJson(json['uploadedAt']),
    );

Map<String, dynamic> _$PortfolioItemToJson(PortfolioItem instance) =>
    <String, dynamic>{
      'url': instance.url,
      'caption': instance.caption,
      'uploadedAt': _timestampToJson(instance.uploadedAt),
    };
