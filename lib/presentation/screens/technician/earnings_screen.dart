// File: lib/screens/technician/earnings_screen.dart
// Purpose: Display earnings overview and transaction history.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/custom_button.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - in real app, this would come from Firestore
    const double totalEarnings = 15240.0;
    const double pendingPayment = 1850.0;
    const double availableBalance = 13390.0;

    final List<Map<String, dynamic>> transactions = [
      {
        'date': '2024-11-22',
        'description': 'AC Repair - Maadi',
        'amount': 450.0,
      },
      {
        'date': '2024-11-21',
        'description': 'Plumbing - Downtown',
        'amount': 320.0,
      },
      {
        'date': '2024-11-20',
        'description': 'Electrical - Nasr City',
        'amount': 580.0,
      },
      {
        'date': '2024-11-19',
        'description': 'Carpentry - Heliopolis',
        'amount': 500.0,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text('earningsTitle'.tr())),
      body: Column(
        children: [
          // Earnings Summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'totalEarnings'.tr(),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '${totalEarnings.toInt()} EGP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'pending'.tr(),
                        '${pendingPayment.toInt()} EGP',
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'available'.tr(),
                        '${availableBalance.toInt()} EGP',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'withdraw'.tr(),
                  variant: ButtonVariant.secondary,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('withdrawalComingSoon'.tr())),
                    );
                  },
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'recentTransactions'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: Text('filter'.tr())),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    title: Text(tx['description']),
                    subtitle: Text(tx['date']),
                    trailing: Text(
                      '+${tx['amount'].toInt()} EGP',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}



