// File: lib/screens/customer/home_screen.dart
// Purpose: Main dashboard for the customer app.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/service_card.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import '../../widgets/promotional_banner.dart';
import 'services_screen.dart';
import 'service_details_screen.dart';
import 'orders_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';
import '../../blocs/service/service_bloc.dart';
import '../../blocs/service/service_state.dart';

import '../../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const ServicesScreen(),
      const OrdersScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      endDrawer: AppDrawer(
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view),
            label: 'services'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: 'orders'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: 'wallet'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'account'.tr(),
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final Function(int) onTabChange;

  const HomeContent({super.key, required this.onTabChange});

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'painting':
        return Icons.format_paint;
      case 'carpentry':
        return Icons.handyman;
      case 'ac repair':
        return Icons.ac_unit;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Logo and Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home_repair_service,
                    color: Colors.deepOrange,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  icon: const Icon(Icons.menu, size: 28, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Promotional Banner
            PromotionalBanner(
              onTap: () {
                onTabChange(1);
              },
            ),
            const SizedBox(height: 24),

            // "What service are you looking for?" Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'What a Service Looking For'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onTabChange(1);
                  },
                  child: Text(
                    'showAll'.tr(),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Services Grid
            BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                if (state.status == ServiceStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == ServiceStatus.failure) {
                  return Center(child: Text('errorLoadingServices'.tr()));
                } else if (state.services.isEmpty) {
                  return Center(child: Text('noServicesAvailable'.tr()));
                }

                final services = state.services;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: min(services.length, 6),
                  itemBuilder: (context, index) {
                    final service = services[index];

                    // Create a localized copy of the service
                    final localizedService = ServiceEntity(
                      id: service.id,
                      name: service.name.tr(),
                      description: service.description,
                      iconUrl: service.iconUrl,
                      category: service.category,
                      avgPrice: service.avgPrice,
                      minPrice: service.minPrice,
                      maxPrice: service.maxPrice,
                      visitFee: service.visitFee,
                      avgCompletionTimeMinutes:
                          service.avgCompletionTimeMinutes,
                      createdAt: service.createdAt,
                    );

                    return ServiceCard(
                      service: localizedService,
                      iconData: _getIconForCategory(service.category),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ServiceDetailsScreen(service: localizedService),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // "View more services" Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onTabChange(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'viewMoreServices'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
