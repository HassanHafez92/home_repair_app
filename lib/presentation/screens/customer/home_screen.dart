import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_repair_app/utils/seed_data.dart';
import '../../widgets/service_card.dart';
import '../../widgets/fixawy_service_card.dart';
import '../../widgets/skeleton_loader.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import '../../widgets/hero_carousel.dart';
import '../../widgets/testimonials_section.dart';
import '../../widgets/location_selector.dart';
import '../../widgets/quick_action_bar.dart';
import '../../widgets/popular_services_section.dart';
import '../../utils/responsive_utils.dart';
import '../../theme/page_transitions.dart';
import 'services_screen.dart';
import 'service_details_screen.dart';
import 'orders_screen.dart';

import 'profile_screen.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/service/service_bloc.dart';
import '../../blocs/service/service_state.dart';
import '../../blocs/service/service_event.dart';
import '../../theme/design_tokens.dart';
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
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: _screens[_currentIndex],
      endDrawer: AppDrawer(
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: colorScheme.surface,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: DesignTokens.neutral400,
          selectedLabelStyle: TextStyle(
            fontWeight: DesignTokens.fontWeightBold,
            fontSize: 12,
            fontFamily: DesignTokens.fontFamily,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: DesignTokens.fontWeightMedium,
            fontSize: 12,
            fontFamily: DesignTokens.fontFamily,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                  _currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                ),
              ),
              label: 'home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                  _currentIndex == 1
                      ? Icons.grid_view_rounded
                      : Icons.grid_view_outlined,
                ),
              ),
              label: 'services'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                  _currentIndex == 2
                      ? Icons.receipt_long_rounded
                      : Icons.receipt_long_outlined,
                ),
              ),
              label: 'orders'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                  _currentIndex == 3
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                ),
              ),
              label: 'account'.tr(),
            ),
          ],
        ),
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
        return Icons.plumbing_rounded;
      case 'electrical':
        return Icons.electrical_services_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'painting':
        return Icons.format_paint_rounded;
      case 'carpentry':
        return Icons.handyman_rounded;
      case 'ac repair':
        return Icons.ac_unit_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Premium Personalized App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceLG,
                ),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final userName = authState is AuthAuthenticated
                        ? authState.user.fullName.split(' ').first
                        : 'guest'.tr();
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'greeting'.tr(namedArgs: {'name': userName}),
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: DesignTokens.fontWeightBold,
                          ),
                        ),
                        Text(
                          'howCanWeHelp'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: DesignTokens.neutral500,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spaceLG),
                      ],
                    );
                  },
                ),
              ),
            ),
            actions: [
              // Search Button
              IconButton(
                onPressed: () => onTabChange(1),
                icon: Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceXS),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
              // Location Selector
              const LocationSelector(),
              const SizedBox(width: DesignTokens.spaceXS),
              // Menu Button
              IconButton(
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                icon: Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceXS),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Icon(
                    Icons.menu_rounded,
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceBase),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceLG,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: DesignTokens.spaceMD),

                // Modern Search Bar
                GestureDetector(
                  onTap: () => onTabChange(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceMD,
                      vertical: DesignTokens.spaceMD,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMD,
                      ),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.5),
                      ),
                      boxShadow: DesignTokens.shadowSoft,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: DesignTokens.spaceSM),
                        Text(
                          'searchService'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: DesignTokens.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: DesignTokens.spaceMD),

                // Quick Action Bar (Emergency / Schedule)
                const QuickActionBar(),

                const SizedBox(height: DesignTokens.spaceXL),

                // Hero Carousel
                HeroCarousel.withDefaultSlides(onCtaTap: () => onTabChange(1)),

                const SizedBox(height: DesignTokens.spaceLG),

                // Popular Services Section
                BlocBuilder<ServiceBloc, ServiceState>(
                  builder: (context, state) {
                    if (state.services.isNotEmpty) {
                      return PopularServicesSection(
                        services: state.services.take(5).toList(),
                        onServiceTap: (service) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ServiceDetailsScreen(service: service),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: DesignTokens.spaceXL),

                // Categories / Services Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'What a Service Looking For'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: DesignTokens.fontWeightBold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onTabChange(1),
                      child: Text(
                        'showAll'.tr(),
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: DesignTokens.fontWeightBold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spaceBase),

                // Services Grid
                BlocBuilder<ServiceBloc, ServiceState>(
                  builder: (context, state) {
                    if (state.status == ServiceStatus.loading) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount =
                              ResponsiveBreakpoints.getGridColumns(
                                constraints.maxWidth,
                              );
                          return SkeletonServiceGrid(
                            itemCount: 6,
                            crossAxisCount: min(crossAxisCount, 3),
                          );
                        },
                      );
                    } else if (state.status == ServiceStatus.failure) {
                      return Center(child: Text('errorLoadingServices'.tr()));
                    } else if (state.services.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('noServicesAvailable'.tr()),
                            if (kDebugMode) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () async {
                                  await SeedData.seedServices();
                                  if (context.mounted) {
                                    context.read<ServiceBloc>().add(
                                      const ServiceLoadRequested(),
                                    );
                                  }
                                },
                                child: const Text('Seed Data (Debug Only)'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    final services = state.services;

                    // Responsive grid with Fixawy-style cards
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            ResponsiveBreakpoints.getGridColumns(
                              constraints.maxWidth,
                            );
                        final aspectRatio =
                            ResponsiveBreakpoints.getCardAspectRatio(
                              constraints.maxWidth,
                            );

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: min(
                                  crossAxisCount,
                                  3,
                                ), // Cap at 3 for home
                                crossAxisSpacing: DesignTokens.spaceMD,
                                mainAxisSpacing: DesignTokens.spaceMD,
                                childAspectRatio: aspectRatio,
                              ),
                          itemCount: min(services.length, 6),
                          itemBuilder: (context, index) {
                            final service = services[index];
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

                            // Use Fixawy card for photo URLs, original for icons
                            final isPhotoUrl =
                                service.iconUrl.toLowerCase().contains(
                                  'unsplash',
                                ) ||
                                service.iconUrl.toLowerCase().contains(
                                  'pexels',
                                );

                            if (isPhotoUrl) {
                              return FixawyServiceCard(
                                service: localizedService,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    FadeScalePageRoute(
                                      page: ServiceDetailsScreen(
                                        service: localizedService,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }

                            return ServiceCard(
                              service: localizedService,
                              iconData: _getIconForCategory(service.category),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  FadeScalePageRoute(
                                    page: ServiceDetailsScreen(
                                      service: localizedService,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: DesignTokens.spaceXL),

                // "View more services" CTA
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => onTabChange(1),
                    child: Text('viewMoreServices'.tr()),
                  ),
                ),
              ]),
            ),
          ),

          // Customer Testimonials Section (outside SliverPadding for proper full-width scroll)
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: DesignTokens.spaceXL),
                const TestimonialsSection(),
                const SizedBox(height: DesignTokens.space2XL),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
