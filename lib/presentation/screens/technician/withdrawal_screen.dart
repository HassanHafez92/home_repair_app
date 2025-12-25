// File: lib/presentation/screens/technician/withdrawal_screen.dart
// Purpose: Screen for technicians to request earnings withdrawal.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/withdrawal_model.dart';
import '../../../services/withdrawal_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../theme/design_tokens.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _ibanController = TextEditingController();

  final _withdrawalService = WithdrawalService();

  TechnicianBalance? _balance;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadBalanceAndBankDetails();
  }

  Future<void> _loadBalanceAndBankDetails() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    try {
      final balance = await _withdrawalService.getTechnicianBalance(
        authState.user.id,
      );
      final savedDetails = await _withdrawalService.getSavedBankDetails(
        authState.user.id,
      );

      if (mounted) {
        setState(() {
          _balance = balance;
          _isLoading = false;

          if (savedDetails != null) {
            _bankNameController.text = savedDetails.bankName;
            _accountNumberController.text = savedDetails.accountNumber;
            _accountHolderController.text = savedDetails.accountHolderName;
            _ibanController.text = savedDetails.iban ?? '';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading balance: $e')));
      }
    }
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isSubmitting = true);

    try {
      final bankDetails = BankDetails(
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        accountHolderName: _accountHolderController.text.trim(),
        iban: _ibanController.text.trim().isNotEmpty
            ? _ibanController.text.trim()
            : null,
      );

      await _withdrawalService.requestWithdrawal(
        technicianId: authState.user.id,
        technicianName: authState.user.fullName,
        amount: double.parse(_amountController.text),
        bankDetails: bankDetails,
      );

      // Save bank details for future use
      await _withdrawalService.saveBankDetails(authState.user.id, bankDetails);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('withdrawalRequestSubmitted'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('withdrawTitle'.tr())),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.spaceMD),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    _buildBalanceCard(theme),
                    const SizedBox(height: DesignTokens.spaceLG),

                    // Amount Input
                    Text(
                      'withdrawAmount'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceSM),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: 'enterAmount'.tr(),
                        prefixText: 'EGP ',
                        suffixIcon: TextButton(
                          onPressed: () {
                            _amountController.text =
                                _balance?.availableBalance.toStringAsFixed(0) ??
                                '0';
                          },
                          child: Text('max'.tr()),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusMD,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'pleaseEnterAmount'.tr();
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'pleaseEnterValidAmount'.tr();
                        }
                        if (amount < 100) {
                          return 'minimumWithdrawal'.tr();
                        }
                        if (amount > (_balance?.availableBalance ?? 0)) {
                          return 'insufficientBalance'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: DesignTokens.spaceLG),

                    // Bank Details Section
                    Text(
                      'bankDetails'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceSM),

                    // Bank Name
                    TextFormField(
                      controller: _bankNameController,
                      decoration: InputDecoration(
                        labelText: 'bankName'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusMD,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'required'.tr() : null,
                    ),
                    const SizedBox(height: DesignTokens.spaceMD),

                    // Account Number
                    TextFormField(
                      controller: _accountNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'accountNumber'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusMD,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'required'.tr() : null,
                    ),
                    const SizedBox(height: DesignTokens.spaceMD),

                    // Account Holder Name
                    TextFormField(
                      controller: _accountHolderController,
                      decoration: InputDecoration(
                        labelText: 'accountHolderName'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusMD,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'required'.tr() : null,
                    ),
                    const SizedBox(height: DesignTokens.spaceMD),

                    // IBAN (Optional)
                    TextFormField(
                      controller: _ibanController,
                      decoration: InputDecoration(
                        labelText: '${'iban'.tr()} (${('optional'.tr())})',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusMD,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceXL),

                    // Processing Time Note
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.spaceMD),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusMD,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: DesignTokens.spaceSM),
                          Expanded(
                            child: Text(
                              'withdrawalProcessingNote'.tr(),
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceLG),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitWithdrawal,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('submitWithdrawal'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
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
            '${_balance?.availableBalance.toStringAsFixed(0) ?? '0'} EGP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBalanceItem(
                'totalEarnings'.tr(),
                '${_balance?.totalEarnings.toStringAsFixed(0) ?? '0'} EGP',
              ),
              const SizedBox(width: 24),
              _buildBalanceItem(
                'pending'.tr(),
                '${_balance?.pendingAmount.toStringAsFixed(0) ?? '0'} EGP',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
