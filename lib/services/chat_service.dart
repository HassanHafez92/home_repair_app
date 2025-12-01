import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../utils/exceptions.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _chatsCollection =>
      _firestore.collection('chats');

  // Get or create a chat for an order
  Future<String> getChatIdForOrder(
    String orderId,
    List<String> participants,
  ) async {
    try {
      // Check if chat already exists
      final querySnapshot = await _chatsCollection
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }

      // Create new chat
      final chatId = const Uuid().v4();
      final chat = ChatModel(
        id: chatId,
        orderId: orderId,
        participants: participants,
        unreadCounts: {for (var p in participants) p: 0},
      );

      await _chatsCollection.doc(chatId).set(chat.toJson());
      return chatId;
    } catch (e) {
      throw FirestoreException(
        'Failed to get or create chat',
        originalError: e,
      );
    }
  }

  // Send a message
  Future<void> sendMessage(String chatId, MessageModel message) async {
    try {
      final chatRef = _chatsCollection.doc(chatId);
      final messagesRef = chatRef.collection('messages');

      await _firestore.runTransaction((transaction) async {
        // Add message to subcollection
        transaction.set(messagesRef.doc(message.id), message.toJson());

        // Update chat metadata
        final chatDoc = await transaction.get(chatRef);
        if (!chatDoc.exists) throw Exception('Chat not found');

        final currentUnread = Map<String, int>.from(
          chatDoc.data()!['unreadCounts'] ?? {},
        );

        // Increment unread count for other participants
        final participants = List<String>.from(chatDoc.data()!['participants']);
        for (var p in participants) {
          if (p != message.senderId) {
            currentUnread[p] = (currentUnread[p] ?? 0) + 1;
          }
        }

        transaction.update(chatRef, {
          'lastMessage': message.type == MessageType.image
              ? '📷 Image'
              : message.text,
          'lastMessageTime': Timestamp.fromDate(message.timestamp),
          'unreadCounts': currentUnread,
        });
      });
    } catch (e) {
      throw FirestoreException('Failed to send message', originalError: e);
    }
  }

  // Stream messages for a chat
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data()))
              .toList();
        });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final chatRef = _chatsCollection.doc(chatId);

      await _firestore.runTransaction((transaction) async {
        final chatDoc = await transaction.get(chatRef);
        if (!chatDoc.exists) return;

        final currentUnread = Map<String, int>.from(
          chatDoc.data()!['unreadCounts'] ?? {},
        );

        if ((currentUnread[userId] ?? 0) > 0) {
          currentUnread[userId] = 0;
          transaction.update(chatRef, {'unreadCounts': currentUnread});
        }
      });
    } catch (e) {
      // Silently fail for read receipts to avoid disrupting UX
      // ignore: avoid_print
      print('Error marking messages as read: $e');
    }
  }

  // Stream user's chats
  Stream<List<ChatModel>> streamUserChats(String userId) {
    return _chatsCollection
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatModel.fromJson(doc.data()))
              .toList();
        });
  }
}
