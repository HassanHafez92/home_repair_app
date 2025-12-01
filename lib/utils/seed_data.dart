// File: lib/utils/seed_data.dart
// Purpose: Seed sample data for testing the application

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class SeedData {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Seeds sample services to Firestore
  static Future<int> seedServices() async {
    print('🌱 Starting to seed services...');

    final services = [
      ServiceModel(
        id: 'service_plumbing',
        name: 'Plumbing Services',
        description:
            'Professional plumbing repair and installation services. Fix leaks, install fixtures, and more.',
        category: 'Plumbing',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/2332/2332688.png',
        avgPrice: 150.0,
        minPrice: 100.0,
        maxPrice: 300.0,
        visitFee: 50.0,
        avgCompletionTimeMinutes: 120,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'service_electrical',
        name: 'Electrical Services',
        description:
            'Expert electrical repairs, installations, and troubleshooting. Licensed electricians.',
        category: 'Electrical',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/1087/1087927.png',
        avgPrice: 200.0,
        minPrice: 150.0,
        maxPrice: 400.0,
        visitFee: 60.0,
        avgCompletionTimeMinutes: 90,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'service_ac_repair',
        name: 'AC Repair & Maintenance',
        description:
            'Air conditioning repair, maintenance, and installation. Keep your home cool.',
        category: 'AC Repair',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/2917/2917995.png',
        avgPrice: 250.0,
        minPrice: 180.0,
        maxPrice: 500.0,
        visitFee: 70.0,
        avgCompletionTimeMinutes: 150,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'service_carpentry',
        name: 'Carpentry Services',
        description:
            'Custom furniture, repairs, and woodworking. Professional carpenters at your service.',
        category: 'Carpentry',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/2917/2917906.png',
        avgPrice: 180.0,
        minPrice: 120.0,
        maxPrice: 350.0,
        visitFee: 40.0,
        avgCompletionTimeMinutes: 180,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'service_painting',
        name: 'Painting Services',
        description:
            'Interior and exterior painting. Transform your space with professional painters.',
        category: 'Painting',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/3039/3039393.png',
        avgPrice: 120.0,
        minPrice: 80.0,
        maxPrice: 250.0,
        visitFee: 30.0,
        avgCompletionTimeMinutes: 240,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'service_appliances',
        name: 'Appliance Repair',
        description:
            'Repair washing machines, refrigerators, ovens, and all household appliances.',
        category: 'Appliances',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/2917/2917874.png',
        avgPrice: 160.0,
        minPrice: 100.0,
        maxPrice: 300.0,
        visitFee: 50.0,
        avgCompletionTimeMinutes: 90,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'service_cleaning',
        name: 'Home Cleaning',
        description:
            'Professional deep cleaning services for your home. Spotless results guaranteed.',
        category: 'Cleaning',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/2917/2917718.png',
        avgPrice: 100.0,
        minPrice: 60.0,
        maxPrice: 200.0,
        visitFee: 20.0,
        avgCompletionTimeMinutes: 120,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'service_pest_control',
        name: 'Pest Control',
        description:
            'Eliminate pests safely and effectively. Licensed pest control experts.',
        category: 'Pest Control',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/2917/2917641.png',
        avgPrice: 140.0,
        minPrice: 90.0,
        maxPrice: 280.0,
        visitFee: 40.0,
        avgCompletionTimeMinutes: 60,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'service_furniture_cleaning',
        name: 'Furniture Cleaning',
        description:
            'Deep cleaning for sofas, carpets, and upholstery. Remove stains and odors.',
        category: 'Furniture Cleaning',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/2558/2558066.png',
        avgPrice: 180.0,
        minPrice: 100.0,
        maxPrice: 400.0,
        visitFee: 50.0,
        avgCompletionTimeMinutes: 90,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'service_marble',
        name: 'Marble Work',
        description:
            'Marble polishing, restoration, and installation. Bring back the shine.',
        category: 'Marble Work',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/4394/4394663.png',
        avgPrice: 300.0,
        minPrice: 200.0,
        maxPrice: 800.0,
        visitFee: 80.0,
        avgCompletionTimeMinutes: 180,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'service_aluminum',
        name: 'Aluminum Work',
        description:
            'Aluminum window and door repairs, installation, and fabrication.',
        category: 'Aluminum Work',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/3059/3059448.png',
        avgPrice: 250.0,
        minPrice: 150.0,
        maxPrice: 600.0,
        visitFee: 60.0,
        avgCompletionTimeMinutes: 120,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    try {
      final batch = _db.batch();

      for (final service in services) {
        final docRef = _db.collection('services').doc(service.id);
        batch.set(docRef, service.toJson());
      }

      await batch.commit();
      print('✅ Successfully seeded ${services.length} services!');
      return services.length;
    } catch (e) {
      print('❌ Error seeding services: $e');
      rethrow;
    }
  }

  /// Run all seed operations
  static Future<void> seedAll() async {
    print('🚀 Starting database seeding...\n');

    try {
      await seedServices();
      print('\n🎉 All sample data seeded successfully!');
      print('📝 You can now test the app with the sample services.');
    } catch (e) {
      print('\n💥 Seeding failed: $e');
      rethrow;
    }
  }
}
