/// Service repository interface for Clean Architecture.

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/service_entity.dart';
import 'i_order_repository.dart'; // For PaginatedResult

/// Repository interface for service operations.
abstract class IServiceRepository {
  /// Streams all services.
  Stream<List<ServiceEntity>> getServices();

  /// Gets paginated services.
  Future<Either<Failure, PaginatedResult<ServiceEntity>>> getServicesPaginated({
    String? startAfterCursor,
    int limit = 20,
    String? category,
    String? searchQuery,
  });

  /// Gets services with optional cache.
  Future<Either<Failure, List<ServiceEntity>>> getServicesWithCache({
    bool forceRefresh = false,
  });

  /// Adds a new service.
  Future<Either<Failure, void>> addService(ServiceEntity service);

  /// Updates an existing service.
  Future<Either<Failure, void>> updateService(ServiceEntity service);

  /// Deletes a service.
  Future<Either<Failure, void>> deleteService(String serviceId);
}
