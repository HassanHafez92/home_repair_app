// Repository interface for chat operations.
//
// Defines the contract for chat-related data access.
// Implementations handle Firestore/remote data sources.

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/chat_entity.dart';

abstract class IChatRepository {
  /// Get all chats for a user.
  Future<Either<Failure, List<ChatEntity>>> getUserChats(String userId);

  /// Get a specific chat by ID.
  Future<Either<Failure, ChatEntity>> getChatById(String chatId);

  /// Get or create a chat for an order.
  Future<Either<Failure, ChatEntity>> getOrCreateOrderChat(
    String orderId,
    List<String> participants,
  );

  /// Stream messages for a chat.
  Stream<List<MessageEntity>> streamMessages(String chatId);

  /// Send a message in a chat.
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    MessageType type,
  });

  /// Mark messages as read for a user.
  Future<Either<Failure, void>> markMessagesAsRead(
    String chatId,
    String userId,
  );

  /// Get unread message count for a user.
  Future<Either<Failure, int>> getUnreadCount(String userId);
}
