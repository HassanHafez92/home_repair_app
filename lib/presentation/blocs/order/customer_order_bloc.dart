import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:home_repair_app/domain/repositories/i_order_repository.dart';
import 'package:home_repair_app/domain/usecases/order/create_order.dart'
    as usecase;
import 'package:home_repair_app/domain/usecases/order/update_order_status.dart'
    as usecase;
import 'customer_order_event.dart';
import 'customer_order_state.dart';

export 'customer_order_event.dart';
export 'customer_order_state.dart';

/// CustomerOrderBloc using Clean Architecture Use Cases.
///
/// Delegates business logic to use cases where applicable, while
/// using repository directly for pagination/querying operations.
class CustomerOrderBloc extends Bloc<CustomerOrderEvent, CustomerOrderState> {
  final IOrderRepository _orderRepository;
  final usecase.CreateOrder _createOrder;
  final usecase.UpdateOrderStatus _updateOrderStatus;

  String? _currentUserId;
  OrderStatus? _currentStatusFilter;

  CustomerOrderBloc({
    required IOrderRepository orderRepository,
    required usecase.CreateOrder createOrder,
    required usecase.UpdateOrderStatus updateOrderStatus,
  }) : _orderRepository = orderRepository,
       _createOrder = createOrder,
       _updateOrderStatus = updateOrderStatus,
       super(const CustomerOrderState()) {
    on<LoadCustomerOrders>(_onLoadCustomerOrders);
    on<LoadMoreCustomerOrders>(_onLoadMoreCustomerOrders);
    on<CreateOrder>(_onCreateOrder);
    on<CancelOrder>(_onCancelOrder);
    on<CustomerOrderError>(_onError);
  }

  Future<void> _onLoadCustomerOrders(
    LoadCustomerOrders event,
    Emitter<CustomerOrderState> emit,
  ) async {
    emit(state.copyWith(status: CustomerOrderStatus.loading));

    // Store for load more
    _currentUserId = event.userId;
    _currentStatusFilter = event.statusFilter;

    final result = await _orderRepository.getCustomerOrdersPaginated(
      customerId: event.userId,
      limit: event.pageSize,
      statusFilter: event.statusFilter,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CustomerOrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (paginatedResult) => emit(
        state.copyWith(
          status: CustomerOrderStatus.success,
          paginatedOrders: paginatedResult,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreCustomerOrders(
    LoadMoreCustomerOrders event,
    Emitter<CustomerOrderState> emit,
  ) async {
    // Don't load if already loading or no more items
    if (state.isLoadingMore || !state.hasMore || _currentUserId == null) return;

    emit(state.copyWith(status: CustomerOrderStatus.loadingMore));

    final result = await _orderRepository.getCustomerOrdersPaginated(
      customerId: _currentUserId!,
      startAfterCursor: state.nextCursor,
      limit: 20,
      statusFilter: _currentStatusFilter,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CustomerOrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (paginatedResult) {
        // Merge new items with existing
        final updatedResult = PaginatedResult<OrderEntity>(
          items: [...state.orders, ...paginatedResult.items],
          hasMore: paginatedResult.hasMore,
          nextCursor: paginatedResult.nextCursor,
        );

        emit(
          state.copyWith(
            status: CustomerOrderStatus.success,
            paginatedOrders: updatedResult,
          ),
        );
      },
    );
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<CustomerOrderState> emit,
  ) async {
    // Use the CreateOrder use case
    final result = await _createOrder(
      usecase.CreateOrderParams(order: event.order),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CustomerOrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        // Reload first page to include new order
        if (_currentUserId != null && !isClosed) {
          add(LoadCustomerOrders(userId: _currentUserId!));
        }
      },
    );
  }

  Future<void> _onCancelOrder(
    CancelOrder event,
    Emitter<CustomerOrderState> emit,
  ) async {
    // Use the UpdateOrderStatus use case
    final result = await _updateOrderStatus(
      usecase.UpdateOrderStatusParams(
        orderId: event.orderId,
        status: OrderStatus.cancelled,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CustomerOrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        // Reload to reflect changes
        if (_currentUserId != null && !isClosed) {
          add(LoadCustomerOrders(userId: _currentUserId!));
        }
      },
    );
  }

  void _onError(CustomerOrderError event, Emitter<CustomerOrderState> emit) {
    emit(
      state.copyWith(
        status: CustomerOrderStatus.failure,
        errorMessage: event.message,
      ),
    );
  }
}
