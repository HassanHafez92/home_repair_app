// File: lib/presentation/screens/customer/service_history_screen.dart
// Purpose: Beautiful timeline view of customer's completed service history.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/order/customer_order_bloc.dart';
import '../../widgets/timeline_widget.dart';
import 'order_details_screen.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  // Filter state
  String? _selectedServiceType;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CustomerOrderBloc>().add(
        LoadCustomerOrders(userId: authState.user.id),
      );
    }
  }

  void _showFilterBottomSheet() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String? tempServiceType = _selectedServiceType;
        DateTimeRange? tempDateRange = _selectedDateRange;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'filterOptions'.tr(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempServiceType = null;
                            tempDateRange = null;
                          });
                        },
                        child: Text('clearAll'.tr()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Service Type Filter
                  Text(
                    'serviceType'.tr(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        label: 'all'.tr(),
                        isSelected: tempServiceType == null,
                        onSelected: () =>
                            setModalState(() => tempServiceType = null),
                      ),
                      _buildFilterChip(
                        label: 'plumbing'.tr(),
                        isSelected: tempServiceType == 'plumbing',
                        onSelected: () =>
                            setModalState(() => tempServiceType = 'plumbing'),
                      ),
                      _buildFilterChip(
                        label: 'electrical'.tr(),
                        isSelected: tempServiceType == 'electrical',
                        onSelected: () =>
                            setModalState(() => tempServiceType = 'electrical'),
                      ),
                      _buildFilterChip(
                        label: 'ac'.tr(),
                        isSelected: tempServiceType == 'ac',
                        onSelected: () =>
                            setModalState(() => tempServiceType = 'ac'),
                      ),
                      _buildFilterChip(
                        label: 'painting'.tr(),
                        isSelected: tempServiceType == 'painting',
                        onSelected: () =>
                            setModalState(() => tempServiceType = 'painting'),
                      ),
                      _buildFilterChip(
                        label: 'cleaning'.tr(),
                        isSelected: tempServiceType == 'cleaning',
                        onSelected: () =>
                            setModalState(() => tempServiceType = 'cleaning'),
                      ),
                      _buildFilterChip(
                        label: 'carpentry'.tr(),
                        isSelected: tempServiceType == 'carpentry',
                        onSelected: () =>
                            setModalState(() => tempServiceType = 'carpentry'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Date Range Filter
                  Text(
                    'dateRange'.tr(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: tempDateRange,
                        builder: (context, child) {
                          return Theme(
                            data: theme.copyWith(
                              colorScheme: theme.colorScheme.copyWith(
                                primary: theme.colorScheme.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (range != null) {
                        setModalState(() => tempDateRange = range);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tempDateRange != null
                                  ? '${_formatDate(tempDateRange!.start)} - ${_formatDate(tempDateRange!.end)}'
                                  : 'selectDateRange'.tr(),
                              style: TextStyle(
                                color: tempDateRange != null
                                    ? theme.textTheme.bodyMedium?.color
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                          if (tempDateRange != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setModalState(() => tempDateRange = null);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedServiceType = tempServiceType;
                          _selectedDateRange = tempDateRange;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('applyFilters'.tr()),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : theme.textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<OrderEntity> _applyFilters(List<OrderEntity> orders) {
    var filtered = orders;

    // Apply service type filter
    if (_selectedServiceType != null) {
      filtered = filtered.where((order) {
        final name = order.serviceName?.toLowerCase() ?? '';
        switch (_selectedServiceType) {
          case 'plumbing':
            return name.contains('plumb') || name.contains('سباكة');
          case 'electrical':
            return name.contains('electric') || name.contains('كهرباء');
          case 'ac':
            return name.contains('ac') ||
                name.contains('مكيف') ||
                name.contains('تكييف');
          case 'painting':
            return name.contains('paint') || name.contains('دهان');
          case 'cleaning':
            return name.contains('clean') || name.contains('نظافة');
          case 'carpentry':
            return name.contains('carpenter') || name.contains('نجار');
          default:
            return true;
        }
      }).toList();
    }

    // Apply date range filter
    if (_selectedDateRange != null) {
      filtered = filtered.where((order) {
        return order.updatedAt.isAfter(
              _selectedDateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            order.updatedAt.isBefore(
              _selectedDateRange!.end.add(const Duration(days: 1)),
            );
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('serviceHistory'.tr()),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterBottomSheet,
                tooltip: 'filter'.tr(),
              ),
              if (_selectedServiceType != null || _selectedDateRange != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<CustomerOrderBloc, CustomerOrderState>(
        builder: (context, state) {
          if (state.status == CustomerOrderStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CustomerOrderStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'errorMessage'.tr(args: [state.errorMessage ?? '']),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadOrders,
                    child: Text('refresh'.tr()),
                  ),
                ],
              ),
            );
          }

          // Filter to only completed orders for the history
          var completedOrders = state.orders
              .where((o) => o.status == OrderStatus.completed)
              .toList();

          // Apply user filters
          completedOrders = _applyFilters(completedOrders);

          if (completedOrders.isEmpty) {
            return _buildEmptyState();
          }

          // Calculate statistics
          final totalSpent = completedOrders.fold<double>(
            0,
            (sum, order) => sum + order.totalPrice,
          );
          final totalOrders = completedOrders.length;

          return CustomScrollView(
            slivers: [
              // Statistics header
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'totalServices'.tr(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalOrders.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 50, color: Colors.white30),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'totalSpent'.tr(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${totalSpent.toInt()} EGP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Section title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'completedServices'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Timeline
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TimelineWidget(
                    items: completedOrders
                        .map((order) => _buildTimelineItem(order))
                        .toList(),
                    reversed: true,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'noServiceHistory'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'noServiceHistoryDesc'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  TimelineItem _buildTimelineItem(OrderEntity order) {
    return TimelineItem(
      id: order.id,
      title: order.serviceName ?? 'service'.tr(),
      subtitle: order.description,
      icon: _getServiceIcon(order.serviceName),
      color: Colors.green,
      dateTime: order.updatedAt,
      isActive: false,
      trailing: Text(
        '${order.totalPrice.toInt()} EGP',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
      expandedContent: _buildExpandedContent(order),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
        );
      },
    );
  }

  Widget _buildExpandedContent(OrderEntity order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photos section
        if (order.photoUrls.isNotEmpty) ...[
          Text(
            'photos'.tr(),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: order.photoUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: order.photoUrls[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Details row
        Row(
          children: [
            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                order.address,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Rebook button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate to booking with the same service
              context.push('/customer/book/${order.serviceId}');
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: Text('rebookService'.tr()),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getServiceIcon(String? serviceName) {
    if (serviceName == null) return Icons.build;

    final name = serviceName.toLowerCase();
    if (name.contains('plumb') || name.contains('سباكة')) {
      return Icons.plumbing;
    } else if (name.contains('electric') || name.contains('كهرباء')) {
      return Icons.electrical_services;
    } else if (name.contains('ac') ||
        name.contains('مكيف') ||
        name.contains('تكييف')) {
      return Icons.ac_unit;
    } else if (name.contains('paint') || name.contains('دهان')) {
      return Icons.format_paint;
    } else if (name.contains('clean') || name.contains('نظافة')) {
      return Icons.cleaning_services;
    } else if (name.contains('carpenter') || name.contains('نجار')) {
      return Icons.carpenter;
    } else {
      return Icons.build;
    }
  }
}
