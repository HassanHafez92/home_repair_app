// File: lib/screens/technician/privacy_settings_screen.dart
// Purpose: Privacy and data management settings for technicians

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('privacySettings'.tr())),
      body: ListView(
        children: [
          // Profile Visibility Section
          _buildSectionHeader('profileVisibility'.tr()),

          FutureBuilder<bool>(
            future: _getProfileVisibility(context),
            builder: (context, snapshot) {
              final isVisible = snapshot.data ?? true;
              return SwitchListTile(
                secondary: const Icon(
                  Icons.visibility_outlined,
                  color: Colors.blue,
                ),
                title: Text('profileVisibility'.tr()),
                subtitle: Text('showProfileInSearch'.tr()),
                value: isVisible,
                onChanged: snapshot.hasData
                    ? (value) => _updateProfileVisibility(context, value)
                    : null,
              );
            },
          ),

          const Divider(height: 32),

          // Data Management Section
          _buildSectionHeader('dataManagement'.tr()),

          ListTile(
            leading: const Icon(Icons.download_outlined, color: Colors.blue),
            title: Text('exportMyData'.tr()),
            subtitle: Text('downloadCopyOfYourData'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showExportDataDialog(context),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blue),
            title: Text('dataWeCollect'.tr()),
            subtitle: Text('seeWhatDataWeStore'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDataCollectionInfo(context),
          ),

          const Divider(height: 32),

          // Privacy Policy Section
          _buildSectionHeader('privacyAndTerms'.tr()),

          ListTile(
            leading: const Icon(Icons.policy_outlined, color: Colors.blue),
            title: Text('privacyPolicy'.tr()),
            subtitle: Text('viewOurPrivacyPolicy'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyPolicy(context),
          ),

          ListTile(
            leading: const Icon(Icons.description_outlined, color: Colors.blue),
            title: Text('termsOfService'.tr()),
            subtitle: Text('viewTermsOfService'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTermsOfService(context),
          ),

          const Divider(height: 32),

          // Account Deletion Section
          _buildSectionHeader('accountDeletion'.tr(), color: Colors.red),

          ListTile(
            leading: const Icon(Icons.warning_outlined, color: Colors.red),
            title: Text(
              'requestAccountDeletion'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
            subtitle: Text('permanentlyDeleteAccount'.tr()),
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: () => _showAccountDeletionDialog(context),
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

  void _showExportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('exportMyData'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('dataExportDescription'.tr()),
            const SizedBox(height: 16),
            Text(
              'dataIncluded'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDataItem('profileInfo'.tr()),
            _buildDataItem('orderHistory'.tr()),
            _buildDataItem('earnings'.tr()),
            _buildDataItem('reviews'.tr()),
            _buildDataItem('serviceAreas'.tr()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _exportUserData(context);
            },
            child: Text('exportData'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _exportUserData(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Collect user data from Firestore
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('technicianId', isEqualTo: user.uid)
          .get();

      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('technicianId', isEqualTo: user.uid)
          .get();

      // Create export data object
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'userId': user.uid,
        'email': user.email,
        'profile': userData.data(),
        'orders': ordersSnapshot.docs.map((doc) => doc.data()).toList(),
        'reviews': reviewsSnapshot.docs.map((doc) => doc.data()).toList(),
      };

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // In a real app, this would generate a downloadable file
      // For now, we'll show a success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('dataExportRequested'.tr()),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // TODO: Implement actual file download
      // This would typically involve:
      // 1. Converting data to JSON/CSV
      // 2. Using a package like path_provider and share_plus
      // 3. Saving file locally or sharing it
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${'error'.tr()}: $e')));
      }
    }
  }

  void _showDataCollectionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('dataWeCollect'.tr()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'dataTransparencyIntro'.tr(),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildDataCategory('personalInfo'.tr(), [
                'name'.tr(),
                'email'.tr(),
                'phoneNumber'.tr(),
                'profilePhoto'.tr(),
              ]),
              const SizedBox(height: 12),
              _buildDataCategory('professionalInfo'.tr(), [
                'specializations'.tr(),
                'yearsOfExperience'.tr(),
                'certifications'.tr(),
                'serviceAreas'.tr(),
              ]),
              const SizedBox(height: 12),
              _buildDataCategory('activityData'.tr(), [
                'orderHistory'.tr(),
                'earnings'.tr(),
                'reviews'.tr(),
                'ratings'.tr(),
              ]),
              const SizedBox(height: 12),
              _buildDataCategory('locationData'.tr(), [
                'serviceLocations'.tr(),
                'currentLocation'.tr(),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCategory(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 3),
            child: Row(
              children: [
                const Icon(Icons.fiber_manual_record, size: 8),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item, style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PolicyViewerScreen(
          title: 'privacyPolicy'.tr(),
          content: _getPrivacyPolicyContent(),
        ),
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PolicyViewerScreen(
          title: 'termsOfService'.tr(),
          content: _getTermsOfServiceContent(),
        ),
      ),
    );
  }

  String _getPrivacyPolicyContent() {
    return '''
# Privacy Policy

**Last Updated: December 2024**

## 1. Information We Collect

We collect information you provide directly to us, including:
- Account information (name, email, phone number)
- Professional credentials and certifications
- Service areas and specializations
- Order history and earnings data
- Location data (with your permission)

## 2. How We Use Your Information

We use the information we collect to:
- Provide and improve our services
- Match you with customer requests
- Process payments
- Send you notifications about orders and updates
- Comply with legal obligations

## 3. Information Sharing

We do not sell your personal information. We may share your information with:
- Customers who book your services
- Payment processors
- Service providers who help us operate our platform

## 4. Data Security

We implement appropriate security measures to protect your personal information.

## 5. Your Rights

You have the right to:
- Access your personal data
- Request corrections to your data
- Request deletion of your account
- Export your data

## 6. Contact Us

For privacy concerns, contact us at privacy@homerepair.com
''';
  }

  String _getTermsOfServiceContent() {
    return '''
# Terms of Service

**Last Updated: December 2024**

## 1. Acceptance of Terms

By using this platform, you agree to these Terms of Service.

## 2. Service Provider Responsibilities

As a service provider, you agree to:
- Provide accurate professional credentials
- Deliver quality services to customers
- Maintain professional conduct
- Comply with local laws and regulations

## 3. Payment Terms

- Service fees are subject to platform commission
- Payments are processed securely
- Refunds are handled according to our refund policy

## 4. Account Termination

We reserve the right to suspend or terminate accounts that violate these terms.

## 5. Liability

The platform connects service providers with customers but is not responsible for the quality of services provided.

## 6. Changes to Terms

We may update these terms from time to time. Continued use constitutes acceptance of changes.

## 7. Contact

For questions about these terms, contact support@homerepair.com
''';
  }

  void _showAccountDeletionDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              Text('deleteAccount'.tr()),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'accountDeletionWarning'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text('accountDeletionConsequences'.tr()),
                const SizedBox(height: 16),
                Text(
                  'whatWillBeDeleted'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDataItem('yourProfile'.tr()),
                _buildDataItem('activeOrdersCancelled'.tr()),
                _buildDataItem('accountAccess'.tr()),
                const SizedBox(height: 12),
                Text(
                  'whatWillBeKept'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDataItem('completedOrderHistory'.tr()),
                _buildDataItem('paymentRecords'.tr()),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'confirmPassword'.tr(),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(
                          () => obscurePassword = !obscurePassword,
                        );
                      },
                    ),
                  ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (passwordController.text.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  _deleteAccount(context, passwordController.text);
                }
              },
              child: Text('deleteAccount'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, String password) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Mark account as deleted in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'accountStatus': 'deleted',
            'deletedAt': FieldValue.serverTimestamp(),
            'profileVisible': false,
          });

      // Cancel all active orders
      final activeOrders = await FirebaseFirestore.instance
          .collection('orders')
          .where('technicianId', isEqualTo: user.uid)
          .where(
            'status',
            whereIn: ['pending', 'accepted', 'traveling', 'working'],
          )
          .get();

      for (var order in activeOrders.docs) {
        await order.reference.update({
          'status': 'cancelled',
          'cancelledBy': 'technician',
          'cancelReason': 'Account deleted',
        });
      }

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Sign out
      await authService.signOut();

      // Show confirmation
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('accountDeletedSuccessfully'.tr()),
            duration: const Duration(seconds: 4),
          ),
        );

        // Navigate to login screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // Close loading if still open
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${'error'.tr()}: $e')));
      }
    }
  }

  Future<bool> _getProfileVisibility(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user == null) return true;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return doc.data()?['profileVisible'] ?? true;
    } catch (e) {
      return true; // Default to visible if error
    }
  }

  Future<void> _updateProfileVisibility(
    BuildContext context,
    bool isVisible,
  ) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'profileVisible': isVisible},
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isVisible ? 'profileNowVisible'.tr() : 'profileNowHidden'.tr(),
            ),
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

// Policy Viewer Screen
class _PolicyViewerScreen extends StatelessWidget {
  final String title;
  final String content;

  const _PolicyViewerScreen({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
      ),
    );
  }
}
