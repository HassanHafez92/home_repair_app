import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../blocs/order/technician_order_bloc.dart';
import 'package:home_repair_app/services/auth_service.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:home_repair_app/utils/map_utils.dart';
import 'job_completion_screen.dart';

class ActiveJobsScreen extends StatefulWidget {
  const ActiveJobsScreen({super.key});

  @override
  State<ActiveJobsScreen> createState() => _ActiveJobsScreenState();
}

class _ActiveJobsScreenState extends State<ActiveJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userId = context.read<AuthService>().currentUser?.uid;
        if (userId != null) {
          context.read<TechnicianOrderBloc>().add(LoadTechnicianOrders(userId));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().currentUser?.uid;

    if (userId == null) {
      return Scaffold(body: Center(child: Text('pleaseLogin'.tr())));
    }

    return Scaffold(
      appBar: AppBar(title: Text('activeJobs'.tr())),
      body: BlocBuilder<TechnicianOrderBloc, TechnicianOrderState>(
        builder: (context, state) {
          if (state.status == TechnicianOrderStatus.loading &&
              state.activeOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TechnicianOrderStatus.failure) {
            return Center(
              child: Text('errorMessage'.tr(args: [state.errorMessage ?? ''])),
            );
          }

          final activeJobs = state.activeOrders
              .where(
                (o) =>
                    o.status == OrderStatus.accepted ||
                    o.status == OrderStatus.traveling ||
                    o.status == OrderStatus.arrived ||
                    o.status == OrderStatus.working,
              )
              .toList();

          if (activeJobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.work_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'noActiveJobs'.tr(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeJobs.length,
            itemBuilder: (context, index) {
              return _buildJobCard(context, activeJobs[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, OrderEntity order) {
    Color statusColor;
    String statusText;

    switch (order.status) {
      case OrderStatus.accepted:
        statusColor = Colors.blue;
        statusText = 'statusAccepted'.tr();
        break;
      case OrderStatus.traveling:
        statusColor = Colors.purple;
        statusText = 'statusTraveling'.tr();
        break;
      case OrderStatus.arrived:
        statusColor = Colors.indigo;
        statusText = 'statusArrived'.tr();
        break;
      case OrderStatus.working:
        statusColor = Colors.orange;
        statusText = 'statusWorking'.tr();
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'UNKNOWN';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'jobId'.tr(args: [order.id.substring(0, 8)]),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.address,
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Navigate button
            OutlinedButton.icon(
              onPressed: () async {
                final location = MapUtils.geoPointToLatLng(order.location);
                if (location != null) {
                  final success = await MapUtils.navigateToLocation(
                    latitude: location.latitude,
                    longitude: location.longitude,
                    label: order.address,
                  );
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open maps application'),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.directions),
              label: Text('navigateToCustomer'.tr()),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (order.status == OrderStatus.accepted)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<TechnicianOrderBloc>().add(
                          UpdateOrderStatus(
                            orderId: order.id,
                            status: OrderStatus.traveling,
                          ),
                        );
                      },
                      child: Text('startTraveling'.tr()),
                    ),
                  ),
                if (order.status == OrderStatus.traveling)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<TechnicianOrderBloc>().add(
                          UpdateOrderStatus(
                            orderId: order.id,
                            status: OrderStatus.arrived,
                          ),
                        );
                      },
                      child: Text('markArrived'.tr()),
                    ),
                  ),
                if (order.status == OrderStatus.arrived)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<TechnicianOrderBloc>().add(
                          UpdateOrderStatus(
                            orderId: order.id,
                            status: OrderStatus.working,
                          ),
                        );
                      },
                      child: Text('startWorking'.tr()),
                    ),
                  ),
                if (order.status == OrderStatus.working)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobCompletionScreen(order: order),
                          ),
                        );
                      },
                      child: Text('completeJob'.tr()),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
