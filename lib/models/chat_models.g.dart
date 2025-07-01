// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSession _$ChatSessionFromJson(Map<String, dynamic> json) => ChatSession(
      lastProcessedMessageId: json['last_processed_message_id'] as String?,
      lastMessageCreatedAt: json['last_message_created_at'] == null
          ? null
          : DateTime.parse(json['last_message_created_at'] as String),
      extra: json['extra'] as Map<String, dynamic>?,
      isGroup: json['is_group'] as bool,
      owner: json['owner'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sessionId: json['session_id'] as String,
    );

Map<String, dynamic> _$ChatSessionToJson(ChatSession instance) =>
    <String, dynamic>{
      'last_processed_message_id': instance.lastProcessedMessageId,
      'last_message_created_at':
          instance.lastMessageCreatedAt?.toIso8601String(),
      'extra': instance.extra,
      'is_group': instance.isGroup,
      'owner': instance.owner,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'session_id': instance.sessionId,
    };

QueryRequest _$QueryRequestFromJson(Map<String, dynamic> json) => QueryRequest(
      sessionId: json['session_id'] as String,
      query: json['query'] as String,
    );

Map<String, dynamic> _$QueryRequestToJson(QueryRequest instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'query': instance.query,
    };
