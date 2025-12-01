import '../../models/dashboard_stats.dart';

abstract class IAdminRepository {
  Future<DashboardStats> getDashboardStats();
}
