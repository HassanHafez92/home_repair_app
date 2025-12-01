// File: lib/utils/geocoding_utils.dart
// Purpose: Enhanced geocoding utilities with Arabic support and RTL formatting

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeocodingUtils {
  // Cache for recent geocoding results to reduce API calls
  static final Map<String, String> _geocodingCache = {};
  static const int _maxCacheSize = 50;

  /// Get address from coordinates with Arabic locale preference
  ///
  /// Returns address in the specified locale if available.
  /// Falls back to any available locale if preferred locale not found.
  static Future<String> getAddressFromLocation(
    LatLng location, {
    String preferredLocale = 'ar', // Arabic by default
    bool useCache = true,
  }) async {
    final String cacheKey =
        '${location.latitude},${location.longitude},$preferredLocale';

    // Check cache first
    if (useCache && _geocodingCache.containsKey(cacheKey)) {
      return _geocodingCache[cacheKey]!;
    }

    try {
      // Get placemarks with locale preference
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
        localeIdentifier: preferredLocale,
      );

      if (placemarks.isEmpty) {
        return 'Unknown location';
      }

      final String address = formatPlacemarkAddress(placemarks.first);

      // Cache the result
      _cacheAddress(cacheKey, address);

      return address;
    } catch (e) {
      debugPrint('Error getting address: $e');

      // Try without locale specification as fallback
      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isEmpty) {
          return 'Unable to get address';
        }

        final String address = formatPlacemarkAddress(placemarks.first);
        _cacheAddress(cacheKey, address);
        return address;
      } catch (fallbackError) {
        debugPrint('Fallback geocoding also failed: $fallbackError');
        return 'Error getting address';
      }
    }
  }

  /// Get bilingual address (Arabic and English) when available
  static Future<BilingualAddress> getBilingualAddress(LatLng location) async {
    String? arabicAddress;
    String? englishAddress;

    try {
      // Get Arabic address
      arabicAddress = await getAddressFromLocation(
        location,
        preferredLocale: 'ar',
        useCache: true,
      );
    } catch (e) {
      debugPrint('Error getting Arabic address: $e');
    }

    try {
      // Get English address
      englishAddress = await getAddressFromLocation(
        location,
        preferredLocale: 'en',
        useCache: true,
      );
    } catch (e) {
      debugPrint('Error getting English address: $e');
    }

    return BilingualAddress(
      arabic: arabicAddress ?? englishAddress ?? 'Unknown location',
      english: englishAddress ?? arabicAddress ?? 'Unknown location',
    );
  }

  /// Format placemark into readable address string
  static String formatPlacemarkAddress(Placemark placemark) {
    final List<String> addressParts = [];

    // Add street
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      addressParts.add(placemark.street!);
    }

    // Add sub-locality
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      addressParts.add(placemark.subLocality!);
    }

    // Add locality (city)
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      addressParts.add(placemark.locality!);
    }

    // Add administrative area if locality not available
    if (addressParts.length < 2 &&
        placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      addressParts.add(placemark.administrativeArea!);
    }

    return addressParts.isEmpty ? 'Unknown location' : addressParts.join(', ');
  }

  /// Format address for RTL display
  ///
  /// Ensures proper text direction for Arabic addresses
  static String formatForRTL(String address) {
    // Add RTL mark at the beginning for proper display
    const String rtlMark = '\u200F';
    return '$rtlMark$address';
  }

  /// Get compact address (first 2-3 components)
  static String getCompactAddress(Placemark placemark) {
    final List<String> parts = [];

    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }

    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    } else if (placemark.subLocality != null &&
        placemark.subLocality!.isNotEmpty) {
      parts.add(placemark.subLocality!);
    }

    return parts.isEmpty ? 'Unknown' : parts.join(', ');
  }

  /// Clear geocoding cache
  static void clearCache() {
    _geocodingCache.clear();
  }

  /// Add address to cache with size limit
  static void _cacheAddress(String key, String address) {
    if (_geocodingCache.length >= _maxCacheSize) {
      // Remove oldest entry (first key)
      _geocodingCache.remove(_geocodingCache.keys.first);
    }
    _geocodingCache[key] = address;
  }

  /// Get coordinates from address string
  static Future<LatLng?> getLocationFromAddress(
    String address, {
    String? locale,
  }) async {
    try {
      final List<Location> locations = await locationFromAddress(address);

      if (locations.isEmpty) {
        return null;
      }

      return LatLng(locations.first.latitude, locations.first.longitude);
    } catch (e) {
      debugPrint('Error getting location from address: $e');
      return null;
    }
  }

  /// Validate if coordinates are within reasonable bounds
  static bool isValidLocation(LatLng location) {
    return location.latitude >= -90 &&
        location.latitude <= 90 &&
        location.longitude >= -180 &&
        location.longitude <= 180;
  }

  /// Check if location is approximately in Egypt
  static bool isInEgypt(LatLng location) {
    // Approximate bounds for Egypt
    const double minLat = 22.0;
    const double maxLat = 32.0;
    const double minLng = 25.0;
    const double maxLng = 36.0;

    return location.latitude >= minLat &&
        location.latitude <= maxLat &&
        location.longitude >= minLng &&
        location.longitude <= maxLng;
  }
}

/// Data class for bilingual address information
class BilingualAddress {
  final String arabic;
  final String english;

  BilingualAddress({required this.arabic, required this.english});

  /// Get address in the specified locale
  String getForLocale(String locale) {
    return locale.startsWith('ar') ? arabic : english;
  }

  @override
  String toString() => 'BilingualAddress(ar: $arabic, en: $english)';
}
