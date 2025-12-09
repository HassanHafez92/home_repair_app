// File: lib/screens/admin/admin_dashboard_screen.dart
// Purpose: High-level statistics and activity feed for admin using BLoC.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../blocs/admin/admin_bloc.dart';
import '../../blocs/admin/admin_event.dart';
import '../../blocs/admin/admin_state.dart';

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
    return Scaffold(
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

          // If stats is null, show error or empty state
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
                  // Stats Grid
                  GridView.count(
                    crossAxisCount: 5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        'totalUsers'.tr(),
                        stats.totalUsers.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'activeOrders'.tr(),
                        stats.activeOrders.toString(),
                        Icons.shopping_bag,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'revenue'.tr(),
                        '${stats.totalRevenue.toInt()} EGP',
                        Icons.attach_money,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'pendingApprovals'.tr(),
                        stats.pendingApprovals.toString(),
                        Icons.verified_user,
                        Colors.red,
                      ),
                      _buildStatCard(
                        'unverifiedUsers'.tr(),
                        stats.unverifiedUsers.toString(),
                        Icons.email_outlined,
                        Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Recent Activity
                  Text(
                    'recentActivity'.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                    Card(
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
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: const Icon(
                                Icons.notifications,
                                color: Colors.grey,
                              ),
                            ),
                            title: Text('newOrderCreated'.tr(args: [order.id])),
                            subtitle: Text(timeString),
                            trailing: const Icon(Icons.chevron_right),
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
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}



