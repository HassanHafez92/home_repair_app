// File: lib/services/order_firestore_service.dart
// Purpose: Handles all order-related Firestore operations.
// Extracted from FirestoreService for better separation of concerns.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/paginated_result.dart';
import '../models/technician_stats.dart';

/// Service class that handles all order-related Firestore operations.
///
/// This service provides methods for:
/// - Order CRUD operations
/// - Order status management
/// - Pagination and filtering
/// - Technician statistics
///
/// ## Usage Example
///
/// ```dart
/// final orderService = OrderFirestoreService();
///
/// // Get paginated orders for a customer
/// final result = await orderService.getCustomerOrdersPaginated(
///   customerId: 'customer123',
///   limit: 10,
/// );
/// print('Found ${result.items.length} orders');
/// ```
@Deprecated(
  'Use IOrderRepository from domain layer instead. '
  'This service is being phased out as part of Clean Architecture migration. '
  'See: lib/domain/repositories/i_order_repository.dart',
)
class OrderFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== Order CRUD Operations ==========

  /// Retrieves an order by its unique ID.
  ///
  /// **Parameters:**
  /// - [orderId]: The unique identifier of the order.
  ///
  /// **Returns:** The order model, or `null` if not found.
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

  /// Creates a new order with denormalized data.
  ///
  /// Automatically fetches and denormalizes:
  /// - Service name from the services collection
  /// - Customer name and phone from the users collection
  ///
  /// **Parameters:**
  /// - [order]: The order model to create.
  ///
  /// **Returns:** The generated order ID.
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
      paymentMethod: order.paymentMethod,
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

  // ========== Order Status Updates ==========

  /// Assigns a technician to an order.
  ///
  /// **Parameters:**
  /// - [orderId]: The order to assign.
  /// - [technicianId]: The technician being assigned.
  /// - [estimate]: The technician's price estimate.
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

  /// Marks an order as completed.
  ///
  /// **Parameters:**
  /// - [orderId]: The order to complete.
  /// - [finalPrice]: The final price charged.
  /// - [notes]: Optional completion notes.
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

  /// Rejects/cancels an order with a reason.
  ///
  /// **Parameters:**
  /// - [orderId]: The order to reject.
  /// - [reason]: The reason for rejection.
  Future<void> rejectOrder(String orderId, String reason) async {
    await _db.collection('orders').doc(orderId).update({
      'status': 'cancelled',
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates an order's status.
  ///
  /// **Parameters:**
  /// - [orderId]: The order to update.
  /// - [status]: The new status.
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ========== Order Queries ==========

  /// Gets paginated orders for a customer.
  ///
  /// **Parameters:**
  /// - [customerId]: The customer's unique identifier.
  /// - [startAfterCursor]: Order ID to start after for pagination.
  /// - [limit]: Maximum number of orders to return.
  /// - [statusFilter]: Optional status filter.
  ///
  /// **Returns:** Paginated result with orders and pagination info.
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

  /// Streams orders for a specific user.
  ///
  /// **Parameters:**
  /// - [userId]: The user's unique identifier.
  /// - [isTechnician]: If true, gets orders assigned to technician.
  ///   If false, gets orders created by customer.
  Stream<List<OrderModel>> getUserOrders(
    String userId, {
    bool isTechnician = false,
  }) {
    Query query = _db.collection('orders');

    if (isTechnician) {
      query = query.where('technicianId', isEqualTo: userId);
    } else {
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

  /// Streams pending orders available for technicians to accept.
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

  /// Streams all orders (for admin dashboard).
  ///
  /// Limited to 100 most recent orders.
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

  // ========== Technician Statistics ==========

  /// Gets comprehensive statistics for a technician.
  ///
  /// Includes today's earnings, completed jobs, ratings, etc.
  ///
  /// **Parameters:**
  /// - [technicianId]: The technician's unique identifier.
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

      // Count total completed jobs
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

  /// Streams technician statistics in real-time.
  ///
  /// Updates when the technician's orders change.
  Stream<TechnicianStats> streamTechnicianStats(String technicianId) async* {
    yield await getTechnicianStats(technicianId);

    await for (final _
        in _db
            .collection('orders')
            .where('technicianId', isEqualTo: technicianId)
            .snapshots()) {
      yield await getTechnicianStats(technicianId);
    }
  }

  // ========== Utility Methods ==========

  /// Generates a unique Firestore document ID for orders.
  String generateId() => _db.collection('orders').doc().id;
}
