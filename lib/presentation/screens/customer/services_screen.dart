// File: lib/screens/customer/services_screen.dart
// Purpose: Screen to browse all available services with search and filter.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/service_card.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import 'service_details_screen.dart';
import '../../blocs/service/service_bloc.dart';
import '../../blocs/service/service_event.dart';
import '../../blocs/service/service_state.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      appBar: AppBar(
        title: Text('allServices'.tr()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'searchServices'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                context.read<ServiceBloc>().add(ServiceSearchChanged(value));
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category Filter
          BlocBuilder<ServiceBloc, ServiceState>(
            buildWhen: (previous, current) =>
                previous.categories != current.categories ||
                previous.selectedCategory != current.selectedCategory,
            builder: (context, state) {
              if (state.categories.isEmpty) return const SizedBox.shrink();

              return SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.categories.length + 1,
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final category = isAll ? null : state.categories[index - 1];
                    final isSelected = state.selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(isAll ? 'all'.tr() : category!),
                        selected: isSelected,
                        onSelected: (selected) {
                          context.read<ServiceBloc>().add(
                            ServiceCategorySelected(selected ? category : null),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Services Grid
          Expanded(
            child: BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                if (state.status == ServiceStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == ServiceStatus.failure) {
                  return Center(child: Text('errorLoadingServices'.tr()));
                } else if (state.filteredServices.isEmpty) {
                  return Center(child: Text('noServicesFound'.tr()));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: state.filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = state.filteredServices[index];

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
          ),
        ],
      ),
    );
  }
}
