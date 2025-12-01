import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MigrationUtils {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Migrates existing orders to include the customer's phone number.
  /// This is a one-time migration script.
  static Future<void> migrateOrdersAddPhoneNumber() async {
    debugPrint('Starting migration: migrateOrdersAddPhoneNumber');
    int updatedCount = 0;
    int skippedCount = 0;
    int errorCount = 0;

    try {
      // Fetch all orders
      final ordersSnapshot = await _db.collection('orders').get();
      debugPrint('Found ${ordersSnapshot.docs.length} orders to check.');

      for (final orderDoc in ordersSnapshot.docs) {
        try {
          final data = orderDoc.data();

          // Check if phone number is already present
          if (data.containsKey('customerPhoneNumber') &&
              data['customerPhoneNumber'] != null) {
            skippedCount++;
            continue;
          }

          final customerId = data['customerId'] as String?;
          if (customerId == null) {
            debugPrint('Order ${orderDoc.id} has no customerId. Skipping.');
            errorCount++;
            continue;
          }

          // Fetch customer details
          final userDoc = await _db.collection('users').doc(customerId).get();
          if (!userDoc.exists) {
            debugPrint(
              'Customer $customerId not found for order ${orderDoc.id}. Skipping.',
            );
            errorCount++;
            continue;
          }

          final phoneNumber = userDoc.data()?['phoneNumber'] as String?;
          if (phoneNumber == null) {
            debugPrint(
              'Customer $customerId has no phone number. Skipping order ${orderDoc.id}.',
            );
            errorCount++;
            continue;
          }

          // Update order with phone number
          await orderDoc.reference.update({'customerPhoneNumber': phoneNumber});

          updatedCount++;
          if (updatedCount % 10 == 0) {
            debugPrint('Migrated $updatedCount orders...');
          }
        } catch (e) {
          debugPrint('Error migrating order ${orderDoc.id}: $e');
          errorCount++;
        }
      }

      debugPrint('Migration completed.');
      debugPrint('Updated: $updatedCount');
      debugPrint('Skipped: $skippedCount');
      debugPrint('Errors: $errorCount');
    } catch (e) {
      debugPrint('Fatal error during migration: $e');
    }
  }
}
