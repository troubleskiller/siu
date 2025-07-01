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