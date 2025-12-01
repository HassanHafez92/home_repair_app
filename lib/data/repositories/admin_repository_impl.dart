import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/i_admin_repository.dart';
import '../../models/dashboard_stats.dart';

class AdminRepositoryImpl implements IAdminRepository {
  final FirebaseFirestore _db;

  AdminRepositoryImpl({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<DashboardStats> getDashboardStats() async {
    // In a real app, this would be a Cloud Function or aggregation query
    // For now, we'll return mock data or simple counts
    try {
      final usersSnapshot = await _db.collection('users').count().get();
      final ordersSnapshot = await _db.collection('orders').count().get();
      final pendingOrdersSnapshot = await _db
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      // Count unverified users
      final unverifiedUsersSnapshot = await _db
          .collection('users')
          .where('emailVerified', isEqualTo: false)
          .count()
          .get();

      // Revenue calculation would require aggregation, mocking for now
      const totalRevenue = 154000.0;

      return DashboardStats(
        totalUsers: usersSnapshot.count ?? 0,
        activeOrders: ordersSnapshot.count ?? 0,
        totalRevenue: totalRevenue,
        pendingApprovals: pendingOrdersSnapshot.count ?? 0,
        unverifiedUsers: unverifiedUsersSnapshot.count ?? 0,
      );
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
      return DashboardStats.empty();
    }
  }
}
