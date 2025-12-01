import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatModel {
  final String id;
  final String orderId;
  final List<String> participants;
  final String? lastMessage;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? lastMessageTime;

  final Map<String, int> unreadCounts; // userId -> count

  ChatModel({
    required this.id,
    required this.orderId,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCounts = const {},
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
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

dynamic _timestampToJson(DateTime? date) =>
    date != null ? Timestamp.fromDate(date) : null;
