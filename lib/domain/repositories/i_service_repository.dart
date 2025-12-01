import 'package:home_repair_app/models/service_model.dart';
import 'package:home_repair_app/models/paginated_result.dart';

abstract class IServiceRepository {
  Stream<List<ServiceModel>> getServices();

  Future<PaginatedResult<ServiceModel>> getServicesPaginated({
    String? startAfterCursor,
    int limit = 20,
    String? category,
    String? searchQuery,
  });

  Future<List<ServiceModel>> getServicesWithCache({bool forceRefresh = false});

  Future<void> addService(ServiceModel service);

  Future<void> updateService(ServiceModel service);

  Future<void> deleteService(String serviceId);
}
