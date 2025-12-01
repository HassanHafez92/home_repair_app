import 'package:home_repair_app/models/order_model.dart';
import 'package:home_repair_app/models/paginated_result.dart';

abstract class IOrderRepository {
  Future<OrderModel?> getOrder(String orderId);

  Future<String> createOrder(OrderModel order);

  Future<void> assignTechnicianToOrder(
    String orderId,
    String technicianId,
    double estimate,
  );

  Future<void> completeOrder(String orderId, double finalPrice, String? notes);

  Future<void> rejectOrder(String orderId, String reason);

  Future<PaginatedResult<OrderModel>> getCustomerOrdersPaginated({
    required String customerId,
    String? startAfterCursor,
    int limit = 20,
    OrderStatus? statusFilter,
  });

  Future<void> updateOrderStatus(String orderId, OrderStatus status);

  Stream<List<OrderModel>> getUserOrders(
    String userId, {
    bool isTechnician = false,
  });

  Stream<List<OrderModel>> streamPendingOrdersForTechnician();

  Stream<List<OrderModel>> streamAllOrders();
}
