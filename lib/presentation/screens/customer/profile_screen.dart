// File: lib/screens/customer/profile_screen.dart
// Purpose: User profile and account settings using BLoC.

import 'package:flutter/material.dart';
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return PerformanceMonitorWrapper(
      screenName: 'ProfileScreen',
      child: Scaffold(
        appBar: AppBar(title: Text('profile'.tr())),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[100],
                    backgroundImage: user?.profilePhoto != null
                        ? NetworkImage(user!.profilePhoto!)
                        : null,
                    child: user?.profilePhoto == null
                        ? const Icon(Icons.person, size: 50, color: Colors.blue)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // Menu Items
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'editProfile'.tr(),
                    onTap: () {
                      context.push('/customer/edit-profile');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.location_on_outlined,
                    title: 'savedAddresses'.tr(),
                    onTap: () {
                      context.push('/customer/addresses');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'notifications'.tr(),
                    onTap: () {
                      context.push('/customer/notifications');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.language_outlined,
                    title: 'language'.tr(),
                    subtitle: context.locale.languageCode == 'en'
                        ? 'English'
                        : 'العربية',
                    onTap: () {
                      if (context.locale.languageCode == 'en') {
                        LocaleProvider.setLanguageCode('ar');
                        context.setLocale(const Locale('ar'));
                      } else {
                        LocaleProvider.setLanguageCode('en');
                        context.setLocale(const Locale('en'));
                      }
                      // Reload services with new locale
                      context.read<ServiceBloc>().add(
                        const ServiceLoadRequested(),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'helpSupport'.tr(),
                    onTap: () {
                      context.push('/customer/help');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'about'.tr(),
                    onTap: () {
                      context.push('/customer/about');
                    },
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  CustomButton(
                    text: 'logout'.tr(),
                    variant: ButtonVariant.outline,
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthLogoutRequested());
                      // AppRouter redirect should handle navigation to /welcome
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${'version'.tr()} 1.0.0',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
