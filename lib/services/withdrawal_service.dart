// File: lib/services/withdrawal_service.dart
// Purpose: Service for managing technician withdrawal requests.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/withdrawal_model.dart';

/// Service for handling technician earnings and withdrawals
class WithdrawalService {
  final FirebaseFirestore _firestore;
  static const _uuid = Uuid();

  WithdrawalService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get the technician's available balance for withdrawal
  Future<TechnicianBalance> getTechnicianBalance(String technicianId) async {
    try {
      // Get completed orders for this technician
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('technicianId', isEqualTo: technicianId)
          .where('status', isEqualTo: 'completed')
          .get();

      // Calculate total earnings
      double totalEarnings = 0;
      for (final doc in ordersSnapshot.docs) {
        final data = doc.data();
        final amount = (data['finalPrice'] as num?)?.toDouble() ?? 0;
        totalEarnings += amount;
      }

      // Get pending withdrawals (not yet completed)
      final pendingWithdrawalsSnapshot = await _firestore
          .collection('withdrawals')
          .where('technicianId', isEqualTo: technicianId)
          .where('status', whereIn: ['pending', 'processing'])
          .get();

      double pendingAmount = 0;
      for (final doc in pendingWithdrawalsSnapshot.docs) {
        pendingAmount += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
      }

      // Get completed withdrawals
      final completedWithdrawalsSnapshot = await _firestore
          .collection('withdrawals')
          .where('technicianId', isEqualTo: technicianId)
          .where('status', isEqualTo: 'completed')
          .get();

      double withdrawnAmount = 0;
      for (final doc in completedWithdrawalsSnapshot.docs) {
        withdrawnAmount += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
      }

      final availableBalance = totalEarnings - withdrawnAmount - pendingAmount;

      return TechnicianBalance(
        totalEarnings: totalEarnings,
        withdrawnAmount: withdrawnAmount,
        pendingAmount: pendingAmount,
        availableBalance: availableBalance > 0 ? availableBalance : 0,
      );
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }

  /// Request a withdrawal
  Future<WithdrawalModel> requestWithdrawal({
    required String technicianId,
    required String technicianName,
    required double amount,
    required BankDetails bankDetails,
  }) async {
    try {
      // Validate balance
      final balance = await getTechnicianBalance(technicianId);
      if (amount > balance.availableBalance) {
        throw Exception('Insufficient balance');
      }

      if (amount < 100) {
        throw Exception('Minimum withdrawal amount is 100 EGP');
      }

      final id = _uuid.v4();
      final withdrawal = WithdrawalModel(
        id: id,
        technicianId: technicianId,
        technicianName: technicianName,
        amount: amount,
        status: WithdrawalStatus.pending,
        bankDetails: bankDetails,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('withdrawals')
          .doc(id)
          .set(withdrawal.toJson());

      return withdrawal;
    } catch (e) {
      throw Exception('Failed to request withdrawal: $e');
    }
  }

  /// Get withdrawal history for a technician
  Stream<List<WithdrawalModel>> streamWithdrawalHistory(String technicianId) {
    return _firestore
        .collection('withdrawals')
        .where('technicianId', isEqualTo: technicianId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    WithdrawalModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  /// Cancel a pending withdrawal
  Future<void> cancelWithdrawal(
    String withdrawalId,
    String technicianId,
  ) async {
    final doc = await _firestore
        .collection('withdrawals')
        .doc(withdrawalId)
        .get();

    if (!doc.exists) {
      throw Exception('Withdrawal not found');
    }

    final data = doc.data()!;
    if (data['technicianId'] != technicianId) {
      throw Exception('Unauthorized');
    }

    if (data['status'] != 'pending') {
      throw Exception('Only pending withdrawals can be cancelled');
    }

    await _firestore.collection('withdrawals').doc(withdrawalId).update({
      'status': 'cancelled',
    });
  }

  /// Save bank details for a technician (for reuse)
  Future<void> saveBankDetails(String technicianId, BankDetails details) async {
    await _firestore.collection('technicians').doc(technicianId).update({
      'bankDetails': details.toJson(),
    });
  }

  /// Get saved bank details for a technician
  Future<BankDetails?> getSavedBankDetails(String technicianId) async {
    final doc = await _firestore
        .collection('technicians')
        .doc(technicianId)
        .get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    if (data['bankDetails'] == null) return null;

    return BankDetails.fromJson(data['bankDetails'] as Map<String, dynamic>);
  }
}

/// Model for technician balance summary
class TechnicianBalance {
  final double totalEarnings;
  final double withdrawnAmount;
  final double pendingAmount;
  final double availableBalance;

  const TechnicianBalance({
    required this.totalEarnings,
    required this.withdrawnAmount,
    required this.pendingAmount,
    required this.availableBalance,
  });
}
