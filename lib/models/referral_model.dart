// File: lib/models/referral_model.dart
// Purpose: Model for tracking referrals and rewards.

import 'package:equatable/equatable.dart';

/// Status of a referral
enum ReferralStatus {
  /// Referral code sent but not used yet
  pending,

  /// Referee signed up but hasn't completed first order
  signedUp,

  /// Referee completed first order - reward eligible
  completed,

  /// Referral expired (not used within validity period)
  expired,

  /// Reward claimed by referrer
  claimed,
}

/// Model for tracking a single referral
class ReferralModel extends Equatable {
  /// Unique referral ID
  final String id;

  /// User ID of the person who referred (referrer)
  final String referrerId;

  /// Referrer's name
  final String referrerName;

  /// Referral code used
  final String referralCode;

  /// User ID of the person who was referred (referee)
  final String? refereeId;

  /// Referee's name
  final String? refereeName;

  /// Referee's email (for tracking before signup)
  final String? refereeEmail;

  /// Current status of the referral
  final ReferralStatus status;

  /// Reward amount in EGP for the referrer
  final double referrerReward;

  /// Reward amount in EGP for the referee
  final double refereeReward;

  /// Date when the referral was created
  final DateTime createdAt;

  /// Date when the referee signed up
  final DateTime? signedUpAt;

  /// Date when the referee completed first order
  final DateTime? completedAt;

  /// Date when the reward was claimed
  final DateTime? claimedAt;

  /// Expiry date for the referral
  final DateTime expiresAt;

  const ReferralModel({
    required this.id,
    required this.referrerId,
    required this.referrerName,
    required this.referralCode,
    this.refereeId,
    this.refereeName,
    this.refereeEmail,
    this.status = ReferralStatus.pending,
    this.referrerReward = 50.0, // 50 EGP default
    this.refereeReward = 25.0, // 25 EGP default
    required this.createdAt,
    this.signedUpAt,
    this.completedAt,
    this.claimedAt,
    required this.expiresAt,
  });

  /// Check if referral is still valid
  bool get isValid =>
      status != ReferralStatus.expired && DateTime.now().isBefore(expiresAt);

  /// Check if reward can be claimed
  bool get canClaimReward =>
      status == ReferralStatus.completed && claimedAt == null;

  /// Get days until expiry
  int get daysUntilExpiry => expiresAt.difference(DateTime.now()).inDays;

  ReferralModel copyWith({
    String? id,
    String? referrerId,
    String? referrerName,
    String? referralCode,
    String? refereeId,
    String? refereeName,
    String? refereeEmail,
    ReferralStatus? status,
    double? referrerReward,
    double? refereeReward,
    DateTime? createdAt,
    DateTime? signedUpAt,
    DateTime? completedAt,
    DateTime? claimedAt,
    DateTime? expiresAt,
  }) {
    return ReferralModel(
      id: id ?? this.id,
      referrerId: referrerId ?? this.referrerId,
      referrerName: referrerName ?? this.referrerName,
      referralCode: referralCode ?? this.referralCode,
      refereeId: refereeId ?? this.refereeId,
      refereeName: refereeName ?? this.refereeName,
      refereeEmail: refereeEmail ?? this.refereeEmail,
      status: status ?? this.status,
      referrerReward: referrerReward ?? this.referrerReward,
      refereeReward: refereeReward ?? this.refereeReward,
      createdAt: createdAt ?? this.createdAt,
      signedUpAt: signedUpAt ?? this.signedUpAt,
      completedAt: completedAt ?? this.completedAt,
      claimedAt: claimedAt ?? this.claimedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrerId': referrerId,
      'referrerName': referrerName,
      'referralCode': referralCode,
      'refereeId': refereeId,
      'refereeName': refereeName,
      'refereeEmail': refereeEmail,
      'status': status.name,
      'referrerReward': referrerReward,
      'refereeReward': refereeReward,
      'createdAt': createdAt.toIso8601String(),
      'signedUpAt': signedUpAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'claimedAt': claimedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] as String,
      referrerId: json['referrerId'] as String,
      referrerName: json['referrerName'] as String,
      referralCode: json['referralCode'] as String,
      refereeId: json['refereeId'] as String?,
      refereeName: json['refereeName'] as String?,
      refereeEmail: json['refereeEmail'] as String?,
      status: ReferralStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ReferralStatus.pending,
      ),
      referrerReward: (json['referrerReward'] as num?)?.toDouble() ?? 50.0,
      refereeReward: (json['refereeReward'] as num?)?.toDouble() ?? 25.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      signedUpAt: json['signedUpAt'] != null
          ? DateTime.parse(json['signedUpAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      claimedAt: json['claimedAt'] != null
          ? DateTime.parse(json['claimedAt'] as String)
          : null,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    referrerId,
    referrerName,
    referralCode,
    refereeId,
    refereeName,
    refereeEmail,
    status,
    referrerReward,
    refereeReward,
    createdAt,
    signedUpAt,
    completedAt,
    claimedAt,
    expiresAt,
  ];
}

/// User's referral stats
class ReferralStats extends Equatable {
  /// User's unique referral code
  final String referralCode;

  /// Total referrals sent
  final int totalReferrals;

  /// Referrals that signed up
  final int signedUp;

  /// Referrals that completed first order
  final int completed;

  /// Total earnings from referrals (EGP)
  final double totalEarnings;

  /// Pending earnings (not yet claimed)
  final double pendingEarnings;

  /// User's rank on leaderboard
  final int? leaderboardRank;

  const ReferralStats({
    required this.referralCode,
    this.totalReferrals = 0,
    this.signedUp = 0,
    this.completed = 0,
    this.totalEarnings = 0,
    this.pendingEarnings = 0,
    this.leaderboardRank,
  });

  /// Conversion rate (signed up / total)
  double get conversionRate =>
      totalReferrals > 0 ? signedUp / totalReferrals : 0;

  /// Completion rate (completed / signed up)
  double get completionRate => signedUp > 0 ? completed / signedUp : 0;

  Map<String, dynamic> toJson() => {
    'referralCode': referralCode,
    'totalReferrals': totalReferrals,
    'signedUp': signedUp,
    'completed': completed,
    'totalEarnings': totalEarnings,
    'pendingEarnings': pendingEarnings,
    'leaderboardRank': leaderboardRank,
  };

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      referralCode: json['referralCode'] as String,
      totalReferrals: json['totalReferrals'] as int? ?? 0,
      signedUp: json['signedUp'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      pendingEarnings: (json['pendingEarnings'] as num?)?.toDouble() ?? 0,
      leaderboardRank: json['leaderboardRank'] as int?,
    );
  }

  @override
  List<Object?> get props => [
    referralCode,
    totalReferrals,
    signedUp,
    completed,
    totalEarnings,
    pendingEarnings,
    leaderboardRank,
  ];
}
