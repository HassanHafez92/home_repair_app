// File: lib/widgets/order_map_view.dart
// Purpose: Widget to display multiple order locations on Google Maps with custom markers

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:home_repair_app/utils/map_utils.dart';

class OrderMapView extends StatefulWidget {
  final List<OrderEntity> orders;
  final Function(OrderEntity)? onOrderTapped;
  final double height;
  final bool showControls;

  const OrderMapView({
    super.key,
    required this.orders,
    this.onOrderTapped,
    this.height = 300,
    this.showControls = true,
  });

  @override
  State<OrderMapView> createState() => _OrderMapViewState();
}

class _OrderMapViewState extends State<OrderMapView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLngBounds? _bounds;

  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _loadMapStyle();
  }

  @override
  void didUpdateWidget(OrderMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orders != widget.orders) {
      _createMarkers();
    }
  }

  void _createMarkers() {
    _markers.clear();
    final List<LatLng> locations = [];

    for (final order in widget.orders) {
      final LatLng? location = MapUtils.geoPointToLatLng(order.location);

      if (location != null) {
        locations.add(location);

        _markers.add(
          Marker(
            markerId: MarkerId(order.id),
            position: location,
            icon: MapUtils.getMarkerForOrderStatus(order.status),
            infoWindow: InfoWindow(
              title: _getStatusLabel(order.status),
              snippet: _getCompactAddress(order.address),
              onTap: () {
                if (widget.onOrderTapped != null) {
                  widget.onOrderTapped!(order);
                }
              },
            ),
            onTap: () {
              if (widget.onOrderTapped != null) {
                widget.onOrderTapped!(order);
              }
            },
          ),
        );
      }
    }

    // Calculate bounds for all markers
    if (locations.isNotEmpty) {
      _bounds = MapUtils.getBoundsForLocations(locations);

      // Animate camera to show all markers if controller is ready
      if (_mapController != null && _bounds != null) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(_bounds!, 50),
          );
        });
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Style is now passed to the widget directly

    if (_bounds != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(_bounds!, 50),
        );
      });
    }
  }

  Future<void> _loadMapStyle() async {
    try {
      final style = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/map_styles/custom_map_style.json');
      if (mounted) {
        setState(() {
          _mapStyle = style;
        });
      }
    } catch (e) {
      debugPrint('Error loading map style: $e');
    }
  }

  String _getCompactAddress(String address) {
    final parts = address.split(',');
    if (parts.length > 2) {
      return '${parts[0]}, ${parts[1]}';
    }
    return address;
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.traveling:
        return 'On the way';
      case OrderStatus.arrived:
        return 'Arrived';
      case OrderStatus.working:
        return 'Working';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orders.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No orders to display',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: _bounds != null
              ? CameraPosition(
                  target: LatLng(
                    (_bounds!.northeast.latitude +
                            _bounds!.southwest.latitude) /
                        2,
                    (_bounds!.northeast.longitude +
                            _bounds!.southwest.longitude) /
                        2,
                  ),
                  zoom: 12,
                )
              : MapUtils.defaultCameraPosition,
          markers: _markers,
          style: _mapStyle,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          myLocationButtonEnabled: widget.showControls,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: widget.showControls,
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }
}
