// File: lib/screens/admin/admin_support_inbox_screen.dart
// Purpose: Admin screen to view and manage all support chat conversations.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/services/chat_service.dart';
import 'admin_support_chat_screen.dart';

class AdminSupportInboxScreen extends StatefulWidget {
  const AdminSupportInboxScreen({super.key});

  @override
  State<AdminSupportInboxScreen> createState() =>
      _AdminSupportInboxScreenState();
}

class _AdminSupportInboxScreenState extends State<AdminSupportInboxScreen>
    with SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();
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
        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(icon: const Icon(Icons.inbox), text: 'openChats'.tr()),
              Tab(
                icon: const Icon(Icons.check_circle_outline),
                text: 'resolvedChats'.tr(),
              ),
            ],
          ),
        ),
        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildChatList(showOpen: true),
              _buildChatList(showOpen: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatList({required bool showOpen}) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: showOpen
          ? _chatService.streamOpenSupportChats()
          : _chatService.streamClosedSupportChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final chats = snapshot.data ?? [];

        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  showOpen ? Icons.inbox_outlined : Icons.check_circle_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  showOpen ? 'noOpenChats'.tr() : 'noResolvedChats'.tr(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return _buildChatCard(chat);
          },
        );
      },
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat) {
    final status = chat['status'] as String? ?? 'open';
    final customerName = chat['customerName'] as String? ?? 'Unknown';
    final lastMessage = chat['lastMessage'] as String? ?? 'No messages';
    final createdAt = chat['createdAt'];
    final unreadCounts = chat['unreadCounts'] as Map<String, dynamic>? ?? {};

    // Calculate total unread for admin
    int totalUnread = 0;
    unreadCounts.forEach((key, value) {
      if (key != chat['customerId']) {
        totalUnread += (value as int? ?? 0);
      }
    });

    DateTime? createdDateTime;
    if (createdAt != null) {
      try {
        createdDateTime = (createdAt as dynamic).toDate();
      } catch (_) {}
    }

    Color statusColor;
    String statusText;
    switch (status) {
      case 'inProgress':
        statusColor = Colors.orange;
        statusText = 'inProgress'.tr();
        break;
      case 'closed':
        statusColor = Colors.green;
        statusText = 'resolved'.tr();
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'new'.tr();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminSupportChatScreen(
                chatId: chat['id'] as String,
                customerName: customerName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue[100],
                child: Text(
                  customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Chat Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage,
                      style: TextStyle(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (createdDateTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, HH:mm').format(createdDateTime),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              // Unread badge
              if (totalUnread > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    totalUnread > 99 ? '99+' : totalUnread.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}



