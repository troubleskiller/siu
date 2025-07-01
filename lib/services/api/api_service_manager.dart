import 'auth_api_service.dart';
import 'chat_api_service.dart';
import 'knowledge_api_service.dart';

/// API服务管理器
/// 统一管理所有API服务，提供便捷的访问方式
class ApiServiceManager {
  static final ApiServiceManager _instance = ApiServiceManager._internal();
  factory ApiServiceManager() => _instance;
  
  ApiServiceManager._internal();

  // 认证相关API服务
  final AuthApiService _authService = AuthApiService();
  AuthApiService get auth => _authService;

  // 聊天相关API服务
  final ChatApiService _chatService = ChatApiService();
  ChatApiService get chat => _chatService;

  // 知识管理相关API服务
  final KnowledgeApiService _knowledgeService = KnowledgeApiService();
  KnowledgeApiService get knowledge => _knowledgeService;
}

/// 全局API服务管理器实例
final apiService = ApiServiceManager(); 