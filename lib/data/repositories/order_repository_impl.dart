import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:home_repair_app/domain/repositories/i_order_repository.dart';
import 'package:home_repair_app/models/order_model.dart';
import 'package:home_repair_app/models/paginated_result.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
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

  @override
  Future<String> createOrder(OrderModel order) async {
    final docRef = _db.collection('orders').doc();
    final orderId = docRef.id;

    String? serviceName = order.serviceName;
    String? customerName = order.customerName;
    String? customerPhoneNumber = order.customerPhoneNumber;

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

  @override
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

  @override
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

  @override
  Future<void> rejectOrder(String orderId, String reason) async {
    await _db.collection('orders').doc(orderId).update({
      'status': 'cancelled',
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<PaginatedResult<OrderModel>> getCustomerOrdersPaginated({
    required String customerId,
    String? startAfterCursor,
    int limit = 20,
    OrderStatus? statusFilter,
  }) async {
    Query query = _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId);

    if (statusFilter != null) {
      query = query.where(
        'status',
        isEqualTo: statusFilter.toString().split('.').last,
      );
    }

    query = query.orderBy('dateRequested', descending: true);
    query = query.limit(limit + 1);

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
    final hasMore = docs.length > limit;
    final items = docs.take(limit).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return OrderModel.fromJson({...data, 'id': doc.id});
    }).toList();

    final nextCursor = hasMore && items.isNotEmpty ? items.last.id : null;

    return PaginatedResult<OrderModel>(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
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

  @override
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

  @override
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
}
