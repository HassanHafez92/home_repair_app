// File: lib/screens/customer/notifications_settings_screen.dart
// Purpose: Manage notification preferences and settings.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/services/firestore_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _newsletter = false;
  bool _smsNotifications = true;
  bool _emailNotifications = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      final firestoreService = context.read<FirestoreService>();

      if (authState is AuthAuthenticated) {
        final userDoc = await firestoreService.getUserDoc(authState.user.id);

        if (userDoc.exists && userDoc.data() != null) {
          final prefs =
              userDoc.data()!['notificationPreferences']
                  as Map<String, dynamic>?;

          if (prefs != null) {
            setState(() {
              _orderUpdates = prefs['orderUpdates'] as bool? ?? true;
              _promotions = prefs['promotions'] as bool? ?? true;
              _newsletter = prefs['newsletter'] as bool? ?? false;
              _smsNotifications = prefs['smsNotifications'] as bool? ?? true;
              _emailNotifications =
                  prefs['emailNotifications'] as bool? ?? true;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('errorMessage'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePreferences() async {
    try {
      final authState = context.read<AuthBloc>().state;
      final firestoreService = context.read<FirestoreService>();

      if (authState is AuthAuthenticated) {
        await firestoreService.updateUserFields(authState.user.id, {
          'notificationPreferences': {
            'orderUpdates': _orderUpdates,
            'promotions': _promotions,
            'newsletter': _newsletter,
            'smsNotifications': _smsNotifications,
            'emailNotifications': _emailNotifications,
          },
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('preferencesSaved'.tr())));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('errorMessage'.tr(args: [e.toString()]))),
        );
      }
    }
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: (newValue) {
          onChanged(newValue);
          _savePreferences();
        },
        activeThumbColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('notifications'.tr())),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'notificationPreferences'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'manageNotificationSettings'.tr(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Notification Types
                  Text(
                    'notificationTypes'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildSettingTile(
                    title: 'orderUpdates'.tr(),
                    subtitle: 'orderUpdatesDesc'.tr(),
                    value: _orderUpdates,
                    onChanged: (value) => setState(() => _orderUpdates = value),
                  ),

                  _buildSettingTile(
                    title: 'promotions'.tr(),
                    subtitle: 'promotionsDesc'.tr(),
                    value: _promotions,
                    onChanged: (value) => setState(() => _promotions = value),
                  ),

                  _buildSettingTile(
                    title: 'newsletter'.tr(),
                    subtitle: 'newsletterDesc'.tr(),
                    value: _newsletter,
                    onChanged: (value) => setState(() => _newsletter = value),
                  ),

                  const SizedBox(height: 24),

                  // Delivery Methods
                  Text(
                    'deliveryMethods'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildSettingTile(
                    title: 'smsNotifications'.tr(),
                    subtitle: 'smsNotificationsDesc'.tr(),
                    value: _smsNotifications,
                    onChanged: (value) =>
                        setState(() => _smsNotifications = value),
                  ),

                  _buildSettingTile(
                    title: 'emailNotifications'.tr(),
                    subtitle: 'emailNotificationsDesc'.tr(),
                    value: _emailNotifications,
                    onChanged: (value) =>
                        setState(() => _emailNotifications = value),
                  ),

                  const SizedBox(height: 24),

                  // Info Card
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'notificationNote'.tr(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}



