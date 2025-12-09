/// Order repository implementation using Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/i_order_repository.dart';

/// Implementation of [IOrderRepository] using Firestore.
class OrderRepositoryImpl implements IOrderRepository {
  final FirebaseFirestore _db;

  OrderRepositoryImpl({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, OrderEntity?>> getOrder(String orderId) async {
    try {
      final doc = await _db.collection('orders').doc(orderId).get();
      if (!doc.exists || doc.data() == null) {
        return const Right(null);
      }
      return Right(_mapToOrderEntity(orderId, doc.data()!));
    } catch (e) {
      debugPrint('Error fetching order $orderId: $e');
      return Left(ServerFailure('Failed to get order: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> createOrder(OrderEntity order) async {
    try {
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
        final userDoc = await _db
            .collection('users')
            .doc(order.customerId)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          customerName ??= userData?['fullName'] as String?;
          customerPhoneNumber ??= userData?['phoneNumber'] as String?;
        }
      }

      final orderData = _orderEntityToMap(
        order.copyWith(
          id: orderId,
          serviceName: serviceName,
          customerName: customerName,
          customerPhoneNumber: customerPhoneNumber,
        ),
      );

      await docRef.set(orderData);
      return Right(orderId);
    } catch (e) {
      return Left(ServerFailure('Failed to create order: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> assignTechnicianToOrder(
    String orderId,
    String technicianId,
    double estimate,
  ) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'technicianId': technicianId,
        'status': 'accepted',
        'initialEstimate': estimate,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to assign technician: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> completeOrder(
    String orderId,
    double finalPrice,
    String? notes,
  ) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': 'completed',
        'finalPrice': finalPrice,
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to complete order: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectOrder(
    String orderId,
    String reason,
  ) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to reject order: $e'));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<OrderEntity>>>
  getCustomerOrdersPaginated({
    required String customerId,
    String? startAfterCursor,
    int limit = 20,
    OrderStatus? statusFilter,
  }) async {
    try {
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
        return _mapToOrderEntity(doc.id, data);
      }).toList();

      final nextCursor = hasMore && items.isNotEmpty ? items.last.id : null;

      return Right(
        PaginatedResult<OrderEntity>(
          items: items,
          hasMore: hasMore,
          nextCursor: nextCursor,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get orders: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update order status: $e'));
    }
  }

  @override
  Stream<List<OrderEntity>> getUserOrders(
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
                (doc) => _mapToOrderEntity(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<List<OrderEntity>> streamPendingOrdersForTechnician() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .orderBy('dateRequested', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _mapToOrderEntity(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<OrderEntity>> streamAllOrders() {
    return _db
        .collection('orders')
        .orderBy('dateRequested', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _mapToOrderEntity(doc.id, doc.data()))
              .toList(),
        );
  }

  // Helper methods for entity mapping
  OrderEntity _mapToOrderEntity(String id, Map<String, dynamic> data) {
    return OrderEntity(
      id: id,
      customerId: data['customerId'] ?? '',
      technicianId: data['technicianId'],
      serviceId: data['serviceId'] ?? '',
      description: data['description'] ?? '',
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      location: Map<String, dynamic>.from(data['location'] ?? {}),
      address: data['address'] ?? '',
      dateRequested: _parseTimestamp(data['dateRequested']),
      dateScheduled: data['dateScheduled'] != null
          ? _parseTimestamp(data['dateScheduled'])
          : null,
      status: _parseOrderStatus(data['status']),
      initialEstimate: (data['initialEstimate'] as num?)?.toDouble(),
      finalPrice: (data['finalPrice'] as num?)?.toDouble(),
      visitFee: (data['visitFee'] as num?)?.toDouble() ?? 0.0,
      vat: (data['vat'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: data['paymentMethod'] ?? 'cash',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      notes: data['notes'],
      serviceName: data['serviceName'],
      customerName: data['customerName'],
      customerPhoneNumber: data['customerPhoneNumber'],
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> _orderEntityToMap(OrderEntity order) {
    return {
      'id': order.id,
      'customerId': order.customerId,
      'technicianId': order.technicianId,
      'serviceId': order.serviceId,
      'description': order.description,
      'photoUrls': order.photoUrls,
      'location': order.location,
      'address': order.address,
      'dateRequested': Timestamp.fromDate(order.dateRequested),
      'dateScheduled': order.dateScheduled != null
          ? Timestamp.fromDate(order.dateScheduled!)
          : null,
      'status': order.status.toString().split('.').last,
      'initialEstimate': order.initialEstimate,
      'finalPrice': order.finalPrice,
      'visitFee': order.visitFee,
      'vat': order.vat,
      'paymentMethod': order.paymentMethod,
      'paymentStatus': order.paymentStatus,
      'notes': order.notes,
      'serviceName': order.serviceName,
      'customerName': order.customerName,
      'customerPhoneNumber': order.customerPhoneNumber,
      'createdAt': Timestamp.fromDate(order.createdAt),
      'updatedAt': Timestamp.fromDate(order.updatedAt),
    };
  }

  OrderStatus _parseOrderStatus(String? status) {
    if (status == null) return OrderStatus.pending;
    switch (status) {
      case 'accepted':
        return OrderStatus.accepted;
      case 'traveling':
        return OrderStatus.traveling;
      case 'arrived':
        return OrderStatus.arrived;
      case 'working':
        return OrderStatus.working;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
