import 'package:dio/dio.dart';
import '../../models/auth_models.dart';
import '../../models/error_models.dart';
import '../../constants/api_constants.dart';
import 'api_client.dart';

class AuthApiService {
  final ApiClient _apiClient = ApiClient();

  /// 微信小程序手机登录
  Future<String> wechatPhoneLogin(WechatLoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authWechatPhoneLogin,
        data: request.toJson(),
      );
      return response.data as String;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 绑定微信账号到用户
  Future<String> bindWechatAccount(WechatLoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authBindWechatAccount,
        data: request.toJson(),
      );
      return response.data as String;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 通过用户名与密码登录 OAuth2
  Future<Token> login(OAuth2LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authToken,
        data: request.toJson(),
        options: Options(
          contentType: ApiConstants.contentTypeFormUrlencoded,
        ),
      );
      final token = Token.fromJson(response.data);
      
      // 保存token
      await _apiClient.saveTokens(token.accessToken, token.refreshToken);
      
      return token;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 刷新 Access Token
  Future<Token> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authTokenRefresh,
        data: TokenRefreshRequest(refreshToken: refreshToken).toJson(),
      );
      final token = Token.fromJson(response.data);
      
      // 保存新token
      await _apiClient.saveTokens(token.accessToken, token.refreshToken);
      
      return token;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 获取用户信息
  Future<User> getUserInfo() async {
    try {
      final token = await _apiClient.getAccessToken();
      if (token == null) {
        throw AuthException(ApiConstants.errorAccessTokenNotFound);
      }
      
      final response = await _apiClient.get(
        ApiConstants.authUsersMe,
        queryParameters: {ApiConstants.paramToken: token},
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 创建新用户（注册）
  Future<User> createUser(UserCreate userCreate) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authUser,
        data: userCreate.toJson(),
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 登出
  Future<void> logout() async {
    await _apiClient.clearTokens();
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await _apiClient.getAccessToken();
    return token != null;
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