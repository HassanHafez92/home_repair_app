import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'order_details_screen.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/order/customer_order_bloc.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'all';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadOrders();
  }

  void _onScroll() {
    if (_isBottom && _selectedFilter == 'all') {
      // Only load more when viewing all orders (not filtered)
      context.read<CustomerOrderBloc>().add(const LoadMoreCustomerOrders());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9); // Trigger at 90% scroll
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('myOrders'.tr())),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all'.tr(), 'all'),
                  _buildFilterChip('pending'.tr(), 'pending'),
                  _buildFilterChip('accepted'.tr(), 'accepted'),
                  _buildFilterChip('working'.tr(), 'working'),
                  _buildFilterChip('completed'.tr(), 'completed'),
                  _buildFilterChip('cancelled'.tr(), 'cancelled'),
                ],
              ),
            ),
          ),
          // Orders List
          Expanded(
            child: BlocBuilder<CustomerOrderBloc, CustomerOrderState>(
              builder: (context, state) {
                if (state.status == CustomerOrderStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == CustomerOrderStatus.failure) {
                  return Center(
                    child: Text(
                      'errorMessage'.tr(args: [state.errorMessage ?? '']),
                    ),
                  );
                }

                final orders = state.orders;
                final filteredOrders = _selectedFilter == 'all'
                    ? orders
                    : orders
                          .where(
                            (o) =>
                                o.status.toString().split('.').last ==
                                _selectedFilter,
                          )
                          .toList();

                if (filteredOrders.isEmpty) {
                  return Center(child: Text('noOrdersFound'.tr()));
                }

                // Calculate item count (including loading indicator)
                final itemCount =
                    filteredOrders.length +
                    (state.hasMore && _selectedFilter == 'all' ? 1 : 0);

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    // Show loading indicator at bottom
                    if (index >= filteredOrders.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return _buildOrderCard(filteredOrders[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = value);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text('orderNumber'.tr(args: [order.id.substring(0, 8)])),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(order.description),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusChip(order.status),
                const Spacer(),
                Text(
                  '${(order.finalPrice ?? order.initialEstimate ?? 0).toInt()} EGP',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String statusText;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        statusText = 'statusPending'.tr();
        break;
      case OrderStatus.accepted:
        color = Colors.blue;
        statusText = 'statusAccepted'.tr();
        break;
      case OrderStatus.traveling:
        color = Colors.purple;
        statusText = 'statusTraveling'.tr();
        break;
      case OrderStatus.arrived:
        color = Colors.purple;
        statusText = 'statusArrived'.tr();
        break;
      case OrderStatus.working:
        color = Colors.purple;
        statusText = 'statusWorking'.tr();
        break;
      case OrderStatus.completed:
        color = Colors.green;
        statusText = 'statusCompleted'.tr();
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        statusText = 'statusCancelled'.tr();
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
