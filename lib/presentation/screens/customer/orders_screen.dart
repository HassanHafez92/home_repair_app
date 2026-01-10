import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:home_repair_app/services/in_app_review_service.dart';
import 'order_details_screen.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/order/customer_order_bloc.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/wrappers.dart';
import '../../widgets/skeleton_order_card.dart';

/// Service for triggering in-app reviews
final _reviewService = InAppReviewService();

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadOrders();
  }

  void _onScroll() {
    if (_isBottom && _tabController.index == 0) {
      context.read<CustomerOrderBloc>().add(const LoadMoreCustomerOrders());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _loadOrders() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CustomerOrderBloc>().add(
        LoadCustomerOrders(userId: authState.user.id),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<OrderEntity> _getFilteredOrders(List<OrderEntity> orders, int tabIndex) {
    switch (tabIndex) {
      case 0: // Current Orders
        return orders
            .where(
              (o) =>
                  o.status == OrderStatus.pending ||
                  o.status == OrderStatus.accepted ||
                  o.status == OrderStatus.traveling ||
                  o.status == OrderStatus.arrived ||
                  o.status == OrderStatus.working,
            )
            .toList();
      case 1: // Past Orders
        return orders.where((o) => o.status == OrderStatus.completed).toList();
      case 2: // Cancelled
        return orders.where((o) => o.status == OrderStatus.cancelled).toList();
      default:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PerformanceMonitorWrapper(
      screenName: 'OrdersScreen',
      child: Scaffold(
        backgroundColor: DesignTokens.neutral100,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'myOrders'.tr(),
            style: TextStyle(
              color: DesignTokens.neutral900,
              fontWeight: DesignTokens.fontWeightBold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: DesignTokens.neutral200, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: DesignTokens.primaryBlue,
                unselectedLabelColor: DesignTokens.neutral500,
                indicatorColor: DesignTokens.primaryBlue,
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontWeight: DesignTokens.fontWeightSemiBold,
                  fontSize: DesignTokens.fontSizeBase,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: DesignTokens.fontWeightMedium,
                  fontSize: DesignTokens.fontSizeBase,
                ),
                tabs: [
                  Tab(text: 'currentOrders'.tr()),
                  Tab(text: 'pastOrders'.tr()),
                  Tab(text: 'cancelled'.tr()),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Could navigate to all orders or filter
              },
              child: Row(
                children: [
                  Text(
                    'seeAll'.tr(),
                    style: TextStyle(
                      color: DesignTokens.primaryBlue,
                      fontWeight: DesignTokens.fontWeightSemiBold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: DesignTokens.primaryBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
        body: BlocBuilder<CustomerOrderBloc, CustomerOrderState>(
          builder: (context, state) {
            if (state.status == CustomerOrderStatus.loading) {
              return const SkeletonOrderList(itemCount: 4);
            } else if (state.status == CustomerOrderStatus.failure) {
              return Center(
                child: Text(
                  'errorMessage'.tr(args: [state.errorMessage ?? '']),
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(
                  _getFilteredOrders(state.orders, 0),
                  state.hasMore,
                  'noCurrentOrders'.tr(),
                ),
                _buildOrdersList(
                  _getFilteredOrders(state.orders, 1),
                  false,
                  'noPastOrders'.tr(),
                  isCompletedOrders: true, // Trigger review for completed
                ),
                _buildOrdersList(
                  _getFilteredOrders(state.orders, 2),
                  false,
                  'noCancelledOrders'.tr(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    List<OrderEntity> orders,
    bool hasMore,
    String emptyMessage, {
    bool isCompletedOrders = false,
  }) {
    // Trigger in-app review check when viewing completed orders
    if (isCompletedOrders && orders.isNotEmpty) {
      // Use addPostFrameCallback to avoid calling during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _reviewService.requestReviewIfEligible();
      });
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: DesignTokens.neutral300,
            ),
            const SizedBox(height: DesignTokens.spaceMD),
            Text(
              emptyMessage,
              style: TextStyle(
                color: DesignTokens.neutral500,
                fontSize: DesignTokens.fontSizeBase,
              ),
            ),
          ],
        ),
      );
    }

    final itemCount = orders.length + (hasMore ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= orders.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _OrderCard(order: orders[index]);
      },
    );
  }
}

/// House Maintenance style order card
class _OrderCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Service title and badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.serviceName ?? 'serviceOrder'.tr(),
                      style: TextStyle(
                        fontSize: DesignTokens.fontSizeMD,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: DesignTokens.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: DesignTokens.neutral100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'cashOnDelivery'.tr(),
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeXS,
                          color: DesignTokens.neutral600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Continue button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsScreen(order: order),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceMD,
                    vertical: DesignTokens.spaceSM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'continue'.tr(),
                  style: const TextStyle(
                    fontSize: DesignTokens.fontSizeSM,
                    fontWeight: DesignTokens.fontWeightSemiBold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: DesignTokens.spaceMD),
          const Divider(height: 1),
          const SizedBox(height: DesignTokens.spaceMD),

          // Date and Service Officer info
          Row(
            children: [
              // Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'date'.tr(),
                      style: TextStyle(
                        fontSize: DesignTokens.fontSizeXS,
                        color: DesignTokens.primaryBlue,
                        fontWeight: DesignTokens.fontWeightSemiBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(order.createdAt),
                      style: TextStyle(
                        fontSize: DesignTokens.fontSizeSM,
                        color: DesignTokens.neutral700,
                        fontWeight: DesignTokens.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
              ),
              // Service Officer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'serviceOfficer'.tr(),
                      style: TextStyle(
                        fontSize: DesignTokens.fontSizeXS,
                        color: DesignTokens.primaryBlue,
                        fontWeight: DesignTokens.fontWeightSemiBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.technicianId != null
                          ? 'assignedTechnician'.tr()
                          : 'pendingAssignment'.tr(),
                      style: TextStyle(
                        fontSize: DesignTokens.fontSizeSM,
                        color: DesignTokens.neutral700,
                        fontWeight: DesignTokens.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Price if available
          if (order.finalPrice != null || order.initialEstimate != null) ...[
            const SizedBox(height: DesignTokens.spaceMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${(order.finalPrice ?? order.initialEstimate ?? 0).toInt()} EGP',
                  style: TextStyle(
                    fontSize: DesignTokens.fontSizeMD,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: DesignTokens.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }
}
