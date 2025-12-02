// File: lib/services/enhanced_permission_service.dart
// Purpose: Comprehensive permission management service

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class EnhancedPermissionService {
  // Check individual permissions
  Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  Future<bool> isPhotosPermissionGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  Future<bool> isNotificationPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // Request individual permissions
  Future<PermissionStatus> requestLocationPermission() async {
    return await Permission.location.request();
  }

  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  Future<PermissionStatus> requestPhotosPermission() async {
    return await Permission.photos.request();
  }

  Future<PermissionStatus> requestNotificationPermission() async {
    return await Permission.notification.request();
  }

  // Check all permissions at once
  Future<Map<String, PermissionStatus>> checkAllPermissions() async {
    return {
      'location': await Permission.location.status,
      'camera': await Permission.camera.status,
      'photos': await Permission.photos.status,
      'notifications': await Permission.notification.status,
    };
  }

  // Get detailed permission info
  Future<PermissionInfo> getPermissionInfo(Permission permission) async {
    final status = await permission.status;
    return PermissionInfo(
      permission: permission,
      status: status,
      isGranted: status.isGranted,
      isDenied: status.isDenied,
      isPermanentlyDenied: status.isPermanentlyDenied,
      isRestricted: status.isRestricted,
      isLimited: status.isLimited,
    );
  }

  // Request permission with rationale
  Future<PermissionStatus> requestPermissionWithRationale(
    BuildContext context,
    Permission permission,
    String rationale,
  ) async {
    final status = await permission.status;

    if (!context.mounted) return status;

    // If permanently denied, guide to settings
    if (status.isPermanentlyDenied) {
      final shouldOpenSettings = await _showSettingsDialog(context, rationale);
      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return status;
    }

    // If denied, show rationale then request
    if (status.isDenied) {
      final shouldRequest = await _showRationaleDialog(context, rationale);
      if (shouldRequest) {
        return await permission.request();
      }
      return status;
    }

    // Already granted or restricted
    return status;
  }

  Future<bool> _showRationaleDialog(
    BuildContext context,
    String rationale,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: Text(rationale),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not Now'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showSettingsDialog(
    BuildContext context,
    String rationale,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Denied'),
            content: Text(
              '$rationale\n\nPlease grant this permission in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  // Get permission name for display
  String getPermissionName(Permission permission) {
    if (permission == Permission.location) return 'Location';
    if (permission == Permission.camera) return 'Camera';
    if (permission == Permission.photos) return 'Photos';
    if (permission == Permission.notification) return 'Notifications';
    return 'Unknown';
  }

  // Get permission description
  String getPermissionDescription(Permission permission) {
    if (permission == Permission.location) {
      return 'Required to show your location to customers and navigate to job sites';
    }
    if (permission == Permission.camera) {
      return 'Required to take photos for job completion and profile updates';
    }
    if (permission == Permission.photos) {
      return 'Required to upload images from your gallery';
    }
    if (permission == Permission.notification) {
      return 'Required to receive new order alerts and customer messages';
    }
    return 'Required for app functionality';
  }

  // Get troubleshooting steps
  List<String> getTroubleshootingSteps(Permission permission) {
    return [
      'Open your device Settings',
      'Find and tap on "Apps" or "Applications"',
      'Find "Home Repair" in the list',
      'Tap on "Permissions"',
      'Enable "${getPermissionName(permission)}" permission',
      'Return to the app and try again',
    ];
  }
}

// Permission info model
class PermissionInfo {
  final Permission permission;
  final PermissionStatus status;
  final bool isGranted;
  final bool isDenied;
  final bool isPermanentlyDenied;
  final bool isRestricted;
  final bool isLimited;

  PermissionInfo({
    required this.permission,
    required this.status,
    required this.isGranted,
    required this.isDenied,
    required this.isPermanentlyDenied,
    required this.isRestricted,
    required this.isLimited,
  });

  String get statusText {
    if (isGranted) return 'Granted';
    if (isPermanentlyDenied) return 'Permanently Denied';
    if (isDenied) return 'Denied';
    if (isRestricted) return 'Restricted';
    if (isLimited) return 'Limited';
    return 'Unknown';
  }

  Color get statusColor {
    if (isGranted) return Colors.green;
    if (isPermanentlyDenied) return Colors.red;
    if (isDenied) return Colors.orange;
    return Colors.grey;
  }

  IconData get statusIcon {
    if (isGranted) return Icons.check_circle;
    if (isPermanentlyDenied) return Icons.block;
    if (isDenied) return Icons.warning;
    return Icons.help;
  }
}
