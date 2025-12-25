// File: lib/services/live_tracking_service.dart
// Purpose: Service for real-time technician location tracking and ETA calculation.

import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_repair_app/models/live_tracking_model.dart';

/// Service for managing live job tracking
class LiveTrackingService {
  final FirebaseFirestore _firestore;

  LiveTrackingService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of tracking updates for a specific order
  Stream<LiveTrackingModel?> trackOrder(String orderId) {
    return _firestore.collection('live_tracking').doc(orderId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return LiveTrackingModel.fromJson(doc.data()!);
    });
  }

  /// Start a tracking session when technician begins traveling
  Future<void> startTracking({
    required String orderId,
    required String technicianId,
    required double technicianLat,
    required double technicianLng,
    required double customerLat,
    required double customerLng,
  }) async {
    final tracking = LiveTrackingModel(
      orderId: orderId,
      technicianId: technicianId,
      technicianLat: technicianLat,
      technicianLng: technicianLng,
      customerLat: customerLat,
      customerLng: customerLng,
      status: TrackingStatus.enRoute,
      lastUpdated: DateTime.now(),
      journeyStartTime: DateTime.now(),
    );

    // Calculate initial ETA
    final withEta = await _calculateEta(tracking);

    await _firestore
        .collection('live_tracking')
        .doc(orderId)
        .set(withEta.toJson());
  }

  /// Update technician location during travel
  Future<void> updateLocation({
    required String orderId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
  }) async {
    final docRef = _firestore.collection('live_tracking').doc(orderId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    var tracking = LiveTrackingModel.fromJson(doc.data()!);
    tracking = tracking.copyWith(
      technicianLat: latitude,
      technicianLng: longitude,
      heading: heading,
      speed: speed,
      lastUpdated: DateTime.now(),
    );

    // Recalculate ETA
    tracking = await _calculateEta(tracking);

    await docRef.update(tracking.toJson());
  }

  /// Mark technician as arrived
  Future<void> markArrived(String orderId) async {
    final docRef = _firestore.collection('live_tracking').doc(orderId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    var tracking = LiveTrackingModel.fromJson(doc.data()!);
    tracking = tracking.copyWith(
      status: TrackingStatus.arrived,
      arrivalTime: DateTime.now(),
      etaMinutes: 0,
      distanceMeters: 0,
      lastUpdated: DateTime.now(),
    );

    await docRef.update(tracking.toJson());
  }

  /// Update status to working
  Future<void> markWorking(String orderId) async {
    await _firestore.collection('live_tracking').doc(orderId).update({
      'status': TrackingStatus.working.name,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  /// Mark job as completed
  Future<void> markCompleted(String orderId) async {
    await _firestore.collection('live_tracking').doc(orderId).update({
      'status': TrackingStatus.completed.name,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  /// Cancel tracking session
  Future<void> cancelTracking(String orderId) async {
    await _firestore.collection('live_tracking').doc(orderId).update({
      'status': TrackingStatus.cancelled.name,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  /// Calculate ETA based on distance and traffic
  Future<LiveTrackingModel> _calculateEta(LiveTrackingModel tracking) async {
    if (tracking.technicianLat == null || tracking.technicianLng == null) {
      return tracking;
    }

    // Calculate straight-line distance using Haversine formula
    final distance = _calculateDistance(
      tracking.technicianLat!,
      tracking.technicianLng!,
      tracking.customerLat,
      tracking.customerLng,
    );

    // Estimate road distance (multiply by 1.3 for typical road factor)
    final roadDistance = distance * 1.3;

    // Estimate travel time based on average speed and traffic
    // Base speed: 30 km/h in city traffic
    double avgSpeedKmH = 30;

    // Adjust for traffic condition
    final trafficCondition = _estimateTrafficCondition();
    switch (trafficCondition) {
      case TrafficCondition.light:
        avgSpeedKmH = 40;
        break;
      case TrafficCondition.normal:
        avgSpeedKmH = 30;
        break;
      case TrafficCondition.moderate:
        avgSpeedKmH = 20;
        break;
      case TrafficCondition.heavy:
        avgSpeedKmH = 15;
        break;
      default:
        avgSpeedKmH = 25;
    }

    // Calculate ETA in minutes
    final etaMinutes = ((roadDistance / 1000) / avgSpeedKmH * 60).round();

    return tracking.copyWith(
      distanceMeters: roadDistance,
      etaMinutes: etaMinutes,
      trafficCondition: trafficCondition,
    );
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // meters

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  /// Estimate traffic condition based on time of day
  TrafficCondition _estimateTrafficCondition() {
    final now = DateTime.now();
    final hour = now.hour;
    final dayOfWeek = now.weekday;

    // Check if weekend (Friday-Saturday in Egypt)
    if (dayOfWeek == DateTime.friday || dayOfWeek == DateTime.saturday) {
      return TrafficCondition.light;
    }

    // Rush hours
    if ((hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 20)) {
      return TrafficCondition.heavy;
    }

    // Midday
    if (hour >= 10 && hour <= 16) {
      return TrafficCondition.moderate;
    }

    // Early morning or late night
    if (hour < 7 || hour > 21) {
      return TrafficCondition.light;
    }

    return TrafficCondition.normal;
  }
}
