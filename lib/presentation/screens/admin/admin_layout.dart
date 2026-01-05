// File: lib/screens/admin/admin_layout.dart
// Purpose: Admin dashboard layout with sidebar navigation - House Maintenance style

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_repair_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:home_repair_app/presentation/blocs/auth/auth_event.dart';
import '../../theme/design_tokens.dart';
import 'admin_dashboard_screen.dart';
import 'user_management_screen.dart';
import 'service_management_screen.dart';
import 'admin_orders_screen.dart';
import 'seed_data_screen.dart';
import 'admin_support_inbox_screen.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const UserManagementScreen(),
    const ServiceManagementScreen(),
    const AdminOrdersScreen(),
    const AdminSupportInboxScreen(),
    const SeedDataScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'User Management',
    'Services',
    'Orders',
    'Support',
    'Seed Data',
  ];

  final List<IconData> _icons = [
    Icons.dashboard_rounded,
    Icons.people_rounded,
    Icons.category_rounded,
    Icons.shopping_bag_rounded,
    Icons.support_agent_rounded,
    Icons.eco_rounded,
  ];

  final List<IconData> _outlinedIcons = [
    Icons.dashboard_outlined,
    Icons.people_outline,
    Icons.category_outlined,
    Icons.shopping_bag_outlined,
    Icons.support_agent_outlined,
    Icons.eco_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // House Maintenance Styled Sidebar
          Container(
            width: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  DesignTokens.primaryBlue,
                  DesignTokens.primaryBlueDark,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusMD,
                        ),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 28,
                        color: DesignTokens.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Navigation Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: _titles.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIndex == index;
                        return _NavItem(
                          icon: isSelected
                              ? _icons[index]
                              : _outlinedIcons[index],
                          label: _titles[index],
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedIndex = index),
                        );
                      },
                    ),
                  ),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: _NavItem(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      isSelected: false,
                      onTap: () {
                        context.read<AuthBloc>().add(
                          const AuthLogoutRequested(),
                        );
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        _titles[_selectedIndex],
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeXL,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: DesignTokens.neutral900,
                        ),
                      ),
                      const Spacer(),
                      // Search
                      Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DesignTokens.neutral100,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusMD,
                          ),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(
                              color: DesignTokens.neutral400,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: DesignTokens.neutral400,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Notifications
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: DesignTokens.neutral600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Admin Avatar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: DesignTokens.primaryBlue.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusFull,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: DesignTokens.primaryBlue,
                              child: const Text(
                                'A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Admin',
                              style: TextStyle(
                                fontWeight: DesignTokens.fontWeightSemiBold,
                                color: DesignTokens.neutral900,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: DesignTokens.neutral600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Screen Content
                Expanded(
                  child: Container(
                    color: DesignTokens.neutral100,
                    child: _screens[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
