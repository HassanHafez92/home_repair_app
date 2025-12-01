// File: lib/models/dashboard_stats.dart
// Purpose: Model for admin dashboard statistics

class DashboardStats {
  final int totalUsers;
  final int activeOrders;
  final double totalRevenue;
  final int pendingApprovals;
  final int unverifiedUsers;

  const DashboardStats({
    required this.totalUsers,
    required this.activeOrders,
    required this.totalRevenue,
    required this.pendingApprovals,
    required this.unverifiedUsers,
  });

  factory DashboardStats.empty() {
    return const DashboardStats(
      totalUsers: 0,
      activeOrders: 0,
      totalRevenue: 0,
      pendingApprovals: 0,
      unverifiedUsers: 0,
    );
  }
}
