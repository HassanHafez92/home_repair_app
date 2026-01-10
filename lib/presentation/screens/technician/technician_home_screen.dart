import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../helpers/auth_helper.dart';
import '../../blocs/technician_dashboard/technician_dashboard_bloc.dart';
import '../../blocs/order/technician_order_bloc.dart';
import '../../widgets/order_map_view.dart';
import '../../theme/design_tokens.dart';
import 'incoming_orders_screen.dart';
import 'active_jobs_screen.dart';
import 'earnings_screen.dart';
import 'technician_profile_screen.dart';
import '../../widgets/wrappers.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      TechnicianDashboard(
        onTabChanged: (index) => setState(() => _currentIndex = index),
      ),
      const IncomingOrdersScreen(),
      const ActiveJobsScreen(),
      const EarningsScreen(),
      const TechnicianProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PerformanceMonitorWrapper(
      screenName: 'TechnicianHomeScreen',
      child: Scaffold(
        body: _screens[_currentIndex],
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
                    icon: Icons.inbox_outlined,
                    activeIcon: Icons.inbox_rounded,
                    label: 'orders'.tr(),
                    isSelected: _currentIndex == 1,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _currentIndex = 1);
                    },
                  ),
                  _AnimatedNavItem(
                    icon: Icons.work_outline_rounded,
                    activeIcon: Icons.work_rounded,
                    label: 'jobs'.tr(),
                    isSelected: _currentIndex == 2,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _currentIndex = 2);
                    },
                  ),
                  _AnimatedNavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    activeIcon: Icons.account_balance_wallet_rounded,
                    label: 'earnings'.tr(),
                    isSelected: _currentIndex == 3,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _currentIndex = 3);
                    },
                  ),
                  _AnimatedNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'profile'.tr(),
                    isSelected: _currentIndex == 4,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _currentIndex = 4);
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

class TechnicianDashboard extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  const TechnicianDashboard({super.key, this.onTabChanged});

  @override
  State<TechnicianDashboard> createState() => _TechnicianDashboardState();
}

