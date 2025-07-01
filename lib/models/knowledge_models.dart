import 'package:json_annotation/json_annotation.dart';
import '../constants/api_constants.dart';

part 'knowledge_models.g.dart';

@JsonSerializable()
class CollectedInformationItem {
  final String id;
  final String ctype;
  final String content;
  final String owner;
  final Map<String, dynamic> metadata;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final List<String> tags;

  CollectedInformationItem({
    required this.id,
    required this.ctype,
    required this.content,
    required this.owner,
    required this.metadata,
    required this.createdAt,
    required this.tags,
  });

  factory CollectedInformationItem.fromJson(Map<String, dynamic> json) =>
      _$CollectedInformationItemFromJson(json);
  Map<String, dynamic> toJson() => _$CollectedInformationItemToJson(this);
}

@JsonSerializable()
class CollectedInformationItemUpdate {
  final String? content;
  final Map<String, dynamic>? metadata;
  final List<String>? tags;

  CollectedInformationItemUpdate({
    this.content,
    this.metadata,
    this.tags,
  });

  factory CollectedInformationItemUpdate.fromJson(Map<String, dynamic> json) =>
      _$CollectedInformationItemUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$CollectedInformationItemUpdateToJson(this);
}

@JsonSerializable()
class BaseInformation {
  final String? title;
  @JsonKey(name: 'short_summary')
  final String? shortSummary;
  final String? category;

  BaseInformation({
    this.title,
    this.shortSummary,
    this.category,
  });

  factory BaseInformation.fromJson(Map<String, dynamic> json) =>
      _$BaseInformationFromJson(json);
  Map<String, dynamic> toJson() => _$BaseInformationToJson(this);
}

@JsonSerializable()
class CollectedInformationItemWithBaseInformation {
  final String id;
  final String ctype;
  final String content;
  final String owner;
  final Map<String, dynamic> metadata;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final List<String> tags;
  @JsonKey(name: 'base_information')
  final BaseInformation baseInformation;

  CollectedInformationItemWithBaseInformation({
    required this.id,
    required this.ctype,
    required this.content,
    required this.owner,
    required this.metadata,
    required this.createdAt,
    required this.tags,
    required this.baseInformation,
  });

  factory CollectedInformationItemWithBaseInformation.fromJson(
          Map<String, dynamic> json) =>
      _$CollectedInformationItemWithBaseInformationFromJson(json);
  Map<String, dynamic> toJson() =>
      _$CollectedInformationItemWithBaseInformationToJson(this);
}

@JsonSerializable()
class CollectedInformationItemWithShortSummary {
  final String id;
  final String ctype;
  final String content;
  final String owner;
  final Map<String, dynamic> metadata;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final List<String> tags;
  @JsonKey(name: 'short_summary', defaultValue: ApiConstants.defaultShortSummary)
  final String shortSummary;

  CollectedInformationItemWithShortSummary({
    required this.id,
    required this.ctype,
    required this.content,
    required this.owner,
    required this.metadata,
    required this.createdAt,
    required this.tags,
    required this.shortSummary,
  });

  factory CollectedInformationItemWithShortSummary.fromJson(
          Map<String, dynamic> json) =>
      _$CollectedInformationItemWithShortSummaryFromJson(json);
  Map<String, dynamic> toJson() =>
      _$CollectedInformationItemWithShortSummaryToJson(this);
}

@JsonSerializable()
class PaginatedCollectedInformation {
  final int totalItems;
  final int page;
  @JsonKey(name: 'page_size')
  final int pageSize;
  final List<CollectedInformationItem> items;

  PaginatedCollectedInformation({
    required this.totalItems,
    required this.page,
    required this.pageSize,
    required this.items,
  });

  factory PaginatedCollectedInformation.fromJson(Map<String, dynamic> json) =>
      _$PaginatedCollectedInformationFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedCollectedInformationToJson(this);
}

@JsonSerializable()
class PaginatedByCursorCollectedInformation {
  final int totalItems;
  final List<CollectedInformationItem> items;

  PaginatedByCursorCollectedInformation({
    required this.totalItems,
    required this.items,
  });

  factory PaginatedByCursorCollectedInformation.fromJson(
          Map<String, dynamic> json) =>
      _$PaginatedByCursorCollectedInformationFromJson(json);
  Map<String, dynamic> toJson() =>
      _$PaginatedByCursorCollectedInformationToJson(this);
}

@JsonSerializable()
class PaginatedByCursorCollectedInformationWithShortSummary {
  final int totalItems;
  final List<CollectedInformationItemWithShortSummary> items;

  PaginatedByCursorCollectedInformationWithShortSummary({
    required this.totalItems,
    required this.items,
  });

  factory PaginatedByCursorCollectedInformationWithShortSummary.fromJson(
          Map<String, dynamic> json) =>
      _$PaginatedByCursorCollectedInformationWithShortSummaryFromJson(json);
  Map<String, dynamic> toJson() =>
      _$PaginatedByCursorCollectedInformationWithShortSummaryToJson(this);
}

@JsonSerializable()
class PaginatedByCursorCollectedInformationWithBaseInformation {
  final int totalItems;
  final List<CollectedInformationItemWithBaseInformation> items;

  PaginatedByCursorCollectedInformationWithBaseInformation({
    required this.totalItems,
    required this.items,
  });

  factory PaginatedByCursorCollectedInformationWithBaseInformation.fromJson(
          Map<String, dynamic> json) =>
      _$PaginatedByCursorCollectedInformationWithBaseInformationFromJson(json);
  Map<String, dynamic> toJson() =>
      _$PaginatedByCursorCollectedInformationWithBaseInformationToJson(this);
}

@JsonSerializable()
class FileInfoResponse {
  @JsonKey(name: 'file_id')
  final String fileId;
  final String? metadata;
  final String filename;
  @JsonKey(name: 'content_type')
  final String contentType;
  @JsonKey(name: 'file_size')
  final int fileSize;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  FileInfoResponse({
    required this.fileId,
    this.metadata,
    required this.filename,
    required this.contentType,
    required this.fileSize,
    required this.createdAt,
  });

  factory FileInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$FileInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FileInfoResponseToJson(this);
}

@JsonSerializable()
class SignedURLResponse {
  final String url;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  SignedURLResponse({
    required this.url,
    required this.expiresAt,
  });

  factory SignedURLResponse.fromJson(Map<String, dynamic> json) =>
      _$SignedURLResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SignedURLResponseToJson(this);
}

@JsonSerializable()
class UploadFileResponse {
  @JsonKey(name: 'file_id')
  final String fileId;
  @JsonKey(name: 'file_name')
  final String fileName;

  UploadFileResponse({
    required this.fileId,
    required this.fileName,
  });

  factory UploadFileResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadFileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UploadFileResponseToJson(this);
} 