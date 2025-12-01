import 'package:equatable/equatable.dart';

class TechnicianStats extends Equatable {
  final double todayEarnings;
  final int completedJobsToday;
  final int completedJobsTotal;
  final double rating;
  final int pendingOrders;
  final int activeJobs;
  final DateTime lastUpdated;

  const TechnicianStats({
    required this.todayEarnings,
    required this.completedJobsToday,
    required this.completedJobsTotal,
    required this.rating,
    required this.pendingOrders,
    required this.activeJobs,
    required this.lastUpdated,
  });

  factory TechnicianStats.empty() {
    return TechnicianStats(
      todayEarnings: 0.0,
      completedJobsToday: 0,
      completedJobsTotal: 0,
      rating: 0.0,
      pendingOrders: 0,
      activeJobs: 0,
      lastUpdated: DateTime.now(),
    );
  }

  TechnicianStats copyWith({
    double? todayEarnings,
    int? completedJobsToday,
    int? completedJobsTotal,
    double? rating,
    int? pendingOrders,
    int? activeJobs,
    DateTime? lastUpdated,
  }) {
    return TechnicianStats(
      todayEarnings: todayEarnings ?? this.todayEarnings,
      completedJobsToday: completedJobsToday ?? this.completedJobsToday,
      completedJobsTotal: completedJobsTotal ?? this.completedJobsTotal,
      rating: rating ?? this.rating,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      activeJobs: activeJobs ?? this.activeJobs,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    todayEarnings,
    completedJobsToday,
    completedJobsTotal,
    rating,
    pendingOrders,
    activeJobs,
    lastUpdated,
  ];
}