class _TechnicianDashboardState extends State<TechnicianDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userId = context.userId;
        if (userId != null) {
          context.read<TechnicianDashboardBloc>().add(
            LoadTechnicianDashboard(userId),
          );
          context.read<TechnicianOrderBloc>().add(LoadTechnicianOrders(userId));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.userId;
    final user = context.currentUser;

    if (userId == null) {
      return Scaffold(body: Center(child: Text('pleaseLogin'.tr())));
    }

    return Scaffold(
      backgroundColor: DesignTokens.neutral100,
      body: BlocBuilder<TechnicianDashboardBloc, TechnicianDashboardState>(
        builder: (context, dashboardState) {
          if (dashboardState.status == TechnicianDashboardStatus.loading &&
              dashboardState.stats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboardState.status == TechnicianDashboardStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'errorMessage'.tr(
                      args: [dashboardState.errorMessage ?? ''],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TechnicianDashboardBloc>().add(
                        RefreshDashboardStats(userId),
                      );
                      context.read<TechnicianOrderBloc>().add(
                        LoadTechnicianOrders(userId),
                      );
                    },
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          final stats = dashboardState.stats;
          if (stats == null) {
            return Center(child: Text('noDataAvailable'.tr()));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TechnicianDashboardBloc>().add(
                RefreshDashboardStats(userId),
              );
              context.read<TechnicianOrderBloc>().add(
                LoadTechnicianOrders(userId),
              );
            },
            child: CustomScrollView(
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
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Welcome
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'welcomeBack'.tr(),
                                          style: TextStyle(
                                            fontSize: DesignTokens.fontSizeBase,
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          '👋',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.fullName ?? 'technician'.tr(),
                                      style: const TextStyle(
                                        fontSize: DesignTokens.fontSizeXL,
                                        fontWeight: DesignTokens.fontWeightBold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                // Availability & Notification
                                Row(
                                  children: [
                                    // Availability Toggle
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: dashboardState.isAvailable
                                            ? DesignTokens.accentGreen
                                                  .withValues(alpha: 0.2)
                                            : Colors.white.withValues(
                                                alpha: 0.15,
                                              ),
                                        borderRadius: BorderRadius.circular(
                                          DesignTokens.radiusFull,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: dashboardState.isAvailable
                                                  ? DesignTokens.accentGreen
                                                  : DesignTokens.neutral400,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            dashboardState.isAvailable
                                                ? 'available'.tr()
                                                : 'unavailable'.tr(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: DesignTokens.fontSizeXS,
                                              fontWeight:
                                                  DesignTokens.fontWeightMedium,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: () {
                                              context
                                                  .read<
                                                    TechnicianDashboardBloc
                                                  >()
                                                  .add(
                                                    ToggleAvailability(
                                                      technicianId: userId,
                                                      isAvailable:
                                                          !dashboardState
                                                              .isAvailable,
                                                    ),
                                                  );
                                            },
                                            child: Icon(
                                              Icons.toggle_on,
                                              color: dashboardState.isAvailable
                                                  ? DesignTokens.accentGreen
                                                  : Colors.white54,
                                              size: 28,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Notification
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.notifications_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: DesignTokens.spaceLG),

                            // Quick Stats Row
                            Row(
                              children: [
                                _QuickStat(
                                  icon: Icons.attach_money,
                                  label: 'todaysEarnings'.tr(),
                                  value: '${stats.todayEarnings.toInt()} EGP',
                                ),
                                const SizedBox(width: DesignTokens.spaceMD),
                                _QuickStat(
                                  icon: Icons.check_circle_outline,
                                  label: 'completed'.tr(),
                                  value: stats.completedJobsToday.toString(),
                                ),
                                const SizedBox(width: DesignTokens.spaceMD),
                                _QuickStat(
                                  icon: Icons.star_outline,
                                  label: 'rating'.tr(),
                                  value: stats.rating.toStringAsFixed(1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Content
                SliverPadding(
                  padding: const EdgeInsets.all(DesignTokens.spaceLG),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Map View for Active Orders
                      Text(
                        'activeJobsMap'.tr(),
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeMD,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: DesignTokens.neutral900,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceMD),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusMD,
                          ),
                          boxShadow: DesignTokens.shadowSoft,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child:
                            BlocBuilder<
                              TechnicianOrderBloc,
                              TechnicianOrderState
                            >(
                              builder: (context, orderState) {
                                return OrderMapView(
                                  orders: orderState.activeOrders,
                                  height: 180,
                                  onOrderTapped: (order) {
                                    context.push(
                                      '/technician/order/${order.id}',
                                    );
                                  },
                                );
                              },
                            ),
                      ),
                      const SizedBox(height: DesignTokens.spaceXL),

                      // Pending Orders Card
                      _DashboardCard(
                        icon: Icons.pending_actions,
                        iconColor: DesignTokens.accentOrange,
                        title: 'pendingOrders'.tr(),
                        value: stats.pendingOrders.toString(),
                        subtitle: 'ordersWaiting'.tr(),
                        onTap: () => widget.onTabChanged?.call(1),
                      ),
                      const SizedBox(height: DesignTokens.spaceMD),

                      // Today's Schedule
                      Text(
                        'todaysSchedule'.tr(),
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeMD,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: DesignTokens.neutral900,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceMD),
                      _ScheduleItem(
                        time: '10:00 AM',
                        title: 'AC Repair',
                        location: 'Downtown',
                        color: DesignTokens.primaryBlue,
                      ),
                      _ScheduleItem(
                        time: '02:00 PM',
                        title: 'Plumbing',
                        location: 'Maadi',
                        color: DesignTokens.accentGreen,
                      ),
                      const SizedBox(height: DesignTokens.spaceXL),

                      // Quick Actions
                      Text(
                        'quickActions'.tr(),
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeMD,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: DesignTokens.neutral900,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceMD),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.inbox_rounded,
                              label: 'viewOrders'.tr(),
                              onTap: () => widget.onTabChanged?.call(1),
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spaceMD),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.work_rounded,
                              label: 'activeJobs'.tr(),
                              onTap: () => widget.onTabChanged?.call(2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.space2XL),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Quick stat widget for header
class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spaceSM),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: DesignTokens.fontSizeMD,
                fontWeight: DesignTokens.fontWeightBold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: DesignTokens.fontSizeXS,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard card widget
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback? onTap;

  const _DashboardCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '$title: $value',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spaceMD),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            boxShadow: DesignTokens.shadowSoft,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: DesignTokens.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: DesignTokens.fontSizeSM,
                        color: DesignTokens.neutral500,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: DesignTokens.fontSizeLG,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: DesignTokens.neutral900,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: DesignTokens.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}

/// Schedule item widget
class _ScheduleItem extends StatelessWidget {
  final String time;
  final String title;
  final String location;
  final Color color;

  const _ScheduleItem({
    required this.time,
    required this.title,
    required this.location,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceSM),
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        boxShadow: DesignTokens.shadowSoft,
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: DesignTokens.fontSizeXS,
                fontWeight: DesignTokens.fontWeightBold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: DesignTokens.neutral900,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: DesignTokens.fontSizeSM,
                    color: DesignTokens.neutral500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: DesignTokens.neutral400),
        ],
      ),
    );
  }
}

/// Action button widget
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.spaceMD),
            decoration: BoxDecoration(
              color: DesignTokens.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              border: Border.all(
                color: DesignTokens.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(widget.icon, size: 28, color: DesignTokens.primaryBlue),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: DesignTokens.primaryBlue,
                    fontSize: DesignTokens.fontSizeSM,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated navigation item
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
                fontSize: 10,
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
