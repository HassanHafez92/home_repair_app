// File: lib/screens/customer/wallet_screen.dart
// Purpose: Display wallet balance and transaction history.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/custom_button.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - in real app, this would come from Firestore
    const double balance = 250.0;
    final List<Map<String, dynamic>> transactions = [
      {
        'type': 'credit',
        'amount': 300.0,
        'description': 'walletTopUp'.tr(),
        'date': '2024-11-20',
      },
      {
        'type': 'debit',
        'amount': 50.0,
        'description': 'orderPayment'.tr(),
        'date': '2024-11-19',
      },
      {
        'type': 'credit',
        'amount': 100.0,
        'description': 'refund'.tr(),
        'date': '2024-11-18',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text('myWallet'.tr())),
      body: Column(
        children: [
          // Balance Card
          Container(
            margin: const EdgeInsets.all(24),
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
                  'availableBalance'.tr(),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '${balance.toInt()} EGP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'addMoney'.tr(),
                  variant: ButtonVariant.secondary,
                  onPressed: () => _showTopUpDialog(context),
                ),
              ],
            ),
          ),

          // Transactions Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'recentTransactions'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Transactions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isCredit = tx['type'] == 'credit';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCredit
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isCredit ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(tx['description']),
                    subtitle: Text(tx['date']),
                    trailing: Text(
                      '${isCredit ? '+' : '-'}${tx['amount'].toInt()} EGP',
                      style: TextStyle(
                        color: isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
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

  Future<void> _showTopUpDialog(BuildContext context) async {
    final amountController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('addMoney'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('enterAmountWallet'.tr()),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'amountEgp'.tr(),
                border: const OutlineInputBorder(),
                prefixText: 'EGP ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('pleaseEnterValidAmount'.tr())),
                );
                return;
              }

              // Simulate payment processing
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'addedToWallet'.tr(args: [amount.toInt().toString()]),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('add'.tr()),
          ),
        ],
      ),
    );
  }
}



