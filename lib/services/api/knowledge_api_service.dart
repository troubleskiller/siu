import 'dart:io';
import 'package:dio/dio.dart';
import '../../models/knowledge_models.dart';
import '../../models/error_models.dart';
import '../../constants/api_constants.dart';
import 'api_client.dart';

class KnowledgeApiService {
  final ApiClient _apiClient = ApiClient();

  /// 文件上传
  Future<UploadFileResponse> uploadFile(
    File file,
    String originalFilename,
  ) async {
    try {
      final formData = FormData.fromMap({
        ApiConstants.fieldFile: await MultipartFile.fromFile(
          file.path,
          filename: originalFilename,
        ),
        ApiConstants.fieldOriginalFilename: originalFilename,
      });

      final response = await _apiClient.post(
        ApiConstants.knowledgeUploadFile,
        data: formData,
        options: Options(
          contentType: ApiConstants.contentTypeFormData,
        ),
      );
      return UploadFileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 根据文件id获取文件
  Future<Response> getFile(String fileId, {String? range}) async {
    try {
      final headers = <String, String>{};
      if (range != null) {
        headers[ApiConstants.rangeKey] = range;
      }

      return await _apiClient.get(
        '${ApiConstants.knowledgeImportFile}/$fileId',
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 获取文件信息
  Future<FileInfoResponse> getFileInfo(String fileId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.knowledgeFileInfo}/$fileId',
      );
      return FileInfoResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 使用游标方式获取知识列表
  Future<PaginatedByCursorCollectedInformation> getItemsByCursor({
    String? startId,
    int? limit,
    String? tags,
    String? filterMode,
    String? startDate,
    String? endDate,
    String? direction,
    List<String>? ctypes,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startId != null) queryParams[ApiConstants.paramStartId] = startId;
      if (limit != null) queryParams[ApiConstants.paramLimit] = limit;
      if (tags != null) queryParams[ApiConstants.paramTags] = tags;
      if (filterMode != null) queryParams[ApiConstants.paramFilterMode] = filterMode;
      if (startDate != null) queryParams[ApiConstants.paramStartDate] = startDate;
      if (endDate != null) queryParams[ApiConstants.paramEndDate] = endDate;
      if (direction != null) queryParams[ApiConstants.paramDirection] = direction;
      if (ctypes != null) queryParams[ApiConstants.paramCtypes] = ctypes;

      final response = await _apiClient.get(
        ApiConstants.knowledgeItemsByCursor,
        queryParameters: queryParams,
      );
      return PaginatedByCursorCollectedInformation.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 使用游标方式获取知识列表（附带摘要）
  Future<PaginatedByCursorCollectedInformationWithShortSummary>
      getItemsWithShortSummaryByCursor({
    String? startId,
    int? limit,
    String? tags,
    String? filterMode,
    String? startDate,
    String? endDate,
    String? direction,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startId != null) queryParams[ApiConstants.paramStartId] = startId;
      if (limit != null) queryParams[ApiConstants.paramLimit] = limit;
      if (tags != null) queryParams[ApiConstants.paramTags] = tags;
      if (filterMode != null) queryParams[ApiConstants.paramFilterMode] = filterMode;
      if (startDate != null) queryParams[ApiConstants.paramStartDate] = startDate;
      if (endDate != null) queryParams[ApiConstants.paramEndDate] = endDate;
      if (direction != null) queryParams[ApiConstants.paramDirection] = direction;

      final response = await _apiClient.get(
        ApiConstants.knowledgeItemsWithShortSummaryByCursor,
        queryParameters: queryParams,
      );
      return PaginatedByCursorCollectedInformationWithShortSummary.fromJson(
          response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 使用游标获取带有基本信息的项目
  Future<PaginatedByCursorCollectedInformationWithBaseInformation>
      getItemsWithBaseInformationByCursor({
    String? startId,
    int? limit,
    List<String>? tags,
    String? filterMode,
    String? startDate,
    String? endDate,
    String? direction,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startId != null) queryParams[ApiConstants.paramStartId] = startId;
      if (limit != null) queryParams[ApiConstants.paramLimit] = limit;
      if (filterMode != null) queryParams[ApiConstants.paramFilterMode] = filterMode;
      if (startDate != null) queryParams[ApiConstants.paramStartDate] = startDate;
      if (endDate != null) queryParams[ApiConstants.paramEndDate] = endDate;
      if (direction != null) queryParams[ApiConstants.paramDirection] = direction;

      final response = await _apiClient.post(
        ApiConstants.knowledgeItemsWithBaseInformationByCursor,
        queryParameters: queryParams,
        data: tags,
      );
      return PaginatedByCursorCollectedInformationWithBaseInformation.fromJson(
          response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 使用页码分页方式获取知识列表
  Future<PaginatedCollectedInformation> getItems({
    int? page,
    int? pageSize,
    String? tags,
    String? filterMode,
    String? startDate,
    String? endDate,
    List<String>? ctypes,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams[ApiConstants.paramPage] = page;
      if (pageSize != null) queryParams[ApiConstants.paramPageSize] = pageSize;
      if (tags != null) queryParams[ApiConstants.paramTags] = tags;
      if (filterMode != null) queryParams[ApiConstants.paramFilterMode] = filterMode;
      if (startDate != null) queryParams[ApiConstants.paramStartDate] = startDate;
      if (endDate != null) queryParams[ApiConstants.paramEndDate] = endDate;
      if (ctypes != null) queryParams[ApiConstants.paramCtypes] = ctypes;

      final response = await _apiClient.get(
        ApiConstants.knowledgeItems,
        queryParameters: queryParams,
      );
      return PaginatedCollectedInformation.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 获取全部知识标签
  Future<List<String>> getTags() async {
    try {
      final response = await _apiClient.get(ApiConstants.knowledgeTags);
      return List<String>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 根据知识id获取知识信息
  Future<CollectedInformationItem> getItem(String itemId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.knowledgeItem}/$itemId',
      );
      return CollectedInformationItem.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 修改知识信息
  Future<CollectedInformationItem> updateItem(
    String itemId,
    CollectedInformationItemUpdate update,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.knowledgeItem}/$itemId',
        data: update.toJson(),
      );
      return CollectedInformationItem.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 局部修改知识信息
  Future<CollectedInformationItem> patchItem(
    String itemId,
    CollectedInformationItemUpdate update,
  ) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.knowledgeItem}/$itemId',
        data: update.toJson(),
      );
      return CollectedInformationItem.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 根据id删除知识
  Future<String> deleteItem(String itemId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.knowledgeItem}/$itemId',
      );
      return response.data as String;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 根据知识id获取额外信息
  Future<String> getItemAdditionalInfo(String itemId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.knowledgeItemAdditionalInfoList}/$itemId',
      );
      return response.data as String;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 根据信息名获取知识的额外信息
  Future<String> getItemAdditionalInfoByField(
    String itemId,
    String fieldName,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.knowledgeItemAdditionalInfoListByField}/$itemId',
        queryParameters: {ApiConstants.paramFieldName: fieldName},
      );
      return response.data as String;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 创建知识
  Future<String> createItem({
    required String content,
    String? tags,
    File? file,
  }) async {
    try {
      final formData = FormData.fromMap({
        ApiConstants.fieldContent: content,
        if (tags != null) ApiConstants.fieldTags: tags,
        if (file != null)
          ApiConstants.fieldFile: await MultipartFile.fromFile(file.path),
      });

      final response = await _apiClient.post(
        ApiConstants.knowledgeItem,
        data: formData,
        options: Options(
          contentType: ApiConstants.contentTypeFormData,
        ),
      );
      return response.data as String;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 根据知识id下载文件
  Future<Response> downloadFile(String itemId, {String? range}) async {
    try {
      final headers = <String, String>{};
      if (range != null) {
        headers[ApiConstants.rangeKey] = range;
      }

      return await _apiClient.get(
        '${ApiConstants.knowledgeDownload}/$itemId',
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 根据知识id获取媒体文件（需要鉴权）
  Future<Response> getMediaFile(String itemId, {String? range}) async {
    try {
      final headers = <String, String>{};
      if (range != null) {
        headers[ApiConstants.rangeKey] = range;
      }

      return await _apiClient.get(
        '${ApiConstants.knowledgeMedia}/$itemId',
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 获取带签名的媒体文件url
  Future<SignedURLResponse> getSignedMediaUrl(String itemId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.knowledgeMedia}/$itemId${ApiConstants.signedUrlSuffix}',
      );
      return SignedURLResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 获取带签名的文件url
  Future<SignedURLResponse> getSignedDownloadUrl(String itemId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.knowledgeDownload}/$itemId${ApiConstants.signedUrlSuffix}',
      );
      return SignedURLResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 通过签名url获取媒体文件（无需登录鉴权）
  Future<Response> getMediaFileWithSignature(
    String itemId,
    String signature,
    int expires, {
    String? range,
  }) async {
    try {
      final headers = <String, String>{};
      if (range != null) {
        headers[ApiConstants.rangeKey] = range;
      }

      return await _apiClient.get(
        '${ApiConstants.knowledgeMediaWithSignature}/$itemId',
        queryParameters: {
          ApiConstants.paramSignature: signature,
          ApiConstants.paramExpires: expires,
        },
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 通过签名url获取文件（无需登录鉴权）
  Future<Response> downloadFileWithSignature(
    String itemId,
    String signature,
    int expires, {
    String? range,
  }) async {
    try {
      final headers = <String, String>{};
      if (range != null) {
        headers[ApiConstants.rangeKey] = range;
      }

      return await _apiClient.get(
        '${ApiConstants.knowledgeDownloadWithSignature}/$itemId',
        queryParameters: {
          ApiConstants.paramSignature: signature,
          ApiConstants.paramExpires: expires,
        },
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 根据ctype获取对应的数量
  Future<int> getItemsCount({List<String>? ctypes}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (ctypes != null) queryParams[ApiConstants.paramCytpes] = ctypes;

      final response = await _apiClient.get(
        ApiConstants.knowledgeItemsSum,
        queryParameters: queryParams,
      );
      return response.data[ApiConstants.jsonSum] as int;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(ApiConstants.errorNetworkTimeout);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final message = _getErrorMessage(e.response?.data);
        
        if (statusCode == ApiConstants.statusUnauthorized) {
          return AuthException(message);
        }
        return ApiException(
          statusCode: statusCode,
          message: message,
          data: e.response?.data,
        );
      case DioExceptionType.cancel:
        return NetworkException(ApiConstants.errorRequestCanceled);
      case DioExceptionType.unknown:
        return NetworkException(ApiConstants.errorNetworkFailed);
      default:
        return NetworkException(ApiConstants.errorUnknownNetwork);
    }
  }

  String _getErrorMessage(dynamic data) {
    if (data is String) {
      return data;
    }
    
    if (data is Map<String, dynamic>) {
      // 尝试解析HTTP验证错误
      try {
        final validationError = HTTPValidationError.fromJson(data);
        if (validationError.detail != null && validationError.detail!.isNotEmpty) {
          return validationError.detail!.first.msg;
        }
      } catch (_) {
        // 如果不是验证错误格式，尝试获取通用错误信息
        if (data.containsKey(ApiConstants.errorFieldMessage)) {
          return data[ApiConstants.errorFieldMessage];
        }
        if (data.containsKey(ApiConstants.errorFieldDetail)) {
          return data[ApiConstants.errorFieldDetail];
        }
        if (data.containsKey(ApiConstants.errorFieldError)) {
          return data[ApiConstants.errorFieldError];
        }
      }
    }
    
    return ApiConstants.errorRequestFailed;
  }
} 