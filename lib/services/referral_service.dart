// File: lib/services/referral_service.dart
// Purpose: Service for managing referral codes, tracking, and rewards.

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_repair_app/models/referral_model.dart';

/// Service for managing referral program
class ReferralService {
  final FirebaseFirestore _firestore;

  /// Tiered reward tiers based on completed referrals
  static const Map<int, double> _rewardTiers = {
    10: 50.0, // Platinum: 10+ referrals = $50 per referral
    5: 30.0, // Gold: 5-9 referrals = $30 per referral
    3: 20.0, // Silver: 3-4 referrals = $20 per referral
    0: 10.0, // Bronze: 0-2 referrals = $10 per referral
  };

  ReferralService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Calculate reward amount based on tiered system
  /// Returns reward amount for the referrer based on their completed referrals
  double calculateTieredReward(int completedReferrals) {
    for (final entry in _rewardTiers.entries) {
      if (completedReferrals >= entry.key) {
        return entry.value;
      }
    }
    return _rewardTiers.values.last;
  }

  /// Get the user's current reward tier name
  String getRewardTierName(int completedReferrals) {
    if (completedReferrals >= 10) return 'Platinum';
    if (completedReferrals >= 5) return 'Gold';
    if (completedReferrals >= 3) return 'Silver';
    return 'Bronze';
  }

  /// Get referrals needed to reach next tier
  int referralsToNextTier(int completedReferrals) {
    if (completedReferrals >= 10) return 0; // Already at max
    if (completedReferrals >= 5) return 10 - completedReferrals;
    if (completedReferrals >= 3) return 5 - completedReferrals;
    return 3 - completedReferrals;
  }

  /// Generate a unique referral code for a user
  Future<String> generateReferralCode(String userId, String userName) async {
    // Check if user already has a code
    final existingStats = await getReferralStats(userId);
    if (existingStats != null) {
      return existingStats.referralCode;
    }

    // Generate new code: First 3 letters of name + random 4 digits
    final namePart = userName
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z]'), '')
        .padRight(3, 'X')
        .substring(0, 3);
    final randomPart = (1000 + Random().nextInt(9000)).toString();
    var code = '$namePart$randomPart';

    // Ensure uniqueness
    var attempts = 0;
    while (await _isCodeTaken(code) && attempts < 10) {
      code = '$namePart${1000 + Random().nextInt(9000)}';
      attempts++;
    }

    // Save the referral stats
    final stats = ReferralStats(referralCode: code);
    await _firestore
        .collection('referral_stats')
        .doc(userId)
        .set(stats.toJson());

