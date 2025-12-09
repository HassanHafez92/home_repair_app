import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_repair_app/domain/repositories/i_user_repository.dart';
import 'package:home_repair_app/domain/usecases/user/get_technician_stats.dart';
import 'technician_dashboard_event.dart';
import 'technician_dashboard_state.dart';

export 'technician_dashboard_event.dart';
export 'technician_dashboard_state.dart';

class TechnicianDashboardBloc
    extends Bloc<TechnicianDashboardEvent, TechnicianDashboardState> {
  final IUserRepository _userRepository;
  StreamSubscription<TechnicianStatsEntity>? _statsSubscription;
  StreamSubscription<bool>? _availabilitySubscription;

  TechnicianDashboardBloc({required IUserRepository userRepository})
    : _userRepository = userRepository,
      super(const TechnicianDashboardState()) {
    on<LoadTechnicianDashboard>(_onLoadDashboard);
    on<ToggleAvailability>(_onToggleAvailability);
    on<RefreshDashboardStats>(_onRefreshStats);
    on<DashboardStatsUpdated>(_onStatsUpdated);
    on<AvailabilityUpdated>(_onAvailabilityUpdated);
    on<DashboardError>(_onError);
  }

  Future<void> _onLoadDashboard(
    LoadTechnicianDashboard event,
    Emitter<TechnicianDashboardState> emit,
  ) async {
    emit(state.copyWith(status: TechnicianDashboardStatus.loading));
    await _cancelSubscriptions();

    try {
      // Load initial availability
      _availabilitySubscription = _userRepository
          .streamTechnicianAvailability(event.technicianId)
          .listen(
            (isAvailable) => add(AvailabilityUpdated(isAvailable)),
            onError: (error) => add(DashboardError(error.toString())),
          );

      // Load and stream stats
      _statsSubscription = _userRepository
          .streamTechnicianStats(event.technicianId)
          .listen(
            (stats) => add(DashboardStatsUpdated(stats)),
            onError: (error) => add(DashboardError(error.toString())),
          );
    } catch (e) {
      emit(
        state.copyWith(
          status: TechnicianDashboardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleAvailability(
    ToggleAvailability event,
    Emitter<TechnicianDashboardState> emit,
  ) async {
    final result = await _userRepository.updateTechnicianAvailability(
      event.technicianId,
      event.isAvailable,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TechnicianDashboardStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => {}, // Stream will update the state automatically
    );
  }

  Future<void> _onRefreshStats(
    RefreshDashboardStats event,
    Emitter<TechnicianDashboardState> emit,
  ) async {
    final result = await _userRepository.getTechnicianStats(event.technicianId);

    result.fold(
      (failure) {
        if (!isClosed) add(DashboardError(failure.message));
      },
      (stats) {
        if (!isClosed) add(DashboardStatsUpdated(stats));
      },
    );
  }

  void _onStatsUpdated(
    DashboardStatsUpdated event,
    Emitter<TechnicianDashboardState> emit,
  ) {
    emit(
      state.copyWith(
        status: TechnicianDashboardStatus.success,
        stats: event.stats,
      ),
    );
  }

  void _onAvailabilityUpdated(
    AvailabilityUpdated event,
    Emitter<TechnicianDashboardState> emit,
  ) {
    emit(state.copyWith(isAvailable: event.isAvailable));
  }

  void _onError(DashboardError event, Emitter<TechnicianDashboardState> emit) {
    emit(
      state.copyWith(
        status: TechnicianDashboardStatus.failure,
        errorMessage: event.message,
      ),
    );
  }

  Future<void> _cancelSubscriptions() async {
    await _statsSubscription?.cancel();
    await _availabilitySubscription?.cancel();
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
