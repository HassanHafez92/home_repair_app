import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final Function(int)? onNavigate;

  const AppDrawer({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final user = state is AuthAuthenticated ? state.user : null;
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.deepOrange),
                accountName: Text(
                  user?.fullName ?? 'Guest',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(user?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: user?.profilePhoto != null
                      ? NetworkImage(user!.profilePhoto!)
                      : null,
                  child: user?.profilePhoto == null
                      ? Text(
                          (user?.fullName ?? 'G').substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.deepOrange,
                          ),
                        )
                      : null,
                ),
              );
            },
          ),

          // Navigation Items
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('home'.tr()),
            onTap: () {
              Navigator.pop(context); // Close drawer
              onNavigate?.call(0); // Go to Home tab
            },
          ),
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: Text('services'.tr()),
            onTap: () {
              Navigator.pop(context);
              onNavigate?.call(1); // Go to Services tab
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: Text('orders'.tr()),
            onTap: () {
              Navigator.pop(context);
              onNavigate?.call(2); // Go to Orders tab
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('profile'.tr()),
            onTap: () {
              Navigator.pop(context);
              onNavigate?.call(4); // Go to Profile tab
            },
          ),

          const Divider(),

          // Settings & Actions
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('language'.tr()),
            trailing: Text(
              context.locale.languageCode == 'en' ? 'EN' : 'AR',
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () {
              if (context.locale.languageCode == 'en') {
                context.setLocale(const Locale('ar'));
              } else {
                context.setLocale(const Locale('en'));
              }
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text('helpSupport'.tr()),
            onTap: () {
              Navigator.pop(context);
              context.push('/customer/help');
            },
          ),

          const Spacer(),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              'logout'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              final authService = context.read<AuthService>();
              await authService.signOut();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
