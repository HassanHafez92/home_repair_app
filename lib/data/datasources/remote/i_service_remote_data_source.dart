// Service remote data source interface.
//
// Defines the contract for service catalog operations with Firestore.

import '../../../models/service_model.dart';

/// Interface for remote service data operations.
abstract class IServiceRemoteDataSource {
  /// Gets all available services.
  ///
  /// [languageCode] - Optional language code (e.g., 'ar' for Arabic) for localized names.
  /// Throws [ServerException] on Firestore errors.
  Future<List<ServiceModel>> getAllServices({String? languageCode});

  /// Gets a service by ID.
  ///
  /// Throws [NotFoundException] if service doesn't exist.
  /// Throws [ServerException] on Firestore errors.
  Future<ServiceModel> getService(String serviceId);

  /// Gets services by category.
  ///
  /// Throws [ServerException] on Firestore errors.
  Future<List<ServiceModel>> getServicesByCategory(String category);

  /// Searches services by query.
  ///
  /// Throws [ServerException] on Firestore errors.
  Future<List<ServiceModel>> searchServices(String query);

  /// Stream of all services.
  Stream<List<ServiceModel>> watchServices();
}
