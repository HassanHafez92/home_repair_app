/// Implementation of IChatRepository using ChatService as data source.
///
/// Wraps the existing ChatService and returns Either types for error handling.

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../../services/chat_service.dart';
import '../../models/message_model.dart' as model;
import 'package:uuid/uuid.dart';

class ChatRepositoryImpl implements IChatRepository {
  final ChatService _chatService;

  ChatRepositoryImpl({ChatService? chatService})
    : _chatService = chatService ?? ChatService();

  @override
  Future<Either<Failure, List<ChatEntity>>> getUserChats(String userId) async {
    try {
      // Get chats from the stream once
      final chats = await _chatService.streamUserChats(userId).first;
      return Right(chats.map((chat) => _mapChatModelToEntity(chat)).toList());
    } catch (e) {
      return Left(ServerFailure('Failed to get user chats: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatEntity>> getChatById(String chatId) async {
    // ChatService doesn't have a direct method for this, would need to add
    // For now, return a failure indicating not implemented
    return const Left(ServerFailure('getChatById not yet implemented'));
  }

  @override
  Future<Either<Failure, ChatEntity>> getOrCreateOrderChat(
    String orderId,
    List<String> participants,
  ) async {
    try {
      final chatId = await _chatService.getChatIdForOrder(
        orderId,
        participants,
      );
      // Return a basic entity with the ID
      return Right(
        ChatEntity(id: chatId, orderId: orderId, participants: participants),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get or create order chat: $e'));
    }
  }

  @override
  Stream<List<MessageEntity>> streamMessages(String chatId) {
    return _chatService
        .streamMessages(chatId)
        .map(
          (messages) => messages
              .map((msg) => _mapMessageModelToEntity(chatId, msg))
              .toList(),
        );
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final messageId = const Uuid().v4();
      final now = DateTime.now();

      final messageModel = model.MessageModel(
        id: messageId,
        senderId: senderId,
        text: content,
        timestamp: now,
        type: _mapEntityTypeToModelType(type),
        isRead: false,
      );

      await _chatService.sendMessage(chatId, messageModel);

      return Right(
        MessageEntity(
          id: messageId,
          chatId: chatId,
          senderId: senderId,
          content: content,
          type: type,
          timestamp: now,
          isRead: false,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to send message: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(
    String chatId,
    String userId,
  ) async {
    try {
      await _chatService.markMessagesAsRead(chatId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to mark messages as read: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String userId) async {
    try {
      // Get all user chats and sum unread counts
      final chats = await _chatService.streamUserChats(userId).first;
      int totalUnread = 0;
      for (final chat in chats) {
        totalUnread += chat.unreadCounts[userId] ?? 0;
      }
      return Right(totalUnread);
    } catch (e) {
      return Left(ServerFailure('Failed to get unread count: $e'));
    }
  }

  // Helper methods for mapping
  ChatEntity _mapChatModelToEntity(dynamic chat) {
    return ChatEntity(
      id: chat.id,
      orderId: chat.orderId,
      participants: List<String>.from(chat.participants),
      lastMessage: chat.lastMessage,
      lastMessageTime: chat.lastMessageTime,
      unreadCounts: Map<String, int>.from(chat.unreadCounts),
    );
  }

  MessageEntity _mapMessageModelToEntity(
    String chatId,
    model.MessageModel msg,
  ) {
    return MessageEntity(
      id: msg.id,
      chatId: chatId,
      senderId: msg.senderId,
      content: msg.text,
      type: _mapModelTypeToEntityType(msg.type),
      timestamp: msg.timestamp,
      isRead: msg.isRead,
    );
  }

  MessageType _mapModelTypeToEntityType(dynamic modelType) {
    switch (modelType.toString()) {
      case 'MessageType.image':
        return MessageType.image;
      case 'MessageType.text':
      default:
        return MessageType.text;
    }
  }

  // Map from domain MessageType to model MessageType
  model.MessageType _mapEntityTypeToModelType(MessageType type) {
    switch (type) {
      case MessageType.image:
        return model.MessageType.image;
      case MessageType.text:
      case MessageType.system:
      default:
        return model.MessageType.text;
    }
  }
}
