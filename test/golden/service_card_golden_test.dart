// File: test/golden/service_card_golden_test.dart
// Purpose: Golden tests for ServiceCard widget visual regression

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import 'package:home_repair_app/presentation/widgets/service_card.dart';
import 'package:home_repair_app/presentation/theme/app_theme_v2.dart';

void main() {
  group('ServiceCard Golden Tests', () {
    final testService = ServiceEntity(
      id: 'test-1',
      name: 'Plumbing Service',
      description: 'Fix leaks and pipes',
      category: 'Plumbing',
      iconUrl: '',
      avgPrice: 100,
      minPrice: 50,
      maxPrice: 150,
      visitFee: 20,
      avgCompletionTimeMinutes: 60,
      createdAt: DateTime(2024, 1, 1),
    );

    Widget buildTestWidget({required Brightness brightness}) {
      return MaterialApp(
        theme: brightness == Brightness.light
            ? AppThemeV2.lightTheme
            : AppThemeV2.darkTheme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: ServiceCard(service: testService, onTap: () {}),
            ),
          ),
        ),
      );
    }

    testWidgets('ServiceCard light mode matches golden', (tester) async {
      await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ServiceCard),
        matchesGoldenFile('goldens/service_card_light.png'),
      );
    });

    testWidgets('ServiceCard dark mode matches golden', (tester) async {
      await tester.pumpWidget(buildTestWidget(brightness: Brightness.dark));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ServiceCard),
        matchesGoldenFile('goldens/service_card_dark.png'),
      );
    });
  });
}
