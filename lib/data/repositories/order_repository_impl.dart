// Order repository implementation using data sources.
//
// Delegates to order remote data source and handles exception-to-failure
// conversion for Clean Architecture.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../../models/order_model.dart' hide OrderStatus;
import '../datasources/remote/i_order_remote_data_source.dart';

/// Implementation of [IOrderRepository] using data sources.
class OrderRepositoryImpl implements IOrderRepository {
  final IOrderRemoteDataSource _remoteDataSource;
  final INetworkInfo _networkInfo;
  final FirebaseFirestore _db;

  OrderRepositoryImpl({
    required IOrderRemoteDataSource remoteDataSource,
    required INetworkInfo networkInfo,
    FirebaseFirestore? db,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo,
       _db = db ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, OrderEntity?>> getOrder(String orderId) async {
    try {
      final orderModel = await _remoteDataSource.getOrder(orderId);
      return Right(_modelToEntity(orderModel));
    } on NotFoundException {
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      debugPrint('Error fetching order $orderId: $e');
      return Left(ServerFailure('Failed to get order: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> createOrder(OrderEntity order) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      // Fetch service name and customer info if not provided
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

      final orderModel = _entityToModel(
        order.copyWith(
          serviceName: serviceName,
          customerName: customerName,
          customerPhoneNumber: customerPhoneNumber,
        ),
      );

      final orderId = await _remoteDataSource.createOrder(orderModel);
      return Right(orderId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
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
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.updateOrder(orderId, {
        'technicianId': technicianId,
        'status': 'accepted',
        'initialEstimate': estimate,
      });
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
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
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.updateOrder(orderId, {
        'status': 'completed',
        'finalPrice': finalPrice,
        'notes': notes,
      });
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to complete order: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectOrder(
    String orderId,
    String reason,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.updateOrder(orderId, {
        'status': 'cancelled',
        'rejectionReason': reason,
      });
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
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
      final result = await _remoteDataSource.getCustomerOrders(
        customerId: customerId,
        limit: limit,
        startAfterId: startAfterCursor,
        status: statusFilter?.toString().split('.').last,
      );

      final entities = result.items.map(_modelToEntity).toList();

      return Right(
        PaginatedResult<OrderEntity>(
          items: entities,
          hasMore: result.hasMore,
          nextCursor: result.nextCursor,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to get orders: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.updateOrderStatus(
        orderId,
        status.toString().split('.').last,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to update order status: $e'));
    }
  }

  @override
  Stream<List<OrderEntity>> getUserOrders(
    String userId, {
    bool isTechnician = false,
  }) {
    if (isTechnician) {
      return _remoteDataSource
          .watchTechnicianOrders(userId)
          .map((models) => models.map(_modelToEntity).toList());
    } else {
      return _remoteDataSource
          .watchCustomerOrders(userId)
          .map((models) => models.map(_modelToEntity).toList());
    }
  }

  @override
  Stream<List<OrderEntity>> streamPendingOrdersForTechnician() {
    // Use direct Firestore for pending orders (all technicians can see)
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .orderBy('dateRequested', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _mapDocToEntity(doc.id, doc.data()))
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
              .map((doc) => _mapDocToEntity(doc.id, doc.data()))
              .toList(),
        );
  }

  // Helper methods for mapping
  OrderEntity _modelToEntity(OrderModel model) {
    return OrderEntity(
      id: model.id,
      customerId: model.customerId,
      technicianId: model.technicianId,
      serviceId: model.serviceId,
      description: model.description,
      photoUrls: model.photoUrls,
      location: model.location,
      address: model.address,
      dateRequested: model.dateRequested,
      dateScheduled: model.dateScheduled,
      status: _parseOrderStatus(model.status.toString().split('.').last),
      initialEstimate: model.initialEstimate,
      finalPrice: model.finalPrice,
      visitFee: model.visitFee,
      vat: model.vat,
      paymentMethod: model.paymentMethod,
      paymentStatus: model.paymentStatus,
      notes: model.notes,
      serviceName: model.serviceName,
      customerName: model.customerName,
      customerPhoneNumber: model.customerPhoneNumber,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  OrderModel _entityToModel(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      customerId: entity.customerId,
      technicianId: entity.technicianId,
      serviceId: entity.serviceId,
      description: entity.description,
      photoUrls: entity.photoUrls,
      location: entity.location,
      address: entity.address,
      dateRequested: entity.dateRequested,
      dateScheduled: entity.dateScheduled,
      status: _entityStatusToModelStatus(entity.status),
      initialEstimate: entity.initialEstimate,
      finalPrice: entity.finalPrice,
      visitFee: entity.visitFee,
      vat: entity.vat,
      paymentMethod: entity.paymentMethod,
      paymentStatus: entity.paymentStatus,
      notes: entity.notes,
      serviceName: entity.serviceName,
      customerName: entity.customerName,
      customerPhoneNumber: entity.customerPhoneNumber,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  OrderEntity _mapDocToEntity(String id, Map<String, dynamic> data) {
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

  // Note: OrderModel uses its own OrderStatus enum
  dynamic _entityStatusToModelStatus(OrderStatus status) {
    // The OrderModel uses the same string representation
    return status.toString().split('.').last;
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
