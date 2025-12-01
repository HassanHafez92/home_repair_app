import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:home_repair_app/domain/repositories/i_service_repository.dart';
import 'package:home_repair_app/models/service_model.dart';
import 'package:home_repair_app/models/paginated_result.dart';
import 'package:home_repair_app/services/cache_service.dart';

class ServiceRepositoryImpl implements IServiceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<List<ServiceModel>> getServices() {
    return _db
        .collection('services')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ServiceModel.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Future<PaginatedResult<ServiceModel>> getServicesPaginated({
    String? startAfterCursor,
    int limit = 20,
    String? category,
    String? searchQuery,
  }) async {
    Query query = _db.collection('services').where('isActive', isEqualTo: true);

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
    final items = docs.take(limit).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ServiceModel.fromJson({...data, 'id': doc.id});
    }).toList();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      final filtered = items.where((service) {
        return service.name.toLowerCase().contains(lowerQuery) ||
            service.description.toLowerCase().contains(lowerQuery);
      }).toList();

      return PaginatedResult<ServiceModel>(
        items: filtered,
        hasMore: hasMore,
        nextCursor: hasMore && items.isNotEmpty ? items.last.id : null,
      );
    }

    final nextCursor = hasMore && items.isNotEmpty ? items.last.id : null;

    return PaginatedResult<ServiceModel>(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  @override
  Future<List<ServiceModel>> getServicesWithCache({
    bool forceRefresh = false,
  }) async {
    final cacheService = CacheService();

    if (!forceRefresh) {
      final cachedData = await cacheService.getCachedCategories();
      if (cachedData != null) {
        return cachedData.map((json) => ServiceModel.fromJson(json)).toList();
      }
    }

    try {
      final snapshot = await _db
          .collection('services')
          .where('isActive', isEqualTo: true)
          .get();

      final services = snapshot.docs
          .map((doc) => ServiceModel.fromJson(doc.data()))
          .toList();

      await cacheService.cacheCategories(
        services.map((s) => s.toJson()).toList(),
      );

      return services;
    } catch (e) {
      debugPrint('Error fetching services: $e');
      return [];
    }
  }

  @override
  Future<void> addService(ServiceModel service) async {
    await _db.collection('services').doc(service.id).set(service.toJson());
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    await _db.collection('services').doc(service.id).update(service.toJson());
  }

  @override
  Future<void> deleteService(String serviceId) async {
    await _db.collection('services').doc(serviceId).update({'isActive': false});
  }
}
