/// Service repository implementation using Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/i_order_repository.dart'; // For PaginatedResult
import '../../domain/repositories/i_service_repository.dart';
import '../../services/cache_service.dart';

/// Implementation of [IServiceRepository] using Firestore.
class ServiceRepositoryImpl implements IServiceRepository {
  final FirebaseFirestore _db;

  ServiceRepositoryImpl({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<ServiceEntity>> getServices() {
    return _db
        .collection('services')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _mapToServiceEntity(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<Either<Failure, PaginatedResult<ServiceEntity>>> getServicesPaginated({
    String? startAfterCursor,
    int limit = 20,
    String? category,
    String? searchQuery,
  }) async {
    try {
      Query query = _db
          .collection('services')
          .where('isActive', isEqualTo: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      query = query.orderBy('name');
      query = query.limit(limit + 1);

      if (startAfterCursor != null && startAfterCursor.isNotEmpty) {
        final startAfterDoc = await _db
            .collection('services')
            .doc(startAfterCursor)
            .get();
        if (startAfterDoc.exists) {
          query = query.startAfterDocument(startAfterDoc);
        }
      }

      final snapshot = await query.get();
      final docs = snapshot.docs;
      final hasMore = docs.length > limit;
      var items = docs.take(limit).map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _mapToServiceEntity(doc.id, data);
      }).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        items = items.where((service) {
          return service.name.toLowerCase().contains(lowerQuery) ||
              service.description.toLowerCase().contains(lowerQuery);
        }).toList();
      }

      final nextCursor = hasMore && items.isNotEmpty ? items.last.id : null;

      return Right(
        PaginatedResult<ServiceEntity>(
          items: items,
          hasMore: hasMore,
          nextCursor: nextCursor,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get services: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServicesWithCache({
    bool forceRefresh = false,
  }) async {
    final cacheService = CacheService();

    if (!forceRefresh) {
      final cachedData = await cacheService.getCachedCategories();
      if (cachedData != null) {
        return Right(
          cachedData
              .map(
                (json) =>
                    _mapToServiceEntity(json['id'] as String? ?? '', json),
              )
              .toList(),
        );
      }
    }

    try {
      final snapshot = await _db
          .collection('services')
          .where('isActive', isEqualTo: true)
          .get();

      final services = snapshot.docs
          .map((doc) => _mapToServiceEntity(doc.id, doc.data()))
          .toList();

      // Cache the data
      await cacheService.cacheCategories(
        services.map((s) => _serviceEntityToMap(s)).toList(),
      );

      return Right(services);
    } catch (e) {
      debugPrint('Error fetching services: $e');
      return Left(ServerFailure('Failed to get services: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addService(ServiceEntity service) async {
    try {
      await _db
          .collection('services')
          .doc(service.id)
          .set(_serviceEntityToMap(service));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add service: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateService(ServiceEntity service) async {
    try {
      await _db
          .collection('services')
          .doc(service.id)
          .update(_serviceEntityToMap(service));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update service: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(String serviceId) async {
    try {
      await _db.collection('services').doc(serviceId).update({
        'isActive': false,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete service: $e'));
    }
  }

  // Helper methods for entity mapping
  ServiceEntity _mapToServiceEntity(String id, Map<String, dynamic> data) {
    return ServiceEntity(
      id: id.isNotEmpty ? id : (data['id'] as String? ?? ''),
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      category: data['category'] ?? '',
      avgPrice: (data['avgPrice'] as num?)?.toDouble() ?? 0.0,
      minPrice: (data['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (data['maxPrice'] as num?)?.toDouble() ?? 0.0,
      visitFee: (data['visitFee'] as num?)?.toDouble() ?? 0.0,
      avgCompletionTimeMinutes: data['avgCompletionTimeMinutes'] ?? 60,
      isActive: data['isActive'] ?? true,
      createdAt: _parseTimestamp(data['createdAt']),
    );
  }

  Map<String, dynamic> _serviceEntityToMap(ServiceEntity service) {
    return {
      'id': service.id,
      'name': service.name,
      'description': service.description,
      'iconUrl': service.iconUrl,
      'category': service.category,
      'avgPrice': service.avgPrice,
      'minPrice': service.minPrice,
      'maxPrice': service.maxPrice,
      'visitFee': service.visitFee,
      'avgCompletionTimeMinutes': service.avgCompletionTimeMinutes,
      'isActive': service.isActive,
      'createdAt': Timestamp.fromDate(service.createdAt),
    };
  }

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
