import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:home_repair_app/domain/repositories/i_order_repository.dart';
import 'customer_order_event.dart';
import 'customer_order_state.dart';

export 'customer_order_event.dart';
export 'customer_order_state.dart';

class CustomerOrderBloc extends Bloc<CustomerOrderEvent, CustomerOrderState> {
  final IOrderRepository _orderRepository;
  String? _currentUserId;
  OrderStatus? _currentStatusFilter;

  CustomerOrderBloc({required IOrderRepository orderRepository})
    : _orderRepository = orderRepository,
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
    final result = await _orderRepository.createOrder(event.order);

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
    final result = await _orderRepository.updateOrderStatus(
      event.orderId,
      OrderStatus.cancelled,
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
