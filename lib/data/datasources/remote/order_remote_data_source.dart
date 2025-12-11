// Order remote data source implementation using Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../models/order_model.dart';
import '../../../models/paginated_result.dart';
import 'i_order_remote_data_source.dart';

/// Implementation of [IOrderRemoteDataSource] using Firestore.
class OrderRemoteDataSource implements IOrderRemoteDataSource {
  final FirebaseFirestore _firestore;

  OrderRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(FirestoreCollections.orders);

  @override
  Future<OrderModel> getOrder(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (!doc.exists) {
        throw NotFoundException('Order not found: $orderId');
      }
      return OrderModel.fromJson({...doc.data()!, 'id': doc.id});
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get order: $e');
    }
  }

  @override
  Future<PaginatedResult<OrderModel>> getCustomerOrders({
    required String customerId,
    int limit = 20,
    String? startAfterId,
    String? status,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _ordersCollection
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .limit(limit + 1); // Fetch one extra to check if there are more

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (startAfterId != null) {
        final startAfterDoc = await _ordersCollection.doc(startAfterId).get();
        if (startAfterDoc.exists) {
          query = query.startAfterDocument(startAfterDoc);
        }
      }

      final snapshot = await query.get();
      final orders = snapshot.docs
          .take(limit)
          .map((doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return PaginatedResult(
        items: orders,
        hasMore: snapshot.docs.length > limit,
        nextCursor: orders.isNotEmpty ? orders.last.id : null,
      );
    } catch (e) {
      throw ServerException('Failed to get customer orders: $e');
    }
  }

  @override
  Future<PaginatedResult<OrderModel>> getTechnicianOrders({
    required String technicianId,
    int limit = 20,
    String? startAfterId,
    String? status,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _ordersCollection
          .where('technicianId', isEqualTo: technicianId)
          .orderBy('createdAt', descending: true)
          .limit(limit + 1);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (startAfterId != null) {
        final startAfterDoc = await _ordersCollection.doc(startAfterId).get();
        if (startAfterDoc.exists) {
          query = query.startAfterDocument(startAfterDoc);
        }
      }

      final snapshot = await query.get();
      final orders = snapshot.docs
          .take(limit)
          .map((doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return PaginatedResult(
        items: orders,
        hasMore: snapshot.docs.length > limit,
        nextCursor: orders.isNotEmpty ? orders.last.id : null,
      );
    } catch (e) {
      throw ServerException('Failed to get technician orders: $e');
    }
  }

  @override
  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = await _ordersCollection.add({
        ...order.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw ServerException('Failed to create order: $e');
    }
  }

  @override
  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    try {
      await _ordersCollection.doc(orderId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to update order: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to update order status: $e');
    }
  }

  @override
  Future<void> assignTechnician(String orderId, String technicianId) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'technicianId': technicianId,
        'status': 'confirmed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to assign technician: $e');
    }
  }

  @override
  Stream<OrderModel?> watchOrder(String orderId) {
    return _ordersCollection.doc(orderId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return OrderModel.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  @override
  Stream<List<OrderModel>> watchCustomerOrders(String customerId) {
    return _ordersCollection
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .limit(PaginationConstants.defaultPageSize)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  @override
  Stream<List<OrderModel>> watchTechnicianOrders(String technicianId) {
    return _ordersCollection
        .where('technicianId', isEqualTo: technicianId)
        .orderBy('createdAt', descending: true)
        .limit(PaginationConstants.defaultPageSize)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }
}
