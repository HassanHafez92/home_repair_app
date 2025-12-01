// File: lib/screens/customer/service_details_screen.dart
// Purpose: Detailed view of a service with booking option.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/service_model.dart';
import '../../widgets/custom_button.dart';
import 'booking/booking_flow_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(service.name),
              background: Container(
                color: Colors.blue, // Placeholder for image
                child: const Center(
                  child: Icon(Icons.image, size: 80, color: Colors.white),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  Row(
                    children: [
                      Text(
                        '${service.minPrice.toInt()} - ${service.maxPrice.toInt()} EGP',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber),
                      Text(' 4.8 (120 ${'reviews'.tr()})'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'visitFee'.tr(args: [service.visitFee.toInt().toString()]),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'description'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Features (Placeholder)
                  Text(
                    'whatsIncluded'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem('professionalService'.tr()),
                  _buildFeatureItem('verifiedTechnician'.tr()),
                  _buildFeatureItem('warranty30Days'.tr()),

                  const SizedBox(height: 32),

                  // Book Button
                  CustomButton(
                    text: 'bookNow'.tr(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingFlowScreen(service: service),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
