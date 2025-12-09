/// Domain entity representing a user notification.
///
/// This is a pure Dart class with no framework dependencies.
/// Use models in the data layer for Firestore/JSON serialization.

import 'package:equatable/equatable.dart';

/// Notification types supported in the system.
enum NotificationType { order, payment, offer, system }

/// Entity representing a notification for a user.
class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime timestamp;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.isRead = false,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    message,
    data,
    isRead,
    timestamp,
  ];

  NotificationEntity copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? timestamp,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
