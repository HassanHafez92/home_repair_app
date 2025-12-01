// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  participants: (json['participants'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lastMessage: json['lastMessage'] as String?,
  lastMessageTime: _timestampFromJson(json['lastMessageTime']),
  unreadCounts:
      (json['unreadCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'participants': instance.participants,
  'lastMessage': instance.lastMessage,
  'lastMessageTime': _timestampToJson(instance.lastMessageTime),
  'unreadCounts': instance.unreadCounts,
};
