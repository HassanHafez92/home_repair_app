import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../blocs/order/technician_order_bloc.dart';
import '../../helpers/auth_helper.dart';
import '../../theme/design_tokens.dart';
import 'order_action_screen.dart';
import '../../widgets/empty_state.dart';

class IncomingOrdersScreen extends StatefulWidget {
  const IncomingOrdersScreen({super.key});

  @override
  State<IncomingOrdersScreen> createState() => _IncomingOrdersScreenState();
}

class _IncomingOrdersScreenState extends State<IncomingOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userId = context.userId;
        if (userId != null) {
          context.read<TechnicianOrderBloc>().add(LoadTechnicianOrders(userId));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.userId;

    if (userId == null) {
      return Scaffold(body: Center(child: Text('pleaseLogin'.tr())));
    }

    return Scaffold(
      backgroundColor: DesignTokens.neutral100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'incomingOrders'.tr(),
          style: TextStyle(
            color: DesignTokens.neutral900,
            fontWeight: DesignTokens.fontWeightBold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: DesignTokens.neutral600),
            onPressed: () {
              context.read<TechnicianOrderBloc>().add(
                LoadTechnicianOrders(userId),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TechnicianOrderBloc, TechnicianOrderState>(
        builder: (context, state) {
          if (state.status == TechnicianOrderStatus.loading &&
              state.incomingOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TechnicianOrderStatus.failure) {
            return Center(
              child: Text('errorMessage'.tr(args: [state.errorMessage ?? ''])),
            );
          }

          final orders = state.incomingOrders;

          if (orders.isEmpty) {
            return EmptyState(
              title: 'noIncomingOrders'.tr(),
              message: 'waitingForRequests'.tr(),
              icon: Icons.inbox,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TechnicianOrderBloc>().add(
                LoadTechnicianOrders(userId),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(DesignTokens.spaceMD),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(
                  serviceName: order.serviceName ?? 'Service',
                  customerName: order.customerName ?? 'Customer',
                  address: order.address,
                  date: order.dateScheduled,
                  estimatedPrice: order.initialEstimate,
                  onAccept: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderActionScreen(order: order),
                      ),
                    );
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderActionScreen(order: order),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Order card widget - House Maintenance style
class _OrderCard extends StatelessWidget {
  final String serviceName;
  final String customerName;
  final String address;
  final DateTime? date;
  final double? estimatedPrice;
  final VoidCallback onAccept;
  final VoidCallback onTap;

  const _OrderCard({
    required this.serviceName,
    required this.customerName,
    required this.address,
    this.date,
    this.estimatedPrice,
    required this.onAccept,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignTokens.spaceMD),
        padding: const EdgeInsets.all(DesignTokens.spaceMD),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          boxShadow: DesignTokens.shadowSoft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  ),
                  child: Icon(
                    Icons.build_rounded,
                    color: DesignTokens.primaryBlue,
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: TextStyle(
                          fontWeight: DesignTokens.fontWeightBold,
                          color: DesignTokens.neutral900,
                        ),
                      ),
                      Text(
                        customerName,
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeSM,
                          color: DesignTokens.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.accentOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusFull,
                    ),
                  ),
                  child: Text(
                    'new'.tr(),
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeXS,
                      fontWeight: DesignTokens.fontWeightSemiBold,
                      color: DesignTokens.accentOrange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: DesignTokens.spaceMD),
            const Divider(height: 1),
            const SizedBox(height: DesignTokens.spaceMD),

            // Details
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: DesignTokens.neutral400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeSM,
                      color: DesignTokens.neutral600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: DesignTokens.neutral400,
                ),
                const SizedBox(width: 6),
                Text(
                  date != null
                      ? DateFormat.yMMMd().add_jm().format(date!)
                      : 'No date specified',
                  style: TextStyle(
                    fontSize: DesignTokens.fontSizeSM,
                    color: DesignTokens.neutral600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: DesignTokens.spaceMD),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (estimatedPrice != null)
                  Text(
                    '${estimatedPrice!.toInt()} EGP',
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeMD,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: DesignTokens.primaryBlue,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceLG,
                      vertical: DesignTokens.spaceSM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMD,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text('viewDetails'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
