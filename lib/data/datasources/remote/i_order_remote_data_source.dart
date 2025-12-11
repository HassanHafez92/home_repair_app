// Order remote data source interface.
//
// Defines the contract for order data operations with Firestore.

import '../../../models/order_model.dart';
import '../../../models/paginated_result.dart';

/// Interface for remote order data operations.
abstract class IOrderRemoteDataSource {
  /// Gets an order by ID.
  ///
  /// Throws [NotFoundException] if order doesn't exist.
  /// Throws [ServerException] on Firestore errors.
  Future<OrderModel> getOrder(String orderId);

  /// Gets orders for a customer with pagination.
  ///
  /// Throws [ServerException] on Firestore errors.
  Future<PaginatedResult<OrderModel>> getCustomerOrders({
    required String customerId,
    int limit = 20,
    String? startAfterId,
    String? status,
  });

  /// Gets orders for a technician with pagination.
  ///
  /// Throws [ServerException] on Firestore errors.
  Future<PaginatedResult<OrderModel>> getTechnicianOrders({
    required String technicianId,
    int limit = 20,
    String? startAfterId,
    String? status,
  });

  /// Creates a new order.
  ///
  /// Returns the created order ID.
  /// Throws [ServerException] on Firestore errors.
  Future<String> createOrder(OrderModel order);

  /// Updates an existing order.
  ///
  /// Throws [ServerException] on Firestore errors.
  Future<void> updateOrder(String orderId, Map<String, dynamic> data);

  /// Updates order status.
  ///
  /// Throws [ServerException] on Firestore errors.
  Future<void> updateOrderStatus(String orderId, String status);

  /// Assigns a technician to an order.
  ///
  /// Throws [ServerException] on Firestore errors.
  Future<void> assignTechnician(String orderId, String technicianId);

  /// Stream of order changes.
  Stream<OrderModel?> watchOrder(String orderId);

  /// Stream of customer orders.
  Stream<List<OrderModel>> watchCustomerOrders(String customerId);

  /// Stream of technician orders.
  Stream<List<OrderModel>> watchTechnicianOrders(String technicianId);
}
