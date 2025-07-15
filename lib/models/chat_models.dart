import 'package:json_annotation/json_annotation.dart';

part 'chat_models.g.dart';

@JsonSerializable()
class ChatSession {
  @JsonKey(name: 'last_processed_message_id')
  final String? lastProcessedMessageId;
  @JsonKey(name: 'last_message_created_at')
  final DateTime? lastMessageCreatedAt;
  final Map<String, dynamic>? extra;
  @JsonKey(name: 'is_group')
  final bool isGroup;
  final String owner;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'session_id')
  final String sessionId;

  ChatSession({
    this.lastProcessedMessageId,
    this.lastMessageCreatedAt,
    this.extra,
    required this.isGroup,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
    required this.sessionId,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionFromJson(json);
  Map<String, dynamic> toJson() => _$ChatSessionToJson(this);
}

@JsonSerializable()
class QueryRequest {
  @JsonKey(name: 'session_id')
  final String sessionId;
  final String query;

  QueryRequest({
    required this.sessionId,
    required this.query,
  });

  factory QueryRequest.fromJson(Map<String, dynamic> json) =>
      _$QueryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$QueryRequestToJson(this);
}

// WebSocket消息类型枚举
enum MessageType {
  user,
  ai;
  
  @override
  String toString() => name;
}

// 消息内容类型枚举
enum MessageContentType {
  @JsonValue('TEXT')
  text,
  @JsonValue('PICTURE')
  picture,
  @JsonValue('VIDEO')
  video,
  @JsonValue('RECORDING')
  recording,
  @JsonValue('SHARING')
  sharing,
  @JsonValue('ATTACHMENT')
  attachment;
  
  @override
  String toString() {
    switch (this) {
      case MessageContentType.text:
        return 'TEXT';
      case MessageContentType.picture:
        return 'PICTURE';
      case MessageContentType.video:
        return 'VIDEO';
      case MessageContentType.recording:
        return 'RECORDING';
      case MessageContentType.sharing:
        return 'SHARING';
      case MessageContentType.attachment:
        return 'ATTACHMENT';
    }
  }
}

// WebSocket消息模型
@JsonSerializable()
class WebSocketMessage {
  @JsonKey(name: 'message_id')
  final String messageId;
  final MessageType? type; // 为null时默认为ai
  final MessageContentType ctype;
  final String content;
  @JsonKey(name: 'created_at')
  final String createdAt;
  final Map<String, dynamic>? extra;
  @JsonKey(name: 'session_id')
  final String? sessionId;
  final String? uid;

  WebSocketMessage({
    required this.messageId,
    this.type,
    required this.ctype,
    required this.content,
    required this.createdAt,
    this.extra,
    this.sessionId,
    this.uid,
  });

  // 获取实际的消息类型（如果type为null则默认为ai）
  MessageType get actualType => type ?? MessageType.ai;
  
  // 是否为用户消息
  bool get isUser => actualType == MessageType.user;
  
  // 是否为AI消息
  bool get isAi => actualType == MessageType.ai;

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) =>
      _$WebSocketMessageFromJson(json);
  Map<String, dynamic> toJson() => _$WebSocketMessageToJson(this);
}

// 消息额外信息模型
@JsonSerializable()
class MessageExtra {
  @JsonKey(name: 'response_for')
  final String? responseFor;
  @JsonKey(name: 'response_status')
  final String? responseStatus;
  @JsonKey(name: 'no_content')
  final bool? noContent;
  @JsonKey(name: 'extra_version')
  final String? extraVersion;
  @JsonKey(name: 'change_to_knowledge_card')
  final bool? changeToKnowledgeCard;
  @JsonKey(name: 'knowledge_card_content')
  final String? knowledgeCardContent;
  final List<String>? cited;

  MessageExtra({
    this.responseFor,
    this.responseStatus,
    this.noContent,
    this.extraVersion,
    this.changeToKnowledgeCard,
    this.knowledgeCardContent,
    this.cited,
  });

  factory MessageExtra.fromJson(Map<String, dynamic> json) =>
      _$MessageExtraFromJson(json);
  Map<String, dynamic> toJson() => _$MessageExtraToJson(this);
}

// 用于前端聊天界面的消息类（兼容原有代码）
@JsonSerializable()
class ChatMessage {
  final String id;
  final String content;
  @JsonKey(name: 'is_user')
  final bool isUser;
  final String createdAt;
  @JsonKey(name: 'session_id')
  final String? sessionId;
  final MessageContentType? ctype;
  final Map<String, dynamic>? extra;
  final bool? isKnowledgeCard;
  final String? knowledgeCardId;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.createdAt,
    this.sessionId,
    this.ctype,
    this.extra,
    this.isKnowledgeCard,
    this.knowledgeCardId,
  });

  // 从WebSocket消息转换为ChatMessage
  factory ChatMessage.fromWebSocketMessage(WebSocketMessage wsMessage) {
    MessageExtra? extraObj;
    try {
      if (wsMessage.extra != null) {
        extraObj = MessageExtra.fromJson(wsMessage.extra!);
      }
    } catch (e) {
      // 如果解析失败，忽略extra
    }

    return ChatMessage(
      id: wsMessage.messageId,
      content: wsMessage.content,
      isUser: wsMessage.isUser,
      createdAt: wsMessage.createdAt,
      sessionId: wsMessage.sessionId,
      ctype: wsMessage.ctype,
      extra: wsMessage.extra,
      isKnowledgeCard: extraObj?.changeToKnowledgeCard,
      knowledgeCardId: extraObj?.knowledgeCardContent,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}

// 用于前端会话列表显示的会话信息类
@JsonSerializable()
class ChatSessionInfo {
  final String id;
  final String title;
  @JsonKey(name: 'last_message')
  final String lastMessage;
  @JsonKey(name: 'last_active_time')
  final DateTime lastActiveTime;
  @JsonKey(name: 'message_count')
  final int? messageCount;

  ChatSessionInfo({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastActiveTime,
    this.messageCount,
  });

  factory ChatSessionInfo.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatSessionInfoToJson(this);
} 