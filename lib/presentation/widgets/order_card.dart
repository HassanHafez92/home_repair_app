import 'package:flutter/material.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'status_badge.dart';
import 'custom_button.dart';
import '../theme/design_tokens.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceMD),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceLG),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: DesignTokens.fontWeightBold,
                      ),
                    ),
                  ),
                  StatusBadge.fromOrderStatus(order.status),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceMD),

              // Details
              _buildDetailRow(
                theme,
                Icons.calendar_today_rounded,
                _formatDate(order.dateRequested),
              ),
              const SizedBox(height: DesignTokens.spaceXS),
              if (order.initialEstimate != null)
                _buildDetailRow(
                  theme,
                  Icons.payments_outlined,
                  '${order.initialEstimate!.toInt()} EGP (Estimated)',
                ),

              if (isTechnicianView && order.status == OrderStatus.pending) ...[
                const SizedBox(height: DesignTokens.spaceLG),
                const Divider(),
                const SizedBox(height: DesignTokens.spaceMD),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Reject',
                        variant: ButtonVariant.outline,
                        onPressed: onReject,
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spaceMD),
                    Expanded(
                      child: CustomButton(
                        text: 'Accept',
                        onPressed: onAccept,
                        height: 48,
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

  Widget _buildDetailRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: DesignTokens.neutral500),
        const SizedBox(width: DesignTokens.spaceSM),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: DesignTokens.neutral600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
