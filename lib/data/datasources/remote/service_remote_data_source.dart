// Service remote data source implementation using Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../models/service_model.dart';
import '../../../services/locale_provider.dart';
import 'i_service_remote_data_source.dart';

/// Implementation of [IServiceRemoteDataSource] using Firestore.
class ServiceRemoteDataSource implements IServiceRemoteDataSource {
  final FirebaseFirestore _firestore;

  ServiceRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _servicesCollection =>
      _firestore.collection(FirestoreCollections.services);

  @override
  Future<List<ServiceModel>> getAllServices({String? languageCode}) async {
    try {
      final snapshot = await _servicesCollection.get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => ServiceModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
      }
      return _loadLocalServices(languageCode: languageCode);
    } catch (e) {
      // Fallback to local data on error or if offline
      return _loadLocalServices(languageCode: languageCode);
    }
  }

  Future<List<ServiceModel>> _loadLocalServices({String? languageCode}) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/fixawy_services.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      // Auto-detect locale if not provided - use LocaleProvider for app locale
      final effectiveLocale =
          languageCode ?? LocaleProvider.currentLanguageCode;
      final isArabic = effectiveLocale == 'ar';

      return jsonList.map((json) {
        // Use Arabic name/description if available and locale is Arabic
        final name = isArabic && json['nameAr'] != null
            ? json['nameAr']
            : json['name'];
        final description = isArabic && json['descriptionAr'] != null
            ? json['descriptionAr']
            : json['description'];

        return ServiceModel(
          id: json['id'],
          name: name,
          description: description,
          iconUrl: json['imageUrl'], // Use the high-quality image URL
          category: name, // Category is the service name itself in this dataset
          avgPrice: 150.0, // Default values
          minPrice: 50.0,
          maxPrice: 300.0,
          visitFee: 50.0,
          avgCompletionTimeMinutes: 60,
          isActive: true,
          createdAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      // If even local loading fails, return empty list
      return [];
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
    return _servicesCollection.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => ServiceModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
      }
      return await _loadLocalServices();
    });
  }
}
