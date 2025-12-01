// File: lib/widgets/order_card.dart
// Purpose: Unified card to display order details for Customer, Technician, and Admin.

import 'package:flutter/material.dart';
import '../models/order_model.dart';
import 'status_badge.dart';
import 'custom_button.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final bool isTechnicianView;
  final bool isAdminView;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.isTechnicianView = false,
    this.isAdminView = false,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Service Name & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.serviceId, // In real app, map ID to Name
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  StatusBadge.fromOrderStatus(order.status),
                ],
              ),
              const SizedBox(height: 12),
              
              // Details
              _buildDetailRow(Icons.calendar_today, _formatDate(order.dateRequested)),
              const SizedBox(height: 8),
              if (order.initialEstimate != null)
                _buildDetailRow(Icons.attach_money, '${order.initialEstimate!.toInt()} EGP (Est.)'),
              
              if (isTechnicianView && order.status == OrderStatus.pending) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Reject',
                        variant: ButtonVariant.outline,
                        onPressed: onReject,
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Accept',
                        onPressed: onAccept,
                        height: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    // Simple formatter, can use intl package later
    return '${date.day}/${date.month}/${date.year}';
  }
}
