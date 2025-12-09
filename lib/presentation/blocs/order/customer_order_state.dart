import 'package:equatable/equatable.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:home_repair_app/domain/repositories/i_order_repository.dart';

enum CustomerOrderStatus { initial, loading, loadingMore, success, failure }

class CustomerOrderState extends Equatable {
  final CustomerOrderStatus status;
  final PaginatedResult<OrderEntity>? paginatedOrders;
  final String? errorMessage;

  const CustomerOrderState({
    this.status = CustomerOrderStatus.initial,
    this.paginatedOrders,
    this.errorMessage,
  });

  // Convenience getters
  List<OrderEntity> get orders => paginatedOrders?.items ?? [];
  bool get hasMore => paginatedOrders?.hasMore ?? false;
  bool get isLoadingMore => status == CustomerOrderStatus.loadingMore;
  String? get nextCursor => paginatedOrders?.nextCursor;

  CustomerOrderState copyWith({
    CustomerOrderStatus? status,
    PaginatedResult<OrderEntity>? paginatedOrders,
    String? errorMessage,
  }) {
    return CustomerOrderState(
      status: status ?? this.status,
      paginatedOrders: paginatedOrders ?? this.paginatedOrders,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, paginatedOrders, errorMessage];
}
