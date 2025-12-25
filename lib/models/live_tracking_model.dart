// File: lib/models/live_tracking_model.dart
// Purpose: Model for real-time job tracking with technician location and ETA.

import 'package:equatable/equatable.dart';

/// Status of the live tracking session
enum TrackingStatus {
  /// Technician hasn't started traveling yet
  pending,

  /// Technician is traveling to customer location
  enRoute,

  /// Technician has arrived at customer location
  arrived,

  /// Job is in progress
  working,

  /// Job is completed
  completed,

  /// Tracking session cancelled
  cancelled,
}

/// Model for real-time job tracking
class LiveTrackingModel extends Equatable {
  /// Order ID being tracked
  final String orderId;

  /// Technician ID
  final String technicianId;

  /// Technician's current latitude
  final double? technicianLat;

  /// Technician's current longitude
  final double? technicianLng;

  /// Customer's latitude
  final double customerLat;

  /// Customer's longitude
  final double customerLng;

  /// Current tracking status
  final TrackingStatus status;

  /// Estimated time of arrival in minutes
  final int? etaMinutes;

  /// Distance remaining in meters
  final double? distanceMeters;

  /// Last location update timestamp
  final DateTime? lastUpdated;

  /// Technician's heading/bearing in degrees
  final double? heading;

  /// Technician's speed in m/s
  final double? speed;

  /// Route polyline (encoded)
  final String? routePolyline;

  /// Traffic condition
  final TrafficCondition trafficCondition;

  /// Start time of the journey
  final DateTime? journeyStartTime;

  /// Arrival time (when technician arrived)
  final DateTime? arrivalTime;

  const LiveTrackingModel({
    required this.orderId,
    required this.technicianId,
    this.technicianLat,
    this.technicianLng,
    required this.customerLat,
    required this.customerLng,
    this.status = TrackingStatus.pending,
    this.etaMinutes,
    this.distanceMeters,
    this.lastUpdated,
    this.heading,
    this.speed,
    this.routePolyline,
    this.trafficCondition = TrafficCondition.unknown,
    this.journeyStartTime,
    this.arrivalTime,
  });

  /// Check if technician location is available
  bool get hasLocation => technicianLat != null && technicianLng != null;

  /// Check if currently tracking
  bool get isTracking =>
      status == TrackingStatus.enRoute || status == TrackingStatus.working;

  /// Get formatted ETA string
  String get etaDisplay {
    if (etaMinutes == null) return '--';
    if (etaMinutes! < 1) return 'Arriving now';
    if (etaMinutes! < 60) return '$etaMinutes min';
    final hours = etaMinutes! ~/ 60;
    final mins = etaMinutes! % 60;
    return '${hours}h ${mins}m';
  }

  /// Get formatted distance string
  String get distanceDisplay {
    if (distanceMeters == null) return '--';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.toInt()} m';
    }
    return '${(distanceMeters! / 1000).toStringAsFixed(1)} km';
  }

  /// Create a copy with updated values
  LiveTrackingModel copyWith({
    String? orderId,
    String? technicianId,
    double? technicianLat,
    double? technicianLng,
    double? customerLat,
    double? customerLng,
    TrackingStatus? status,
    int? etaMinutes,
    double? distanceMeters,
    DateTime? lastUpdated,
    double? heading,
    double? speed,
    String? routePolyline,
    TrafficCondition? trafficCondition,
    DateTime? journeyStartTime,
    DateTime? arrivalTime,
  }) {
    return LiveTrackingModel(
      orderId: orderId ?? this.orderId,
      technicianId: technicianId ?? this.technicianId,
      technicianLat: technicianLat ?? this.technicianLat,
      technicianLng: technicianLng ?? this.technicianLng,
      customerLat: customerLat ?? this.customerLat,
      customerLng: customerLng ?? this.customerLng,
      status: status ?? this.status,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      routePolyline: routePolyline ?? this.routePolyline,
      trafficCondition: trafficCondition ?? this.trafficCondition,
      journeyStartTime: journeyStartTime ?? this.journeyStartTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'technicianId': technicianId,
      'technicianLat': technicianLat,
      'technicianLng': technicianLng,
      'customerLat': customerLat,
      'customerLng': customerLng,
      'status': status.name,
      'etaMinutes': etaMinutes,
      'distanceMeters': distanceMeters,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'heading': heading,
      'speed': speed,
      'routePolyline': routePolyline,
      'trafficCondition': trafficCondition.name,
      'journeyStartTime': journeyStartTime?.toIso8601String(),
      'arrivalTime': arrivalTime?.toIso8601String(),
    };
  }

  /// Create from JSON (from Firestore)
  factory LiveTrackingModel.fromJson(Map<String, dynamic> json) {
    return LiveTrackingModel(
      orderId: json['orderId'] as String,
      technicianId: json['technicianId'] as String,
      technicianLat: (json['technicianLat'] as num?)?.toDouble(),
      technicianLng: (json['technicianLng'] as num?)?.toDouble(),
      customerLat: (json['customerLat'] as num).toDouble(),
      customerLng: (json['customerLng'] as num).toDouble(),
      status: TrackingStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TrackingStatus.pending,
      ),
      etaMinutes: json['etaMinutes'] as int?,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      heading: (json['heading'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      routePolyline: json['routePolyline'] as String?,
      trafficCondition: TrafficCondition.values.firstWhere(
        (t) => t.name == json['trafficCondition'],
        orElse: () => TrafficCondition.unknown,
      ),
      journeyStartTime: json['journeyStartTime'] != null
          ? DateTime.parse(json['journeyStartTime'] as String)
          : null,
      arrivalTime: json['arrivalTime'] != null
          ? DateTime.parse(json['arrivalTime'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    orderId,
    technicianId,
    technicianLat,
    technicianLng,
    customerLat,
    customerLng,
    status,
    etaMinutes,
    distanceMeters,
    lastUpdated,
    heading,
    speed,
    routePolyline,
    trafficCondition,
    journeyStartTime,
    arrivalTime,
  ];
}

/// Traffic condition levels
enum TrafficCondition {
  /// Unknown traffic condition
  unknown,

  /// Light traffic, faster than usual
  light,

  /// Normal traffic conditions
  normal,

  /// Moderate traffic, slight delays
  moderate,

  /// Heavy traffic, significant delays
  heavy,
}
