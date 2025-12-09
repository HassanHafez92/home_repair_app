// File: lib/screens/admin/user_management_screen.dart
// Purpose: Manage users and approve pending technicians.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_repair_app/services/firestore_service.dart';
import 'package:home_repair_app/models/technician_model.dart';
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
            children: [
              _buildPendingTechniciansList(),
              const Center(child: Text('All Users List (Coming Soon)')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTechniciansList() {
    final firestoreService = context.read<FirestoreService>();

    return StreamBuilder<List<TechnicianModel>>(
      stream: firestoreService.streamPendingTechnicians(),
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
                        await firestoreService.updateTechnicianStatus(
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
                        await firestoreService.updateTechnicianStatus(
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
}



