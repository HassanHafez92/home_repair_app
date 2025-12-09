import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:home_repair_app/models/chat_model.dart';
import 'package:home_repair_app/services/chat_service.dart';
import 'package:home_repair_app/services/auth_service.dart';
import 'package:home_repair_app/services/firestore_service.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    final chatService = ChatService();
    final firestoreService = context.read<FirestoreService>();

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: Text('messages'.tr())),
      body: StreamBuilder<List<ChatModel>>(
        stream: chatService.streamUserChats(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'noMessagesYet'.tr(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!;

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat.participants.firstWhere(
                (id) => id != user.uid,
              );
              final unreadCount = chat.unreadCounts[user.uid] ?? 0;

              return FutureBuilder(
                future: firestoreService.getUserDoc(otherUserId),
                builder: (context, userSnapshot) {
                  final otherUserData = userSnapshot.data?.data();
                  final otherUserName =
                      otherUserData?['name'] ?? 'Unknown User';
                  final otherUserPhoto = otherUserData?['profileImageUrl'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: otherUserPhoto != null
                          ? NetworkImage(otherUserPhoto)
                          : null,
                      child: otherUserPhoto == null
                          ? Text(otherUserName[0].toUpperCase())
                          : null,
                    ),
                    title: Text(
                      otherUserName,
                      style: TextStyle(
                        fontWeight: unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      chat.lastMessage ?? 'startedChat'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: unreadCount > 0
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (chat.lastMessageTime != null)
                          Text(
                            _formatTime(chat.lastMessageTime!),
                            style: TextStyle(
                              fontSize: 12,
                              color: unreadCount > 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                          ),
                        if (unreadCount > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    onTap: () {
                      context.push(
                        '/chat/${chat.id}',
                        extra: {
                          'otherUserName': otherUserName,
                          'otherUserId': otherUserId,
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return DateFormat.jm().format(time);
    } else if (now.difference(time).inDays < 7) {
      return DateFormat.E().format(time);
    } else {
      return DateFormat.yMd().format(time);
    }
  }
}



