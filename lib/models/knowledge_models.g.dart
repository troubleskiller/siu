// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectedInformationItem _$CollectedInformationItemFromJson(
        Map<String, dynamic> json) =>
    CollectedInformationItem(
      id: json['id'] as String,
      ctype: json['ctype'] as String,
      content: json['content'] as String,
      owner: json['owner'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CollectedInformationItemToJson(
        CollectedInformationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ctype': instance.ctype,
      'content': instance.content,
      'owner': instance.owner,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'tags': instance.tags,
    };

CollectedInformationItemUpdate _$CollectedInformationItemUpdateFromJson(
        Map<String, dynamic> json) =>
    CollectedInformationItemUpdate(
      content: json['content'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CollectedInformationItemUpdateToJson(
        CollectedInformationItemUpdate instance) =>
    <String, dynamic>{
      'content': instance.content,
      'metadata': instance.metadata,
      'tags': instance.tags,
    };

BaseInformation _$BaseInformationFromJson(Map<String, dynamic> json) =>
    BaseInformation(
      title: json['title'] as String?,
      shortSummary: json['short_summary'] as String?,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$BaseInformationToJson(BaseInformation instance) =>
    <String, dynamic>{
      'title': instance.title,
      'short_summary': instance.shortSummary,
      'category': instance.category,
    };

CollectedInformationItemWithBaseInformation
    _$CollectedInformationItemWithBaseInformationFromJson(
            Map<String, dynamic> json) =>
        CollectedInformationItemWithBaseInformation(
          id: json['id'] as String,
          ctype: json['ctype'] as String,
          content: json['content'] as String,
          owner: json['owner'] as String,
          metadata: json['metadata'] as Map<String, dynamic>,
          createdAt: DateTime.parse(json['created_at'] as String),
          tags:
              (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
          baseInformation: BaseInformation.fromJson(
              json['base_information'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$CollectedInformationItemWithBaseInformationToJson(
        CollectedInformationItemWithBaseInformation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ctype': instance.ctype,
      'content': instance.content,
      'owner': instance.owner,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'tags': instance.tags,
      'base_information': instance.baseInformation,
    };

CollectedInformationItemWithShortSummary
    _$CollectedInformationItemWithShortSummaryFromJson(
            Map<String, dynamic> json) =>
        CollectedInformationItemWithShortSummary(
          id: json['id'] as String,
          ctype: json['ctype'] as String,
          content: json['content'] as String,
          owner: json['owner'] as String,
          metadata: json['metadata'] as Map<String, dynamic>,
          createdAt: DateTime.parse(json['created_at'] as String),
          tags:
              (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
          shortSummary: json['short_summary'] as String? ?? '总结正在赶来中',
        );

Map<String, dynamic> _$CollectedInformationItemWithShortSummaryToJson(
        CollectedInformationItemWithShortSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ctype': instance.ctype,
      'content': instance.content,
      'owner': instance.owner,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'tags': instance.tags,
      'short_summary': instance.shortSummary,
    };

PaginatedCollectedInformation _$PaginatedCollectedInformationFromJson(
        Map<String, dynamic> json) =>
    PaginatedCollectedInformation(
      totalItems: (json['totalItems'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['page_size'] as num).toInt(),
      items: (json['items'] as List<dynamic>)
          .map((e) =>
              CollectedInformationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaginatedCollectedInformationToJson(
        PaginatedCollectedInformation instance) =>
    <String, dynamic>{
      'totalItems': instance.totalItems,
      'page': instance.page,
      'page_size': instance.pageSize,
      'items': instance.items,
    };

PaginatedByCursorCollectedInformation
    _$PaginatedByCursorCollectedInformationFromJson(
            Map<String, dynamic> json) =>
        PaginatedByCursorCollectedInformation(
          totalItems: (json['totalItems'] as num).toInt(),
          items: (json['items'] as List<dynamic>)
              .map((e) =>
                  CollectedInformationItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        );

Map<String, dynamic> _$PaginatedByCursorCollectedInformationToJson(
        PaginatedByCursorCollectedInformation instance) =>
    <String, dynamic>{
      'totalItems': instance.totalItems,
      'items': instance.items,
    };

PaginatedByCursorCollectedInformationWithShortSummary
    _$PaginatedByCursorCollectedInformationWithShortSummaryFromJson(
            Map<String, dynamic> json) =>
        PaginatedByCursorCollectedInformationWithShortSummary(
          totalItems: (json['totalItems'] as num).toInt(),
          items: (json['items'] as List<dynamic>)
              .map((e) => CollectedInformationItemWithShortSummary.fromJson(
                  e as Map<String, dynamic>))
              .toList(),
        );

Map<String, dynamic>
    _$PaginatedByCursorCollectedInformationWithShortSummaryToJson(
            PaginatedByCursorCollectedInformationWithShortSummary instance) =>
        <String, dynamic>{
          'totalItems': instance.totalItems,
          'items': instance.items,
        };

PaginatedByCursorCollectedInformationWithBaseInformation
    _$PaginatedByCursorCollectedInformationWithBaseInformationFromJson(
            Map<String, dynamic> json) =>
        PaginatedByCursorCollectedInformationWithBaseInformation(
          totalItems: (json['totalItems'] as num).toInt(),
          items: (json['items'] as List<dynamic>)
              .map((e) => CollectedInformationItemWithBaseInformation.fromJson(
                  e as Map<String, dynamic>))
              .toList(),
        );

Map<String,
    dynamic> _$PaginatedByCursorCollectedInformationWithBaseInformationToJson(
        PaginatedByCursorCollectedInformationWithBaseInformation instance) =>
    <String, dynamic>{
      'totalItems': instance.totalItems,
      'items': instance.items,
    };

FileInfoResponse _$FileInfoResponseFromJson(Map<String, dynamic> json) =>
    FileInfoResponse(
      fileId: json['file_id'] as String,
      metadata: json['metadata'] as String?,
      filename: json['filename'] as String,
      contentType: json['content_type'] as String,
      fileSize: (json['file_size'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$FileInfoResponseToJson(FileInfoResponse instance) =>
    <String, dynamic>{
      'file_id': instance.fileId,
      'metadata': instance.metadata,
      'filename': instance.filename,
      'content_type': instance.contentType,
      'file_size': instance.fileSize,
      'created_at': instance.createdAt.toIso8601String(),
    };

SignedURLResponse _$SignedURLResponseFromJson(Map<String, dynamic> json) =>
    SignedURLResponse(
      url: json['url'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$SignedURLResponseToJson(SignedURLResponse instance) =>
    <String, dynamic>{
      'url': instance.url,
      'expires_at': instance.expiresAt.toIso8601String(),
    };

UploadFileResponse _$UploadFileResponseFromJson(Map<String, dynamic> json) =>
    UploadFileResponse(
      fileId: json['file_id'] as String,
      fileName: json['file_name'] as String,
    );

Map<String, dynamic> _$UploadFileResponseToJson(UploadFileResponse instance) =>
    <String, dynamic>{
      'file_id': instance.fileId,
      'file_name': instance.fileName,
    };
