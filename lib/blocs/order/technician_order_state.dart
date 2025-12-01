import 'package:equatable/equatable.dart';
import '../../models/order_model.dart';

enum TechnicianOrderStatus { initial, loading, success, failure }

class TechnicianOrderState extends Equatable {
  final TechnicianOrderStatus status;
  final List<OrderModel> activeOrders;
  final List<OrderModel> incomingOrders;
  final String? errorMessage;

  const TechnicianOrderState({
    this.status = TechnicianOrderStatus.initial,
    this.activeOrders = const [],
    this.incomingOrders = const [],
    this.errorMessage,
  });

  TechnicianOrderState copyWith({
    TechnicianOrderStatus? status,
    List<OrderModel>? activeOrders,
    List<OrderModel>? incomingOrders,
    String? errorMessage,
  }) {
    return TechnicianOrderState(
      status: status ?? this.status,
      activeOrders: activeOrders ?? this.activeOrders,
      incomingOrders: incomingOrders ?? this.incomingOrders,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    activeOrders,
    incomingOrders,
    errorMessage,
  ];
}
