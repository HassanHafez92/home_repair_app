// File: lib/screens/admin/user_management_screen.dart
// Purpose: Manage users and approve pending technicians.

import 'package:flutter/material.dart';
import 'package:home_repair_app/domain/repositories/i_user_repository.dart';
import 'package:home_repair_app/core/di/injection_container.dart';
import 'package:home_repair_app/domain/entities/technician_entity.dart';
import 'package:home_repair_app/domain/entities/user_entity.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/technician_card.dart';

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
        TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Pending Technicians'),
            Tab(text: 'All Users'),
          ],
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
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final technicians = snapshot.data ?? [];

        if (technicians.isEmpty) {
          return const Center(child: Text('No pending approvals'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: technicians.length,
          itemBuilder: (context, index) {
            final tech = technicians[index];
            return Column(
              children: [
                TechnicianCard(technician: tech, showStatus: true),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      text: 'Reject',
                      width: 100,
                      variant: ButtonVariant.outline,
                      onPressed: () async {
                        await userRepository.updateTechnicianStatus(
                          tech.id,
                          TechnicianStatus.rejected,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    CustomButton(
                      text: 'Approve',
                      width: 100,
                      onPressed: () async {
                        await userRepository.updateTechnicianStatus(
                          tech.id,
                          TechnicianStatus.approved,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${tech.fullName} approved'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
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
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.profilePhoto != null
                      ? NetworkImage(user.profilePhoto!)
                      : null,
                  child: user.profilePhoto == null
                      ? Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : '?',
                        )
                      : null,
                ),
                title: Text(user.fullName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    const SizedBox(height: 4),
                    _buildRoleBadge(user.role),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _handleUserAction(user, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View Details'),
                    ),
                    if (user.role == UserRole.technician)
                      const PopupMenuItem(
                        value: 'suspend',
                        child: Text('Suspend'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    Color color;
    String label;
    switch (role) {
      case UserRole.admin:
        color = Colors.purple;
        label = 'Admin';
        break;
      case UserRole.technician:
        color = Colors.blue;
        label = 'Technician';
        break;
      case UserRole.customer:
        color = Colors.green;
        label = 'Customer';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
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
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.fullName} deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
