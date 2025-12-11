// Service remote data source implementation using Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../models/service_model.dart';
import 'i_service_remote_data_source.dart';

/// Implementation of [IServiceRemoteDataSource] using Firestore.
class ServiceRemoteDataSource implements IServiceRemoteDataSource {
  final FirebaseFirestore _firestore;

  ServiceRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _servicesCollection =>
      _firestore.collection(FirestoreCollections.services);

  @override
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final snapshot = await _servicesCollection.get();
      return snapshot.docs
          .map((doc) => ServiceModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get services: $e');
    }
  }

  @override
  Future<ServiceModel> getService(String serviceId) async {
    try {
      final doc = await _servicesCollection.doc(serviceId).get();
      if (!doc.exists) {
        throw NotFoundException('Service not found: $serviceId');
      }
      return ServiceModel.fromJson({...doc.data()!, 'id': doc.id});
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get service: $e');
    }
  }

  @override
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    try {
      final snapshot = await _servicesCollection
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) => ServiceModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get services by category: $e');
    }
  }

  @override
  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      // Firestore doesn't support full-text search, so we use a prefix match
      final queryLower = query.toLowerCase();
      final snapshot = await _servicesCollection.get();

      return snapshot.docs
          .map((doc) => ServiceModel.fromJson({...doc.data(), 'id': doc.id}))
          .where(
            (service) =>
                service.name.toLowerCase().contains(queryLower) ||
                service.description.toLowerCase().contains(queryLower),
          )
          .toList();
    } catch (e) {
      throw ServerException('Failed to search services: $e');
    }
  }

  @override
  Stream<List<ServiceModel>> watchServices() {
    return _servicesCollection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => ServiceModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList(),
    );
  }
}
