// File: lib/screens/customer/help_support_screen.dart
// Purpose: Help & Support screen with FAQ, contact options, and live chat placeholder.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('couldNotLaunch'.tr(args: [url]))),
        );
      }
    }
  }

  Widget _buildFAQTab() {
    final faqs = [
      {'question': 'faqQuestion1'.tr(), 'answer': 'faqAnswer1'.tr()},
      {'question': 'faqQuestion2'.tr(), 'answer': 'faqAnswer2'.tr()},
      {'question': 'faqQuestion3'.tr(), 'answer': 'faqAnswer3'.tr()},
      {'question': 'faqQuestion4'.tr(), 'answer': 'faqAnswer4'.tr()},
      {'question': 'faqQuestion5'.tr(), 'answer': 'faqAnswer5'.tr()},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              faqs[index]['question']!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  faqs[index]['answer']!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'contactUs'.tr(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('contactUsDesc'.tr(), style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),

          _buildContactCard(
            icon: Icons.email_outlined,
            title: 'emailSupport'.tr(),
            subtitle: 'support@homerepair.com',
            onTap: () => _launchUrl('mailto:support@homerepair.com'),
          ),

          _buildContactCard(
            icon: Icons.phone_outlined,
            title: 'phoneSupport'.tr(),
            subtitle: '+20 123 456 7890',
            onTap: () => _launchUrl('tel:+201234567890'),
          ),

          _buildContactCard(
            icon: Icons.chat_outlined,
            title: 'whatsapp'.tr(),
            subtitle: 'chatWithUs'.tr(),
            onTap: () => _launchUrl('https://wa.me/201234567890'),
          ),

          const SizedBox(height: 24),

          Text(
            'socialMedia'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: Icons.facebook,
                label: 'Facebook',
                onTap: () => _launchUrl('https://facebook.com/homerepair'),
              ),
              _buildSocialButton(
                icon: Icons.chat,
                label: 'Twitter',
                onTap: () => _launchUrl('https://twitter.com/homerepair'),
              ),
              _buildSocialButton(
                icon: Icons.camera_alt,
                label: 'Instagram',
                onTap: () => _launchUrl('https://instagram.com/homerepair'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'supportHours'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'supportHoursDesc'.tr(),
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue[100],
            child: Icon(icon, color: Colors.blue, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'liveChatPlaceholder'.tr(),
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'liveChatComingSoon'.tr(),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'typeMessage'.tr(),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  enabled: false,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.grey[400],
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('helpSupport'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.help_outline), text: 'faq'.tr()),
            Tab(
              icon: const Icon(Icons.contact_support_outlined),
              text: 'contactUs'.tr(),
            ),
            Tab(icon: const Icon(Icons.chat_outlined), text: 'liveChat'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFAQTab(), _buildContactTab(), _buildChatTab()],
      ),
    );
  }
}
