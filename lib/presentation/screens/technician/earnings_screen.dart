// File: lib/screens/technician/earnings_screen.dart
// Purpose: Display earnings overview and transaction history - House Maintenance style

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/design_tokens.dart';
import 'withdrawal_screen.dart';
import '../../widgets/wrappers.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - in real app would come from BLoC
    const totalEarnings = 24820.0;
    const thisMonthEarnings = 3420.0;
    const pendingAmount = 1250.0;

    final transactions = [
      _Transaction(
        'AC Repair Service',
        DateTime.now().subtract(const Duration(hours: 2)),
        350,
        true,
      ),
      _Transaction(
        'Plumbing - Leak Fix',
        DateTime.now().subtract(const Duration(days: 1)),
        220,
        true,
      ),
      _Transaction(
        'Electrical Wiring',
        DateTime.now().subtract(const Duration(days: 2)),
        480,
        true,
      ),
      _Transaction(
        'Withdrawal',
        DateTime.now().subtract(const Duration(days: 3)),
        1000,
        false,
      ),
      _Transaction(
        'Painting Service',
        DateTime.now().subtract(const Duration(days: 4)),
        650,
        true,
      ),
    ];

    return PerformanceMonitorWrapper(
      screenName: 'EarningsScreen',
      child: Scaffold(
        backgroundColor: DesignTokens.neutral100,
        body: CustomScrollView(
          slivers: [
            // Gradient Header with Total Earnings
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: DesignTokens.headerGradient,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(DesignTokens.radiusXL),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(DesignTokens.spaceLG),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'earnings'.tr(),
                              style: const TextStyle(
                                fontSize: DesignTokens.fontSizeXL,
                                fontWeight: DesignTokens.fontWeightBold,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () => _showFilterDialog(context),
                                icon: const Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.spaceXL),

                        // Total Earnings
                        Text(
                          'totalEarnings'.tr(),
                          style: TextStyle(
                            fontSize: DesignTokens.fontSizeSM,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${totalEarnings.toInt()}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: DesignTokens.fontWeightBold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: Text(
                                'EGP',
                                style: TextStyle(
                                  fontSize: DesignTokens.fontSizeMD,
                                  fontWeight: DesignTokens.fontWeightMedium,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.spaceLG),

                        // Stats Row
                        Row(
                          children: [
                            _StatChip(
                              label: 'thisMonth'.tr(),
                              value: '${thisMonthEarnings.toInt()} EGP',
                              icon: Icons.trending_up,
                            ),
                            const SizedBox(width: DesignTokens.spaceMD),
                            _StatChip(
                              label: 'pending'.tr(),
                              value: '${pendingAmount.toInt()} EGP',
                              icon: Icons.hourglass_empty,
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.spaceLG),

                        // Withdraw Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WithdrawalScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.account_balance_wallet),
                            label: Text('withdraw'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: DesignTokens.primaryBlue,
                              padding: const EdgeInsets.symmetric(
                                vertical: DesignTokens.spaceMD,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusMD,
                                ),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Transactions Section
            SliverPadding(
              padding: const EdgeInsets.all(DesignTokens.spaceLG),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'recentTransactions'.tr(),
                      style: TextStyle(
                        fontSize: DesignTokens.fontSizeMD,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: DesignTokens.neutral900,
                      ),
                    ),
                    TextButton(onPressed: () {}, child: Text('seeAll'.tr())),
                  ],
                ),
              ),
            ),

            // Transaction List
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceLG,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final tx = transactions[index];
                  return _TransactionCard(transaction: tx);
                }, childCount: transactions.length),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: DesignTokens.space2XL),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLG),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'filterTransactions'.tr(),
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeMD,
                      fontWeight: DesignTokens.fontWeightBold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceMD),
              _FilterOption('thisWeek'.tr(), true),
              _FilterOption('thisMonth'.tr(), false),
              _FilterOption('last3Months'.tr(), false),
              _FilterOption('thisYear'.tr(), false),
              const SizedBox(height: DesignTokens.spaceLG),
            ],
          ),
        );
      },
    );
  }
}

class _Transaction {
  final String title;
  final DateTime date;
  final double amount;
  final bool isCredit;

  _Transaction(this.title, this.date, this.amount, this.isCredit);
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spaceSM),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: DesignTokens.fontSizeXS,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: DesignTokens.fontSizeSM,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final _Transaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceSM),
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        boxShadow: DesignTokens.shadowSoft,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: transaction.isCredit
                  ? DesignTokens.accentGreen.withValues(alpha: 0.1)
                  : DesignTokens.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
            ),
            child: Icon(
              transaction.isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: transaction.isCredit
                  ? DesignTokens.accentGreen
                  : DesignTokens.error,
            ),
          ),
          const SizedBox(width: DesignTokens.spaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: DesignTokens.neutral900,
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(transaction.date),
                  style: TextStyle(
                    fontSize: DesignTokens.fontSizeSM,
                    color: DesignTokens.neutral500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isCredit ? '+' : '-'}${transaction.amount.toInt()} EGP',
            style: TextStyle(
              fontWeight: DesignTokens.fontWeightBold,
              color: transaction.isCredit
                  ? DesignTokens.accentGreen
                  : DesignTokens.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterOption(this.label, this.isSelected);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: DesignTokens.primaryBlue)
          : null,
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