    return code;
  }

  /// Check if a referral code is already taken
  Future<bool> _isCodeTaken(String code) async {
    final query = await _firestore
        .collection('referral_stats')
        .where('referralCode', isEqualTo: code)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Get referral stats for a user
  Future<ReferralStats?> getReferralStats(String userId) async {
    final doc = await _firestore.collection('referral_stats').doc(userId).get();
    if (!doc.exists) return null;
    return ReferralStats.fromJson(doc.data()!);
  }

  /// Validate a referral code and get the referrer info
  Future<Map<String, String>?> validateReferralCode(String code) async {
    final query = await _firestore
        .collection('referral_stats')
        .where('referralCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final userId = query.docs.first.id;
    final userDoc = await _firestore.collection('users').doc(userId).get();

    return {
      'referrerId': userId,
      'referrerName': userDoc.data()?['fullName'] ?? 'User',
    };
  }

  /// Create a new referral when someone uses a referral code
  Future<ReferralModel?> createReferral({
    required String referralCode,
    required String refereeEmail,
  }) async {
    final referrerInfo = await validateReferralCode(referralCode);
    if (referrerInfo == null) return null;

    final referral = ReferralModel(
      id: _firestore.collection('referrals').doc().id,
      referrerId: referrerInfo['referrerId']!,
      referrerName: referrerInfo['referrerName']!,
      referralCode: referralCode.toUpperCase(),
      refereeEmail: refereeEmail,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );

    await _firestore
        .collection('referrals')
        .doc(referral.id)
        .set(referral.toJson());

    // Update referrer stats
    await _incrementReferralCount(referrerInfo['referrerId']!);

    return referral;
  }

  /// Mark referral as signed up when referee creates account
  Future<void> markReferralSignedUp({
    required String refereeId,
    required String refereeName,
    required String refereeEmail,
  }) async {
    final query = await _firestore
        .collection('referrals')
        .where('refereeEmail', isEqualTo: refereeEmail)
        .where('status', isEqualTo: ReferralStatus.pending.name)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final referralDoc = query.docs.first;
    await referralDoc.reference.update({
      'refereeId': refereeId,
      'refereeName': refereeName,
      'status': ReferralStatus.signedUp.name,
      'signedUpAt': DateTime.now().toIso8601String(),
    });

    // Update referrer stats
    final referral = ReferralModel.fromJson(referralDoc.data());
    await _firestore
        .collection('referral_stats')
        .doc(referral.referrerId)
        .update({'signedUp': FieldValue.increment(1)});
  }

  /// Mark referral as completed when referee completes first order
  Future<void> markReferralCompleted(String refereeId) async {
    final query = await _firestore
        .collection('referrals')
        .where('refereeId', isEqualTo: refereeId)
        .where('status', isEqualTo: ReferralStatus.signedUp.name)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final referralDoc = query.docs.first;
    final referral = ReferralModel.fromJson(referralDoc.data());

    await referralDoc.reference.update({
      'status': ReferralStatus.completed.name,
      'completedAt': DateTime.now().toIso8601String(),
    });

    // Update referrer stats
    await _firestore
        .collection('referral_stats')
        .doc(referral.referrerId)
        .update({
          'completed': FieldValue.increment(1),
          'pendingEarnings': FieldValue.increment(referral.referrerReward),
        });
  }

  /// Claim pending referral rewards
  Future<double> claimRewards(String userId) async {
    // Get pending referrals
    final pendingReferrals = await _firestore
        .collection('referrals')
        .where('referrerId', isEqualTo: userId)
        .where('status', isEqualTo: ReferralStatus.completed.name)
        .get();

    if (pendingReferrals.docs.isEmpty) return 0;

    double totalClaimed = 0;

    for (final doc in pendingReferrals.docs) {
      final referral = ReferralModel.fromJson(doc.data());
      if (referral.claimedAt == null) {
        totalClaimed += referral.referrerReward;
        await doc.reference.update({
          'status': ReferralStatus.claimed.name,
          'claimedAt': DateTime.now().toIso8601String(),
        });
      }
    }

    // Update stats
    await _firestore.collection('referral_stats').doc(userId).update({
      'pendingEarnings': 0,
      'totalEarnings': FieldValue.increment(totalClaimed),
    });

    return totalClaimed;
  }

  /// Get all referrals for a user
  Future<List<ReferralModel>> getUserReferrals(String userId) async {
    final query = await _firestore
        .collection('referrals')
        .where('referrerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return query.docs.map((doc) => ReferralModel.fromJson(doc.data())).toList();
  }

  /// Get leaderboard of top referrers
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 10}) async {
    final query = await _firestore
        .collection('referral_stats')
        .orderBy('completed', descending: true)
        .limit(limit)
        .get();

    final entries = <LeaderboardEntry>[];
    int rank = 1;

    for (final doc in query.docs) {
      final stats = ReferralStats.fromJson(doc.data());
      final userDoc = await _firestore.collection('users').doc(doc.id).get();

      entries.add(
        LeaderboardEntry(
          rank: rank,
          userId: doc.id,
          userName: userDoc.data()?['fullName'] ?? 'User',
          profilePhotoUrl: userDoc.data()?['profilePhoto'],
          completedReferrals: stats.completed,
          totalEarnings: stats.totalEarnings,
        ),
      );
      rank++;
    }

    return entries;
  }

  Future<void> _incrementReferralCount(String userId) async {
    await _firestore.collection('referral_stats').doc(userId).update({
      'totalReferrals': FieldValue.increment(1),
    });
  }
}

/// Leaderboard entry model
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String userName;
  final String? profilePhotoUrl;
  final int completedReferrals;
  final double totalEarnings;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    this.profilePhotoUrl,
    required this.completedReferrals,
    required this.totalEarnings,
  });
}
