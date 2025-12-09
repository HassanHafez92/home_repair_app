import 'package:equatable/equatable.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';

abstract class CustomerOrderEvent extends Equatable {
  const CustomerOrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomerOrders extends CustomerOrderEvent {
  final String userId;
  final int pageSize;
  final OrderStatus? statusFilter;

  const LoadCustomerOrders({
    required this.userId,
    this.pageSize = 20,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [userId, pageSize, statusFilter];
}

class LoadMoreCustomerOrders extends CustomerOrderEvent {
  const LoadMoreCustomerOrders();
}

class CreateOrder extends CustomerOrderEvent {
  final OrderEntity order;

  const CreateOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class CancelOrder extends CustomerOrderEvent {
  final String orderId;

  const CancelOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

// Internal event for stream updates
class CustomerOrdersUpdated extends CustomerOrderEvent {
  final List<OrderEntity> orders;

  const CustomerOrdersUpdated(this.orders);

  @override
  List<Object?> get props => [orders];
}

class CustomerOrderError extends CustomerOrderEvent {
  final String message;

  const CustomerOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
