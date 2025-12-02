import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/auth_service.dart';
import '../../blocs/technician_dashboard/technician_dashboard_bloc.dart';
import '../../blocs/order/technician_order_bloc.dart';
import '../../widgets/order_map_view.dart';
import 'incoming_orders_screen.dart';
import 'active_jobs_screen.dart';
import 'earnings_screen.dart';
import 'technician_profile_screen.dart';

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
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inbox),
            label: 'orders'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work),
            label: 'jobs'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.attach_money),
            label: 'earnings'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'profile'.tr(),
          ),
        ],
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
    // Schedule the BLoC events to run after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userId = context.read<AuthService>().currentUser?.uid;
        if (userId != null) {
          context.read<TechnicianDashboardBloc>().add(
            LoadTechnicianDashboard(userId),
          );
          // Load orders for the map
          context.read<TechnicianOrderBloc>().add(LoadTechnicianOrders(userId));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    final userId = user?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('dashboard'.tr())),
        body: Center(child: Text('pleaseLogin'.tr())),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard'.tr()),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('welcomeBack'.tr()),
                          Text(
                            user?.displayName ?? 'technician'.tr(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Availability Toggle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'available'.tr(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          Switch(
                            value: dashboardState.isAvailable,
                            onChanged: (value) {
                              context.read<TechnicianDashboardBloc>().add(
                                ToggleAvailability(
                                  technicianId: userId,
                                  isAvailable: value,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Map View for Active Orders
                  Text(
                    'activeJobsMap'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<TechnicianOrderBloc, TechnicianOrderState>(
                    builder: (context, orderState) {
                      return OrderMapView(
                        orders: orderState.activeOrders,
                        height: 200,
                        onOrderTapped: (order) {
                          context.push('/technician/order/${order.id}');
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'todaysEarnings'.tr(),
                          '${stats.todayEarnings.toInt()} EGP',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'completedJobs'.tr(),
                          stats.completedJobsToday.toString(),
                          Icons.check_circle,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'rating'.tr(),
                          stats.rating.toStringAsFixed(1),
                          Icons.star,
                          Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'pendingOrders'.tr(),
                          stats.pendingOrders.toString(),
                          Icons.pending,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Today's Schedule
                  Text(
                    'todaysSchedule'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildScheduleItem(
                    '10:00 AM',
                    'AC Repair - Downtown',
                    'Customer: Ahmed Mohamed',
                    Colors.blue,
                  ),
                  _buildScheduleItem(
                    '02:00 PM',
                    'Plumbing - Maadi',
                    'Customer: Sara Ali',
                    Colors.green,
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'quickActions'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'viewOrders'.tr(),
                          Icons.inbox,
                          () {
                            widget.onTabChanged?.call(1);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          'activeJobs'.tr(),
                          Icons.work,
                          () {
                            widget.onTabChanged?.call(2);
                          },
                        ),
                      ),
                    ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    String time,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 60,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
