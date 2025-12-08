import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../utils/exceptions.dart';
import 'dart:io';
import 'storage_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

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

  // Upload chat image
  Future<String> uploadChatImage(File imageFile, String chatId) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final String storagePath = 'chat_images/$chatId/$fileName';
      return await _storageService.uploadFile(storagePath, imageFile);
    } catch (e) {
      throw FirestoreException('Failed to upload chat image', originalError: e);
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

  // ========== SUPPORT CHAT METHODS ==========

  CollectionReference<Map<String, dynamic>> get _supportChatsCollection =>
      _firestore.collection('support_chats');

  /// Get or create a support chat for a customer.
  ///
  /// Returns existing open chat or creates a new one.
  Future<String> getOrCreateSupportChat({
    required String customerId,
    required String customerName,
    String? subject,
  }) async {
    try {
      // Check for existing open chat
      final querySnapshot = await _supportChatsCollection
          .where('customerId', isEqualTo: customerId)
          .where('status', isEqualTo: 'open')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }

      // Create new support chat
      final chatId = const Uuid().v4();
      final now = DateTime.now();

      await _supportChatsCollection.doc(chatId).set({
        'id': chatId,
        'customerId': customerId,
        'customerName': customerName,
        'subject': subject,
        'status': 'open',
        'assignedAdminId': null,
        'assignedAdminName': null,
        'lastMessage': null,
        'lastMessageTime': null,
        'createdAt': Timestamp.fromDate(now),
        'unreadCounts': {customerId: 0},
      });

      return chatId;
    } catch (e) {
      throw FirestoreException(
        'Failed to get or create support chat',
        originalError: e,
      );
    }
  }

  /// Send a message in a support chat.
  Future<void> sendSupportMessage(String chatId, MessageModel message) async {
    try {
      final chatRef = _supportChatsCollection.doc(chatId);
      final messagesRef = chatRef.collection('messages');

      await _firestore.runTransaction((transaction) async {
        transaction.set(messagesRef.doc(message.id), message.toJson());

        final chatDoc = await transaction.get(chatRef);
        if (!chatDoc.exists) throw Exception('Support chat not found');

        final currentUnread = Map<String, int>.from(
          chatDoc.data()!['unreadCounts'] ?? {},
        );

        // Increment unread for all participants except sender
        final customerId = chatDoc.data()!['customerId'] as String;
        final adminId = chatDoc.data()!['assignedAdminId'] as String?;

        if (message.senderId == customerId && adminId != null) {
          currentUnread[adminId] = (currentUnread[adminId] ?? 0) + 1;
        } else if (message.senderId != customerId) {
          currentUnread[customerId] = (currentUnread[customerId] ?? 0) + 1;
        }

        // Mark as in progress if admin responds
        final updates = <String, dynamic>{
          'lastMessage': message.type == MessageType.image
              ? '📷 Image'
              : message.text,
          'lastMessageTime': Timestamp.fromDate(message.timestamp),
          'unreadCounts': currentUnread,
        };

        if (message.senderId != customerId &&
            chatDoc.data()!['status'] == 'open') {
          updates['status'] = 'inProgress';
        }

        transaction.update(chatRef, updates);
      });
    } catch (e) {
      throw FirestoreException(
        'Failed to send support message',
        originalError: e,
      );
    }
  }

  /// Stream messages for a support chat.
  Stream<List<MessageModel>> streamSupportMessages(String chatId) {
    return _supportChatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data()))
              .toList();
        });
  }

  /// Mark support chat messages as read.
  Future<void> markSupportMessagesAsRead(String chatId, String userId) async {
    try {
      final chatRef = _supportChatsCollection.doc(chatId);

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
      // Silently fail for read receipts
      // ignore: avoid_print
      print('Error marking support messages as read: $e');
    }
  }

  /// Close a support chat.
  Future<void> closeSupportChat(String chatId) async {
    try {
      await _supportChatsCollection.doc(chatId).update({'status': 'closed'});
    } catch (e) {
      throw FirestoreException(
        'Failed to close support chat',
        originalError: e,
      );
    }
  }

  /// Stream all open support chats (for admin dashboard).
  Stream<List<Map<String, dynamic>>> streamOpenSupportChats() {
    return _supportChatsCollection
        .where('status', whereIn: ['open', 'inProgress'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  /// Assign an admin to a support chat.
  Future<void> assignAdminToSupportChat({
    required String chatId,
    required String adminId,
    required String adminName,
  }) async {
    try {
      final chatRef = _supportChatsCollection.doc(chatId);

      await _firestore.runTransaction((transaction) async {
        final chatDoc = await transaction.get(chatRef);
        if (!chatDoc.exists) throw Exception('Support chat not found');

        final currentUnread = Map<String, int>.from(
          chatDoc.data()!['unreadCounts'] ?? {},
        );
        currentUnread[adminId] = 0;

        transaction.update(chatRef, {
          'assignedAdminId': adminId,
          'assignedAdminName': adminName,
          'status': 'inProgress',
          'unreadCounts': currentUnread,
        });
      });
    } catch (e) {
      throw FirestoreException(
        'Failed to assign admin to support chat',
        originalError: e,
      );
    }
  }
}
