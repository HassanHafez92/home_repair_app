// Domain entity representing a chat conversation.
//
// This is a pure Dart class with no framework dependencies.
// Use models in the data layer for Firestore/JSON serialization.

import 'package:equatable/equatable.dart';

/// Entity representing a chat room/conversation between users.
class ChatEntity extends Equatable {
  final String id;
  final String orderId;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCounts; // userId -> count

  const ChatEntity({
    required this.id,
    required this.orderId,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCounts = const {},
  });

  @override
  List<Object?> get props => [
    id,
    orderId,
    participants,
    lastMessage,
    lastMessageTime,
    unreadCounts,
  ];

  ChatEntity copyWith({
    String? id,
    String? orderId,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCounts,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }
}

/// Entity representing a single chat message.
class MessageEntity extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [
    id,
    chatId,
    senderId,
    content,
    type,
    timestamp,
    isRead,
  ];
}

/// Message types supported in chat.
enum MessageType { text, image, system }
