// File: lib/screens/customer/about_screen.dart
// Purpose: About screen with app information, terms, privacy policy, and licenses.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _showDetailDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('about'.tr())),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              color: Colors.blue[50],
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.home_repair_service,
                      size: 64,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'appTitle'.tr(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${'version'.tr()} 1.0.0',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // About Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'aboutApp'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'aboutAppDesc'.tr(),
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Features
                  Text(
                    'features'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureItem(
                    icon: Icons.verified_user,
                    title: 'verifiedTechnicians'.tr(),
                    description: 'verifiedTechniciansDesc'.tr(),
                  ),
                  _buildFeatureItem(
                    icon: Icons.schedule,
                    title: 'instantBooking'.tr(),
                    description: 'instantBookingDesc'.tr(),
                  ),
                  _buildFeatureItem(
                    icon: Icons.payment,
                    title: 'securePayment'.tr(),
                    description: 'securePaymentDesc'.tr(),
                  ),
                  _buildFeatureItem(
                    icon: Icons.track_changes,
                    title: 'realtimeTracking'.tr(),
                    description: 'realtimeTrackingDesc'.tr(),
                  ),

                  const SizedBox(height: 24),

                  // Legal Section
                  Text(
                    'legal'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildLegalItem(
                    context,
                    icon: Icons.description_outlined,
                    title: 'termsConditions'.tr(),
                    onTap: () => _showDetailDialog(
                      context,
                      'termsConditions'.tr(),
                      'termsConditionsContent'.tr(),
                    ),
                  ),

                  _buildLegalItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'privacyPolicy'.tr(),
                    onTap: () => _showDetailDialog(
                      context,
                      'privacyPolicy'.tr(),
                      'privacyPolicyContent'.tr(),
                    ),
                  ),

                  _buildLegalItem(
                    context,
                    icon: Icons.code_outlined,
                    title: 'openSourceLicenses'.tr(),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'appTitle'.tr(),
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.home_repair_service,
                        size: 48,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Company Info
                  Text(
                    'companyInfo'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            Icons.location_on_outlined,
                            'companyAddress'.tr(),
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.email_outlined,
                            'info@homerepair.com',
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.phone_outlined,
                            '+20 123 456 7890',
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.language_outlined,
                            'www.homerepair.com',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'madeWithLove'.tr(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '© 2024 Home Repair App. ${'allRightsReserved'.tr()}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue[100],
            child: Icon(icon, size: 20, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
