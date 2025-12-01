import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../../models/order_model.dart';
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

    try {
      final result = await _orderRepository.getCustomerOrdersPaginated(
        customerId: event.userId,
        limit: event.pageSize,
        statusFilter: event.statusFilter,
      );

      emit(
        state.copyWith(
          status: CustomerOrderStatus.success,
          paginatedOrders: result,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerOrderStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMoreCustomerOrders(
    LoadMoreCustomerOrders event,
    Emitter<CustomerOrderState> emit,
  ) async {
    // Don't load if already loading or no more items
    if (state.isLoadingMore || !state.hasMore || _currentUserId == null) return;

    emit(state.copyWith(status: CustomerOrderStatus.loadingMore));

    try {
      final result = await _orderRepository.getCustomerOrdersPaginated(
        customerId: _currentUserId!,
        startAfterCursor: state.nextCursor,
        limit: 20,
        statusFilter: _currentStatusFilter,
      );

      // Merge new items with existing
      final updatedResult = state.paginatedOrders!.copyWith(
        items: [...state.orders, ...result.items],
        hasMore: result.hasMore,
        nextCursor: result.nextCursor,
      );

      emit(
        state.copyWith(
          status: CustomerOrderStatus.success,
          paginatedOrders: updatedResult,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerOrderStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<CustomerOrderState> emit,
  ) async {
    try {
      await _orderRepository.createOrder(event.order);
      // Reload first page to include new order
      if (_currentUserId != null && !isClosed) {
        add(LoadCustomerOrders(userId: _currentUserId!));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerOrderStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCancelOrder(
    CancelOrder event,
    Emitter<CustomerOrderState> emit,
  ) async {
    try {
      await _orderRepository.updateOrderStatus(
        event.orderId,
        OrderStatus.cancelled,
      );
      // Reload to reflect changes
      if (_currentUserId != null && !isClosed) {
        add(LoadCustomerOrders(userId: _currentUserId!));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerOrderStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
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
