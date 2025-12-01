// Widget tests for the Home Repair App

import 'package:flutter_test/flutter_test.dart';
import 'package:home_repair_app/data/services_data.dart';

void main() {
  group('Services Data Tests', () {
    test('Services data is properly loaded', () {
      // Verify that services data has the expected number of items
      expect(servicesData.length, 25);

      // Verify first service has required fields
      final firstService = servicesData.first;
      expect(firstService.service.id, isNotEmpty);
      expect(firstService.service.name, isNotEmpty);
      expect(firstService.icon, isNotNull);
    });

    test('Services have valid pricing', () {
      // Verify all services have valid pricing
      for (final serviceItem in servicesData) {
        expect(serviceItem.service.minPrice, greaterThan(0));
        expect(
          serviceItem.service.maxPrice,
          greaterThanOrEqualTo(serviceItem.service.minPrice),
        );
        expect(serviceItem.service.avgPrice, greaterThan(0));
        expect(serviceItem.service.visitFee, greaterThanOrEqualTo(0));
      }
    });

    test('All services have unique IDs', () {
      final ids = servicesData.map((s) => s.service.id).toList();
      final uniqueIds = ids.toSet();

      expect(
        ids.length,
        equals(uniqueIds.length),
        reason: 'All service IDs should be unique',
      );
    });

    test('All services have valid categories', () {
      for (final serviceItem in servicesData) {
        expect(
          serviceItem.service.category,
          isNotEmpty,
          reason: 'Service ${serviceItem.service.id} should have a category',
        );
      }
    });

    test('All services have reasonable completion times', () {
      for (final serviceItem in servicesData) {
        expect(
          serviceItem.service.avgCompletionTimeMinutes,
          greaterThan(0),
          reason:
              'Service ${serviceItem.service.id} should have a positive completion time',
        );
        expect(
          serviceItem.service.avgCompletionTimeMinutes,
          lessThan(1440),
          reason:
              'Service ${serviceItem.service.id} completion time should be less than 24 hours',
        );
      }
    });
  });
}
