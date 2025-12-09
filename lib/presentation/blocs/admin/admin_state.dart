// File: lib/blocs/admin/admin_state.dart
// Purpose: State for AdminBloc

import 'package:equatable/equatable.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:home_repair_app/models/dashboard_stats.dart';

enum AdminStatus { initial, loading, success, failure }

class AdminState extends Equatable {
  final AdminStatus status;
  final DashboardStats? stats;
  final List<OrderEntity> recentActivity;
  final List<OrderEntity> allOrders;
  final String? errorMessage;

  const AdminState({
    this.status = AdminStatus.initial,
    this.stats,
    this.recentActivity = const [],
    this.allOrders = const [],
    this.errorMessage,
  });

  AdminState copyWith({
    AdminStatus? status,
    DashboardStats? stats,
    List<OrderEntity>? recentActivity,
    List<OrderEntity>? allOrders,
    String? errorMessage,
  }) {
    return AdminState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      recentActivity: recentActivity ?? this.recentActivity,
      allOrders: allOrders ?? this.allOrders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stats,
    recentActivity,
    allOrders,
    errorMessage,
  ];
}
