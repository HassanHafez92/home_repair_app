// File: lib/presentation/screens/customer/referral_screen.dart
// Purpose: Screen for viewing and sharing referral code with leaderboard.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/models/referral_model.dart';
import 'package:home_repair_app/services/referral_service.dart';

class ReferralScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ReferralScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen>
    with SingleTickerProviderStateMixin {
  final ReferralService _referralService = ReferralService();
  late TabController _tabController;

  ReferralStats? _stats;
  List<ReferralModel> _referrals = [];
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Ensure user has a referral code
      final code = await _referralService.generateReferralCode(
        widget.userId,
        widget.userName,
      );

      final stats = await _referralService.getReferralStats(widget.userId);
      final referrals = await _referralService.getUserReferrals(widget.userId);
      final leaderboard = await _referralService.getLeaderboard();

      if (mounted) {
        setState(() {
          _stats = stats ?? ReferralStats(referralCode: code);
          _referrals = referrals;
          _leaderboard = leaderboard;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('referralProgram'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'myReferrals'.tr()),
            Tab(text: 'leaderboard'.tr()),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats card
                _buildStatsCard(theme),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildReferralsTab(), _buildLeaderboardTab()],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Referral code
          Text(
            'yourReferralCode'.tr(),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _stats?.referralCode ?? '---',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white70),
                onPressed: _copyCode,
                tooltip: 'copy'.tr(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Share button
          ElevatedButton.icon(
            onPressed: _shareCode,
            icon: const Icon(Icons.share),
            label: Text('shareCode'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),

          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'invited'.tr(),
                _stats?.totalReferrals.toString() ?? '0',
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              _buildStatItem(
                'signedUp'.tr(),
                _stats?.signedUp.toString() ?? '0',
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              _buildStatItem(
                'earned'.tr(),
                '${_stats?.totalEarnings.toInt() ?? 0} EGP',
              ),
            ],
          ),

          // Pending earnings
          if ((_stats?.pendingEarnings ?? 0) > 0) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _claimRewards,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              child: Text(
                '${'claimRewards'.tr()} (${_stats!.pendingEarnings.toInt()} EGP)',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildReferralsTab() {
    if (_referrals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'noReferralsYet'.tr(),
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'shareCodeToStart'.tr(),
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _referrals.length,
      itemBuilder: (context, index) {
        final referral = _referrals[index];
        return _ReferralCard(referral: referral);
      },
    );
  }

  Widget _buildLeaderboardTab() {
    if (_leaderboard.isEmpty) {
      return Center(child: Text('noLeaderboardData'.tr()));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _leaderboard.length,
      itemBuilder: (context, index) {
        final entry = _leaderboard[index];
        final isCurrentUser = entry.userId == widget.userId;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: isCurrentUser
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Rank
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getRankColor(entry.rank),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#${entry.rank}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Avatar & name
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                backgroundImage: entry.profilePhotoUrl != null
                    ? NetworkImage(entry.profilePhotoUrl!)
                    : null,
                child: entry.profilePhotoUrl == null
                    ? Text(entry.userName[0].toUpperCase())
                    : null,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${entry.completedReferrals} ${'referrals'.tr()}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Earnings
              Text(
                '${entry.totalEarnings.toInt()} EGP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  void _copyCode() {
    if (_stats?.referralCode != null) {
      Clipboard.setData(ClipboardData(text: _stats!.referralCode));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('codeCopied'.tr())));
    }
  }

  void _shareCode() {
    if (_stats?.referralCode != null) {
      final shareText =
          '${'inviteMessage'.tr()} ${_stats!.referralCode}\n\n'
          '${'downloadApp'.tr()}: https://homerepair.app/invite/${_stats!.referralCode}';
      Clipboard.setData(ClipboardData(text: shareText));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'codeCopied'.tr()} - ${'shareViaApps'.tr()}'),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    }
  }

  Future<void> _claimRewards() async {
    final claimed = await _referralService.claimRewards(widget.userId);
    if (claimed > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'rewardsClaimed'.tr()}: $claimed EGP')),
      );
      _loadData();
    }
  }
}

class _ReferralCard extends StatelessWidget {
  final ReferralModel referral;

  const _ReferralCard({required this.referral});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getStatusIcon(), color: _getStatusColor()),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    referral.refereeName ??
                        referral.refereeEmail ??
                        'pendingSignup'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusText(),
                    style: TextStyle(fontSize: 12, color: _getStatusColor()),
                  ),
                ],
              ),
            ),

            // Reward
            if (referral.status == ReferralStatus.completed ||
                referral.status == ReferralStatus.claimed)
              Text(
                '+${referral.referrerReward.toInt()} EGP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (referral.status) {
      case ReferralStatus.pending:
        return Colors.orange;
      case ReferralStatus.signedUp:
        return Colors.blue;
      case ReferralStatus.completed:
        return Colors.green;
      case ReferralStatus.claimed:
        return Colors.grey;
      case ReferralStatus.expired:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (referral.status) {
      case ReferralStatus.pending:
        return Icons.hourglass_empty;
      case ReferralStatus.signedUp:
        return Icons.person_add;
      case ReferralStatus.completed:
        return Icons.check_circle;
      case ReferralStatus.claimed:
        return Icons.done_all;
      case ReferralStatus.expired:
        return Icons.timer_off;
    }
  }

  String _getStatusText() {
    switch (referral.status) {
      case ReferralStatus.pending:
        return 'awaitingSignup'.tr();
      case ReferralStatus.signedUp:
        return 'awaitingFirstOrder'.tr();
      case ReferralStatus.completed:
        return 'rewardReady'.tr();
      case ReferralStatus.claimed:
        return 'rewardClaimed'.tr();
      case ReferralStatus.expired:
        return 'expired'.tr();
    }
  }
}
