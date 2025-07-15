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

WebSocketMessage _$WebSocketMessageFromJson(Map<String, dynamic> json) =>
    WebSocketMessage(
      messageId: json['message_id'] as String,
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']),
      ctype: $enumDecode(_$MessageContentTypeEnumMap, json['ctype']),
      content: json['content'] as String,
      createdAt: json['created_at'],
      extra: json['extra'] as Map<String, dynamic>?,
      sessionId: json['session_id'] as String?,
      uid: json['uid'] as String?,
    );

Map<String, dynamic> _$WebSocketMessageToJson(WebSocketMessage instance) =>
    <String, dynamic>{
      'message_id': instance.messageId,
      'type': _$MessageTypeEnumMap[instance.type],
      'ctype': _$MessageContentTypeEnumMap[instance.ctype]!,
      'content': instance.content,
      'created_at': instance.createdAt,
      'extra': instance.extra,
      'session_id': instance.sessionId,
      'uid': instance.uid,
    };

const _$MessageTypeEnumMap = {
  MessageType.user: 'user',
  MessageType.ai: 'ai',
};

const _$MessageContentTypeEnumMap = {
  MessageContentType.text: 'TEXT',
  MessageContentType.picture: 'PICTURE',
  MessageContentType.video: 'VIDEO',
  MessageContentType.recording: 'RECORDING',
  MessageContentType.sharing: 'SHARING',
  MessageContentType.attachment: 'ATTACHMENT',
};

MessageExtra _$MessageExtraFromJson(Map<String, dynamic> json) => MessageExtra(
      responseFor: json['response_for'] as String?,
      responseStatus: json['response_status'] as String?,
      noContent: json['no_content'] as bool?,
      extraVersion: json['extra_version'] as String?,
      changeToKnowledgeCard: json['change_to_knowledge_card'] as bool?,
      knowledgeCardContent: json['knowledge_card_content'] as String?,
      cited:
          (json['cited'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MessageExtraToJson(MessageExtra instance) =>
    <String, dynamic>{
      'response_for': instance.responseFor,
      'response_status': instance.responseStatus,
      'no_content': instance.noContent,
      'extra_version': instance.extraVersion,
      'change_to_knowledge_card': instance.changeToKnowledgeCard,
      'knowledge_card_content': instance.knowledgeCardContent,
      'cited': instance.cited,
    };

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['is_user'] as bool,
      createdAt: json['timestamp'],
      sessionId: json['session_id'] as String?,
      ctype: $enumDecodeNullable(_$MessageContentTypeEnumMap, json['ctype']),
      extra: json['extra'] as Map<String, dynamic>?,
      isKnowledgeCard: json['isKnowledgeCard'] as bool?,
      knowledgeCardId: json['knowledgeCardId'] as String?,
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'is_user': instance.isUser,
      'timestamp': instance.createdAt,
      'session_id': instance.sessionId,
      'ctype': _$MessageContentTypeEnumMap[instance.ctype],
      'extra': instance.extra,
      'isKnowledgeCard': instance.isKnowledgeCard,
      'knowledgeCardId': instance.knowledgeCardId,
    };

ChatSessionInfo _$ChatSessionInfoFromJson(Map<String, dynamic> json) =>
    ChatSessionInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      lastMessage: json['last_message'] as String,
      lastActiveTime: DateTime.parse(json['last_active_time'] as String),
      messageCount: (json['message_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ChatSessionInfoToJson(ChatSessionInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'last_message': instance.lastMessage,
      'last_active_time': instance.lastActiveTime.toIso8601String(),
      'message_count': instance.messageCount,
    };
