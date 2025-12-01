// File: test/service_bloc_test.dart
// Purpose: Unit tests for ServiceBloc

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_repair_app/blocs/service/service_bloc.dart';
import 'package:home_repair_app/blocs/service/service_event.dart';
import 'package:home_repair_app/blocs/service/service_state.dart';
import 'package:home_repair_app/models/service_model.dart';
import 'package:home_repair_app/domain/repositories/i_service_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<IServiceRepository>()])
import 'service_bloc_test.mocks.dart';

void main() {
  group('ServiceBloc', () {
    late IServiceRepository mockServiceRepository;
    late ServiceBloc serviceBloc;

    final fixedDate = DateTime(2023, 1, 1);
    final mockServices = [
      ServiceModel(
        id: '1',
        name: 'Plumbing Service',
        description: 'Fix leaks',
        category: 'Plumbing',
        iconUrl: 'https://example.com/icon.png',
        avgPrice: 100,
        minPrice: 50,
        maxPrice: 150,
        visitFee: 20,
        avgCompletionTimeMinutes: 60,
        createdAt: fixedDate,
      ),
      ServiceModel(
        id: '2',
        name: 'Electrical Service',
        description: 'Fix wiring',
        category: 'Electrical',
        iconUrl: 'https://example.com/icon.png',
        avgPrice: 120,
        minPrice: 60,
        maxPrice: 180,
        visitFee: 25,
        avgCompletionTimeMinutes: 90,
        createdAt: fixedDate,
      ),
    ];

    setUp(() {
      mockServiceRepository = MockIServiceRepository();
      serviceBloc = ServiceBloc(serviceRepository: mockServiceRepository);
    });

    tearDown(() {
      serviceBloc.close();
    });

    test('initial state is correct', () {
      expect(serviceBloc.state, const ServiceState());
    });

    blocTest<ServiceBloc, ServiceState>(
      'emits [loading, success] when ServiceLoadRequested is added',
      setUp: () {
        when(
          mockServiceRepository.getServices(),
        ).thenAnswer((_) => Stream.value(mockServices));
      },
      build: () => serviceBloc,
      act: (bloc) => bloc.add(const ServiceLoadRequested()),
      expect: () => [
        const ServiceState(status: ServiceStatus.loading),
        ServiceState(
          status: ServiceStatus.success,
          services: mockServices,
          filteredServices: mockServices,
        ),
      ],
    );

    blocTest<ServiceBloc, ServiceState>(
      'filters services by search query',
      setUp: () {
        when(
          mockServiceRepository.getServices(),
        ).thenAnswer((_) => Stream.value(mockServices));
      },
      build: () => serviceBloc,
      act: (bloc) async {
        bloc.add(const ServiceLoadRequested());
        await Future.delayed(Duration.zero); // Wait for load
        bloc.add(const ServiceSearchChanged('Plumbing'));
      },
      skip: 1, // Skip loading state
      expect: () => [
        ServiceState(
          status: ServiceStatus.success,
          services: mockServices,
          filteredServices: mockServices,
        ),
        ServiceState(
          status: ServiceStatus.success,
          services: mockServices,
          filteredServices: [mockServices[0]],
          searchQuery: 'Plumbing',
        ),
      ],
    );

    blocTest<ServiceBloc, ServiceState>(
      'filters services by category',
      setUp: () {
        when(
          mockServiceRepository.getServices(),
        ).thenAnswer((_) => Stream.value(mockServices));
      },
      build: () => serviceBloc,
      act: (bloc) async {
        bloc.add(const ServiceLoadRequested());
        await Future.delayed(Duration.zero); // Wait for load
        bloc.add(const ServiceCategorySelected('Electrical'));
      },
      skip: 1, // Skip loading state
      expect: () => [
        ServiceState(
          status: ServiceStatus.success,
          services: mockServices,
          filteredServices: mockServices,
        ),
        ServiceState(
          status: ServiceStatus.success,
          services: mockServices,
          filteredServices: [mockServices[1]],
          selectedCategory: 'Electrical',
        ),
      ],
    );
  });
}
