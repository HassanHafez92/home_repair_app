/// Get technician stats use case.

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/i_user_repository.dart';

/// Technician statistics entity.
class TechnicianStatsEntity extends Equatable {
  final double todayEarnings;
  final int completedJobsToday;
  final int completedJobsTotal;
  final double rating;
  final int pendingOrders;
  final int activeJobs;
  final DateTime lastUpdated;

  const TechnicianStatsEntity({
    required this.todayEarnings,
    required this.completedJobsToday,
    required this.completedJobsTotal,
    required this.rating,
    required this.pendingOrders,
    required this.activeJobs,
    required this.lastUpdated,
  });

  /// Empty stats with default values.
  factory TechnicianStatsEntity.empty() {
    return TechnicianStatsEntity(
      todayEarnings: 0.0,
      completedJobsToday: 0,
      completedJobsTotal: 0,
      rating: 0.0,
      pendingOrders: 0,
      activeJobs: 0,
      lastUpdated: DateTime.now(),
    );
  }

  // Convenience getters for backward compatibility
  int get completedJobs => completedJobsTotal;
  double get totalEarnings => todayEarnings;
  double get averageRating => rating;
  int get totalReviews => 0; // Not tracked currently

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

/// Use case for getting technician statistics.
class GetTechnicianStats
    implements UseCase<TechnicianStatsEntity, GetTechnicianStatsParams> {
  final IUserRepository repository;

  GetTechnicianStats(this.repository);

  @override
  Future<Either<Failure, TechnicianStatsEntity>> call(
    GetTechnicianStatsParams params,
  ) {
    return repository.getTechnicianStats(params.technicianId);
  }
}

/// Parameters for getting technician stats.
class GetTechnicianStatsParams {
  final String technicianId;

  const GetTechnicianStatsParams({required this.technicianId});
}
