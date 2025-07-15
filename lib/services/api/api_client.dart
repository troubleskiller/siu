import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
            await clearTokens();
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
    
    // 保存token存储时间，用于后续检查
    await prefs.setInt('token_saved_time', DateTime.now().millisecondsSinceEpoch);
    
    debugPrint('Tokens saved successfully');
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
    await prefs.remove('token_saved_time');
    debugPrint('Tokens cleared');
  }
  
  /// 检查是否有token存储
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }
  
  /// 检查token是否可能过期（基于时间判断）
  Future<bool> isTokenLikelyExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('token_saved_time');
    
    if (savedTime == null) return true;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final hoursSinceToken = (now - savedTime) / (1000 * 60 * 60);
    
    // 如果token存储超过23小时，认为可能过期（假设token有效期24小时）
    return hoursSinceToken > 23;
  }
  
  /// 验证当前token是否有效
  Future<bool> validateCurrentToken() async {
    try {
      final token = await getAccessToken();
      if (token == null) return false;
      
      // 创建一个简单的请求来验证token
      final response = await _dio.get(
        ApiConstants.authUsersMe,
        options: Options(
          headers: {
            ApiConstants.authorizationKey: '${ApiConstants.bearerPrefix}$token',
          },
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Token validation failed: $e');
      return false;
    }
  }
  
  /// 主动刷新token
  Future<bool> refreshTokenIfNeeded() async {
    try {
      // 检查是否有refresh token
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        debugPrint('No refresh token available');
        return false;
      }
      
      // 如果token看起来还新鲜，先验证一下
      if (!(await isTokenLikelyExpired())) {
        final isValid = await validateCurrentToken();
        if (isValid) {
          debugPrint('Current token is still valid');
          return true;
        }
      }
      
      // 尝试刷新token
      debugPrint('Attempting to refresh token...');
      return await _refreshToken();
      
    } catch (e) {
      debugPrint('Error in refreshTokenIfNeeded: $e');
      return false;
    }
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        debugPrint('No refresh token available for refresh');
        return false;
      }
      
      debugPrint('Refreshing access token...');
      
      final response = await _dio.post(
        ApiConstants.authTokenRefresh,
        data: {ApiConstants.jsonRefreshToken: refreshToken},
      );
      print('1111111');
      print(response.statusCode);
      print('1111111');
      if(response.statusCode!=200){

        return false;
      }
      final tokenData = response.data;
      await saveTokens(
        tokenData[ApiConstants.jsonAccessToken],
        tokenData[ApiConstants.jsonRefreshToken],
      );
      
      debugPrint('Token refreshed successfully');
      return true;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      // 如果刷新失败，清除所有token
      await clearTokens();
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