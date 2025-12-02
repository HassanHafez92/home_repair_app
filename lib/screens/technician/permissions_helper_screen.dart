// File: lib/screens/technician/permissions_helper_screen.dart
// Purpose: Help users understand and manage app permissions

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/enhanced_permission_service.dart';

class PermissionsHelperScreen extends StatefulWidget {
  const PermissionsHelperScreen({super.key});

  @override
  State<PermissionsHelperScreen> createState() =>
      _PermissionsHelperScreenState();
}

class _PermissionsHelperScreenState extends State<PermissionsHelperScreen> {
  final _permissionService = EnhancedPermissionService();
  Map<String, PermissionStatus>? _permissionStatuses;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    setState(() => _isLoading = true);
    final statuses = await _permissionService.checkAllPermissions();
    setState(() {
      _permissionStatuses = statuses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('appPermissions'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPermissions,
            tooltip: 'refresh'.tr(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'permissionsHelperIntro'.tr(),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                _buildPermissionCard(
                  Permission.location,
                  'location'.tr(),
                  'locationPermissionDesc'.tr(),
                  Icons.location_on,
                  _permissionStatuses!['location']!,
                ),
                _buildPermissionCard(
                  Permission.camera,
                  'camera'.tr(),
                  'cameraPermissionDesc'.tr(),
                  Icons.camera_alt,
                  _permissionStatuses!['camera']!,
                ),
                _buildPermissionCard(
                  Permission.photos,
                  'photos'.tr(),
                  'photosPermissionDesc'.tr(),
                  Icons.photo_library,
                  _permissionStatuses!['photos']!,
                ),
                _buildPermissionCard(
                  Permission.notification,
                  'notifications'.tr(),
                  'notificationsPermissionDesc'.tr(),
                  Icons.notifications,
                  _permissionStatuses!['notifications']!,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: () => openAppSettings(),
                    icon: const Icon(Icons.settings),
                    label: Text('openDeviceSettings'.tr()),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildPermissionCard(
    Permission permission,
    String title,
    String description,
    IconData icon,
    PermissionStatus status,
  ) {
    final isGranted = status.isGranted;
    final isPermanentlyDenied = status.isPermanentlyDenied;
    final isDenied = status.isDenied;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: Icon(
          icon,
          color: isGranted ? Colors.green : Colors.orange,
          size: 32,
        ),
        title: Text(title),
        subtitle: Text(
          isGranted
              ? 'granted'.tr()
              : isPermanentlyDenied
              ? 'permanentlyDenied'.tr()
              : 'notGranted'.tr(),
          style: TextStyle(
            color: isGranted
                ? Colors.green
                : isPermanentlyDenied
                ? Colors.red
                : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: isGranted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : isDenied || isPermanentlyDenied
            ? const Icon(Icons.warning, color: Colors.orange)
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'whyNeeded'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(description),
                const SizedBox(height: 16),
                if (!isGranted) ...[
                  Text(
                    'howToEnable'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._permissionService
                      .getTroubleshootingSteps(permission)
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key + 1}. ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(child: Text(entry.value)),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (!isPermanentlyDenied)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _requestPermission(permission),
                            icon: const Icon(Icons.check),
                            label: Text('grantPermission'.tr()),
                          ),
                        ),
                      if (isPermanentlyDenied)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => openAppSettings(),
                            icon: const Icon(Icons.settings),
                            label: Text('openSettings'.tr()),
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
    );
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    await _loadPermissions();

    if (mounted) {
      final message = status.isGranted
          ? 'permissionGranted'.tr()
          : 'permissionDenied'.tr();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
