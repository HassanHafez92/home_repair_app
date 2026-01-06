// File: lib/screens/admin/admin_dashboard_screen.dart
// Purpose: High-level statistics and activity feed for admin - House Maintenance style

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../blocs/admin/admin_bloc.dart';
import '../../blocs/admin/admin_event.dart';
import '../../blocs/admin/admin_state.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/wrappers.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const AdminDashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return PerformanceMonitorWrapper(
      screenName: 'AdminDashboardScreen',
      child: Scaffold(
        backgroundColor: DesignTokens.neutral100,
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state.status == AdminStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == AdminStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('errorMessage'.tr(args: [state.errorMessage ?? ''])),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AdminBloc>().add(
                          const AdminDashboardLoadRequested(),
                        );
                      },
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              );
            }

            final stats = state.stats;
            final recentActivity = state.recentActivity;

            if (stats == null) {
              return Center(child: Text('noDataAvailable'.tr()));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AdminBloc>().add(const AdminRefreshRequested());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(DesignTokens.spaceLG),
                      decoration: BoxDecoration(
                        gradient: DesignTokens.headerGradient,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusLG,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DesignTokens.primaryBlue.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome back, Admin! 👋',
                                  style: TextStyle(
                                    fontSize: DesignTokens.fontSizeXL,
                                    fontWeight: DesignTokens.fontWeightBold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Here\'s what\'s happening with your platform today.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.insights_rounded,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.4,
                      children: [
                        _StatCard(
                          title: 'totalUsers'.tr(),
                          value: stats.totalUsers.toString(),
                          icon: Icons.people_rounded,
                          color: DesignTokens.primaryBlue,
                          trend: '+12%',
                          trendUp: true,
                        ),
                        _StatCard(
                          title: 'activeOrders'.tr(),
                          value: stats.activeOrders.toString(),
                          icon: Icons.shopping_bag_rounded,
                          color: DesignTokens.accentOrange,
                          trend: '+5%',
                          trendUp: true,
                        ),
                        _StatCard(
                          title: 'revenue'.tr(),
                          value: '${stats.totalRevenue.toInt()} EGP',
                          icon: Icons.attach_money_rounded,
                          color: DesignTokens.accentGreen,
                          trend: '+18%',
                          trendUp: true,
                        ),
                        _StatCard(
                          title: 'pendingApprovals'.tr(),
                          value: stats.pendingApprovals.toString(),
                          icon: Icons.verified_user_rounded,
                          color: DesignTokens.error,
                          trend: '-3',
                          trendUp: false,
                        ),
                        _StatCard(
                          title: 'unverifiedUsers'.tr(),
                          value: stats.unverifiedUsers.toString(),
                          icon: Icons.email_outlined,
                          color: const Color(0xFF9333EA),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Recent Activity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'recentActivity'.tr(),
                          style: TextStyle(
                            fontSize: DesignTokens.fontSizeMD,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: DesignTokens.neutral900,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('viewAll'.tr()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (recentActivity.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text('noRecentActivity'.tr()),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusMD,
                          ),
                          boxShadow: DesignTokens.shadowSoft,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentActivity.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final order = recentActivity[index];
                            final timeAgo = DateTime.now().difference(
                              order.createdAt,
                            );
                            String timeString;
                            if (timeAgo.inMinutes < 60) {
                              timeString = 'minutesAgo'.tr(
                                args: [timeAgo.inMinutes.toString()],
                              );
                            } else if (timeAgo.inHours < 24) {
                              timeString = 'hoursAgo'.tr(
                                args: [timeAgo.inHours.toString()],
                              );
                            } else {
                              timeString = 'daysAgo'.tr(
                                args: [timeAgo.inDays.toString()],
                              );
                            }

                            return ListTile(
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: DesignTokens.primaryBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusSM,
                                  ),
                                ),
                                child: Icon(
                                  Icons.notifications_rounded,
                                  color: DesignTokens.primaryBlue,
                                ),
                              ),
                              title: Text(
                                'newOrderCreated'.tr(
                                  args: [order.id.substring(0, 8)],
                                ),
                                style: TextStyle(
                                  fontWeight: DesignTokens.fontWeightSemiBold,
                                ),
                              ),
                              subtitle: Text(
                                timeString,
                                style: TextStyle(
                                  color: DesignTokens.neutral500,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: DesignTokens.neutral400,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? trendUp;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        boxShadow: DesignTokens.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (trendUp == true
                                ? DesignTokens.accentGreen
                                : DesignTokens.error)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusFull,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp == true
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color: trendUp == true
                            ? DesignTokens.accentGreen
                            : DesignTokens.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeXS,
                          fontWeight: DesignTokens.fontWeightSemiBold,
                          color: trendUp == true
                              ? DesignTokens.accentGreen
                              : DesignTokens.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: DesignTokens.fontSizeLG,
                  fontWeight: DesignTokens.fontWeightBold,
                  color: DesignTokens.neutral900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: DesignTokens.fontSizeSM,
                  color: DesignTokens.neutral500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
