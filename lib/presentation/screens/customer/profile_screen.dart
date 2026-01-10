// File: lib/screens/customer/profile_screen.dart
// Purpose: User profile and account settings using BLoC with premium design.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:home_repair_app/services/locale_provider.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/service/service_bloc.dart';
import '../../blocs/service/service_event.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/wrappers.dart';
import '../../widgets/skeleton_loader.dart';
import '../../theme/design_tokens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PerformanceMonitorWrapper(
      screenName: 'ProfileScreen',
      child: Scaffold(
        backgroundColor: isDark
            ? DesignTokens.backgroundDark
            : DesignTokens.neutral100,
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const _ProfileSkeleton();
            }

            final user = state.user;

            return CustomScrollView(
              slivers: [
                // Gradient Header
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
                            // App Bar Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'profile'.tr(),
                                  style: const TextStyle(
                                    fontSize: DesignTokens.fontSizeXL,
                                    fontWeight: DesignTokens.fontWeightBold,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    onPressed: () =>
                                        context.push('/customer/notifications'),
                                    icon: const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DesignTokens.spaceXL),

                            // Profile Avatar
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.white,
                                backgroundImage: user?.profilePhoto != null
                                    ? NetworkImage(user!.profilePhoto!)
                                    : null,
                                child: user?.profilePhoto == null
                                    ? Icon(
                                        Icons.person,
                                        size: 48,
                                        color: DesignTokens.primaryBlue,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spaceMD),

                            // Name and Email
                            Text(
                              user?.fullName ?? 'User',
                              style: const TextStyle(
                                fontSize: DesignTokens.fontSizeLG,
                                fontWeight: DesignTokens.fontWeightBold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: DesignTokens.fontSizeSM,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spaceLG),

                            // Stats Row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DesignTokens.spaceMD,
                                vertical: DesignTokens.spaceSM,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusMD,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _StatItem(value: '0', label: 'orders'.tr()),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  _StatItem(value: '0', label: 'reviews'.tr()),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  _StatItem(value: '0', label: 'saved'.tr()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Menu Items
                SliverPadding(
                  padding: const EdgeInsets.all(DesignTokens.spaceLG),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildAnimatedMenuItem(
                        context,
                        index: 0,
                        icon: Icons.person_outline,
                        title: 'editProfile'.tr(),
                        onTap: () => context.push('/customer/edit-profile'),
                      ),
                      _buildAnimatedMenuItem(
                        context,
                        index: 1,
                        icon: Icons.location_on_outlined,
                        title: 'savedAddresses'.tr(),
                        onTap: () => context.push('/customer/addresses'),
                      ),
                      _buildAnimatedMenuItem(
                        context,
                        index: 2,
                        icon: Icons.notifications_outlined,
                        title: 'notifications'.tr(),
                        onTap: () => context.push('/customer/notifications'),
                      ),
                      _buildAnimatedMenuItem(
                        context,
                        index: 3,
                        icon: Icons.language_outlined,
                        title: 'language'.tr(),
                        subtitle: context.locale.languageCode == 'en'
                            ? 'English'
                            : 'العربية',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          if (context.locale.languageCode == 'en') {
                            LocaleProvider.setLanguageCode('ar');
                            context.setLocale(const Locale('ar'));
                          } else {
                            LocaleProvider.setLanguageCode('en');
                            context.setLocale(const Locale('en'));
                          }
                          context.read<ServiceBloc>().add(
                            const ServiceLoadRequested(),
                          );
                        },
                      ),
                      _buildAnimatedMenuItem(
                        context,
                        index: 4,
                        icon: Icons.help_outline,
                        title: 'helpSupport'.tr(),
                        onTap: () => context.push('/customer/help'),
                      ),
                      _buildAnimatedMenuItem(
                        context,
                        index: 5,
                        icon: Icons.info_outline,
                        title: 'about'.tr(),
                        onTap: () => context.push('/customer/about'),
                      ),
                      const SizedBox(height: DesignTokens.spaceLG),

                      // Logout Button
                      CustomButton(
                        text: 'logout'.tr(),
                        variant: ButtonVariant.outline,
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            const AuthLogoutRequested(),
                          );
                        },
                      ),
                      const SizedBox(height: DesignTokens.spaceMD),
                      Center(
                        child: Text(
                          '${'version'.tr()} 1.0.0',
                          style: TextStyle(
                            color: DesignTokens.neutral500,
                            fontSize: DesignTokens.fontSizeXS,
                          ),
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceXL),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedMenuItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _animController,
              curve: Interval(
                0.1 + (index * 0.08),
                0.5 + (index * 0.08),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Interval(
              0.1 + (index * 0.08),
              0.5 + (index * 0.08),
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: DesignTokens.spaceSM),
          child: Material(
            color: isDark ? DesignTokens.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              child: Container(
                padding: const EdgeInsets.all(DesignTokens.spaceMD),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                  boxShadow: DesignTokens.shadowSoft,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusSM,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: DesignTokens.primaryBlue,
                        size: DesignTokens.iconSizeMD,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: DesignTokens.fontSizeBase,
                              fontWeight: DesignTokens.fontWeightMedium,
                              color: isDark
                                  ? Colors.white
                                  : DesignTokens.neutral900,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: DesignTokens.fontSizeSM,
                                color: DesignTokens.neutral500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: DesignTokens.neutral400),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Stats item for profile header
class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: DesignTokens.fontSizeMD,
            fontWeight: DesignTokens.fontWeightBold,
            color: Colors.white,
          ),
        ),
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

/// Skeleton loader for profile screen
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header skeleton
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: DesignTokens.neutral200,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(DesignTokens.radiusXL),
              ),
            ),
            child: ShimmerEffect(
              child: Container(color: DesignTokens.neutral200),
            ),
          ),
          // Menu items skeleton
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceLG),
            child: Column(
              children: List.generate(
                6,
                (index) => const Padding(
                  padding: EdgeInsets.only(bottom: DesignTokens.spaceSM),
                  child: SkeletonCard(height: 70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
