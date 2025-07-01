import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/api_constants.dart';

class ApiClient {
  late final Dio _dio;
  
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        ApiConstants.contentTypeKey: ApiConstants.contentTypeJson,
        ApiConstants.acceptKey: ApiConstants.contentTypeJson,
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    // 认证拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getAccessToken();
          if (token != null) {
            options.headers[ApiConstants.authorizationKey] = '${ApiConstants.bearerPrefix}$token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == ApiConstants.statusUnauthorized) {
            // Token过期，尝试刷新
            final refreshed = await _refreshToken();
            if (refreshed) {
              // 重试原请求
              final token = await getAccessToken();
              error.requestOptions.headers[ApiConstants.authorizationKey] = '${ApiConstants.bearerPrefix}$token';
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } else {
              // 刷新失败，清除token并跳转到登录页
              await clearTokens();
            }
          }
          handler.next(error);
        },
      ),
    );
    
    // 日志拦截器（仅在调试模式下）
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }
  
  // Token管理
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.accessTokenKey, accessToken);
    await prefs.setString(ApiConstants.refreshTokenKey, refreshToken);
  }
  
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConstants.accessTokenKey);
  }
  
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConstants.refreshTokenKey);
  }
  
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.accessTokenKey);
    await prefs.remove(ApiConstants.refreshTokenKey);
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await _dio.post(
        ApiConstants.authTokenRefresh,
        data: {ApiConstants.jsonRefreshToken: refreshToken},
      );
      
      final tokenData = response.data;
      await saveTokens(
        tokenData[ApiConstants.jsonAccessToken],
        tokenData[ApiConstants.jsonRefreshToken],
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // HTTP方法封装
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
} 