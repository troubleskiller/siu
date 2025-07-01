import 'package:dio/dio.dart';
import '../../models/chat_models.dart';
import '../../models/error_models.dart';
import '../../constants/api_constants.dart';
import 'api_client.dart';

class ChatApiService {
  final ApiClient _apiClient = ApiClient();

  /// 创建聊天session
  Future<ChatSession> createSession(String sourceType) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.chatSession,
        queryParameters: {ApiConstants.paramSourceType: sourceType},
      );
      return ChatSession.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 获取当前session（不存在会自动创建）
  Future<ChatSession> getCurrentSession(String sourceType) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.chatCurrentSession,
        queryParameters: {ApiConstants.paramSourceType: sourceType},
      );
      return ChatSession.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 创建新知识对话
  Future<String> createItemChatSession(List<String> itemIds) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.itemChatNewSession,
        data: itemIds,
      );
      return response.data as String;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 根据知识聊天session获取所有消息
  Future<String> getMessagesBySessionId(String sessionId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.itemChatMessagesBySessionId}/$sessionId',
      );
      return response.data as String;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 知识对话询问
  Future<String> queryItemChat(QueryRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.itemChatQuery,
        data: request.toJson(),
      );
      return response.data as String;
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