// File: lib/screens/technician/technician_profile_screen.dart
// Purpose: Technician profile with professional details and settings - House Maintenance style

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../helpers/auth_helper.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:home_repair_app/domain/repositories/i_user_repository.dart';
import 'package:home_repair_app/core/di/injection_container.dart';
import 'package:home_repair_app/domain/entities/technician_entity.dart';
import 'package:home_repair_app/services/review_service.dart';
import 'package:home_repair_app/models/technician_stats.dart';
import 'package:home_repair_app/models/review_model.dart';
import '../../theme/design_tokens.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({super.key});

  @override
  State<TechnicianProfileScreen> createState() =>
      _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  final _userRepository = sl<IUserRepository>();
  final _reviewService = ReviewService();

  TechnicianStats? _stats;
  List<ReviewModel> _reviews = [];
  TechnicianEntity? _technician;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = context.userId;

    if (userId != null) {
      try {
        final statsResult = await _userRepository.getTechnicianStats(userId);
        final techResult = await _userRepository.getTechnician(userId);
        final reviews = await _reviewService.getReviewsForTechnician(userId);

        if (mounted) {
          setState(() {
            statsResult.fold(
              (failure) => _stats = null,
              (stats) => _stats = TechnicianStats(
                rating: stats.rating,
                completedJobsToday: stats.completedJobsToday,
                completedJobsTotal: stats.completedJobsTotal,
                todayEarnings: stats.todayEarnings,
                pendingOrders: stats.pendingOrders,
                activeJobs: stats.activeJobs,
                lastUpdated: DateTime.now(),
              ),
            );
            techResult.fold(
              (failure) => _technician = null,
              (tech) => _technician = tech,
            );
            _reviews = reviews;
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
    final user = context.currentUser;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: DesignTokens.neutral100,
      body: CustomScrollView(
        slivers: [
          // Gradient Profile Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: DesignTokens.headerGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(DesignTokens.radiusXL),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spaceLG),
                  child: Column(
                    children: [
                      // Avatar and Edit Button
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 47,
                              backgroundColor: Colors.white,
                              backgroundImage: user?.profilePhoto != null
                                  ? NetworkImage(user!.profilePhoto!)
                                  : null,
                              child: user?.profilePhoto == null
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: DesignTokens.primaryBlue,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  context.push('/technician/edit-profile'),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: DesignTokens.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spaceMD),

                      // Name and Email
                      Text(
                        user?.fullName ?? 'technician'.tr(),
                        style: const TextStyle(
                          fontSize: DesignTokens.fontSizeXL,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceMD),

                      // Verified Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: DesignTokens.accentGreen.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusFull,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'verified'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: DesignTokens.fontWeightSemiBold,
                                fontSize: DesignTokens.fontSizeSM,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceLG),

                      // Stats Row
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.spaceMD),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusMD,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              label: 'rating'.tr(),
                              value: _stats?.rating.toStringAsFixed(1) ?? '0.0',
                              icon: Icons.star,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white24,
                            ),
                            _StatItem(
                              label: 'jobs'.tr(),
                              value: '${_stats?.completedJobsTotal ?? 0}',
                              icon: Icons.check_circle,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white24,
                            ),
                            _StatItem(
                              label: 'reviews'.tr(),
                              value: '${_reviews.length}',
                              icon: Icons.rate_review,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(DesignTokens.spaceLG),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Recent Reviews Section
                if (_reviews.isNotEmpty) ...[
                  _SectionTitle(title: 'recentReviews'.tr()),
                  const SizedBox(height: DesignTokens.spaceSM),
                  ...(_reviews
                      .take(2)
                      .map((review) => _ReviewCard(review: review))),
                  const SizedBox(height: DesignTokens.spaceXL),
                ],

                // Specializations
                if (_technician != null &&
                    _technician!.specializations.isNotEmpty) ...[
                  _SectionTitle(title: 'specializations'.tr()),
                  const SizedBox(height: DesignTokens.spaceSM),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _technician!.specializations.map((spec) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: DesignTokens.primaryBlue.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusFull,
                          ),
                          border: Border.all(
                            color: DesignTokens.primaryBlue.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Text(
                          spec,
                          style: TextStyle(
                            color: DesignTokens.primaryBlue,
                            fontWeight: DesignTokens.fontWeightMedium,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: DesignTokens.spaceXL),
                ],

                // Menu Items
                _SectionTitle(title: 'account'.tr()),
                const SizedBox(height: DesignTokens.spaceSM),
                _MenuItem(
                  icon: Icons.person_outline,
                  title: 'editProfile'.tr(),
                  onTap: () => context.push('/technician/edit-profile'),
                ),
                _MenuItem(
                  icon: Icons.work_outline,
                  title: 'portfolio'.tr(),
                  onTap: () => context.push('/technician/portfolio'),
                ),
                _MenuItem(
                  icon: Icons.card_membership,
                  title: 'certifications'.tr(),
                  onTap: () => context.push('/technician/certifications'),
                ),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'serviceAreas'.tr(),
                  onTap: () => context.push('/technician/service-areas'),
                ),

                const SizedBox(height: DesignTokens.spaceLG),
                _SectionTitle(title: 'settings'.tr()),
                const SizedBox(height: DesignTokens.spaceSM),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'notifications'.tr(),
                  onTap: () =>
                      context.push('/technician/notification-settings'),
                ),
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'privacy'.tr(),
                  onTap: () => context.push('/technician/privacy-settings'),
                ),
                _MenuItem(
                  icon: Icons.bar_chart_outlined,
                  title: 'performance'.tr(),
                  onTap: () => context.push('/technician/performance'),
                ),
                _MenuItem(
                  icon: Icons.build_outlined,
                  title: 'diagnostics'.tr(),
                  onTap: () => context.push('/technician/diagnostics'),
                ),
                _MenuItem(
                  icon: Icons.security_outlined,
                  title: 'appPermissions'.tr(),
                  onTap: () => context.push('/technician/permissions'),
                ),

                const SizedBox(height: DesignTokens.spaceXL),

                // Logout Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.spaceMD,
                    ),
                    decoration: BoxDecoration(
                      color: DesignTokens.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMD,
                      ),
                      border: Border.all(
                        color: DesignTokens.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: DesignTokens.error, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'logout'.tr(),
                          style: TextStyle(
                            color: DesignTokens.error,
                            fontWeight: DesignTokens.fontWeightSemiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.space2XL),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: DesignTokens.fontSizeMD,
                fontWeight: DesignTokens.fontWeightBold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: DesignTokens.fontSizeXS,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: DesignTokens.fontSizeMD,
        fontWeight: DesignTokens.fontWeightBold,
        color: DesignTokens.neutral900,
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceSM),
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        boxShadow: DesignTokens.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RatingBarIndicator(
                rating: review.rating.toDouble(),
                itemBuilder: (context, index) =>
                    const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 16.0,
                direction: Axis.horizontal,
              ),
              const Spacer(),
              Text(
                DateFormat.yMMMd().format(review.timestamp),
                style: TextStyle(
                  fontSize: DesignTokens.fontSizeXS,
                  color: DesignTokens.neutral500,
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: TextStyle(color: DesignTokens.neutral700),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignTokens.spaceSM),
        padding: const EdgeInsets.all(DesignTokens.spaceMD),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          boxShadow: DesignTokens.shadowSoft,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DesignTokens.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              ),
              child: Icon(icon, color: DesignTokens.primaryBlue, size: 20),
            ),
            const SizedBox(width: DesignTokens.spaceMD),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: DesignTokens.fontWeightMedium,
                  color: DesignTokens.neutral900,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: DesignTokens.neutral400),
          ],
        ),
      ),
    );
  }
}
