// File: lib/blocs/admin/admin_bloc.dart
// Purpose: BLoC for admin dashboard logic

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_admin_repository.dart';
import '../../domain/repositories/i_order_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final IAdminRepository _adminRepository;
  final IOrderRepository _orderRepository;

  AdminBloc({
    required IAdminRepository adminRepository,
    required IOrderRepository orderRepository,
  }) : _adminRepository = adminRepository,
       _orderRepository = orderRepository,
       super(const AdminState()) {
    on<AdminDashboardLoadRequested>(_onLoadRequested);
    on<AdminRefreshRequested>(_onLoadRequested);
    on<LoadAllOrders>(_onLoadAllOrders);
  }

  Future<void> _onLoadRequested(
    AdminEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      // Fetch stats
      final stats = await _adminRepository.getDashboardStats();

      // Fetch recent activity (orders)
      // We'll use the stream to get the first value.
      final recentActivity = await _orderRepository.streamAllOrders().first;

      emit(
        state.copyWith(
          status: AdminStatus.success,
          stats: stats,
          recentActivity: recentActivity.take(5).toList(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoadAllOrders(
    LoadAllOrders event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      // In a real app, we might want to stream this or paginate
      // For now, just fetch once
      final orders = await _orderRepository.streamAllOrders().first;
      emit(state.copyWith(status: AdminStatus.success, allOrders: orders));
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
