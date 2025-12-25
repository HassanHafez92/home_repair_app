// File: lib/presentation/widgets/live_tracking_map_widget.dart
// Purpose: Widget displaying live map with technician location and ETA for customers.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_repair_app/models/live_tracking_model.dart';
import 'package:home_repair_app/services/live_tracking_service.dart';

/// Widget for displaying live technician tracking on a map
class LiveTrackingMapWidget extends StatefulWidget {
  /// Order ID to track
  final String orderId;

  /// Customer location
  final LatLng customerLocation;

  /// Optional height of the widget
  final double? height;

  /// Whether to show the ETA card
  final bool showEtaCard;

  /// Callback when technician arrives
  final VoidCallback? onArrival;

  const LiveTrackingMapWidget({
    super.key,
    required this.orderId,
    required this.customerLocation,
    this.height,
    this.showEtaCard = true,
    this.onArrival,
  });

  @override
  State<LiveTrackingMapWidget> createState() => _LiveTrackingMapWidgetState();
}

class _LiveTrackingMapWidgetState extends State<LiveTrackingMapWidget> {
  final LiveTrackingService _trackingService = LiveTrackingService();
  GoogleMapController? _mapController;
  StreamSubscription<LiveTrackingModel?>? _trackingSubscription;
  LiveTrackingModel? _tracking;
  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _hasCalledArrival = false;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    _trackingSubscription = _trackingService.trackOrder(widget.orderId).listen((
      tracking,
    ) {
      if (!mounted) return;

      setState(() {
        _tracking = tracking;
        _updateMarkers();
      });

      // Handle arrival notification
      if (tracking?.status == TrackingStatus.arrived &&
          !_hasCalledArrival &&
          widget.onArrival != null) {
        _hasCalledArrival = true;
        widget.onArrival!();
      }

      // Auto-focus camera on technician
      if (tracking != null && tracking.hasLocation && _mapController != null) {
        _animateCameraToShowBoth();
      }
    });
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    // Customer marker
    markers.add(
      Marker(
        markerId: const MarkerId('customer'),
        position: widget.customerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'yourLocation'.tr()),
      ),
    );

    // Technician marker
    if (_tracking?.hasLocation == true) {
      markers.add(
        Marker(
          markerId: const MarkerId('technician'),
          position: LatLng(
            _tracking!.technicianLat!,
            _tracking!.technicianLng!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'technician'.tr(),
            snippet: 'ETA: ${_tracking!.etaDisplay}',
          ),
          rotation: _tracking!.heading ?? 0,
        ),
      );
    }

    _markers = markers;
  }

  void _animateCameraToShowBoth() {
    if (_tracking == null ||
        !_tracking!.hasLocation ||
        _mapController == null) {
      return;
    }

    final techLatLng = LatLng(
      _tracking!.technicianLat!,
      _tracking!.technicianLng!,
    );

    // Calculate bounds to show both locations
    final bounds = LatLngBounds(
      southwest: LatLng(
        techLatLng.latitude < widget.customerLocation.latitude
            ? techLatLng.latitude
            : widget.customerLocation.latitude,
        techLatLng.longitude < widget.customerLocation.longitude
            ? techLatLng.longitude
            : widget.customerLocation.longitude,
      ),
      northeast: LatLng(
        techLatLng.latitude > widget.customerLocation.latitude
            ? techLatLng.latitude
            : widget.customerLocation.latitude,
        techLatLng.longitude > widget.customerLocation.longitude
            ? techLatLng.longitude
            : widget.customerLocation.longitude,
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: widget.height ?? 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.customerLocation,
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              _animateCameraToShowBoth();
            },
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // ETA Card overlay
          if (widget.showEtaCard && _tracking != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildEtaCard(theme),
            ),

          // Status indicator
          if (_tracking != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildStatusBar(theme),
            ),

          // Loading overlay
          if (_tracking == null)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text('waitingForTracking'.tr()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEtaCard(ThemeData theme) {
    final status = _tracking!.status;
    final isEnRoute = status == TrackingStatus.enRoute;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ETA icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isEnRoute
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEnRoute ? Icons.navigation : Icons.check_circle,
              color: isEnRoute ? Colors.blue : Colors.green,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // ETA info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnRoute
                      ? 'technicianEnRoute'.tr()
                      : 'technicianArrived'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isEnRoute) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${_tracking!.distanceDisplay} away',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ETA time
          if (isEnRoute)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _tracking!.etaDisplay,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'eta'.tr(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(ThemeData theme) {
    final trafficColor = _getTrafficColor(_tracking!.trafficCondition);
    final trafficLabel = _getTrafficLabel(_tracking!.trafficCondition);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.traffic, size: 18, color: trafficColor),
          const SizedBox(width: 8),
          Text(
            trafficLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: trafficColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 16, color: Colors.grey[300]),
          const SizedBox(width: 16),
          Icon(Icons.update, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            _getLastUpdatedText(),
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Color _getTrafficColor(TrafficCondition condition) {
    switch (condition) {
      case TrafficCondition.light:
        return Colors.green;
      case TrafficCondition.normal:
        return Colors.blue;
      case TrafficCondition.moderate:
        return Colors.orange;
      case TrafficCondition.heavy:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTrafficLabel(TrafficCondition condition) {
    switch (condition) {
      case TrafficCondition.light:
        return 'lightTraffic'.tr();
      case TrafficCondition.normal:
        return 'normalTraffic'.tr();
      case TrafficCondition.moderate:
        return 'moderateTraffic'.tr();
      case TrafficCondition.heavy:
        return 'heavyTraffic'.tr();
      default:
        return 'checkingTraffic'.tr();
    }
  }

  String _getLastUpdatedText() {
    if (_tracking?.lastUpdated == null) return '--';

    final diff = DateTime.now().difference(_tracking!.lastUpdated!);
    if (diff.inSeconds < 60) {
      return 'justNow'.tr();
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }
}
