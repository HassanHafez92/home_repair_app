// File: lib/screens/technician/notification_settings_screen.dart
// Purpose: Allow technicians to manage their notification preferences

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../models/notification_preferences_model.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _firestore = FirebaseFirestore.instance;
  NotificationPreferences? _preferences;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('notifications')
          .get();

      if (mounted) {
        setState(() {
          if (doc.exists) {
            _preferences = NotificationPreferences.fromFirestore(doc);
          } else {
            _preferences = NotificationPreferences.defaults();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _preferences = NotificationPreferences.defaults();
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errorLoadingSettings'.tr())));
      }
    }
  }

  Future<void> _savePreferences() async {
    if (_preferences == null) return;

    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('notifications')
          .set(_preferences!.toFirestore());

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('settingsSaved'.tr())));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errorSavingSettings'.tr())));
      }
    }
  }

  void _updatePreference(NotificationPreferences newPreferences) {
    setState(() => _preferences = newPreferences);
    _savePreferences();
  }

  Future<void> _pickQuietHoursStart() async {
    final time = await showTimePicker(
      context: context,
      initialTime:
          _preferences?.quietHoursStart ?? const TimeOfDay(hour: 22, minute: 0),
    );

    if (time != null && _preferences != null) {
      _updatePreference(_preferences!.copyWith(quietHoursStart: time));
    }
  }

  Future<void> _pickQuietHoursEnd() async {
    final time = await showTimePicker(
      context: context,
      initialTime:
          _preferences?.quietHoursEnd ?? const TimeOfDay(hour: 7, minute: 0),
    );

    if (time != null && _preferences != null) {
      _updatePreference(_preferences!.copyWith(quietHoursEnd: time));
    }
  }

  void _clearQuietHours() {
    if (_preferences != null) {
      _updatePreference(_preferences!.copyWith(clearQuietHours: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('notificationSettings'.tr())),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _preferences == null
          ? Center(child: Text('errorLoadingSettings'.tr()))
          : ListView(
              children: [
                // Notification Types Section
                _buildSectionHeader('notificationTypes'.tr()),
                _buildToggleTile(
                  icon: Icons.work_outline,
                  title: 'newOrderAlerts'.tr(),
                  subtitle: 'whenNewJobsMatchServices'.tr(),
                  value: _preferences!.newOrders,
                  onChanged: (value) => _updatePreference(
                    _preferences!.copyWith(newOrders: value),
                  ),
                ),
                _buildToggleTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'chatMessages'.tr(),
                  subtitle: 'customerMessages'.tr(),
                  value: _preferences!.chatMessages,
                  onChanged: (value) => _updatePreference(
                    _preferences!.copyWith(chatMessages: value),
                  ),
                ),
                _buildToggleTile(
                  icon: Icons.star_outline,
                  title: 'newReviews'.tr(),
                  subtitle: 'whenCustomersRateYou'.tr(),
                  value: _preferences!.reviews,
                  onChanged: (value) =>
                      _updatePreference(_preferences!.copyWith(reviews: value)),
                ),
                _buildToggleTile(
                  icon: Icons.payment_outlined,
                  title: 'paymentReceived'.tr(),
                  subtitle: 'earningsNotifications'.tr(),
                  value: _preferences!.payments,
                  onChanged: (value) => _updatePreference(
                    _preferences!.copyWith(payments: value),
                  ),
                ),
                _buildToggleTile(
                  icon: Icons.bar_chart_outlined,
                  title: 'performanceUpdates'.tr(),
                  subtitle: 'weeklySummaries'.tr(),
                  value: _preferences!.performanceUpdates,
                  onChanged: (value) => _updatePreference(
                    _preferences!.copyWith(performanceUpdates: value),
                  ),
                ),
                _buildToggleTile(
                  icon: Icons.update_outlined,
                  title: 'orderStatusChanges'.tr(),
                  subtitle: 'customerActionsOnOrders'.tr(),
                  value: _preferences!.orderStatusChanges,
                  onChanged: (value) => _updatePreference(
                    _preferences!.copyWith(orderStatusChanges: value),
                  ),
                ),

                const Divider(height: 32),

                // Sound & Vibration Section
                _buildSectionHeader('soundAndVibration'.tr()),
                _buildToggleTile(
                  icon: Icons.volume_up_outlined,
                  title: 'sound'.tr(),
                  subtitle: 'playSoundForNotifications'.tr(),
                  value: _preferences!.soundEnabled,
                  onChanged: (value) => _updatePreference(
                    _preferences!.copyWith(soundEnabled: value),
                  ),
                ),
                _buildToggleTile(
                  icon: Icons.vibration_outlined,
                  title: 'vibration'.tr(),
                  subtitle: 'vibrateForNotifications'.tr(),
                  value: _preferences!.vibrationEnabled,
                  onChanged: (value) => _updatePreference(
                    _preferences!.copyWith(vibrationEnabled: value),
                  ),
                ),

                const Divider(height: 32),

                // Quiet Hours Section
                _buildSectionHeader('quietHours'.tr()),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'quietHoursDescription'.tr(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.bedtime_outlined),
                  title: Text('startTime'.tr()),
                  subtitle: _preferences!.quietHoursStart != null
                      ? Text(_preferences!.quietHoursStart!.format(context))
                      : Text('notSet'.tr()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickQuietHoursStart,
                ),
                ListTile(
                  leading: const Icon(Icons.wb_sunny_outlined),
                  title: Text('endTime'.tr()),
                  subtitle: _preferences!.quietHoursEnd != null
                      ? Text(_preferences!.quietHoursEnd!.format(context))
                      : Text('notSet'.tr()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickQuietHoursEnd,
                ),
                if (_preferences!.quietHoursStart != null &&
                    _preferences!.quietHoursEnd != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextButton.icon(
                      onPressed: _clearQuietHours,
                      icon: const Icon(Icons.clear),
                      label: Text('clearQuietHours'.tr()),
                    ),
                  ),

                const Divider(height: 32),

                // Device Settings
                _buildSectionHeader('deviceSettings'.tr()),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text('manageNotificationPermissions'.tr()),
                  subtitle: Text('openDeviceSettings'.tr()),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    // This will be implemented with permission_handler
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('openSettingsManually'.tr()),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      value: value,
      onChanged: _isSaving ? null : onChanged,
    );
  }
}
