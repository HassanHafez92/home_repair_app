// File: lib/screens/technician/technician_profile_screen.dart
// Purpose: Technician profile with professional details and settings.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/auth_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../services/firestore_service.dart';
import '../../services/review_service.dart';
import '../../models/technician_stats.dart';
import '../../models/review_model.dart';
import '../../widgets/custom_button.dart';
import '../../models/technician_model.dart';
import 'edit_profile_screen.dart';
import 'portfolio_screen.dart';
import 'certifications_screen.dart';
import 'service_areas_screen.dart';
import 'account_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'notification_settings_screen.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({super.key});

  @override
  State<TechnicianProfileScreen> createState() =>
      _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  final _firestoreService = FirestoreService();
  final _reviewService = ReviewService();

  TechnicianStats? _stats;
  List<ReviewModel> _reviews = [];
  TechnicianModel? _technician;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user != null) {
      try {
        final stats = await _firestoreService.getTechnicianStats(user.uid);
        final reviews = await _reviewService.getReviewsForTechnician(user.uid);
        final userData = await _firestoreService.getUser(user.uid);

        if (mounted) {
          setState(() {
            _stats = stats;
            _reviews = reviews;
            if (userData is TechnicianModel) {
              _technician = userData;
            }
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error loading profile data: $e');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Mock specializations removed

    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Picture & Info
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[100],
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 50, color: Colors.blue)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'technician'.tr(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  'rating'.tr(),
                  '${_stats?.rating.toStringAsFixed(1) ?? "0.0"} ⭐',
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildStatColumn(
                  'jobs'.tr(),
                  '${_stats?.completedJobsTotal ?? 0}',
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildStatColumn('status'.tr(), 'verified'.tr()),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Reviews
            if (_reviews.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'recentReviews'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reviews.take(3).length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final review = _reviews[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        RatingBarIndicator(
                          rating: review.rating.toDouble(),
                          itemBuilder: (context, index) =>
                              const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 16.0,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat.yMMMd().format(review.timestamp),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(review.comment ?? ''),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],

            // Specializations
            if (_technician != null &&
                _technician!.specializations.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'specializations'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _technician!.specializations.map((spec) {
                  return Chip(
                    label: Text(spec),
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],

            // Menu Items
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: 'editProfile'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            // ... other menu items ...
            _buildMenuItem(
              context,
              icon: Icons.work_outline,
              title: 'portfolio'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PortfolioScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.card_membership,
              title: 'certifications'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CertificationsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.location_on_outlined,
              title: 'serviceAreas'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ServiceAreasScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              title: 'settings'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountSettingsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications_outlined,
              title: 'notifications'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'privacy'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacySettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Logout Button
            CustomButton(
              text: 'logout'.tr(),
              variant: ButtonVariant.outline,
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuItem(
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
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
