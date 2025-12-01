import 'package:equatable/equatable.dart';
import '../../models/order_model.dart';
import '../../models/paginated_result.dart';

enum CustomerOrderStatus { initial, loading, loadingMore, success, failure }

class CustomerOrderState extends Equatable {
  final CustomerOrderStatus status;
  final PaginatedResult<OrderModel>? paginatedOrders;
  final String? errorMessage;

  const CustomerOrderState({
    this.status = CustomerOrderStatus.initial,
    this.paginatedOrders,
    this.errorMessage,
  });

  // Convenience getters
  List<OrderModel> get orders => paginatedOrders?.items ?? [];
  bool get hasMore => paginatedOrders?.hasMore ?? false;
  bool get isLoadingMore => status == CustomerOrderStatus.loadingMore;
  String? get nextCursor => paginatedOrders?.nextCursor;

  CustomerOrderState copyWith({
    CustomerOrderStatus? status,
    PaginatedResult<OrderModel>? paginatedOrders,
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
