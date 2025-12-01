import 'package:equatable/equatable.dart';
import '../../models/order_model.dart';

abstract class TechnicianOrderEvent extends Equatable {
  const TechnicianOrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadTechnicianOrders extends TechnicianOrderEvent {
  final String technicianId;

  const LoadTechnicianOrders(this.technicianId);

  @override
  List<Object?> get props => [technicianId];
}

class UpdateOrderStatus extends TechnicianOrderEvent {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatus({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}

class AcceptOrder extends TechnicianOrderEvent {
  final String orderId;
  final String technicianId;
  final double estimate;

  const AcceptOrder({
    required this.orderId,
    required this.technicianId,
    required this.estimate,
  });

  @override
  List<Object?> get props => [orderId, technicianId, estimate];
}

class RejectOrder extends TechnicianOrderEvent {
  final String orderId;
  final String reason;

  const RejectOrder({required this.orderId, required this.reason});

  @override
  List<Object?> get props => [orderId, reason];
}

// Internal events
class TechnicianActiveOrdersUpdated extends TechnicianOrderEvent {
  final List<OrderModel> orders;

  const TechnicianActiveOrdersUpdated(this.orders);

  @override
  List<Object?> get props => [orders];
}

class TechnicianIncomingOrdersUpdated extends TechnicianOrderEvent {
  final List<OrderModel> orders;

  const TechnicianIncomingOrdersUpdated(this.orders);

  @override
  List<Object?> get props => [orders];
}

class TechnicianOrderError extends TechnicianOrderEvent {
  final String message;

  const TechnicianOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
