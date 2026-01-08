import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:home_repair_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:home_repair_app/presentation/blocs/auth/auth_state.dart';
import 'package:home_repair_app/presentation/blocs/auth/auth_event.dart';
import 'package:home_repair_app/presentation/blocs/service/service_bloc.dart';
import 'package:home_repair_app/presentation/blocs/service/service_event.dart';
import 'package:home_repair_app/services/locale_provider.dart';
import '../theme/design_tokens.dart';

class AppDrawer extends StatelessWidget {
  final Function(int)? onNavigate;

  const AppDrawer({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Premium Drawer Header
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final user = state is AuthAuthenticated ? state.user : null;
              return Container(
                padding: const EdgeInsets.only(
                  top: DesignTokens.space2XL,
                  left: DesignTokens.spaceLG,
                  right: DesignTokens.spaceLG,
                  bottom: DesignTokens.spaceLG,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, DesignTokens.primaryBlueDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusSM,
                        ),
                        image: user?.profilePhoto != null
                            ? DecorationImage(
                                image: NetworkImage(user!.profilePhoto!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: user?.profilePhoto == null
                          ? Text(
                              (user?.fullName ?? 'G')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: DesignTokens.fontWeightBold,
                                color: colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: DesignTokens.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Guest User',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: DesignTokens.fontWeightBold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user?.email ?? 'Sign in to access features',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: DesignTokens.spaceMD),

          // Navigation Items
          _buildDrawerItem(
            context,
            icon: Icons.home_rounded,
            label: 'home'.tr(),
            onTap: () {
              Navigator.pop(context);
              onNavigate?.call(0);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.grid_view_rounded,
            label: 'services'.tr(),
            onTap: () {
              Navigator.pop(context);
              onNavigate?.call(1);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.receipt_long_rounded,
            label: 'orders'.tr(),
            onTap: () {
              Navigator.pop(context);
              onNavigate?.call(2);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person_rounded,
            label: 'profile'.tr(),
            onTap: () {
              Navigator.pop(context);
              onNavigate?.call(3);
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spaceLG),
            child: Divider(),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.language_rounded,
            label: 'language'.tr(),
            trailing: Text(
              context.locale.languageCode == 'en' ? 'EN' : 'AR',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: DesignTokens.fontWeightBold,
              ),
            ),
            onTap: () {
              if (context.locale.languageCode == 'en') {
                LocaleProvider.setLanguageCode('ar');
                context.setLocale(const Locale('ar'));
              } else {
                LocaleProvider.setLanguageCode('en');
                context.setLocale(const Locale('en'));
              }
              // Reload services with new locale
              context.read<ServiceBloc>().add(const ServiceLoadRequested());
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.help_outline_rounded,
            label: 'helpSupport'.tr(),
            onTap: () {
              Navigator.pop(context);
              context.push('/customer/help');
            },
          ),

          const Spacer(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spaceLG),
            child: Divider(),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.logout_rounded,
            label: 'logout'.tr(),
            color: DesignTokens.statusCancelled,
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
          const SizedBox(height: DesignTokens.spaceLG),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: color ?? DesignTokens.neutral600),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: color ?? DesignTokens.neutral800,
          fontWeight: DesignTokens.fontWeightSemiBold,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceLG,
      ),
    );
  }
}
