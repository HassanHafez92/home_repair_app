// File: lib/models/support_chat_model.dart
// Purpose: Model for support chat conversations between customers and support staff.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'support_chat_model.g.dart';

/// Status of a support chat conversation.
enum SupportChatStatus {
  /// Chat is active and awaiting response.
  open,

  /// Chat is being handled by support.
  inProgress,

  /// Chat has been resolved.
  closed,
}

/// Model representing a support chat conversation.
///
/// Used for customer-to-support communication in the Help & Support section.
@JsonSerializable()
class SupportChatModel {
  /// Unique identifier for the chat.
  final String id;

  /// ID of the customer who initiated the chat.
  final String customerId;

  /// Display name of the customer.
  final String customerName;

  /// Optional subject/topic of the conversation.
  final String? subject;

  /// Current status of the chat.
  final SupportChatStatus status;

  /// ID of the admin handling this chat (if assigned).
  final String? assignedAdminId;

  /// Name of the assigned admin.
  final String? assignedAdminName;

  /// Last message preview text.
  final String? lastMessage;

  /// Timestamp of the last message.
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? lastMessageTime;

  /// When the chat was created.
  @JsonKey(fromJson: _requiredTimestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  /// Unread message count for each participant.
  final Map<String, int> unreadCounts;

  const SupportChatModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.subject,
    this.status = SupportChatStatus.open,
    this.assignedAdminId,
    this.assignedAdminName,
    this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
    this.unreadCounts = const {},
  });

  factory SupportChatModel.fromJson(Map<String, dynamic> json) =>
      _$SupportChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$SupportChatModelToJson(this);

  /// Creates a copy with updated fields.
  SupportChatModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? subject,
    SupportChatStatus? status,
    String? assignedAdminId,
    String? assignedAdminName,
    String? lastMessage,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    Map<String, int>? unreadCounts,
  }) {
    return SupportChatModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      assignedAdminId: assignedAdminId ?? this.assignedAdminId,
      assignedAdminName: assignedAdminName ?? this.assignedAdminName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }
}

DateTime? _timestampFromJson(dynamic timestamp) {
  if (timestamp == null) return null;
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  } else if (timestamp is String) {
    return DateTime.parse(timestamp);
  } else {
    return null;
  }
}

DateTime _requiredTimestampFromJson(dynamic timestamp) {
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  } else if (timestamp is String) {
    return DateTime.parse(timestamp);
  } else {
    return DateTime.now();
  }
}

dynamic _timestampToJson(DateTime? date) =>
    date != null ? Timestamp.fromDate(date) : null;
