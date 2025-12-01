// File: lib/services/search_service.dart
// Purpose: Search functionality with Firestore queries

import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/exceptions.dart';

/// Search result wrapper class
class SearchResult<T> {
  final List<T> items;
  final int totalCount;
  final String? nextCursor;

  SearchResult({required this.items, this.totalCount = 0, this.nextCursor});

  bool get hasMore => nextCursor != null;
}

/// Service for handling search operations
class SearchService {
  static final SearchService _instance = SearchService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Search configuration
  static const int defaultPageSize = 20;

  SearchService._internal();

  factory SearchService() {
    return _instance;
  }

  /// Search documents in a collection by text fields
  Future<List<Map<String, dynamic>>> searchCollection(
    String collectionName,
    String query, {
    List<String> searchFields = const ['name', 'title', 'description'],
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
    int limit = defaultPageSize,
  }) async {
    try {
      if (query.isEmpty) {
        return _getCollectionByFilters(
          collectionName,
          filters: filters,
          orderBy: orderBy,
          descending: descending,
          limit: limit,
        );
      }

      return await _searchByText(
        collectionName,
        query,
        searchFields: searchFields,
        filters: filters,
        orderBy: orderBy,
        descending: descending,
        limit: limit,
      );
    } catch (e) {
      throw NetworkException('Failed to search in $collectionName: $e');
    }
  }

  /// Get trending items (most popular by bookingCount/viewCount)
  Future<List<Map<String, dynamic>>> getTrendingItems(
    String collectionName, {
    String countField = 'bookingCount',
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .orderBy(countField, descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw FirestoreException('Failed to fetch trending items: $e');
    }
  }

  /// Get top rated items
  Future<List<Map<String, dynamic>>> getTopRatedItems(
    String collectionName, {
    double minRating = 4.0,
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('rating', isGreaterThan: minRating)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw FirestoreException('Failed to fetch top rated items: $e');
    }
  }

  /// Search by single field value
  Future<List<Map<String, dynamic>>> searchByField(
    String collectionName,
    String fieldName,
    dynamic fieldValue, {
    int limit = defaultPageSize,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where(fieldName, isEqualTo: fieldValue)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw FirestoreException('Failed to search by field: $e');
    }
  }

  /// Search by rating range
  Future<List<Map<String, dynamic>>> searchByRatingRange(
    String collectionName, {
    required double minRating,
    required double maxRating,
    int limit = defaultPageSize,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('rating', isGreaterThanOrEqualTo: minRating)
          .where('rating', isLessThanOrEqualTo: maxRating)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw FirestoreException('Failed to search by rating range: $e');
    }
  }

  /// Get recent items
  Future<List<Map<String, dynamic>>> getRecentItems(
    String collectionName, {
    String timestampField = 'createdAt',
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .orderBy(timestampField, descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw FirestoreException('Failed to fetch recent items: $e');
    }
  }

  /// Search by location with radius
  Future<List<Map<String, dynamic>>> searchByLocation(
    String collectionName,
    double latitude,
    double longitude, {
    double radiusKm = 25,
    String latField = 'location.latitude',
    String lonField = 'location.longitude',
    int limit = defaultPageSize,
  }) async {
    try {
      // Approximate radius in degrees (1 degree ≈ 111 km)
      final radiusDegrees = radiusKm / 111;

      final snapshot = await _firestore
          .collection(collectionName)
          .where(latField, isGreaterThan: latitude - radiusDegrees)
          .where(latField, isLessThan: latitude + radiusDegrees)
          .limit(limit * 2)
          .get();

      final results = snapshot.docs.map((doc) => doc.data()).toList();

      // Filter by longitude and sort by distance
      return _filterAndSortByDistance(
        results,
        latitude,
        longitude,
        radiusKm,
        lonField,
      );
    } catch (e) {
      throw NetworkException('Failed to search by location: $e');
    }
  }

  /// Text-based search (case-insensitive)
  Future<List<Map<String, dynamic>>> _searchByText(
    String collectionName,
    String query, {
    List<String> searchFields = const ['name'],
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
    int limit = defaultPageSize,
  }) async {
    final lowerQuery = query.toLowerCase();

    var baseQuery = _firestore.collection(collectionName) as Query;

    // Apply filters
    if (filters != null) {
      filters.forEach((key, value) {
        baseQuery = baseQuery.where(key, isEqualTo: value);
      });
    }

    final snapshot = await baseQuery.limit(limit * 2).get();

    final results = snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .where((doc) {
          // Check if any search field contains the query
          return searchFields.any((field) {
            final value = doc[field]?.toString().toLowerCase() ?? '';
            return value.contains(lowerQuery);
          });
        })
        .take(limit)
        .toList();

    // Sort if orderBy is specified
    if (orderBy != null && results.isNotEmpty) {
      results.sort((a, b) {
        final aVal = a[orderBy] as Comparable?;
        final bVal = b[orderBy] as Comparable?;
        if (aVal == null || bVal == null) return 0;
        final comparison = aVal.compareTo(bVal);
        return descending ? -comparison : comparison;
      });
    }

    return results;
  }

  /// Get collection items filtered
  Future<List<Map<String, dynamic>>> _getCollectionByFilters(
    String collectionName, {
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
    int limit = defaultPageSize,
  }) async {
    var query = _firestore.collection(collectionName) as Query;

    // Apply filters
    if (filters != null) {
      filters.forEach((key, value) {
        query = query.where(key, isEqualTo: value);
      });
    }

    // Apply ordering
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    final snapshot = await query.limit(limit).get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  /// Filter items by distance and sort
  List<Map<String, dynamic>> _filterAndSortByDistance(
    List<Map<String, dynamic>> items,
    double latitude,
    double longitude,
    double radiusKm,
    String lonField,
  ) {
    return items.where((item) {
      final lon = item[lonField] as double?;
      if (lon == null) return false;
      final distance = _calculateDistance(
        latitude,
        longitude,
        latitude, // Note: approximate without full location data
        lon,
      );
      return distance <= radiusKm;
    }).toList()..sort((a, b) {
      final lonA = a[lonField] as double? ?? 0;
      final lonB = b[lonField] as double? ?? 0;
      final distanceA = _calculateDistance(latitude, longitude, latitude, lonA);
      final distanceB = _calculateDistance(latitude, longitude, latitude, lonB);
      return distanceA.compareTo(distanceB);
    });
  }

  /// Calculate distance between two coordinates (simplified)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadian(lat2 - lat1);
    final dLon = _toRadian(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadian(lat1)) *
            math.cos(_toRadian(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Convert degrees to radians
  double _toRadian(double degree) => degree * math.pi / 180;
}
