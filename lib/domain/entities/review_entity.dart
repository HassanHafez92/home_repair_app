/// Domain entity representing a review for a technician.
///
/// This is a pure Dart class with no framework dependencies.
/// Use models in the data layer for Firestore/JSON serialization.

import 'package:equatable/equatable.dart';

/// Entity representing a customer review for a technician.
class ReviewEntity extends Equatable {
  final String id;
  final String orderId;
  final String technicianId;
  final String customerId;
  final int rating; // 1-5
  final Map<String, int>
  categories; // {quality, punctuality, professionalism, price}
  final String? comment;
  final List<String> photoUrls;
  final DateTime timestamp;

  const ReviewEntity({
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

  @override
  List<Object?> get props => [
    id,
    orderId,
    technicianId,
    customerId,
    rating,
    categories,
    comment,
    photoUrls,
    timestamp,
  ];

  ReviewEntity copyWith({
    String? id,
    String? orderId,
    String? technicianId,
    String? customerId,
    int? rating,
    Map<String, int>? categories,
    String? comment,
    List<String>? photoUrls,
    DateTime? timestamp,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      technicianId: technicianId ?? this.technicianId,
      customerId: customerId ?? this.customerId,
      rating: rating ?? this.rating,
      categories: categories ?? this.categories,
      comment: comment ?? this.comment,
      photoUrls: photoUrls ?? this.photoUrls,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
