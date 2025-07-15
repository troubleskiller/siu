import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../services/api/api_service_manager.dart';
import '../services/api/api_client.dart';
import '../routes/app_pages.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();
  
  // 认证状态
  final _isAuthenticated = false.obs;
  bool get isAuthenticated => _isAuthenticated.value;
  
  // 初始化状态
  final _isInitializing = true.obs;
  bool get isInitializing => _isInitializing.value;
  
  // 当前用户信息
  final _currentUser = Rxn<User>();
  User? get currentUser => _currentUser.value;
  
  // 加载状态
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  // 表单控制器
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // 表单验证
  final _isUsernameValid = true.obs;
  final _isPasswordValid = true.obs;
  final _isConfirmPasswordValid = true.obs;
  
  bool get isUsernameValid => _isUsernameValid.value;
  bool get isPasswordValid => _isPasswordValid.value;
  bool get isConfirmPasswordValid => _isConfirmPasswordValid.value;
  
  // 当前页面模式
  final _isLoginMode = true.obs;
  bool get isLoginMode => _isLoginMode.value;
  
  // API客户端实例
  final ApiClient _apiClient = ApiClient();
  
  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }
  
  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  /// 初始化认证状态
  Future<void> _initializeAuth() async {
    try {
      _isInitializing.value = true;
      debugPrint('Initializing authentication...');
      
      // 检查并刷新token
      final authResult = await checkTokenAndRefresh();
      
      if (authResult) {
        // Token有效，获取用户信息
        await loadUserInfo();
        _isAuthenticated.value = true;
        debugPrint('Authentication initialized successfully');
      } else {
        // Token无效或不存在
        _isAuthenticated.value = false;
        debugPrint('No valid authentication found');
      }
      
    } catch (e) {
      debugPrint('Auth initialization failed: $e');
      _isAuthenticated.value = false;
    } finally {
      _isInitializing.value = false;
    }
  }
  
  /// 检查并刷新token
  Future<bool> checkTokenAndRefresh() async {
    try {
      debugPrint('Checking token status...');
      
      // 检查是否有token
      if (!(await _apiClient.hasTokens())) {
        debugPrint('No tokens found');
        return false;
      }
      
      // 尝试刷新token（如果需要）
      final refreshSuccess = await _apiClient.refreshTokenIfNeeded();
      
      if (refreshSuccess) {
        debugPrint('Token is valid or refreshed successfully');
        return true;
      } else {
        debugPrint('Token refresh failed. Redirecting to login page.');
        // 清除认证状态并跳转到登录页
        await _handleLogout();
        return false;
      }
      
    } catch (e) {
      debugPrint('Token check failed: $e. Redirecting to login page.');
      await _handleLogout();
      return false;
    }
  }
  
  /// 清除认证状态
  Future<void> _clearAuthState() async {
    _isAuthenticated.value = false;
    _currentUser.value = null;
    await _apiClient.clearTokens();
  }
  
  /// 封装登出逻辑
  Future<void> _handleLogout() async {
    await _clearAuthState();
    _clearForm();
    Get.offAllNamed(Routes.auth);
  }
  
  /// 检查认证状态（保留原有方法，用于兼容）
  Future<void> checkAuthStatus() async {
    await _initializeAuth();
  }
  
  /// 加载用户信息
  Future<void> loadUserInfo() async {
    try {
      debugPrint('Loading user info...');
      final user = await apiService.auth.getUserInfo();
      _currentUser.value = user;
      debugPrint('User info loaded: ${user.username}');
    } catch (e) {
      debugPrint('Load user info failed: $e');
      // 如果获取用户信息失败，可能token已过期
      await _handleLogout();
      throw e;
    }
  }
  
  /// 切换登录/注册模式
  void toggleAuthMode() {
    _isLoginMode.value = !_isLoginMode.value;
    _clearForm();
  }
  
  /// 登录
  Future<void> login() async {
    if (!_validateLoginForm()) return;
    
    try {
      _isLoading.value = true;
      debugPrint('Attempting login...');
      
      final loginRequest = OAuth2LoginRequest(
        username: usernameController.text.trim(),
        password: passwordController.text,
        grantType: 'password',
      );
      
      final token = await apiService.auth.login(loginRequest);
      debugPrint('Login successful, token received');
      
      // 登录成功后获取用户信息
      await loadUserInfo();
      
      _isAuthenticated.value = true;
      _clearForm();
      
      // 跳转到主页
      Get.offAllNamed(Routes.home);
      
      Get.snackbar(
        '登录成功',
        '欢迎回来！',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
    } catch (e) {
      debugPrint('Login failed: $e');
      Get.snackbar(
        'errorAuthFailed'.tr,
        _getErrorMessage(e),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 注册
  Future<void> register() async {
    if (!_validateRegisterForm()) return;
    
    try {
      _isLoading.value = true;
      debugPrint('Attempting registration...');
      
      final userCreate = UserCreate(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );
      
      final user = await apiService.auth.createUser(userCreate);
      debugPrint('Registration successful for user: ${user.username}');
      
      Get.snackbar(
        '注册成功',
        '账号创建成功，请登录',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      // 注册成功后切换到登录模式
      _isLoginMode.value = true;
      _clearForm();
      
    } catch (e) {
      debugPrint('Registration failed: $e');
      Get.snackbar(
        '注册失败',
        _getErrorMessage(e),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 登出
  Future<void> logout() async {
    try {
      debugPrint('Logging out...');
      
      await apiService.auth.logout();
      await _handleLogout(); // 使用封装的登出逻辑
      
      Get.snackbar(
        '已登出',
        '您已成功登出',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      debugPrint('Logout completed');
      
    } catch (e) {
      debugPrint('Logout failed: $e');
      // 即使API调用失败，也尝试清理本地状态
      await _handleLogout();
    }
  }
  
  /// 强制刷新token
  Future<bool> forceRefreshToken() async {
    try {
      debugPrint('Force refreshing token...');
      return await _apiClient.refreshTokenIfNeeded();
    } catch (e) {
      debugPrint('Force refresh failed: $e');
      return false;
    }
  }
  
  /// 微信登录（可选功能）
  Future<void> wechatLogin(String code, String encryptedData, String iv) async {
    try {
      _isLoading.value = true;
      debugPrint('Attempting WeChat login...');
      
      final wechatRequest = WechatLoginRequest(
        code: code,
        encryptedData: encryptedData,
        iv: iv,
      );
      
      final result = await apiService.auth.wechatPhoneLogin(wechatRequest);
      debugPrint('WeChat login successful');
      
      // 微信登录成功的处理逻辑
      await loadUserInfo();
      _isAuthenticated.value = true;
      
      Get.offAllNamed(Routes.home);
      
    } catch (e) {
      debugPrint('WeChat login failed: $e');
      Get.snackbar(
        '微信登录失败',
        _getErrorMessage(e),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 验证登录表单
  bool _validateLoginForm() {
    bool isValid = true;
    
    // 验证用户名
    if (usernameController.text.trim().isEmpty) {
      _isUsernameValid.value = false;
      isValid = false;
    } else if (usernameController.text.trim().length < 3) {
      _isUsernameValid.value = false;
      isValid = false;
    } else {
      _isUsernameValid.value = true;
    }
    
    // 验证密码
    if (passwordController.text.isEmpty) {
      _isPasswordValid.value = false;
      isValid = false;
    } else if (passwordController.text.length < 6) {
      _isPasswordValid.value = false;
      isValid = false;
    } else {
      _isPasswordValid.value = true;
    }
    
    return isValid;
  }
  
  /// 验证注册表单
  bool _validateRegisterForm() {
    bool isValid = _validateLoginForm();
    
    // 验证确认密码
    if (confirmPasswordController.text != passwordController.text) {
      _isConfirmPasswordValid.value = false;
      isValid = false;
    } else {
      _isConfirmPasswordValid.value = true;
    }
    
    return isValid;
  }
  
  /// 清除表单验证状态
  void clearValidation() {
    _isUsernameValid.value = true;
    _isPasswordValid.value = true;
    _isConfirmPasswordValid.value = true;
  }
  
  /// 清除表单
  void _clearForm() {
    usernameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    clearValidation();
  }
  
  /// 获取用户名验证错误信息
  String? getUsernameError() {
    if (!_isUsernameValid.value) {
      if (usernameController.text.trim().isEmpty) {
        return '请输入用户名';
      } else if (usernameController.text.trim().length < 3) {
        return '用户名至少3个字符';
      }
    }
    return null;
  }
  
  /// 获取密码验证错误信息
  String? getPasswordError() {
    if (!_isPasswordValid.value) {
      if (passwordController.text.isEmpty) {
        return '请输入密码';
      } else if (passwordController.text.length < 6) {
        return '密码至少6个字符';
      }
    }
    return null;
  }
  
  /// 获取确认密码验证错误信息
  String? getConfirmPasswordError() {
    if (!_isConfirmPasswordValid.value) {
      return '两次输入的密码不一致';
    }
    return null;
  }
  
  /// 获取错误信息
  String _getErrorMessage(dynamic error) {
    if (error is String) {
      final errorStr = error.toLowerCase();
      if (errorStr.contains('username') && errorStr.contains('exist')) {
        return '用户名已存在';
      } else if (errorStr.contains('invalid') && errorStr.contains('credential')) {
        return '用户名或密码错误';
      } else if (errorStr.contains('timeout')) {
        return 'errorNetworkTimeout'.tr;
      } else if (errorStr.contains('unauthorized') || errorStr.contains('401')) {
        return '认证失败，请检查用户名和密码';
      }
    }
    
    return 'errorRequestFailed'.tr;
  }
} 