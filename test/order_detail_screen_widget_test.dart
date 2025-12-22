// File: test/order_detail_screen_widget_test.dart
// Purpose: Widget tests for OrderDetailScreen

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:home_repair_app/presentation/screens/technician/order_detail_screen.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  SharedPreferences.setMockInitialValues({});
  await ez.EasyLocalization.ensureInitialized();

  Widget createTestWidget(OrderEntity order) {
    return ez.EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MaterialApp(home: OrderDetailScreen(order: order)),
    );
  }

  final testOrder = OrderEntity(
    id: 'test-order-id',
    customerId: 'customer-123',
    serviceId: 'service-456',
    status: OrderStatus.pending,
    description: 'Test repair description',
    address: '123 Test Street, Test City',
    location: const {'latitude': 30.0444, 'longitude': 31.2357},
    dateRequested: DateTime(2024, 1, 1),
    initialEstimate: 150.0,
    visitFee: 50.0,
    vat: 0.15,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    serviceName: 'Plumbing Service',
    customerName: 'John Doe',
  );

  group('OrderDetailScreen Widget Tests', () {
    testWidgets('displays service name correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testOrder));
      await tester.pumpAndSettle();

      expect(find.text('Plumbing Service'), findsOneWidget);
    });

    testWidgets('displays customer name correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(testOrder));
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays address correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testOrder));
      await tester.pumpAndSettle();

      expect(find.text('123 Test Street, Test City'), findsOneWidget);
    });

    testWidgets('shows action buttons for pending orders', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(testOrder));
      await tester.pumpAndSettle();

      // Look for accept and reject buttons by type (expect keys if localization fails)
      expect(
        find.widgetWithText(ElevatedButton, 'acceptOrder'),
        findsOneWidget,
      );
      expect(find.widgetWithText(OutlinedButton, 'reject'), findsOneWidget);
    });

    testWidgets('does not show action buttons for accepted orders', (
      WidgetTester tester,
    ) async {
      final acceptedOrder = testOrder.copyWith(status: OrderStatus.accepted);
      await tester.pumpWidget(createTestWidget(acceptedOrder));
      await tester.pumpAndSettle();

      // Action buttons should not be present
      expect(find.widgetWithText(OutlinedButton, 'reject'), findsNothing);
    });

    testWidgets('shows navigate button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testOrder));
      await tester.pumpAndSettle();

      expect(find.text('navigateToCustomer'), findsOneWidget);
    });

    testWidgets('shows unknown service when serviceName is null', (
      WidgetTester tester,
    ) async {
      final orderWithoutServiceName = OrderEntity(
        id: 'test-order-id',
        customerId: 'customer-123',
        serviceId: 'service-456',
        status: OrderStatus.pending,
        description: 'Test repair description',
        address: '123 Test Street, Test City',
        location: const {'latitude': 30.0444, 'longitude': 31.2357},
        dateRequested: DateTime(2024, 1, 1),
        initialEstimate: 150.0,
        visitFee: 50.0,
        vat: 0.15,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        serviceName: null, // Explicitly null
        customerName: 'John Doe',
      );
      await tester.pumpWidget(createTestWidget(orderWithoutServiceName));
      await tester.pumpAndSettle();

      expect(find.text('Unknown Service'), findsOneWidget);
    });

    testWidgets('shows unknown customer when customerName is null', (
      WidgetTester tester,
    ) async {
      final orderWithoutCustomerName = OrderEntity(
        id: 'test-order-id',
        customerId: 'customer-123',
        serviceId: 'service-456',
        status: OrderStatus.pending,
        description: 'Test repair description',
        address: '123 Test Street, Test City',
        location: const {'latitude': 30.0444, 'longitude': 31.2357},
        dateRequested: DateTime(2024, 1, 1),
        initialEstimate: 150.0,
        visitFee: 50.0,
        vat: 0.15,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        serviceName: 'Plumbing Service',
        customerName: null, // Explicitly null
      );
      await tester.pumpWidget(createTestWidget(orderWithoutCustomerName));
      await tester.pumpAndSettle();

      expect(find.text('Unknown Customer'), findsOneWidget);
    });

    testWidgets('displays status badge', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testOrder));
      await tester.pumpAndSettle();

      // Look for status text (uppercase)
      expect(find.text('PENDING'), findsOneWidget);
    });
  });
}
