import 'package:equatable/equatable.dart';
import 'package:home_repair_app/domain/usecases/user/get_technician_stats.dart';

enum TechnicianDashboardStatus { initial, loading, success, failure }

class TechnicianDashboardState extends Equatable {
  final TechnicianDashboardStatus status;
  final bool isAvailable;
  final TechnicianStatsEntity? stats;
  final String? errorMessage;

  const TechnicianDashboardState({
    this.status = TechnicianDashboardStatus.initial,
    this.isAvailable = false,
    this.stats,
    this.errorMessage,
  });

  TechnicianDashboardState copyWith({
    TechnicianDashboardStatus? status,
    bool? isAvailable,
    TechnicianStatsEntity? stats,
    String? errorMessage,
  }) {
    return TechnicianDashboardState(
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, isAvailable, stats, errorMessage];
}
