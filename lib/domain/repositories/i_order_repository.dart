// Order repository interface for Clean Architecture.

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/order_entity.dart';

/// Paginated result wrapper.
class PaginatedResult<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });
}

/// Repository interface for order operations.
abstract class IOrderRepository {
  /// Gets an order by ID.
  Future<Either<Failure, OrderEntity?>> getOrder(String orderId);

  /// Creates a new order and returns the order ID.
  Future<Either<Failure, String>> createOrder(OrderEntity order);

  /// Assigns a technician to an order.
  Future<Either<Failure, void>> assignTechnicianToOrder(
    String orderId,
    String technicianId,
    double estimate,
  );

  /// Completes an order.
  Future<Either<Failure, void>> completeOrder(
    String orderId,
    double finalPrice,
    String? notes,
  );

  /// Rejects an order.
  Future<Either<Failure, void>> rejectOrder(String orderId, String reason);

  /// Gets paginated customer orders.
  Future<Either<Failure, PaginatedResult<OrderEntity>>>
  getCustomerOrdersPaginated({
    required String customerId,
    String? startAfterCursor,
    int limit = 20,
    OrderStatus? statusFilter,
  });

  /// Updates order status.
  Future<Either<Failure, void>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  );

  /// Streams orders for a user.
  Stream<List<OrderEntity>> getUserOrders(
    String userId, {
    bool isTechnician = false,
  });

  /// Streams pending orders for technicians.
  Stream<List<OrderEntity>> streamPendingOrdersForTechnician();

  /// Streams all orders (for admin).
  Stream<List<OrderEntity>> streamAllOrders();
}
