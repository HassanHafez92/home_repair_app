// File: lib/providers/service_provider.dart
// Purpose: Manage available services and categories.

import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/firestore_service.dart';

class ServiceProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;

  ServiceProvider(this._firestoreService);

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<String> get categories {
    return _services.map((s) => s.category).toSet().toList();
  }

  Future<void> fetchServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Note: In a real app with streams, we might listen to the stream instead.
      // For simplicity here, we'll fetch once or listen in the UI.
      // However, since FirestoreService.getServices returns a Stream, 
      // we can subscribe to it.
      
      _firestoreService.getServices().listen((servicesList) {
        _services = servicesList;
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      });
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ServiceModel> getServicesByCategory(String category) {
    return _services.where((s) => s.category == category).toList();
  }
  
  List<ServiceModel> searchServices(String query) {
    if (query.isEmpty) return _services;
    final lowerQuery = query.toLowerCase();
    return _services.where((s) => 
      s.name.toLowerCase().contains(lowerQuery) || 
      s.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}
