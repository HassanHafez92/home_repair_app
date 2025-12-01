// File: lib/blocs/admin/admin_event.dart
// Purpose: Events for AdminBloc

import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class AdminDashboardLoadRequested extends AdminEvent {
  const AdminDashboardLoadRequested();
}

class AdminRefreshRequested extends AdminEvent {
  const AdminRefreshRequested();
}

class LoadAllOrders extends AdminEvent {
  const LoadAllOrders();
}
