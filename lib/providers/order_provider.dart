// File: lib/providers/order_provider.dart
// Purpose: Manage order state for customers and technicians.

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<OrderModel> _myOrders = [];
  List<OrderModel> _incomingOrders = [];
  StreamSubscription? _ordersSubscription;
  StreamSubscription? _incomingSubscription;

  bool _isLoading = false;

  OrderProvider(this._firestoreService);

  List<OrderModel> get myOrders => _myOrders;
  List<OrderModel> get incomingOrders => _incomingOrders;
  bool get isLoading => _isLoading;

  // --- Customer Methods ---

  void listenToCustomerOrders(String userId) {
    _cancelSubscriptions();
    _isLoading = true;
    notifyListeners();

    _ordersSubscription = _firestoreService
        .getUserOrders(userId)
        .listen(
          (orders) {
            _myOrders = orders;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error listening to customer orders: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // --- Technician Methods ---

  void listenToTechnicianOrders(String technicianId) {
    _cancelSubscriptions();
    _isLoading = true;
    notifyListeners();

    // Listen to active/completed jobs assigned to this technician
    _ordersSubscription = _firestoreService
        .getUserOrders(technicianId, isTechnician: true)
        .listen((orders) {
          _myOrders = orders;
          notifyListeners();
        });

    // Listen to pending orders available for pickup
    _incomingSubscription = _firestoreService
        .streamPendingOrdersForTechnician()
        .listen((orders) {
          _incomingOrders = orders;
          notifyListeners();
        });

    _isLoading = false;
    notifyListeners();
  }

  // --- Common Methods ---

  Future<void> createOrder(OrderModel order) async {
    try {
      await _firestoreService.createOrder(order);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, OrderStatus.cancelled);
    } catch (e) {
      rethrow;
    }
  }

  void _cancelSubscriptions() {
    _ordersSubscription?.cancel();
    _incomingSubscription?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
