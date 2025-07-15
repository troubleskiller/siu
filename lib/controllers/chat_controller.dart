import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/api_constants.dart';
import '../models/chat_models.dart';
import '../services/api/api_service_manager.dart';
import '../services/websocket/websocket_service.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find();

  // 聊天会话列表
  final _chatSessions = <ChatSessionInfo>[].obs;

  List<ChatSessionInfo> get chatSessions => _chatSessions;

  // 当前选中的会话
  final _currentSession = Rxn<ChatSessionInfo>();

  ChatSessionInfo? get currentSession => _currentSession.value;

  // 当前会话的消息列表
  final _messages = <ChatMessage>[].obs;

  List<ChatMessage> get messages => _messages;

  // 输入的消息
  final _inputMessage = ''.obs;

  String get inputMessage => _inputMessage.value;

  // 是否正在发送消息
  final _isSending = false.obs;

  bool get isSending => _isSending.value;

  // 是否正在加载
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  // WebSocket连接状态
  final _connectionStatus = ''.obs;

  String get connectionStatus => _connectionStatus.value;

  // AI是否正在思考
  final _isAIThinking = false.obs;

  bool get isAIThinking => _isAIThinking.value;

  // 消息队列大小
  final _queuedMessageCount = 0.obs;

  int get queuedMessageCount => _queuedMessageCount.value;

  // WebSocket服务
  final WebSocketService _wsService = WebSocketService.instance;

  // 流订阅
  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _messageStatusSubscription;

  // 滚动控制器
  final scrollController = ScrollController();

  // 消息状态映射
  final Map<String, MessageStatus> _messageStatuses = {};

  /// 生成3位精度的UTC时间字符串
  String _generateTimeString([DateTime? dateTime]) {
    final now = dateTime ?? DateTime.now().toUtc();
    
    // 手动构建3位精度的时间字符串
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final millisecond = now.millisecond.toString().padLeft(3, '0');
    
    return '$year-$month-${day}T$hour:$minute:$second.${millisecond}Z';
  }

  @override
  void onInit() {
    super.onInit();
    _initializeWebSocket();
    loadChatSessions();
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    _messageStatusSubscription?.cancel();
    _wsService.disconnect();
    scrollController.dispose();
    super.onClose();
  }

  /// 初始化WebSocket监听
  void _initializeWebSocket() {
    // 监听WebSocket消息
    _messageSubscription = _wsService.messageStream.listen(
      _handleWebSocketMessage,
      onError: (error) {
        debugPrint('WebSocket message stream error: $error');
      },
    );

    // 监听连接状态
    _connectionSubscription = _wsService.connectionState.listen(
      _handleConnectionStateChange,
    );

    // 监听错误信息
    _errorSubscription = _wsService.errorStream.listen(
      _handleWebSocketError,
    );

    // 监听消息状态
    _messageStatusSubscription = _wsService.messageStatusStream.listen(
      _handleMessageStatusUpdate,
    );
  }

  /// 处理WebSocket消息
  void _handleWebSocketMessage(WebSocketMessage wsMessage) {
    try {
      // 处理消息状态和AI思考状态
      if (wsMessage.extra != null) {
        final extra = MessageExtra.fromJson(wsMessage.extra!);
        
        // 如果收到response_status为success的消息，停止AI思考状态
        if (extra.responseStatus == 'success') {
          _isAIThinking.value = false;
          debugPrint('✅ AI finished thinking - response_status: success');
        }

        // 处理知识卡片转换
        if (extra.changeToKnowledgeCard == true && extra.responseFor != null) {
          _handleKnowledgeCardConversion(wsMessage, extra);
          return;
        }

        // 跳过无内容消息
        if (extra.noContent == true) {
          debugPrint('Skipping no_content message');
          return;
        }
      } else {
        // 如果是AI消息且没有extra，也停止思考状态
        if (wsMessage.actualType == MessageType.ai) {
          _isAIThinking.value = false;
          debugPrint('✅ AI finished thinking - received AI message');
        }
      }

      // 转换为ChatMessage并添加到消息列表
      final chatMessage = ChatMessage.fromWebSocketMessage(wsMessage);
      _messages.add(chatMessage);

      // 更新会话的最后消息
      _updateSessionLastMessage(chatMessage);

      // 滚动到底部
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
      // 出错时也停止AI思考状态
      _isAIThinking.value = false;
    }
  }

  /// 处理知识卡片转换
  void _handleKnowledgeCardConversion(
      WebSocketMessage wsMessage, MessageExtra extra) {
    if (extra.responseFor == null) return;

    // 查找原始消息并更新为知识卡片
    final messageIndex =
        _messages.indexWhere((msg) => msg.id == extra.responseFor);
    if (messageIndex >= 0) {
      final originalMessage = _messages[messageIndex];
      final updatedMessage = ChatMessage(
        id: originalMessage.id,
        content: originalMessage.content,
        isUser: originalMessage.isUser,
        createdAt: originalMessage.createdAt,
        sessionId: originalMessage.sessionId,
        ctype: originalMessage.ctype,
        extra: originalMessage.extra,
        isKnowledgeCard: true,
        knowledgeCardId: extra.knowledgeCardContent,
      );

      _messages[messageIndex] = updatedMessage;
    }

    // 添加确认消息
    if (wsMessage.content.isNotEmpty) {
      final confirmMessage = ChatMessage.fromWebSocketMessage(wsMessage);
      _messages.add(confirmMessage);
      _scrollToBottom();
    }
  }

  /// 处理连接状态变化
  void _handleConnectionStateChange(WebSocketConnectionState state) {
    // 更新队列消息数量
    _queuedMessageCount.value = _wsService.queuedMessageCount;

    switch (state) {
      case WebSocketConnectionState.connecting:
        _connectionStatus.value = '正在连接...';
        break;
      case WebSocketConnectionState.connected:
        _connectionStatus.value = '已连接';
        _queuedMessageCount.value = 0; // 连接后队列会被处理
        break;
      case WebSocketConnectionState.reconnecting:
        _connectionStatus.value = '重新连接中...';
        break;
      case WebSocketConnectionState.disconnected:
        _connectionStatus.value = '已断开';
        break;
      case WebSocketConnectionState.error:
        _connectionStatus.value = '连接错误';
        break;
    }
  }

  /// 处理WebSocket错误
  void _handleWebSocketError(String error) {
    Get.snackbar(
      '连接错误',
      error,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// 处理消息状态更新
  void _handleMessageStatusUpdate(Map<String, MessageStatus> statuses) {
    _messageStatuses.clear();
    _messageStatuses.addAll(statuses);

    // 更新队列消息数量
    _queuedMessageCount.value = _wsService.queuedMessageCount;

    // 强制更新UI
    update();
  }

  /// 获取消息状态
  MessageStatus? getMessageStatus(String messageId) {
    return _messageStatuses[messageId];
  }

  /// 获取消息状态图标
  IconData? getMessageStatusIcon(String messageId) {
    final status = getMessageStatus(messageId);
    switch (status) {
      case MessageStatus.sending:
        return Icons.schedule;
      case MessageStatus.success:
        return Icons.check;
      case MessageStatus.fail:
        return Icons.error_outline;
      case MessageStatus.timeout:
        return Icons.access_time;
      case MessageStatus.queued:
        return Icons.queue;
      default:
        return null;
    }
  }

  /// 获取消息状态颜色
  Color? getMessageStatusColor(String messageId) {
    final status = getMessageStatus(messageId);
    switch (status) {
      case MessageStatus.sending:
        return Colors.orange;
      case MessageStatus.success:
        return Colors.green;
      case MessageStatus.fail:
        return Colors.red;
      case MessageStatus.timeout:
        return Colors.grey;
      case MessageStatus.queued:
        return Colors.blue;
      default:
        return null;
    }
  }

  /// 加载聊天会话列表
  Future<void> loadChatSessions() async {
    try {
      _isLoading.value = true;

      // 获取当前会话（如果没有会自动创建）
      final session =
          await apiService.chat.getCurrentSession(ApiConstants.sourceTypeApp);

      // 将API返回的ChatSession转换为ChatSessionInfo用于显示
      final sessionInfo = ChatSessionInfo(
        id: session.sessionId,
        title: '主对话',
        lastMessage: '',
        lastActiveTime: session.updatedAt,
      );

      _chatSessions.value = [sessionInfo];

      // 默认选中第一个会话
      if (_chatSessions.isNotEmpty) {
        selectSession(_chatSessions.first);
      }
    } catch (e) {
      debugPrint('Load chat sessions failed: $e');
      // 如果API调用失败，使用演示数据
      _initializeDemoData();
    } finally {
      _isLoading.value = false;
    }
  }

  /// 初始化演示数据（API失败时的后备方案）
  void _initializeDemoData() {
    _chatSessions.value = [
      ChatSessionInfo(
        id: '1',
        title: 'AI产品设计讨论',
        lastMessage: '关于用户体验优化的几个问题...',
        lastActiveTime: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatSessionInfo(
        id: '2',
        title: '知识库整理计划',
        lastMessage: '如何更好地组织我的学习资料...',
        lastActiveTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ChatSessionInfo(
        id: '3',
        title: '竞品分析总结',
        lastMessage: '帮我总结一下最新的竞品调研...',
        lastActiveTime: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    // 默认选中第一个会话
    if (_chatSessions.isNotEmpty) {
      selectSession(_chatSessions.first);
    }
  }

  /// 选择会话
  void selectSession(ChatSessionInfo session) {
    _currentSession.value = session;
    _clearMessages();
    _connectToSession(session.id);
  }

  /// 连接到会话的WebSocket
  Future<void> _connectToSession(String sessionId) async {
    try {
      debugPrint('🔌 Connecting to WebSocket session: $sessionId');
      
      // 添加调试检查
      await _wsService.checkTokenValidity();
      
      await _wsService.connect(sessionId);
      _loadSessionMessages(sessionId);
    } catch (e) {
      debugPrint('Failed to connect to session: $e');
      Get.snackbar(
        '连接失败',
        '无法连接到聊天服务器: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// 加载会话消息
  void _loadSessionMessages(String sessionId) async {
    // 暂时使用演示数据
    _loadDemoMessages();
  }

  /// 加载演示消息
  void _loadDemoMessages() {
    _messages.value = [
      ChatMessage(
        id: '1',
        content: 'aiGreeting'.tr,
        isUser: false,
        createdAt: _generateTimeString(),
        ctype: MessageContentType.text,
      ),
    ];

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  /// 创建新会话
  Future<void> createNewSession() async {
    try {
      final session =
          await apiService.chat.createSession(ApiConstants.sourceTypeApp);

      final newSession = ChatSessionInfo(
        id: session.sessionId,
        title: '新对话 ${_chatSessions.length + 1}',
        lastMessage: '',
        lastActiveTime: DateTime.now(),
      );

      _chatSessions.insert(0, newSession);
      selectSession(newSession);
    } catch (e) {
      Get.snackbar(
        'errorRequestFailed'.tr,
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );

      // API失败时创建本地会话
      final newSession = ChatSessionInfo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '新对话 ${_chatSessions.length + 1}',
        lastMessage: '',
        lastActiveTime: DateTime.now(),
      );

      _chatSessions.insert(0, newSession);
      selectSession(newSession);
    }
  }

  /// 设置输入消息
  void setInputMessage(String message) {
    _inputMessage.value = message;
  }

  /// 发送消息
  Future<void> sendMessage() async {
    if (_inputMessage.value.trim().isEmpty || _isSending.value) {
      return;
    }

    final userMessage = _inputMessage.value.trim();
    _inputMessage.value = '';

    try {
      _isSending.value = true;

      // 立即在UI中显示用户消息
      final userChatMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: userMessage,
        isUser: true,
        createdAt: _generateTimeString(),
        sessionId: _currentSession.value?.id,
        ctype: MessageContentType.text,
      );

      _messages.add(userChatMessage);
      _scrollToBottom();

      // 更新会话的最后消息
      _updateSessionLastMessage(userChatMessage);

      // 设置AI思考状态
      _isAIThinking.value = true;

      // 通过WebSocket发送消息
      final success = await _wsService.sendMessage(
        content: userMessage,
        ctype: MessageContentType.text,
      );

      if (!success) {
        // 发送失败的提示会通过消息状态显示
        debugPrint('Message queued due to connection issue');
      }
    } catch (e) {
      // 发送失败时添加错误消息
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'errorRequestFailed'.tr + ': ${e.toString()}',
        isUser: false,
        createdAt: _generateTimeString(),
        sessionId: _currentSession.value?.id,
        ctype: MessageContentType.text,
      );
      _messages.add(errorMessage);
      _scrollToBottom();

      // 显示错误提示
      Get.snackbar(
        'errorRequestFailed'.tr,
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      _isSending.value = false;
    }
  }

  /// 发送知识对话消息
  Future<void> sendKnowledgeMessage(
      String content, List<String> knowledgeIds) async {
    if (content.trim().isEmpty || _isSending.value) {
      return;
    }

    try {
      _isSending.value = true;

      // 立即在UI中显示用户消息，包含cited信息
      final userChatMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content.trim(),
        isUser: true,
        createdAt: _generateTimeString(),
        sessionId: _currentSession.value?.id,
        ctype: MessageContentType.text,
        extra: {
          'cited': knowledgeIds, // 确保cited字段包含知识ID列表
        },
      );

      _messages.add(userChatMessage);
      _scrollToBottom();

      // 更新会话的最后消息
      _updateSessionLastMessage(userChatMessage);

      // 设置AI思考状态
      _isAIThinking.value = true;

      // 通过WebSocket发送知识对话消息
      final success = await _wsService.sendKnowledgeMessage(
        content: content.trim(),
        citedKnowledgeIds: knowledgeIds,
      );

      if (!success) {
        debugPrint('Knowledge message queued due to connection issue');
      }
    } catch (e) {
      Get.snackbar(
        'errorRequestFailed'.tr,
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      _isSending.value = false;
    }
  }

  /// 重新发送失败的消息
  Future<void> retryMessage(String messageId) async {
    final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
    if (messageIndex < 0) return;

    final message = _messages[messageIndex];
    if (!message.isUser) return;

    // 重新发送消息
    final success = await _wsService.sendMessage(
      content: message.content,
      ctype: message.ctype!,
      extra: message.extra,
    );

    if (success) {
      Get.snackbar(
        '消息重发',
        '消息已重新发送',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// 更新会话最后消息
  void _updateSessionLastMessage(ChatMessage message) {
    if (_currentSession.value == null) return;

    final sessionIndex = _chatSessions.indexWhere(
      (s) => s.id == _currentSession.value!.id,
    );

    if (sessionIndex >= 0) {
      _chatSessions[sessionIndex] = ChatSessionInfo(
        id: _currentSession.value!.id,
        title: _currentSession.value!.title,
        lastMessage: message.isUser ? message.content : 'AI回复了消息',
        lastActiveTime: DateTime.now(),
      );
    }
  }

  /// 清空消息
  void _clearMessages() {
    _messages.clear();
    _messageStatuses.clear();
    _isAIThinking.value = false;
  }

  /// 滚动到底部
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// 格式化时间
  String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  /// 删除会话
  void deleteSession(String sessionId) {
    _chatSessions.removeWhere((session) => session.id == sessionId);

    // 如果删除的是当前会话，选择第一个可用会话
    if (_currentSession.value?.id == sessionId) {
      if (_chatSessions.isNotEmpty) {
        selectSession(_chatSessions.first);
      } else {
        _currentSession.value = null;
        _messages.clear();
        _wsService.disconnect();
      }
    }
  }

  /// 重新连接WebSocket
  Future<void> reconnectWebSocket() async {
    if (_currentSession.value != null) {
      await _wsService.reconnect();
    }
  }

  /// 重置聊天状态
  Future<void> resetChat() async {
    await _wsService.reset();
    _messages.clear();
    _messageStatuses.clear();
    _isAIThinking.value = false;
    _queuedMessageCount.value = 0;
  }

  /// 获取连接状态颜色
  Color getConnectionStatusColor() {
    switch (_wsService.currentState) {
      case WebSocketConnectionState.connected:
        return Colors.green;
      case WebSocketConnectionState.connecting:
      case WebSocketConnectionState.reconnecting:
        return Colors.orange;
      case WebSocketConnectionState.error:
        return Colors.red;
      case WebSocketConnectionState.disconnected:
        return Colors.grey;
    }
  }
}
