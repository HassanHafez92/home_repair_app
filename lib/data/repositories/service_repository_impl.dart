// Service repository implementation using data sources.
//
// Implements offline-first pattern using local and remote data sources.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/i_order_repository.dart'; // For PaginatedResult
import '../../domain/repositories/i_service_repository.dart';
import '../../models/service_model.dart';
import '../datasources/local/service_local_data_source.dart';
import '../datasources/remote/i_service_remote_data_source.dart';

/// Implementation of [IServiceRepository] using data sources.
class ServiceRepositoryImpl implements IServiceRepository {
  final IServiceRemoteDataSource _remoteDataSource;
  final IServiceLocalDataSource _localDataSource;
  final INetworkInfo _networkInfo;
  final FirebaseFirestore _db;

  ServiceRepositoryImpl({
    required IServiceRemoteDataSource remoteDataSource,
    required IServiceLocalDataSource localDataSource,
    required INetworkInfo networkInfo,
    FirebaseFirestore? db,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<ServiceEntity>> getServices() {
    return _remoteDataSource.watchServices().map(
      (models) => models.map(_modelToEntity).toList(),
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<ServiceEntity>>> getServicesPaginated({
    String? startAfterCursor,
    int limit = 20,
    String? category,
    String? searchQuery,
    String? languageCode,
  }) async {
    try {
      List<ServiceModel> services;

      if (category != null && category.isNotEmpty) {
        services = await _remoteDataSource.getServicesByCategory(category);
      } else if (searchQuery != null && searchQuery.isNotEmpty) {
        services = await _remoteDataSource.searchServices(searchQuery);
      } else {
        services = await _remoteDataSource.getAllServices(
          languageCode: languageCode,
        );
      }

      // Apply pagination manually since data source returns all
      int startIndex = 0;
      if (startAfterCursor != null && startAfterCursor.isNotEmpty) {
        startIndex = services.indexWhere((s) => s.id == startAfterCursor) + 1;
        if (startIndex < 0) startIndex = 0;
      }

      final paginatedServices = services
          .skip(startIndex)
          .take(limit + 1)
          .toList();
      final hasMore = paginatedServices.length > limit;
      final items = paginatedServices.take(limit).map(_modelToEntity).toList();
      final nextCursor = hasMore && items.isNotEmpty ? items.last.id : null;

      return Right(
        PaginatedResult<ServiceEntity>(
          items: items,
          hasMore: hasMore,
          nextCursor: nextCursor,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to get services: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServicesWithCache({
    bool forceRefresh = false,
    String? languageCode,
  }) async {
    // Offline-first: check cache first
    if (!forceRefresh) {
      try {
        if (await _localDataSource.hasCachedServices()) {
          final cachedServices = await _localDataSource.getCachedServices();
          return Right(cachedServices.map(_modelToEntity).toList());
        }
      } on CacheException catch (e) {
        debugPrint('Cache miss: ${e.message}');
      }
    }

    // Check network connectivity
    if (!await _networkInfo.isConnected) {
      // Try to return cached data even if expired
      try {
        final cachedServices = await _localDataSource.getCachedServices();
        return Right(cachedServices.map(_modelToEntity).toList());
      } catch (_) {
        return const Left(NetworkFailure('No cached data available offline'));
      }
    }

    // Fetch from remote
    try {
      final services = await _remoteDataSource.getAllServices(
        languageCode: languageCode,
      );

      // Update cache
      await _localDataSource.cacheServices(services);

      return Right(services.map(_modelToEntity).toList());
    } on ServerException catch (e) {
      // Fallback to cache on server error
      try {
        final cachedServices = await _localDataSource.getCachedServices();
        return Right(cachedServices.map(_modelToEntity).toList());
      } catch (_) {
        return Left(ServerFailure(e.message, e.code));
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
      return Left(ServerFailure('Failed to get services: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addService(ServiceEntity service) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _db
          .collection('services')
          .doc(service.id)
          .set(_serviceEntityToMap(service));

      // Invalidate cache
      await _localDataSource.clearCache();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add service: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateService(ServiceEntity service) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _db
          .collection('services')
          .doc(service.id)
          .update(_serviceEntityToMap(service));

      // Invalidate cache
      await _localDataSource.clearCache();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update service: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(String serviceId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _db.collection('services').doc(serviceId).update({
        'isActive': false,
      });

      // Invalidate cache
      await _localDataSource.clearCache();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete service: $e'));
    }
  }

  // Helper methods for mapping
  ServiceEntity _modelToEntity(ServiceModel model) {
    return ServiceEntity(
      id: model.id,
      name: model.name,
      description: model.description,
      iconUrl: model.iconUrl,
      category: model.category,
      avgPrice: model.avgPrice,
      minPrice: model.minPrice,
      maxPrice: model.maxPrice,
      visitFee: model.visitFee,
      avgCompletionTimeMinutes: model.avgCompletionTimeMinutes,
      isActive: model.isActive,
      createdAt: model.createdAt,
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
}
