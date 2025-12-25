// File: lib/models/safety_checkin_model.dart
// Purpose: Model for technician safety check-ins and SOS alerts.

import 'package:equatable/equatable.dart';

/// Type of safety event
enum SafetyEventType {
  /// Regular automatic check-in
  autoCheckIn,

  /// Manual check-in by technician
  manualCheckIn,

  /// Check-in missed (system-generated)
  missedCheckIn,

  /// SOS alert triggered
  sosAlert,

  /// Job started
  jobStarted,

  /// Job completed
  jobCompleted,
}

/// Status of a safety alert
enum AlertStatus {
  /// Alert is active, awaiting response
  active,

  /// Alert acknowledged by support
  acknowledged,

  /// Alert resolved
  resolved,

  /// False alarm
  falseAlarm,
}

/// Model for safety check-in events
class SafetyCheckInModel extends Equatable {
  /// Unique event ID
  final String id;

  /// Technician ID
  final String technicianId;

  /// Technician name
  final String technicianName;

  /// Order ID (if on a job)
  final String? orderId;

  /// Event type
  final SafetyEventType eventType;

  /// Event timestamp
  final DateTime timestamp;

  /// Location latitude
  final double? latitude;

  /// Location longitude
  final double? longitude;

  /// Location address (reverse geocoded)
  final String? address;

  /// Battery level (0-100)
  final int? batteryLevel;

  /// Optional note from technician
  final String? note;

  /// Alert status (for SOS alerts)
  final AlertStatus? alertStatus;

  /// Response notes (from support)
  final String? responseNotes;

  /// Resolved by (admin ID)
  final String? resolvedBy;

  /// Resolution time
  final DateTime? resolvedAt;

  const SafetyCheckInModel({
    required this.id,
    required this.technicianId,
    required this.technicianName,
    this.orderId,
    required this.eventType,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.address,
    this.batteryLevel,
    this.note,
    this.alertStatus,
    this.responseNotes,
    this.resolvedBy,
    this.resolvedAt,
  });

  /// Check if this is an SOS alert
  bool get isSosAlert => eventType == SafetyEventType.sosAlert;

  /// Check if location is available
  bool get hasLocation => latitude != null && longitude != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'technicianId': technicianId,
    'technicianName': technicianName,
    'orderId': orderId,
    'eventType': eventType.name,
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'batteryLevel': batteryLevel,
    'note': note,
    'alertStatus': alertStatus?.name,
    'responseNotes': responseNotes,
    'resolvedBy': resolvedBy,
    'resolvedAt': resolvedAt?.toIso8601String(),
  };

  factory SafetyCheckInModel.fromJson(Map<String, dynamic> json) {
    return SafetyCheckInModel(
      id: json['id'] as String,
      technicianId: json['technicianId'] as String,
      technicianName: json['technicianName'] as String,
      orderId: json['orderId'] as String?,
      eventType: SafetyEventType.values.firstWhere(
        (e) => e.name == json['eventType'],
        orElse: () => SafetyEventType.autoCheckIn,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      batteryLevel: json['batteryLevel'] as int?,
      note: json['note'] as String?,
      alertStatus: json['alertStatus'] != null
          ? AlertStatus.values.firstWhere(
              (s) => s.name == json['alertStatus'],
              orElse: () => AlertStatus.active,
            )
          : null,
      responseNotes: json['responseNotes'] as String?,
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, technicianId, eventType, timestamp];
}

/// Configuration for safety check-ins
class SafetyConfig {
  /// Interval for automatic check-ins in minutes
  static const int autoCheckInIntervalMinutes = 30;

  /// Time before missed check-in alert in minutes
  static const int missedCheckInThresholdMinutes = 45;

  /// Emergency contacts
  static const List<String> emergencyContacts = [
    'Support: 16XXX',
    'Police: 122',
    'Ambulance: 123',
  ];
}
