// File: lib/screens/admin/user_management_screen.dart
// Purpose: Manage users and approve pending technicians - House Maintenance style

import 'package:flutter/material.dart';
import 'package:home_repair_app/domain/repositories/i_user_repository.dart';
import 'package:home_repair_app/core/di/injection_container.dart';
import 'package:home_repair_app/domain/entities/technician_entity.dart';
import 'package:home_repair_app/domain/entities/user_entity.dart';
import '../../theme/design_tokens.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // House Maintenance Styled Tab Bar
        Container(
          margin: const EdgeInsets.all(DesignTokens.spaceMD),
          decoration: BoxDecoration(
            color: DesignTokens.neutral200,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: DesignTokens.neutral600,
            indicator: BoxDecoration(
              color: DesignTokens.primaryBlue,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.all(4),
            tabs: const [
              Tab(text: 'Pending Technicians'),
              Tab(text: 'All Users'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildPendingTechniciansList(), _buildAllUsersList()],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTechniciansList() {
    final userRepository = sl<IUserRepository>();

    return StreamBuilder<List<TechnicianEntity>>(
      stream: userRepository.streamPendingTechnicians(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: DesignTokens.neutral400,
                ),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final technicians = snapshot.data ?? [];

        if (technicians.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: DesignTokens.accentGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 40,
                    color: DesignTokens.accentGreen,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No pending approvals',
                  style: TextStyle(
                    fontSize: DesignTokens.fontSizeMD,
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: DesignTokens.neutral900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'All technicians have been reviewed',
                  style: TextStyle(color: DesignTokens.neutral500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(DesignTokens.spaceMD),
          itemCount: technicians.length,
          itemBuilder: (context, index) {
            final tech = technicians[index];
            return _TechnicianApprovalCard(
              technician: tech,
              onApprove: () async {
                await userRepository.updateTechnicianStatus(
                  tech.id,
                  TechnicianStatus.approved,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${tech.fullName} approved'),
                      backgroundColor: DesignTokens.accentGreen,
                    ),
                  );
                }
              },
              onReject: () async {
                await userRepository.updateTechnicianStatus(
                  tech.id,
                  TechnicianStatus.rejected,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAllUsersList() {
    final userRepository = sl<IUserRepository>();

    return StreamBuilder<List<UserEntity>>(
      stream: userRepository.streamAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 48,
                  color: DesignTokens.neutral400,
                ),
                const SizedBox(height: 16),
                Text('No users found'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(DesignTokens.spaceMD),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _UserCard(
              user: user,
              onAction: (action) => _handleUserAction(user, action),
            );
          },
        );
      },
    );
  }

  void _handleUserAction(UserEntity user, String action) {
    switch (action) {
      case 'view':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('View details for ${user.fullName}')),
        );
        break;
      case 'suspend':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Suspend ${user.fullName}')));
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  void _showDeleteConfirmation(UserEntity user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.fullName} deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TechnicianApprovalCard extends StatelessWidget {
  final TechnicianEntity technician;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _TechnicianApprovalCard({
    required this.technician,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceMD),
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
              CircleAvatar(
                radius: 28,
                backgroundColor: DesignTokens.primaryBlue.withValues(
                  alpha: 0.1,
                ),
                backgroundImage: technician.profilePhoto != null
                    ? NetworkImage(technician.profilePhoto!)
                    : null,
                child: technician.profilePhoto == null
                    ? Text(
                        technician.fullName.isNotEmpty
                            ? technician.fullName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: DesignTokens.primaryBlue,
                          fontWeight: DesignTokens.fontWeightBold,
                          fontSize: DesignTokens.fontSizeMD,
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
                      technician.fullName,
                      style: TextStyle(
                        fontWeight: DesignTokens.fontWeightBold,
                        fontSize: DesignTokens.fontSizeMD,
                        color: DesignTokens.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      technician.email,
                      style: TextStyle(
                        color: DesignTokens.neutral500,
                        fontSize: DesignTokens.fontSizeSM,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Text(
                  'Pending',
                  style: TextStyle(
                    color: DesignTokens.accentOrange,
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    fontSize: DesignTokens.fontSizeXS,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMD),

          // Specializations
          if (technician.specializations.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: technician.specializations.take(3).map((spec) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.neutral100,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  ),
                  child: Text(
                    spec,
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeXS,
                      color: DesignTokens.neutral700,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: DesignTokens.spaceMD),
          ],

          const Divider(height: 1),
          const SizedBox(height: DesignTokens.spaceMD),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignTokens.error,
                  side: BorderSide(color: DesignTokens.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  ),
                ),
                child: const Text('Reject'),
              ),
              const SizedBox(width: DesignTokens.spaceSM),
              ElevatedButton(
                onPressed: onApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.accentGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  ),
                ),
                child: const Text('Approve'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserEntity user;
  final Function(String) onAction;

  const _UserCard({required this.user, required this.onAction});

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
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.1),
            backgroundImage: user.profilePhoto != null
                ? NetworkImage(user.profilePhoto!)
                : null,
            child: user.profilePhoto == null
                ? Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: _getRoleColor(user.role),
                      fontWeight: DesignTokens.fontWeightBold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: DesignTokens.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontWeight: DesignTokens.fontWeightSemiBold,
                        color: DesignTokens.neutral900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildRoleBadge(user.role),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: DesignTokens.neutral500,
                    fontSize: DesignTokens.fontSizeSM,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: onAction,
            icon: Icon(Icons.more_vert, color: DesignTokens.neutral400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
              if (user.role == UserRole.technician)
                const PopupMenuItem(
                  value: 'suspend',
                  child: Row(
                    children: [
                      Icon(Icons.pause_circle_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Suspend'),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: DesignTokens.error,
                    ),
                    const SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: DesignTokens.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFF9333EA);
      case UserRole.technician:
        return DesignTokens.primaryBlue;
      case UserRole.customer:
        return DesignTokens.accentGreen;
    }
  }

  Widget _buildRoleBadge(UserRole role) {
    final color = _getRoleColor(role);
    String label;
    switch (role) {
      case UserRole.admin:
        label = 'Admin';
        break;
      case UserRole.technician:
        label = 'Technician';
        break;
      case UserRole.customer:
        label = 'Customer';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: DesignTokens.fontSizeXS,
          fontWeight: DesignTokens.fontWeightMedium,
        ),
      ),
    );
  }
}
