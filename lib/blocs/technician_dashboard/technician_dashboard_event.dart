import 'package:equatable/equatable.dart';
import '../../models/technician_stats.dart';

abstract class TechnicianDashboardEvent extends Equatable {
  const TechnicianDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load dashboard data for a technician
class LoadTechnicianDashboard extends TechnicianDashboardEvent {
  final String technicianId;

  const LoadTechnicianDashboard(this.technicianId);

  @override
  List<Object?> get props => [technicianId];
}

/// Toggle technician availability
class ToggleAvailability extends TechnicianDashboardEvent {
  final String technicianId;
  final bool isAvailable;

  const ToggleAvailability({
    required this.technicianId,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [technicianId, isAvailable];
}

/// Force refresh dashboard statistics
class RefreshDashboardStats extends TechnicianDashboardEvent {
  final String technicianId;

  const RefreshDashboardStats(this.technicianId);

  @override
  List<Object?> get props => [technicianId];
}

// Internal events

/// Stats were updated from stream
class DashboardStatsUpdated extends TechnicianDashboardEvent {
  final TechnicianStats stats;

  const DashboardStatsUpdated(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Availability status updated from stream
class AvailabilityUpdated extends TechnicianDashboardEvent {
  final bool isAvailable;

  const AvailabilityUpdated(this.isAvailable);

  @override
  List<Object?> get props => [isAvailable];
}

/// Error occurred
class DashboardError extends TechnicianDashboardEvent {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
