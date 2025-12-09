// File: test/technician_dashboard_bloc_test.dart
// Purpose: Unit tests for TechnicianDashboardBloc

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:home_repair_app/presentation/blocs/technician_dashboard/technician_dashboard_bloc.dart';
import 'package:home_repair_app/domain/repositories/i_user_repository.dart';
import 'package:home_repair_app/domain/usecases/user/get_technician_stats.dart';

import 'technician_dashboard_bloc_test.mocks.dart';

@GenerateMocks([IUserRepository])
void main() {
  late MockIUserRepository mockUserRepository;
  late TechnicianDashboardBloc bloc;

  setUp(() {
    mockUserRepository = MockIUserRepository();
    bloc = TechnicianDashboardBloc(userRepository: mockUserRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('TechnicianDashboardBloc', () {
    const testTechnicianId = 'test-technician-id';

    test('initial state has initial status', () {
      expect(bloc.state.status, equals(TechnicianDashboardStatus.initial));
    });

    group('LoadTechnicianDashboard', () {
      final mockStats = TechnicianStatsEntity(
        todayEarnings: 500.0,
        completedJobsToday: 3,
        completedJobsTotal: 150,
        rating: 4.5,
        pendingOrders: 5,
        activeJobs: 2,
        lastUpdated: DateTime.now(),
      );

      blocTest<TechnicianDashboardBloc, TechnicianDashboardState>(
        'emits loading and streams stats successfully',
        build: () {
          when(
            mockUserRepository.streamTechnicianAvailability(testTechnicianId),
          ).thenAnswer((_) => Stream.value(false));
          when(
            mockUserRepository.streamTechnicianStats(testTechnicianId),
          ).thenAnswer((_) => Stream.value(mockStats));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const LoadTechnicianDashboard(testTechnicianId)),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          predicate<TechnicianDashboardState>(
            (state) => state.status == TechnicianDashboardStatus.loading,
          ),
          predicate<TechnicianDashboardState>(
            (state) => state.isAvailable == false,
          ),
          predicate<TechnicianDashboardState>(
            (state) =>
                state.status == TechnicianDashboardStatus.success &&
                state.stats?.todayEarnings == 500.0,
          ),
        ],
        verify: (_) {
          verify(
            mockUserRepository.streamTechnicianAvailability(testTechnicianId),
          ).called(1);
          verify(
            mockUserRepository.streamTechnicianStats(testTechnicianId),
          ).called(1);
        },
      );
    });

    group('ToggleAvailability', () {
      blocTest<TechnicianDashboardBloc, TechnicianDashboardState>(
        'calls updateTechnicianAvailability when toggled',
        build: () {
          when(
            mockUserRepository.updateTechnicianAvailability(
              testTechnicianId,
              true,
            ),
          ).thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const ToggleAvailability(
            technicianId: testTechnicianId,
            isAvailable: true,
          ),
        ),
        verify: (_) {
          verify(
            mockUserRepository.updateTechnicianAvailability(
              testTechnicianId,
              true,
            ),
          ).called(1);
        },
      );
    });

    group('RefreshDashboardStats', () {
      final mockStats = TechnicianStatsEntity(
        todayEarnings: 600.0,
        completedJobsToday: 4,
        completedJobsTotal: 151,
        rating: 4.6,
        pendingOrders: 4,
        activeJobs: 3,
        lastUpdated: DateTime.now(),
      );

      blocTest<TechnicianDashboardBloc, TechnicianDashboardState>(
        'fetches updated stats when refreshed',
        build: () {
          when(
            mockUserRepository.getTechnicianStats(testTechnicianId),
          ).thenAnswer((_) async => Right(mockStats));
          return bloc;
        },
        seed: () => TechnicianDashboardState(
          status: TechnicianDashboardStatus.success,
          stats: TechnicianStatsEntity.empty(),
        ),
        act: (bloc) => bloc.add(const RefreshDashboardStats(testTechnicianId)),
        expect: () => [
          predicate<TechnicianDashboardState>(
            (state) =>
                state.status == TechnicianDashboardStatus.success &&
                state.stats?.todayEarnings == 600.0,
          ),
        ],
        verify: (_) {
          verify(
            mockUserRepository.getTechnicianStats(testTechnicianId),
          ).called(1);
        },
      );
    });
  });
}
