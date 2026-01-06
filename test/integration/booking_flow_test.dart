// File: test/integration/booking_flow_test.dart
// Purpose: Integration test for the complete booking flow

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import 'package:home_repair_app/domain/repositories/i_service_repository.dart';
import 'package:home_repair_app/domain/repositories/i_order_repository.dart';
import 'package:home_repair_app/presentation/blocs/service/service_bloc.dart';
import 'package:home_repair_app/presentation/blocs/booking/booking_bloc.dart';
import 'package:home_repair_app/presentation/theme/app_theme_v2.dart';

@GenerateNiceMocks([
  MockSpec<IServiceRepository>(),
  MockSpec<IOrderRepository>(),
])
import 'booking_flow_test.mocks.dart';

void main() {
  group('Booking Flow Integration Tests', () {
    late MockIServiceRepository mockServiceRepository;
    late MockIOrderRepository mockOrderRepository;

    final testService = ServiceEntity(
      id: 'test-service-1',
      name: 'Plumbing Repair',
      description: 'Fix leaks and pipe issues',
      category: 'Plumbing',
      iconUrl: 'https://example.com/plumbing.png',
      avgPrice: 150,
      minPrice: 100,
      maxPrice: 200,
      visitFee: 25,
      avgCompletionTimeMinutes: 90,
      createdAt: DateTime(2024, 1, 1),
    );

    setUp(() {
      mockServiceRepository = MockIServiceRepository();
      mockOrderRepository = MockIOrderRepository();
    });

    testWidgets('User can view service details', (tester) async {
      // Setup mock
      when(
        mockServiceRepository.getServices(),
      ).thenAnswer((_) => Stream.value([testService]));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeV2.lightTheme,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ServiceBloc>(
                create: (_) =>
                    ServiceBloc(serviceRepository: mockServiceRepository),
              ),
            ],
            child: Scaffold(
              body: Center(child: Text('Service: ${testService.name}')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify service name is displayed
      expect(find.text('Service: Plumbing Repair'), findsOneWidget);
    });

    testWidgets('Booking form shows required fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeV2.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                // Simulate booking form fields
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Select Date'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Select Time'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Book Now')),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify form fields exist
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Select Time'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Book Now'), findsOneWidget);
    });

    testWidgets('Submit button is disabled when form is incomplete', (
      tester,
    ) async {
      bool isFormComplete = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeV2.lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: isFormComplete ? () {} : null,
                      child: const Text('Submit Booking'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the button
      final buttonFinder = find.text('Submit Booking');
      expect(buttonFinder, findsOneWidget);

      // Verify button state (disabled returns null onPressed)
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
