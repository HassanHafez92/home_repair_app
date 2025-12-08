// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportChatModel _$SupportChatModelFromJson(Map<String, dynamic> json) =>
    SupportChatModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      subject: json['subject'] as String?,
      status:
          $enumDecodeNullable(_$SupportChatStatusEnumMap, json['status']) ??
          SupportChatStatus.open,
      assignedAdminId: json['assignedAdminId'] as String?,
      assignedAdminName: json['assignedAdminName'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: _timestampFromJson(json['lastMessageTime']),
      createdAt: _requiredTimestampFromJson(json['createdAt']),
      unreadCounts:
          (json['unreadCounts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$SupportChatModelToJson(SupportChatModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'subject': instance.subject,
      'status': _$SupportChatStatusEnumMap[instance.status]!,
      'assignedAdminId': instance.assignedAdminId,
      'assignedAdminName': instance.assignedAdminName,
      'lastMessage': instance.lastMessage,
      'lastMessageTime': _timestampToJson(instance.lastMessageTime),
      'createdAt': _timestampToJson(instance.createdAt),
      'unreadCounts': instance.unreadCounts,
    };

const _$SupportChatStatusEnumMap = {
  SupportChatStatus.open: 'open',
  SupportChatStatus.inProgress: 'inProgress',
  SupportChatStatus.closed: 'closed',
};
