// File: lib/services/firestore_service.dart
// Purpose: Handles all Firestore database operations.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/customer_model.dart';
import '../models/technician_model.dart';
import '../models/service_model.dart';
import '../models/order_model.dart' hide OrderStatus;
import '../models/notification_model.dart';
import '../models/dashboard_stats.dart';
import '../models/technician_stats.dart';
import '../models/paginated_result.dart';
import '../domain/entities/order_entity.dart' show OrderStatus;
import 'cache_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Users ---

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;

      // Determine user role to parse into correct model
      final roleStr = data['role'] as String?;

      // Handle missing role field
      if (roleStr == null) {
        debugPrint(
          'FirestoreService: User document missing role field for uid: $uid',
        );
        return null;
      }

      if (roleStr == 'UserRole.customer' || roleStr == 'customer') {
        return CustomerModel.fromJson(data);
      } else if (roleStr == 'UserRole.technician' || roleStr == 'technician') {
        return TechnicianModel.fromJson(data);
      } else {
        return UserModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('FirestoreService: Error loading user $uid: $e');
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toJson());
  }

  // Helper for partial field updates
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    await _db.collection('users').doc(uid).update(fields);
  }

  // Helper to get user document
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // --- Services ---

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

  /// Get a single service by ID
  Future<ServiceModel?> getService(String serviceId) async {
    try {
      final doc = await _db.collection('services').doc(serviceId).get();
      if (!doc.exists || doc.data() == null) return null;
      return ServiceModel.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Error fetching service $serviceId: $e');
      return null;
    }
  }

  /// Get services with pagination support
  /// Returns PaginatedResult for better pagination control
  Future<PaginatedResult<ServiceModel>> getServicesPaginated({
    String? startAfterCursor,
    int limit = 20,
    String? category,
    String? searchQuery,
  }) async {
    Query query = _db.collection('services').where('isActive', isEqualTo: true);

    // Filter by category if provided
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    // Order by name for consistent pagination
    query = query.orderBy('name');

    // Fetch one extra to check if there are more items
    query = query.limit(limit + 1);

    // Start after cursor if provided
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

    // Check if there are more items
    final hasMore = docs.length > limit;
    final items = docs.take(limit).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ServiceModel.fromJson({...data, 'id': doc.id});
    }).toList();

    // Apply search filter locally if provided
    // (Firestore doesn't support case-insensitive text search well)
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

    // Get cursor for next page (ID of last item)
    final nextCursor = hasMore && items.isNotEmpty ? items.last.id : null;

    return PaginatedResult<ServiceModel>(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

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

  Future<void> addService(ServiceModel service) async {
    await _db.collection('services').doc(service.id).set(service.toJson());
  }

  Future<void> updateService(ServiceModel service) async {
    await _db.collection('services').doc(service.id).update(service.toJson());
  }

  Future<void> deleteService(String serviceId) async {
    // Soft delete by setting isActive to false
    await _db.collection('services').doc(serviceId).update({'isActive': false});
  }

  // --- Orders ---

  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _db.collection('orders').doc(orderId).get();
      if (!doc.exists || doc.data() == null) return null;
      return OrderModel.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Error fetching order $orderId: $e');
      return null;
    }
  }

  Future<String> createOrder(OrderModel order) async {
    // Generate a new document ID
    final docRef = _db.collection('orders').doc();
    final orderId = docRef.id;

    String? serviceName = order.serviceName;

    String? customerName = order.customerName;
    String? customerPhoneNumber = order.customerPhoneNumber;

    // Fetch names if missing (Denormalization)
    if (serviceName == null) {
      final serviceDoc = await _db
          .collection('services')
          .doc(order.serviceId)
          .get();
      if (serviceDoc.exists) {
        serviceName = serviceDoc.data()?['name'] as String?;
      }
    }

    if (customerName == null || customerPhoneNumber == null) {
      final userDoc = await _db.collection('users').doc(order.customerId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        customerName ??= userData?['name'] as String?;
        customerPhoneNumber ??= userData?['phoneNumber'] as String?;
      }
    }

    // Create order with the generated ID and denormalized data
    final orderWithId = OrderModel(
      id: orderId,
      customerId: order.customerId,
      serviceId: order.serviceId,
      status: order.status,
      description: order.description,
      address: order.address,
      location: order.location,
      dateRequested: order.dateRequested,
      dateScheduled: order.dateScheduled,
      initialEstimate: order.initialEstimate,
      visitFee: order.visitFee,
      vat: order.vat,
      customerPhoneNumber: customerPhoneNumber,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
      technicianId: order.technicianId,
      finalPrice: order.finalPrice,
      notes: order.notes,
      serviceName: serviceName,
      customerName: customerName,
    );

    await docRef.set(orderWithId.toJson());
    return orderId;
  }

  Future<void> assignTechnicianToOrder(
    String orderId,
    String technicianId,
    double estimate,
  ) async {
    await _db.collection('orders').doc(orderId).update({
      'technicianId': technicianId,
      'status': 'accepted',
      'initialEstimate': estimate,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeOrder(
    String orderId,
    double finalPrice,
    String? notes,
  ) async {
    await _db.collection('orders').doc(orderId).update({
      'status': 'completed',
      'finalPrice': finalPrice,
      'notes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectOrder(String orderId, String reason) async {
    await _db.collection('orders').doc(orderId).update({
      'status':
          'cancelled', // Using cancelled for now as there is no rejected status in enum
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get customer orders with pagination support
  /// Returns PaginatedResult for better pagination control
  Future<PaginatedResult<OrderModel>> getCustomerOrdersPaginated({
    required String customerId,
    String? startAfterCursor,
    int limit = 20,
    OrderStatus? statusFilter,
  }) async {
    Query query = _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId);

    // Filter by status if provided
    if (statusFilter != null) {
      query = query.where(
        'status',
        isEqualTo: statusFilter.toString().split('.').last,
      );
    }

    // Order by dateRequested for consistent pagination
    query = query.orderBy('dateRequested', descending: true);

    // Fetch one extra to check if there are more items
    query = query.limit(limit + 1);

    // Start after cursor if provided
    if (startAfterCursor != null && startAfterCursor.isNotEmpty) {
      final startAfterDoc = await _db
          .collection('orders')
          .doc(startAfterCursor)
          .get();
      if (startAfterDoc.exists) {
        query = query.startAfterDocument(startAfterDoc);
      }
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;

    // Check if there are more items
    final hasMore = docs.length > limit;
    final items = docs.take(limit).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return OrderModel.fromJson({...data, 'id': doc.id});
    }).toList();

    // Get cursor for next page (ID of last item)
    final nextCursor = hasMore && items.isNotEmpty ? items.last.id : null;

    return PaginatedResult<OrderModel>(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Streams orders for a specific user (customer or technician)
  /// When isTechnician is true, returns orders assigned to the technicianId
  /// When isTechnician is false, returns orders created by the customerId
  Stream<List<OrderModel>> getUserOrders(
    String userId, {
    bool isTechnician = false,
  }) {
    Query query = _db.collection('orders');

    if (isTechnician) {
      // Get orders assigned to this technician
      query = query.where('technicianId', isEqualTo: userId);
    } else {
      // Get orders created by this customer
      query = query.where('customerId', isEqualTo: userId);
    }

    return query
        .orderBy('dateRequested', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    OrderModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  /// Streams pending orders that are available for any technician to accept
  Stream<List<OrderModel>> streamPendingOrdersForTechnician() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .orderBy('dateRequested', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // --- Admin Methods ---

  Stream<List<TechnicianModel>> streamPendingTechnicians() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'technician')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TechnicianModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> updateTechnicianStatus(
    String uid,
    TechnicianStatus status,
  ) async {
    await _db.collection('users').doc(uid).update({
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Technician Dashboard Methods ---

  /// Updates technician availability status
  Future<void> updateTechnicianAvailability(
    String uid,
    bool isAvailable,
  ) async {
    await _db.collection('users').doc(uid).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Streams technician availability status
  Stream<bool> streamTechnicianAvailability(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return false;
      return snapshot.data()!['isAvailable'] as bool? ?? false;
    });
  }

  /// Gets comprehensive technician statistics
  Future<TechnicianStats> getTechnicianStats(String technicianId) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Get user document for rating
      final userDoc = await _db.collection('users').doc(technicianId).get();
      final rating = userDoc.data()?['rating'] as double? ?? 0.0;

      // Count pending orders (available for any technician)
      final pendingOrdersSnapshot = await _db
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      // Count active jobs (assigned to this technician, not completed)
      final activeJobsSnapshot = await _db
          .collection('orders')
          .where('technicianId', isEqualTo: technicianId)
          .where(
            'status',
            whereIn: ['accepted', 'traveling', 'arrived', 'working'],
          )
          .count()
          .get();

      //Count total completed jobs
      final completedJobsTotalSnapshot = await _db
          .collection('orders')
          .where('technicianId', isEqualTo: technicianId)
          .where('status', isEqualTo: 'completed')
          .count()
          .get();

      // Get today's completed orders for earnings and count
      final todayCompletedOrders = await _db
          .collection('orders')
          .where('technicianId', isEqualTo: technicianId)
          .where('status', isEqualTo: 'completed')
          .where(
            'updatedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
          )
          .where('updatedAt', isLessThan: Timestamp.fromDate(todayEnd))
          .get();

      double todayEarnings = 0.0;
      for (var doc in todayCompletedOrders.docs) {
        final order = OrderModel.fromJson(doc.data());
        todayEarnings += order.finalPrice ?? order.initialEstimate ?? 0.0;
      }

      return TechnicianStats(
        todayEarnings: todayEarnings,
        completedJobsToday: todayCompletedOrders.docs.length,
        completedJobsTotal: completedJobsTotalSnapshot.count ?? 0,
        rating: rating,
        pendingOrders: pendingOrdersSnapshot.count ?? 0,
        activeJobs: activeJobsSnapshot.count ?? 0,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error fetching technician stats: $e');
      return TechnicianStats.empty();
    }
  }

  /// Streams technician statistics (updates when orders change)
  Stream<TechnicianStats> streamTechnicianStats(String technicianId) async* {
    // This is a simplified version that polls periodically
    // In a production app, you might want to use Cloud Functions to aggregate
    // or listen to specific order changes

    yield await getTechnicianStats(technicianId);

    // Listen to technician's orders to trigger stats refresh
    await for (final _
        in _db
            .collection('orders')
            .where('technicianId', isEqualTo: technicianId)
            .snapshots()) {
      yield await getTechnicianStats(technicianId);
    }
  }

  Stream<List<OrderModel>> streamAllOrders() {
    return _db
        .collection('orders')
        .orderBy('dateRequested', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // --- Notifications ---

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // --- Generic ---

  Future<DashboardStats> getDashboardStats() async {
    // In a real app, this would be a Cloud Function or aggregation query
    // For now, we'll return mock data or simple counts
    try {
      final usersSnapshot = await _db.collection('users').count().get();
      final ordersSnapshot = await _db.collection('orders').count().get();
      final pendingOrdersSnapshot = await _db
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      // Count unverified users
      final unverifiedUsersSnapshot = await _db
          .collection('users')
          .where('emailVerified', isEqualTo: false)
          .count()
          .get();

      // Revenue calculation would require aggregation, mocking for now
      const totalRevenue = 154000.0;

      return DashboardStats(
        totalUsers: usersSnapshot.count ?? 0,
        activeOrders: ordersSnapshot.count ?? 0,
        totalRevenue: totalRevenue,
        pendingApprovals: pendingOrdersSnapshot.count ?? 0,
        unverifiedUsers: unverifiedUsersSnapshot.count ?? 0,
      );
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
      return DashboardStats.empty();
    }
  }

  // Helper to generate IDs
  String generateId() => _db.collection('tmp').doc().id;
}
