import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:home_repair_app/domain/repositories/i_user_repository.dart';
import 'package:home_repair_app/models/user_model.dart';
import 'package:home_repair_app/models/customer_model.dart';
import 'package:home_repair_app/models/technician_model.dart';
import 'package:home_repair_app/models/technician_stats.dart';
import 'package:home_repair_app/models/order_model.dart';

class UserRepositoryImpl implements IUserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toJson());
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;
      final roleStr = data['role'] as String?;

      if (roleStr == null) {
        debugPrint(
          'UserRepository: User document missing role field for uid: $uid',
        );
        return null;
      }

      if (roleStr == 'UserRole.customer' || roleStr == 'customer') {
        return CustomerModel.fromJson(data);
      } else if (roleStr == 'UserRole.technician' || roleStr == 'technician') {
        return TechnicianModel.fromJson(data);
      } else {
        return UserModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('UserRepository: Error loading user $uid: $e');
      return null;
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toJson());
  }

  @override
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    await _db.collection('users').doc(uid).update(fields);
  }

  @override
  Stream<List<TechnicianModel>> streamPendingTechnicians() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'technician')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TechnicianModel.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> updateTechnicianStatus(
    String uid,
    TechnicianStatus status,
  ) async {
    await _db.collection('users').doc(uid).update({
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateTechnicianAvailability(
    String uid,
    bool isAvailable,
  ) async {
    await _db.collection('users').doc(uid).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<bool> streamTechnicianAvailability(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return false;
      return snapshot.data()!['isAvailable'] as bool? ?? false;
    });
  }

  @override
  Future<TechnicianStats> getTechnicianStats(String technicianId) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final userDoc = await _db.collection('users').doc(technicianId).get();
      final rating = userDoc.data()?['rating'] as double? ?? 0.0;

      final pendingOrdersSnapshot = await _db
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      final activeJobsSnapshot = await _db
          .collection('orders')
          .where('technicianId', isEqualTo: technicianId)
          .where(
            'status',
            whereIn: ['accepted', 'traveling', 'arrived', 'working'],
          )
          .count()
          .get();

      final completedJobsTotalSnapshot = await _db
          .collection('orders')
          .where('technicianId', isEqualTo: technicianId)
          .where('status', isEqualTo: 'completed')
          .count()
          .get();

      final todayCompletedOrders = await _db
          .collection('orders')
          .where('technicianId', isEqualTo: technicianId)
          .where('status', isEqualTo: 'completed')
          .where(
            'updatedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
          )
          .where('updatedAt', isLessThan: Timestamp.fromDate(todayEnd))
          .get();

      double todayEarnings = 0.0;
      for (var doc in todayCompletedOrders.docs) {
        final order = OrderModel.fromJson(doc.data());
        todayEarnings += order.finalPrice ?? order.initialEstimate ?? 0.0;
      }

      return TechnicianStats(
        todayEarnings: todayEarnings,
        completedJobsToday: todayCompletedOrders.docs.length,
        completedJobsTotal: completedJobsTotalSnapshot.count ?? 0,
        rating: rating,
        pendingOrders: pendingOrdersSnapshot.count ?? 0,
        activeJobs: activeJobsSnapshot.count ?? 0,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error fetching technician stats: $e');
      return TechnicianStats.empty();
    }
  }

  @override
  Stream<TechnicianStats> streamTechnicianStats(String technicianId) async* {
    yield await getTechnicianStats(technicianId);
    await for (final _
        in _db
            .collection('orders')
            .where('technicianId', isEqualTo: technicianId)
            .snapshots()) {
      yield await getTechnicianStats(technicianId);
    }
  }
}
