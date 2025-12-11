// File: lib/screens/technician/account_settings_screen.dart
// Purpose: Allow technicians to manage their account and security settings

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/services/auth_service.dart';
import '../../helpers/auth_helper.dart';
import '../../widgets/custom_text_field.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('accountSettings'.tr())),
      body: ListView(
        children: [
          // Account Information Section
          _buildSectionHeader('accountInformation'.tr()),

          ListTile(
            leading: const Icon(Icons.email_outlined, color: Colors.blue),
            title: Text('email'.tr()),
            subtitle: Text(user?.email ?? 'notAvailable'.tr()),
            trailing: user?.emailVerified == true
                ? Chip(
                    label: Text('verified'.tr()),
                    backgroundColor: Colors.green.withValues(alpha: 0.2),
                    labelStyle: const TextStyle(color: Colors.green),
                  )
                : TextButton(
                    onPressed: () => _resendVerificationEmail(context),
                    child: Text('verifyNow'.tr()),
                  ),
          ),

          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.blue),
            title: Text('changePassword'.tr()),
            subtitle: Text('updateYourPassword'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(context),
          ),

          ListTile(
            leading: const Icon(Icons.email_outlined, color: Colors.blue),
            title: Text('updateEmail'.tr()),
            subtitle: Text('changeYourEmailAddress'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showUpdateEmailDialog(context),
          ),

          const Divider(height: 32),

          // Security Section
          _buildSectionHeader('security'.tr()),

          ListTile(
            leading: const Icon(Icons.history_outlined, color: Colors.blue),
            title: Text('loginActivity'.tr()),
            subtitle: Text('viewRecentLoginActivity'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('featureComingSoon'.tr())));
            },
          ),

          const Divider(height: 32),

          // Danger Zone
          _buildSectionHeader('dangerZone'.tr(), color: Colors.red),

          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: Text(
              'deleteAccount'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
            subtitle: Text('permanentlyDeleteYourAccount'.tr()),
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('contactSupportToDeleteAccount'.tr()),
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

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color ?? Colors.blue,
        ),
      ),
    );
  }

  Future<void> _resendVerificationEmail(BuildContext context) async {
    final authService = context.read<AuthService>();

    try {
      await authService.sendEmailVerification();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('verificationEmailSent'.tr())));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${'error'.tr()}: $e')));
      }
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('changePassword'.tr()),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: currentPasswordController,
                  label: 'currentPassword'.tr(),
                  obscureText: obscureCurrent,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureCurrent ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setDialogState(() => obscureCurrent = !obscureCurrent);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEnterPassword'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: newPasswordController,
                  label: 'newPassword'.tr(),
                  obscureText: obscureNew,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNew ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setDialogState(() => obscureNew = !obscureNew);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEnterPassword'.tr();
                    }
                    if (value.length < 8) {
                      return 'passwordMinLength8'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: confirmPasswordController,
                  label: 'confirmNewPassword'.tr(),
                  obscureText: obscureConfirm,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setDialogState(() => obscureConfirm = !obscureConfirm);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEnterPassword'.tr();
                    }
                    if (value != newPasswordController.text) {
                      return 'passwordsDoNotMatch'.tr();
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext);
                  await _changePassword(
                    context,
                    currentPasswordController.text,
                    newPasswordController.text,
                  );
                }
              },
              child: Text('changePassword'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword(
    BuildContext context,
    String currentPassword,
    String newPassword,
  ) async {
    final authService = context.read<AuthService>();

    try {
      await authService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('passwordChangedSuccessfully'.tr())),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${'error'.tr()}: $e')));
      }
    }
  }

  void _showUpdateEmailDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final newEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('updateEmail'.tr()),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'verificationWillBeSentToNewEmail'.tr(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: newEmailController,
                  label: 'newEmail'.tr(),
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEnterEmail'.tr();
                    }
                    if (!value.contains('@')) {
                      return 'invalidEmail'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  label: 'currentPassword'.tr(),
                  obscureText: obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setDialogState(() => obscurePassword = !obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEnterPassword'.tr();
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext);
                  await _updateEmail(
                    context,
                    passwordController.text,
                    newEmailController.text,
                  );
                }
              },
              child: Text('updateEmail'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateEmail(
    BuildContext context,
    String password,
    String newEmail,
  ) async {
    final authService = context.read<AuthService>();

    try {
      await authService.updateEmail(
        currentPassword: password,
        newEmail: newEmail,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('verificationEmailSentToNewAddress'.tr()),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${'error'.tr()}: $e')));
      }
    }
  }
}
