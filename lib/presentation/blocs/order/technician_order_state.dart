import 'package:equatable/equatable.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';

enum TechnicianOrderStatus { initial, loading, success, failure }

class TechnicianOrderState extends Equatable {
  final TechnicianOrderStatus status;
  final List<OrderEntity> activeOrders;
  final List<OrderEntity> incomingOrders;
  final String? errorMessage;

  const TechnicianOrderState({
    this.status = TechnicianOrderStatus.initial,
    this.activeOrders = const [],
    this.incomingOrders = const [],
    this.errorMessage,
  });

  TechnicianOrderState copyWith({
    TechnicianOrderStatus? status,
    List<OrderEntity>? activeOrders,
    List<OrderEntity>? incomingOrders,
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
