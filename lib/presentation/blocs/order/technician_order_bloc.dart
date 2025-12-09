import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:home_repair_app/domain/repositories/i_order_repository.dart';
import 'technician_order_event.dart';
import 'technician_order_state.dart';

export 'technician_order_event.dart';
export 'technician_order_state.dart';

class TechnicianOrderBloc
    extends Bloc<TechnicianOrderEvent, TechnicianOrderState> {
  final IOrderRepository _orderRepository;
  StreamSubscription<List<OrderEntity>>? _activeOrdersSubscription;
  StreamSubscription<List<OrderEntity>>? _incomingOrdersSubscription;

  TechnicianOrderBloc({required IOrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const TechnicianOrderState()) {
    on<LoadTechnicianOrders>(_onLoadTechnicianOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<AcceptOrder>(_onAcceptOrder);
    on<RejectOrder>(_onRejectOrder);
    on<TechnicianActiveOrdersUpdated>(_onActiveOrdersUpdated);
    on<TechnicianIncomingOrdersUpdated>(_onIncomingOrdersUpdated);
    on<TechnicianOrderError>(_onError);
  }

  Future<void> _onLoadTechnicianOrders(
    LoadTechnicianOrders event,
    Emitter<TechnicianOrderState> emit,
  ) async {
    emit(state.copyWith(status: TechnicianOrderStatus.loading));
    await _cancelSubscriptions();

    // Listen to active jobs (assigned to this technician)
    _activeOrdersSubscription = _orderRepository
        .getUserOrders(event.technicianId, isTechnician: true)
        .listen(
          (orders) => add(TechnicianActiveOrdersUpdated(orders)),
          onError: (error) => add(TechnicianOrderError(error.toString())),
        );

    // Listen to incoming pending orders (available for any technician)
    _incomingOrdersSubscription = _orderRepository
        .streamPendingOrdersForTechnician()
        .listen(
          (orders) => add(TechnicianIncomingOrdersUpdated(orders)),
          onError: (error) => add(TechnicianOrderError(error.toString())),
        );
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<TechnicianOrderState> emit,
  ) async {
    final result = await _orderRepository.updateOrderStatus(
      event.orderId,
      event.status,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TechnicianOrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => {}, // Stream will update the state
    );
  }

  Future<void> _onAcceptOrder(
    AcceptOrder event,
    Emitter<TechnicianOrderState> emit,
  ) async {
    final result = await _orderRepository.assignTechnicianToOrder(
      event.orderId,
      event.technicianId,
      event.estimate,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TechnicianOrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => {}, // Stream will update the state
    );
  }

  Future<void> _onRejectOrder(
    RejectOrder event,
    Emitter<TechnicianOrderState> emit,
  ) async {
    final result = await _orderRepository.rejectOrder(
      event.orderId,
      event.reason,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TechnicianOrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => {}, // Stream will update the state
    );
  }

  void _onActiveOrdersUpdated(
    TechnicianActiveOrdersUpdated event,
    Emitter<TechnicianOrderState> emit,
  ) {
    emit(
      state.copyWith(
        status: TechnicianOrderStatus.success,
        activeOrders: event.orders,
      ),
    );
  }

  void _onIncomingOrdersUpdated(
    TechnicianIncomingOrdersUpdated event,
    Emitter<TechnicianOrderState> emit,
  ) {
    emit(
      state.copyWith(
        status: TechnicianOrderStatus.success,
        incomingOrders: event.orders,
      ),
    );
  }

  void _onError(
    TechnicianOrderError event,
    Emitter<TechnicianOrderState> emit,
  ) {
    emit(
      state.copyWith(
        status: TechnicianOrderStatus.failure,
        errorMessage: event.message,
      ),
    );
  }

  Future<void> _cancelSubscriptions() async {
    await _activeOrdersSubscription?.cancel();
    await _incomingOrdersSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
