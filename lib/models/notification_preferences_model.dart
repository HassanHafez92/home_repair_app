// File: lib/models/notification_preferences_model.dart
// Purpose: Model for storing technician notification preferences

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationPreferences {
  final bool newOrders;
  final bool chatMessages;
  final bool reviews;
  final bool payments;
  final bool performanceUpdates;
  final bool orderStatusChanges;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const NotificationPreferences({
    required this.newOrders,
    required this.chatMessages,
    required this.reviews,
    required this.payments,
    required this.performanceUpdates,
    required this.orderStatusChanges,
    required this.soundEnabled,
    required this.vibrationEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor with defaults (all notifications enabled)
  factory NotificationPreferences.defaults() {
    final now = Timestamp.now();
    return NotificationPreferences(
      newOrders: true,
      chatMessages: true,
      reviews: true,
      payments: true,
      performanceUpdates: true,
      orderStatusChanges: true,
      soundEnabled: true,
      vibrationEnabled: true,
      quietHoursStart: null,
      quietHoursEnd: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  // From Firestore document
  factory NotificationPreferences.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return NotificationPreferences(
      newOrders: data['newOrders'] ?? true,
      chatMessages: data['chatMessages'] ?? true,
      reviews: data['reviews'] ?? true,
      payments: data['payments'] ?? true,
      performanceUpdates: data['performanceUpdates'] ?? true,
      orderStatusChanges: data['orderStatusChanges'] ?? true,
      soundEnabled: data['soundEnabled'] ?? true,
      vibrationEnabled: data['vibrationEnabled'] ?? true,
      quietHoursStart: data['quietHoursStart'] != null
          ? _timeOfDayFromString(data['quietHoursStart'])
          : null,
      quietHoursEnd: data['quietHoursEnd'] != null
          ? _timeOfDayFromString(data['quietHoursEnd'])
          : null,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  // To Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'newOrders': newOrders,
      'chatMessages': chatMessages,
      'reviews': reviews,
      'payments': payments,
      'performanceUpdates': performanceUpdates,
      'orderStatusChanges': orderStatusChanges,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'quietHoursStart': quietHoursStart != null
          ? _timeOfDayToString(quietHoursStart!)
          : null,
      'quietHoursEnd': quietHoursEnd != null
          ? _timeOfDayToString(quietHoursEnd!)
          : null,
      'createdAt': createdAt,
      'updatedAt': Timestamp.now(),
    };
  }

  // Check if currently in quiet hours
  bool isInQuietHours() {
    if (quietHoursStart == null || quietHoursEnd == null) {
      return false;
    }

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = quietHoursStart!.hour * 60 + quietHoursStart!.minute;
    final endMinutes = quietHoursEnd!.hour * 60 + quietHoursEnd!.minute;

    // Handle overnight quiet hours (e.g., 22:00 to 07:00)
    if (startMinutes > endMinutes) {
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    }

    // Normal quiet hours (e.g., 13:00 to 14:00)
    return nowMinutes >= startMinutes && nowMinutes < endMinutes;
  }

  // Should notification be silenced based on quiet hours and sound settings
  bool shouldSilenceNotification() {
    return isInQuietHours() || !soundEnabled;
  }

  // Helper: Convert TimeOfDay to string (HH:mm format)
  static String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Helper: Convert string to TimeOfDay
  static TimeOfDay _timeOfDayFromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Copy with method for updates
  NotificationPreferences copyWith({
    bool? newOrders,
    bool? chatMessages,
    bool? reviews,
    bool? payments,
    bool? performanceUpdates,
    bool? orderStatusChanges,
    bool? soundEnabled,
    bool? vibrationEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    bool clearQuietHours = false,
  }) {
    return NotificationPreferences(
      newOrders: newOrders ?? this.newOrders,
      chatMessages: chatMessages ?? this.chatMessages,
      reviews: reviews ?? this.reviews,
      payments: payments ?? this.payments,
      performanceUpdates: performanceUpdates ?? this.performanceUpdates,
      orderStatusChanges: orderStatusChanges ?? this.orderStatusChanges,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursStart: clearQuietHours
          ? null
          : (quietHoursStart ?? this.quietHoursStart),
      quietHoursEnd: clearQuietHours
          ? null
          : (quietHoursEnd ?? this.quietHoursEnd),
      createdAt: createdAt,
      updatedAt: Timestamp.now(),
    );
  }
}
