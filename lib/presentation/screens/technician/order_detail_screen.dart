import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:home_repair_app/utils/map_utils.dart';
import 'package:home_repair_app/services/analytics_service.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('orderDetails'.tr())),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Preview
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      MapUtils.geoPointToLatLng(order.location) ??
                      const LatLng(30.0444, 31.2357),
                  zoom: 15,
                ),
                markers: {
                  if (MapUtils.geoPointToLatLng(order.location) != null)
                    Marker(
                      markerId: MarkerId(order.id),
                      position: MapUtils.geoPointToLatLng(order.location)!,
                      icon: MapUtils.getMarkerForOrderStatus(order.status),
                    ),
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        order.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(order.status)),
                    ),
                    child: Text(
                      order.status.name.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Service Details
                  Text(
                    order.serviceName ?? 'Unknown Service',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${order.totalPrice.toInt()} EGP',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Customer Info
                  _buildSectionTitle('customerInfo'.tr()),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(order.customerName ?? 'Unknown Customer'),
                      subtitle: Text(order.address),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // WhatsApp Button
                          IconButton(
                            icon: const Icon(Icons.chat, color: Colors.green),
                            onPressed: order.customerPhoneNumber != null
                                ? () async {
                                    await AnalyticsService().logWhatsAppContact(
                                      orderId: order.id,
                                    );
                                    final success =
                                        await MapUtils.launchWhatsApp(
                                          order.customerPhoneNumber!,
                                        );
                                    if (!success && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'unableToLaunchWhatsApp'.tr(),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                : null,
                          ),
                          // Call Button
                          IconButton(
                            icon: const Icon(Icons.phone),
                            onPressed: order.customerPhoneNumber != null
                                ? () async {
                                    await AnalyticsService().logCallCustomer(
                                      orderId: order.id,
                                    );
                                    final success =
                                        await MapUtils.launchPhoneDialer(
                                          order.customerPhoneNumber!,
                                        );
                                    if (!success && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'unableToMakeCall'.tr(),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Navigation Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final location = MapUtils.geoPointToLatLng(
                          order.location,
                        );
                        if (location != null) {
                          MapUtils.launchMaps(
                            location.latitude,
                            location.longitude,
                          );
                        }
                      },
                      icon: const Icon(Icons.directions),
                      label: Text('navigateToCustomer'.tr()),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Order Actions
                  if (order.status == OrderStatus.pending) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Reject logic
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: Text('reject'.tr()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Accept logic
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('acceptOrder'.tr()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.traveling:
        return Colors.purple;
      case OrderStatus.arrived:
        return Colors.indigo;
      case OrderStatus.working:
        return Colors.amber;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
