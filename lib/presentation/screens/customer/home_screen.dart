import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_repair_app/utils/seed_data.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
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
import '../../widgets/wrappers.dart';

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

    return PerformanceMonitorWrapper(
      screenName: 'HomeScreen',
      child: Scaffold(
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
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceMD,
                vertical: DesignTokens.spaceXS,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AnimatedNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'home'.tr(),
                    isSelected: _currentIndex == 0,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _currentIndex = 0);
                    },
                  ),
                  _AnimatedNavItem(
                    icon: Icons.search_outlined,
                    activeIcon: Icons.search_rounded,
                    label: 'search'.tr(),
                    isSelected: _currentIndex == 1,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _currentIndex = 1);
                    },
                  ),
                  _AnimatedNavItem(
                    icon: Icons.shopping_bag_outlined,
                    activeIcon: Icons.shopping_bag_rounded,
                    label: 'orders'.tr(),
                    isSelected: _currentIndex == 2,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _currentIndex = 2);
                    },
                  ),
                  _AnimatedNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'profile'.tr(),
                    isSelected: _currentIndex == 3,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _currentIndex = 3);
                    },
                  ),
                ],
              ),
            ),
          ),
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
      case 'pest control':
        return Icons.pest_control_rounded;
      case 'appliance':
        return Icons.kitchen_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: DesignTokens.neutral100,
      body: CustomScrollView(
        slivers: [
          // House Maintenance Style Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: DesignTokens.headerGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(DesignTokens.radiusXL),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spaceLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row with greeting and menu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Greeting
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              final userName = authState is AuthAuthenticated
                                  ? authState.user.fullName.split(' ').first
                                  : 'guest'.tr();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Hello, Welcome ',
                                        style: TextStyle(
                                          fontSize: DesignTokens.fontSizeBase,
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        '👋',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: DesignTokens.fontSizeXL,
                                      fontWeight: DesignTokens.fontWeightBold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          // User Avatar
                          GestureDetector(
                            onTap: () => Scaffold.of(context).openEndDrawer(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  if (state is AuthAuthenticated &&
                                      state.user.fullName.isNotEmpty) {
                                    return Center(
                                      child: Text(
                                        state.user.fullName[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: DesignTokens.fontSizeLG,
                                          fontWeight:
                                              DesignTokens.fontWeightBold,
                                          color: DesignTokens.primaryBlue,
                                        ),
                                      ),
                                    );
                                  }
                                  return Icon(
                                    Icons.person,
                                    color: DesignTokens.primaryBlue,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: DesignTokens.spaceLG),

                      // Promotional Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(DesignTokens.spaceMD),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusLG,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Banner image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                DesignTokens.radiusMD,
                              ),
                              child: Image.asset(
                                'assets/images/promo_banner.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        DesignTokens.radiusMD,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.engineering,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: DesignTokens.spaceMD),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'bookOurServicesNow'.tr(),
                                    style: const TextStyle(
                                      fontSize: DesignTokens.fontSizeMD,
                                      fontWeight: DesignTokens.fontWeightBold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'getHomeFixed'.tr(),
                                    style: TextStyle(
                                      fontSize: DesignTokens.fontSizeSM,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SliverPadding(
            padding: const EdgeInsets.all(DesignTokens.spaceLG),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Choose a Service Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'chooseAService'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: DesignTokens.fontWeightBold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onTabChange(1),
                      child: Row(
                        children: [
                          Text(
                            'chooseAService'.tr(),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: DesignTokens.fontWeightSemiBold,
                              fontSize: DesignTokens.fontSizeSM,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spaceMD),

                // Services Grid - House Maintenance Style
                BlocBuilder<ServiceBloc, ServiceState>(
                  builder: (context, state) {
                    if (state.status == ServiceStatus.loading) {
                      return const _ServiceIconGridSkeleton();
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
                    final displayServices = services.take(8).toList();

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: DesignTokens.spaceMD,
                            mainAxisSpacing: DesignTokens.spaceMD,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: displayServices.length,
                      itemBuilder: (context, index) {
                        final service = displayServices[index];
                        return _ServiceIconCard(
                          icon: _getIconForCategory(service.category),
                          label: service.name.tr(),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              FadeScalePageRoute(
                                page: ServiceDetailsScreen(service: service),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: DesignTokens.spaceXL),

                // Most Popular Services in Your Area
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'mostPopularServices'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: DesignTokens.fontWeightBold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spaceMD),

                // Popular Services Horizontal Scroll
                BlocBuilder<ServiceBloc, ServiceState>(
                  builder: (context, state) {
                    if (state.services.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final popularServices = state.services.take(5).toList();

                    return SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: popularServices.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: DesignTokens.spaceMD),
                        itemBuilder: (context, index) {
                          final service = popularServices[index];
                          return _PopularServiceCard(
                            service: service,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                FadeScalePageRoute(
                                  page: ServiceDetailsScreen(service: service),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: DesignTokens.space2XL),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// House Maintenance style service icon card
class _ServiceIconCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ServiceIconCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DesignTokens.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              border: Border.all(
                color: DesignTokens.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, color: DesignTokens.primaryBlue, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: DesignTokens.fontSizeXS,
              fontWeight: DesignTokens.fontWeightMedium,
              color: DesignTokens.neutral700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Popular service card with image
class _PopularServiceCard extends StatelessWidget {
  final ServiceEntity service;
  final VoidCallback onTap;

  const _PopularServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          boxShadow: DesignTokens.shadowSoft,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DesignTokens.primaryBlue.withValues(alpha: 0.8),
                    DesignTokens.primaryBlueLight.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child:
                  service.iconUrl.isNotEmpty &&
                      (service.iconUrl.contains('http'))
                  ? Image.network(
                      service.iconUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.build_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 40,
                        );
                      },
                    )
                  : Icon(
                      Icons.build_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 40,
                    ),
            ),
            // Label
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceSM),
              child: Text(
                service.name.tr(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: DesignTokens.fontSizeSM,
                  fontWeight: DesignTokens.fontWeightSemiBold,
                  color: DesignTokens.neutral800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for service icon grid
class _ServiceIconGridSkeleton extends StatelessWidget {
  const _ServiceIconGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: DesignTokens.spaceMD,
        mainAxisSpacing: DesignTokens.spaceMD,
        childAspectRatio: 0.85,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: DesignTokens.neutral200,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 50,
              height: 12,
              decoration: BoxDecoration(
                color: DesignTokens.neutral200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Animated navigation item with scale effect
class _AnimatedNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? DesignTokens.primaryBlue
        : DesignTokens.neutral400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: DesignTokens.durationFast,
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? DesignTokens.spaceMD : DesignTokens.spaceSM,
          vertical: DesignTokens.spaceXS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignTokens.primaryBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: DesignTokens.durationFast,
              child: Icon(
                isSelected ? activeIcon : icon,
                color: color,
                size: DesignTokens.iconSizeMD,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: DesignTokens.durationFast,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected
                    ? DesignTokens.fontWeightBold
                    : DesignTokens.fontWeightMedium,
                fontFamily: DesignTokens.fontFamily,
                color: color,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
