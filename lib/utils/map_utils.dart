// File: lib/utils/map_utils.dart
// Purpose: Utility functions for map operations, navigation, and marker customization

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;
import '../domain/entities/order_entity.dart';

class MapUtils {
  /// Opens Google Maps for navigation to the specified coordinates
  ///
  /// Platform-specific deep linking:
  /// - Android: Uses google.navigation intent
  /// - iOS: Uses comgooglemaps:// or maps.apple.com fallback
  /// - Web: Uses google.com/maps
  static Future<bool> navigateToLocation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final String destination = '$latitude,$longitude';
    final String labelParam = label != null
        ? '&label=${Uri.encodeComponent(label)}'
        : '';

    // Try Google Maps app first
    final Uri googleMapsUrl = Uri.parse(
      'google.navigation:q=$destination$labelParam',
    );

    // Fallback to web URL
    final Uri fallbackUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destination$labelParam',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        return await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        return await launchUrl(
          fallbackUrl,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Error launching navigation: $e');
      return false;
    }
  }

  static Future<bool> launchMaps(double latitude, double longitude) {
    return navigateToLocation(latitude: latitude, longitude: longitude);
  }

  /// Launch phone dialer with the specified phone number
  ///
  /// Supports tel:// URI scheme across all platforms
  static Future<bool> launchPhoneDialer(String phoneNumber) async {
    // Remove any spaces, dashes, or special characters except + for international numbers
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    final Uri phoneUri = Uri.parse('tel:$cleanNumber');

    try {
      if (await canLaunchUrl(phoneUri)) {
        return await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Cannot launch phone dialer for: $phoneNumber');
        return false;
      }
    } catch (e) {
      debugPrint('Error launching phone dialer: $e');
      return false;
    }
  }

  /// Launch WhatsApp with the specified phone number
  ///
  /// Uses https://wa.me/ scheme which works on both Android and iOS
  /// and falls back to browser if app is not installed.
  static Future<bool> launchWhatsApp(String phoneNumber) async {
    // Remove any spaces, dashes, or special characters except + for international numbers
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        return await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('Cannot launch WhatsApp for: $phoneNumber');
        return false;
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      return false;
    }
  }

  /// Convert Firestore GeoPoint Map to LatLng
  ///
  /// Firestore stores GeoPoints as: {'latitude': double, 'longitude': double}
  static LatLng? geoPointToLatLng(Map<String, dynamic>? geoPoint) {
    if (geoPoint == null) return null;

    try {
      final lat = geoPoint['latitude'] as double?;
      final lng = geoPoint['longitude'] as double?;

      if (lat == null || lng == null) return null;

      return LatLng(lat, lng);
    } catch (e) {
      debugPrint('Error converting GeoPoint to LatLng: $e');
      return null;
    }
  }

  /// Convert LatLng to Firestore GeoPoint Map
  static Map<String, dynamic> latLngToGeoPoint(LatLng location) {
    return {'latitude': location.latitude, 'longitude': location.longitude};
  }

  /// Calculate distance between two coordinates in kilometers
  /// Uses Haversine formula
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadius = 6371; // Earth radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  /// Helper to convert degrees to radians
  static double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180.0);
  }

  /// Helper sine function
  static double sin(double radians) {
    // Using built-in dart:math sin
    return radians - (radians * radians * radians) / 6;
  }

  /// Calculate distance between two LatLng points
  static double calculateDistanceLatLng(LatLng point1, LatLng point2) {
    return calculateDistance(
      lat1: point1.latitude,
      lon1: point1.longitude,
      lat2: point2.latitude,
      lon2: point2.longitude,
    );
  }

  /// Get distance from current location to a point
  static Future<double?> getDistanceFromCurrentLocation(
    LatLng destination,
  ) async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      return calculateDistance(
        lat1: position.latitude,
        lon1: position.longitude,
        lat2: destination.latitude,
        lon2: destination.longitude,
      );
    } catch (e) {
      debugPrint('Error getting current location for distance: $e');
      return null;
    }
  }

  /// Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  /// Get custom marker color based on order status
  static BitmapDescriptor getMarkerForOrderStatus(OrderStatus status) {
    // Note: For actual custom icons, you'd need to generate BitmapDescriptors
    // from custom assets or programmatically. This uses default hue values.
    switch (status) {
      case OrderStatus.pending:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      case OrderStatus.accepted:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case OrderStatus.traveling:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      case OrderStatus.arrived:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        );
      case OrderStatus.working:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );
      case OrderStatus.completed:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case OrderStatus.cancelled:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  /// Get marker color for order status (for custom marker creation)
  static Color getColorForOrderStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.traveling:
        return Colors.cyan;
      case OrderStatus.arrived:
        return Colors.purple;
      case OrderStatus.working:
        return Colors.amber;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  /// Get bounds that contain all the given locations
  static LatLngBounds? getBoundsForLocations(List<LatLng> locations) {
    if (locations.isEmpty) return null;
    if (locations.length == 1) {
      // Create small bounds around single location
      final loc = locations.first;
      return LatLngBounds(
        southwest: LatLng(loc.latitude - 0.01, loc.longitude - 0.01),
        northeast: LatLng(loc.latitude + 0.01, loc.longitude + 0.01),
      );
    }

    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLng = locations.first.longitude;
    double maxLng = locations.first.longitude;

    for (final location in locations) {
      if (location.latitude < minLat) minLat = location.latitude;
      if (location.latitude > maxLat) maxLat = location.latitude;
      if (location.longitude < minLng) minLng = location.longitude;
      if (location.longitude > maxLng) maxLng = location.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Default camera position for Cairo, Egypt
  static const LatLng defaultCairoLocation = LatLng(30.0444, 31.2357);

  static const CameraPosition defaultCameraPosition = CameraPosition(
    target: defaultCairoLocation,
    zoom: 12,
  );
}
