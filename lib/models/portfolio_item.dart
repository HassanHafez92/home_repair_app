// File: lib/models/portfolio_item.dart
// Purpose: Model for portfolio items with caption support.

import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'portfolio_item.g.dart';

@JsonSerializable()
class PortfolioItem {
  final String url;
  final String? caption;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime uploadedAt;

  PortfolioItem({required this.url, this.caption, required this.uploadedAt});

  factory PortfolioItem.fromJson(Map<String, dynamic> json) =>
      _$PortfolioItemFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioItemToJson(this);
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
