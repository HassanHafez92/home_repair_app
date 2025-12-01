// File: lib/models/review_model.dart
// Purpose: Model representing a review for a technician.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ReviewModel {
  final String id;
  final String orderId;
  final String technicianId;
  final String customerId;
  final int rating; // 1-5
  final Map<String, int> categories; // {quality, punctuality, professionalism, price}
  final String? comment;
  final List<String> photoUrls;
  
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime timestamp;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.technicianId,
    required this.customerId,
    required this.rating,
    required this.categories,
    this.comment,
    this.photoUrls = const [],
    required this.timestamp,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => _$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
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
