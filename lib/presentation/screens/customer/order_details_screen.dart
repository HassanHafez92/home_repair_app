// File: lib/screens/customer/order_details_screen.dart
// Purpose: Detailed view of a single order with status tracking.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import '../../widgets/custom_button.dart';
import 'package:home_repair_app/domain/repositories/i_order_repository.dart';
import 'package:home_repair_app/core/di/injection_container.dart';
import 'package:home_repair_app/services/chat_service.dart';
import '../../helpers/auth_helper.dart';
import 'add_review_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsScreen({super.key, required this.order});

  Future<void> _cancelOrder(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('cancelOrder'.tr()),
        content: Text('cancelOrderConfirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('no'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('yesCancel'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final orderRepository = sl<IOrderRepository>();
        final result = await orderRepository.updateOrderStatus(
          order.id,
          OrderStatus.cancelled,
        );

        result.fold(
          (failure) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'errorCancellingOrder'.tr(args: [failure.message]),
                  ),
                ),
              );
            }
          },
          (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('orderCancelledSuccessfully'.tr())),
              );
              Navigator.pop(context);
            }
          },
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('errorCancellingOrder'.tr(args: [e.toString()])),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('orderNumber'.tr(args: [order.id.substring(0, 8)])),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Timeline
            _buildStatusTimeline(),
            const SizedBox(height: 32),

            // Order Details
            _buildSectionTitle('orderDetails'.tr()),
            const SizedBox(height: 16),
            _buildDetailRow('description'.tr(), order.description),
            _buildDetailRow('serviceAddress'.tr(), order.address),
            if (order.dateScheduled != null)
              _buildDetailRow(
                'scheduled'.tr(),
                order.dateScheduled.toString().split('.')[0],
              ),
            const SizedBox(height: 24),

            // Pricing
            _buildSectionTitle('Pricing'),
            const SizedBox(height: 16),
            if (order.initialEstimate != null)
              _buildDetailRow(
                'estimatedFee'.tr(),
                '${order.initialEstimate!.toInt()} EGP',
              ),
            if (order.finalPrice != null)
              _buildDetailRow(
                'finalPrice'.tr(),
                '${order.finalPrice!.toInt()} EGP',
              ),
            _buildDetailRow('visitFee'.tr(), '${order.visitFee.toInt()} EGP'),
            _buildDetailRow('vat'.tr(), '${order.vat.toInt()} EGP'),
            const Divider(),
            _buildDetailRow(
              'total'.tr(),
              '${((order.finalPrice ?? order.initialEstimate ?? 0) + order.visitFee + order.vat).toInt()} EGP',
              bold: true,
            ),
            const SizedBox(height: 32),

            // Actions
            if (order.status == OrderStatus.pending)
              CustomButton(
                text: 'cancelOrder'.tr(),
                variant: ButtonVariant.outline,
                onPressed: () => _cancelOrder(context),
              ),
            if (order.status == OrderStatus.accepted ||
                order.status == OrderStatus.traveling ||
                order.status == OrderStatus.working)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: CustomButton(
                  text: 'chatWithTechnician'.tr(),
                  variant: ButtonVariant.outline,
                  icon: Icons.chat_bubble_outline,
                  onPressed: () async {
                    if (order.technicianId == null) return;

                    final chatService = ChatService();
                    final userId = context.userId;

                    if (userId == null) return;

                    try {
                      final chatId = await chatService.getChatIdForOrder(
                        order.id,
                        [userId, order.technicianId!],
                      );

                      if (context.mounted) {
                        context.push(
                          '/chat/$chatId',
                          extra: {
                            'otherUserName': 'Technician',
                            'otherUserId': order.technicianId,
                          },
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('failedToStartChat'.tr())),
                        );
                      }
                    }
                  },
                ),
              ),
            if (order.status == OrderStatus.completed)
              CustomButton(
                text: 'leaveReview'.tr(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddReviewScreen(
                        orderId: order.id,
                        technicianId: order.technicianId!,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statusIndex = order.status.index;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'statusTimeline'.tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildTimelineItem(
          'statusPending'.tr(),
          statusIndex >= 0,
          statusIndex > 0,
        ),
        _buildTimelineItem(
          'statusAccepted'.tr(),
          statusIndex >= 1,
          statusIndex > 1,
        ),
        _buildTimelineItem(
          'statusTraveling'.tr(),
          statusIndex >= 2,
          statusIndex > 2,
        ),
        _buildTimelineItem(
          'statusWorking'.tr(),
          statusIndex >= 3,
          statusIndex > 3,
        ),
        _buildTimelineItem('statusCompleted'.tr(), statusIndex >= 4, false),
      ],
    );
  }

  Widget _buildTimelineItem(String title, bool isActive, bool showLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isActive ? Colors.blue : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isActive
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            if (showLine)
              Container(
                width: 2,
                height: 30,
                color: isActive ? Colors.blue : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDetailRow(String label, String? value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
