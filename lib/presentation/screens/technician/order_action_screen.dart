// File: lib/screens/technician/order_action_screen.dart
// Purpose: Detailed order view for technician to accept/reject with estimate.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:home_repair_app/services/auth_service.dart';
import '../../blocs/order/technician_order_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class OrderActionScreen extends StatefulWidget {
  final OrderEntity order;

  const OrderActionScreen({super.key, required this.order});

  @override
  State<OrderActionScreen> createState() => _OrderActionScreenState();
}

class _OrderActionScreenState extends State<OrderActionScreen> {
  final _estimateController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _estimateController.dispose();
    super.dispose();
  }

  Future<void> _acceptOrder() async {
    final estimate = double.tryParse(_estimateController.text);
    if (estimate == null || estimate <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('enterValidEstimate'.tr())));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = context.read<AuthService>();
      final technicianId = authService.currentUser?.uid;

      if (technicianId == null) throw Exception('Not logged in');

      context.read<TechnicianOrderBloc>().add(
        AcceptOrder(
          orderId: widget.order.id,
          technicianId: technicianId,
          estimate: estimate,
        ),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('orderAcceptedSuccess'.tr())));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errorMessage'.tr(args: [e.toString()])),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('orderDetails'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info
            Text(
              'orderInfo'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'orderIdLabel'.tr(),
              '#${widget.order.id.substring(0, 8)}',
            ),
            _buildInfoRow('description'.tr(), widget.order.description),
            _buildInfoRow('serviceAddress'.tr(), widget.order.address),
            if (widget.order.dateScheduled != null)
              _buildInfoRow(
                'scheduled'.tr(),
                widget.order.dateScheduled.toString().split('.')[0],
              ),
            const SizedBox(height: 24),

            // Customer Info (mock - in real app, fetch from Firestore)
            Text(
              'customerInfo'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('nameLabel'.tr(), 'Customer Name'),
            _buildInfoRow('phoneLabel'.tr(), '+20 XXX XXX XXXX'),
            const SizedBox(height: 24),

            // Estimate Input
            Text(
              'yourEstimate'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'estimatedPriceLabel'.tr(),
              hint: 'estimatedPriceHint'.tr(),
              controller: _estimateController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              'visitFeeIncluded'.tr(
                args: [widget.order.visitFee.toInt().toString()],
              ),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 32),

            // Actions
            CustomButton(
              text: 'acceptOrder'.tr(),
              onPressed: _acceptOrder,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'reject'.tr(),
              variant: ButtonVariant.outline,
              onPressed: () => _rejectOrder(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rejectOrder(BuildContext context) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('rejectOrderTitle'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('rejectReasonPrompt'.tr()),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'rejectReasonHint'.tr(),
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('reject'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      if (reasonController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('provideReason'.tr())));
        return;
      }

      try {
        context.read<TechnicianOrderBloc>().add(
          RejectOrder(orderId: widget.order.id, reason: reasonController.text),
        );

        if (context.mounted) {
          Navigator.pop(context); // Close screen
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('orderRejected'.tr())));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('errorMessage'.tr(args: [e.toString()]))),
          );
        }
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
