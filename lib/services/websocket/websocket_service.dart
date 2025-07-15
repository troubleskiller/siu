import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_client/web_socket_client.dart';

import '../../constants/api_constants.dart';
import '../../models/chat_models.dart';
import '../api/api_client.dart';

enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

// 消息状态枚举
enum MessageStatus {
  sending,
  success,
  fail,
  timeout,
  queued,
}

// 排队的消息结构
class QueuedMessage {
  final WebSocketMessage message;
  final DateTime timestamp;
  int retryCount;

  QueuedMessage({
    required this.message,
    required this.timestamp,
    this.retryCount = 0,
  });
}

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._();
  
  WebSocketService._();
  
  WebSocket? _webSocket;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  Timer? _connectionTimeoutTimer;
  
  // 状态管理
  final _connectionState = StreamController<WebSocketConnectionState>.broadcast();
  final _messageStream = StreamController<WebSocketMessage>.broadcast();
  final _errorStream = StreamController<String>.broadcast();
  final _messageStatusStream = StreamController<Map<String, MessageStatus>>.broadcast();
  
  WebSocketConnectionState _currentState = WebSocketConnectionState.disconnected;
  String? _currentSessionId;
  
  // 重连配置 - 指数退避
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  static const Duration baseReconnectDelay = Duration(seconds: 1);
  static const Duration maxReconnectDelay = Duration(seconds: 30);
  static const double reconnectBackoffFactor = 1.5;
  static const Duration heartbeatInterval = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration responseTimeout = Duration(seconds: 120);
  
  // 消息队列和状态管理
  final List<QueuedMessage> _messageQueue = [];
  static const int maxQueueSize = 50;
  final Map<String, Timer> _timeoutTimers = {};
  final Map<String, MessageStatus> _messageStatuses = {};
  final Set<String> _processedMessageIds = {};
  
  // API客户端实例
  final ApiClient _apiClient = ApiClient();
  
  // 流获取器
  Stream<WebSocketConnectionState> get connectionState => _connectionState.stream;
  Stream<WebSocketMessage> get messageStream => _messageStream.stream;
  Stream<String> get errorStream => _errorStream.stream;
  Stream<Map<String, MessageStatus>> get messageStatusStream => _messageStatusStream.stream;
  
  // 当前状态
  WebSocketConnectionState get currentState => _currentState;
  bool get isConnected => _currentState == WebSocketConnectionState.connected;
  String? get currentSessionId => _currentSessionId;
  int get queuedMessageCount => _messageQueue.length;
  
  /// 连接到指定session的WebSocket
  Future<void> connect(String sessionId) async {
    if (_currentSessionId == sessionId && isConnected) {
      debugPrint('WebSocket already connected to session: $sessionId');
      return;
    }
    
    // 如果连接到不同的session，先断开当前连接
    if (_currentSessionId != sessionId && _currentState != WebSocketConnectionState.disconnected) {
      await disconnect();
    }
    
    _currentSessionId = sessionId;
    await _connect();
  }
  
  Future<void> _connect() async {
    if (_currentSessionId == null) return;
    
    if (_currentState == WebSocketConnectionState.connecting) {
      debugPrint('WebSocket connection already in progress');
      return;
    }
    
    try {
      _updateState(WebSocketConnectionState.connecting);
      
      // 构建WebSocket URL
      final wsUrl = await _buildWebSocketUrl(_currentSessionId!);
      debugPrint('🔗 Connecting to WebSocket: $wsUrl');
      
      // 使用 web_socket_client 创建连接
      _webSocket = WebSocket(Uri.parse(wsUrl));
      
      // 监听连接状态
      _connectionSubscription = _webSocket!.connection.listen(
        _handleConnectionState,
        onError: (error) {
          debugPrint('WebSocket connection error: $error');
          _updateState(WebSocketConnectionState.error);
          _errorStream.add('连接错误: $error');
          _scheduleReconnect();
        },
      );
      
      // 监听消息
      _messageSubscription = _webSocket!.messages.listen(
        _onMessage,
        onError: (error) {
          debugPrint('WebSocket message error: $error');
          _errorStream.add('消息错误: $error');
        },
        onDone: () {
          debugPrint('WebSocket messages stream closed');
          _onDisconnected();
        },
      );
      
    } catch (e) {
      debugPrint('❌ WebSocket connection failed: $e');
      _updateState(WebSocketConnectionState.error);
      _errorStream.add('连接失败: $e');
      _scheduleReconnect();
    }
  }
  
  /// 处理连接状态变化
  void _handleConnectionState(ConnectionState connectionState) {
    if (connectionState is Connected) {
      debugPrint('✅ WebSocket connected');
      _updateState(WebSocketConnectionState.connected);
      _reconnectAttempts = 0;
      
      // 启动心跳
      _startHeartbeat();
      
      // 处理排队的消息
      _processMessageQueue();
      
    } else if (connectionState is Connecting) {
      debugPrint('🔄 WebSocket connecting...');
      _updateState(WebSocketConnectionState.connecting);
      
    } else if (connectionState is Reconnecting) {
      debugPrint('🔄 WebSocket reconnecting...');
      _updateState(WebSocketConnectionState.reconnecting);
      
    } else if (connectionState is Disconnected) {
      debugPrint('❌ WebSocket disconnected');
      _onDisconnected();
    }
  }
  
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
    
    final result = '$year-$month-${day}T$hour:$minute:$second.${millisecond}Z';
    debugPrint('🕐 Generated time: $result');
    return result;
  }
  
  /// 发送消息
  Future<bool> sendMessage({
    required String content,
    MessageContentType ctype = MessageContentType.text,
    Map<String, dynamic>? extra,
  }) async {
    final message = WebSocketMessage(
      messageId: const Uuid().v4(),
      type: MessageType.user,
      ctype: ctype,
      content: content,
      createdAt: _generateTimeString(), // 使用工具方法生成时间
      sessionId: _currentSessionId,
      extra: extra,
    );
    print(message.toJson());
    
    return await sendRawMessage(message);
  }
  
  /// 发送知识对话消息
  Future<bool> sendKnowledgeMessage({
    required String content,
    required List<String> citedKnowledgeIds,
  }) async {
    final extra = <String, dynamic>{
      'cited': citedKnowledgeIds,
    };
    
    return await sendMessage(
      content: content,
      ctype: MessageContentType.text,
      extra: extra,
    );
  }
  
  /// 发送原始消息
  Future<bool> sendRawMessage(WebSocketMessage message) async {
    // 更新消息状态
    _updateMessageStatus(message.messageId, MessageStatus.sending);
    
    if (!isConnected || _webSocket == null) {
      debugPrint('WebSocket not connected, queueing message: ${message.messageId}');
      _queueMessage(message);
      _updateMessageStatus(message.messageId, MessageStatus.queued);
      return false;
    }
    
    try {
      // 构建符合服务器期望的消息格式，确保时间包含时区信息
      final serverMessage = {
        "message_id": message.messageId,
        "session_id": _currentSessionId,
        "ctype": message.ctype.name.toUpperCase(),
        "content": message.content,
        // "create_at": message.createdAt, // 现在已经是带时区的ISO字符串
        "extra": message.extra ?? {}
      };
      
      final jsonString = jsonEncode(serverMessage);
      _webSocket!.send(jsonString);
      
      debugPrint('✅ Sent message: ${message.messageId}');
      _updateMessageStatus(message.messageId, MessageStatus.success);
      
      // 设置响应超时（仅对文本消息）
      if (message.ctype == MessageContentType.text) {
        _setMessageTimeout(message.messageId);
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ Failed to send message: $e');
      _updateMessageStatus(message.messageId, MessageStatus.fail);
      _queueMessage(message);
      _errorStream.add('发送消息失败: $e');
      return false;
    }
  }
  
  /// 将消息添加到队列
  void _queueMessage(WebSocketMessage message) {
    // 避免重复添加
    final existingIndex = _messageQueue.indexWhere((q) => q.message.messageId == message.messageId);
    if (existingIndex >= 0) {
      return;
    }
    
    // 限制队列大小
    if (_messageQueue.length >= maxQueueSize) {
      final removed = _messageQueue.removeAt(0);
      debugPrint('Message queue full, removed oldest message: ${removed.message.messageId}');
    }
    
    _messageQueue.add(QueuedMessage(
      message: message,
      timestamp: DateTime.now(),
    ));
    
    debugPrint('Queued message: ${message.messageId}, queue size: ${_messageQueue.length}');
  }
  
  /// 处理消息队列
  Future<void> _processMessageQueue() async {
    if (_messageQueue.isEmpty || !isConnected) {
      return;
    }
    
    debugPrint('Processing message queue, ${_messageQueue.length} messages');
    
    // 复制队列并清空
    final currentQueue = List<QueuedMessage>.from(_messageQueue);
    _messageQueue.clear();
    
    // 逐个发送消息
    for (final queuedMessage in currentQueue) {
      if (!isConnected) {
        // 如果连接断开，重新排队
        _messageQueue.addAll(currentQueue.sublist(currentQueue.indexOf(queuedMessage)));
        break;
      }
      
      debugPrint('Sending queued message: ${queuedMessage.message.messageId}');
      await sendRawMessage(queuedMessage.message);
      
      // 添加小延迟避免消息发送过快
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
  
  /// 设置消息超时
  void _setMessageTimeout(String messageId) {
    // 清除已存在的超时计时器
    _clearMessageTimeout(messageId);
    
    _timeoutTimers[messageId] = Timer(responseTimeout, () {
      debugPrint('Message timeout: $messageId');
      _updateMessageStatus(messageId, MessageStatus.timeout);
      _timeoutTimers.remove(messageId);
      
      _errorStream.add('消息响应超时，请检查网络连接');
    });
  }
  
  /// 清除消息超时
  void _clearMessageTimeout(String messageId) {
    final timer = _timeoutTimers.remove(messageId);
    timer?.cancel();
  }
  
  /// 更新消息状态
  void _updateMessageStatus(String messageId, MessageStatus status) {
    _messageStatuses[messageId] = status;
    _messageStatusStream.add(Map.from(_messageStatuses));
  }
  
  /// 获取消息状态
  MessageStatus? getMessageStatus(String messageId) {
    return _messageStatuses[messageId];
  }
  
  /// 断开连接
  Future<void> disconnect() async {
    debugPrint('Disconnecting WebSocket');
    
    _stopHeartbeat();
    _stopReconnectTimer();
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
    
    // 清除所有超时计时器
    for (final timer in _timeoutTimers.values) {
      timer.cancel();
    }
    _timeoutTimers.clear();
    
    await _messageSubscription?.cancel();
    _messageSubscription = null;
    
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    
    _webSocket?.close();
    _webSocket = null;
    
    _currentSessionId = null;
    _reconnectAttempts = 0;
    
    _updateState(WebSocketConnectionState.disconnected);
  }
  
  /// 重连
  Future<void> reconnect() async {
    if (_currentSessionId == null) return;
    
    debugPrint('Reconnecting WebSocket to session: $_currentSessionId');
    _stopReconnectTimer();
    _reconnectAttempts = 0;
    await disconnect();
    await _connect();
  }
  
  /// 重置所有状态
  Future<void> reset() async {
    debugPrint('Resetting WebSocket service');
    
    await disconnect();
    _messageQueue.clear();
    _messageStatuses.clear();
    _processedMessageIds.clear();
    _currentSessionId = null;
  }
  
  void _onMessage(messageData) {
    try {
      // 跳过心跳响应
      if (messageData == 'pong' || messageData.trim().isEmpty) {
        return;
      }

      debugPrint('📨 Raw WebSocket message: $messageData');
      final Map<String, dynamic> json = jsonDecode(messageData);

      // 将服务器消息格式转换为我们的WebSocketMessage格式
      final message = _convertServerMessage(json);

      debugPrint('📨 Converted message: ${message.messageId}, type: ${message.type}, ctype: ${message.ctype}');
      if (message.extra != null) {
        debugPrint('📨 Message extra: ${message.extra}');
      }

      // 消息去重
      if (!_shouldProcessMessage(message)) {
        return;
      }

      // 标记为已处理
      _processedMessageIds.add(message.messageId);

      // 处理响应消息的超时清除和状态更新
      if (message.extra != null) {
        final extra = MessageExtra.fromJson(message.extra!);
        
        // 清除对应消息的超时计时器
        if (extra.responseFor != null) {
          _clearMessageTimeout(extra.responseFor!);
          debugPrint('🔄 Cleared timeout for message: ${extra.responseFor}');
        }
        
        // 检查响应状态，如果是success则表示AI回答完成
        if (extra.responseStatus == 'success') {
          debugPrint('✅ AI response completed successfully');
        }

        // 检查知识引用
        if (extra.cited != null && extra.cited!.isNotEmpty) {
          debugPrint('📚 Message contains ${extra.cited!.length} cited knowledge items');
        }

        // 检查是否需要隐藏消息
        if (extra.noContent == true) {
          debugPrint('Message marked as no_content, skipping display');
          return;
        }
      }

      debugPrint('✅ Processing and forwarding message to UI');
      _messageStream.add(message);
    } catch (e) {
      debugPrint('❌ Failed to parse message: $e');
      debugPrint('❌ Raw message data: $messageData');
      _errorStream.add('消息解析失败: $e');
    }
  }

  /// 将服务器消息格式转换为WebSocketMessage
  WebSocketMessage _convertServerMessage(Map<String, dynamic> json) {
    return WebSocketMessage(
      messageId: json['message_id'] ?? const Uuid().v4(),
      type: _parseMessageType(json['type']),
      ctype: _parseContentType(json['ctype']),
      content: json['content'] ?? '',
      createdAt: json['create_at'] ?? _generateTimeString(), // 使用统一的时间格式
      sessionId: json['session_id'] ?? _currentSessionId,
      extra: json['extra'],
    );
  }

  /// 解析消息类型
  MessageType _parseMessageType(dynamic type) {
    if (type == null) return MessageType.ai;

    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'user':
        return MessageType.user;
      case 'ai':
      case 'assistant':
        return MessageType.ai;
      case 'system':
        return MessageType.ai;
      default:
        return MessageType.ai;
    }
  }

  /// 解析内容类型
  MessageContentType _parseContentType(dynamic ctype) {
    if (ctype == null) return MessageContentType.text;

    final ctypeStr = ctype.toString().toLowerCase();
    switch (ctypeStr) {
      case 'text':
        return MessageContentType.text;
      case 'image':
        return MessageContentType.picture;
      case 'file':
        return MessageContentType.attachment;
      case 'knowledge_card':
        return MessageContentType.attachment;
      default:
        return MessageContentType.text;
    }
  }

  /// 判断消息是否应该被处理
  bool _shouldProcessMessage(WebSocketMessage message) {
    // 1. 检查消息ID是否重复
    if (_processedMessageIds.contains(message.messageId)) {
      debugPrint('Duplicate message ID, skipping: ${message.messageId}');
      return false;
    }

    // 2. 过滤服务器回显的用户消息
    if (message.actualType == MessageType.user) {
      debugPrint('Skipping server echo of user message');
      return false;
    }

    // 3. 检查是否是有意义的响应消息
    if (message.extra != null) {
      try {
        final extra = MessageExtra.fromJson(message.extra!);
        
        // 如果有response_status，说明是重要的响应消息，应该处理
        if (extra.responseStatus != null) {
          debugPrint('Processing message with response_status: ${extra.responseStatus}');
          return true;
        }
        
        // 如果有cited字段，说明是知识引用消息，应该处理
        if (extra.cited != null && extra.cited!.isNotEmpty) {
          debugPrint('Processing message with cited knowledge: ${extra.cited!.length} items');
          return true;
        }
      } catch (e) {
        debugPrint('Error parsing message extra: $e');
      }
    }

    // 4. 过滤简单确认类消息（但保留有意义的响应）
    if (message.content.contains('消息成功接收并保存') && 
        message.extra == null) {
      debugPrint('Skipping simple confirmation message: ${message.content}');
      return false;
    }

    // 5. 默认处理其他消息
    return true;
  }

  void _onDisconnected() {
    debugPrint('WebSocket disconnected');
    if (_currentState != WebSocketConnectionState.disconnected) {
      _updateState(WebSocketConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  /// 计算指数退避延迟
  Duration _calculateReconnectDelay() {
    final delay = baseReconnectDelay.inMilliseconds *
        math.pow(reconnectBackoffFactor, _reconnectAttempts);
    return Duration(milliseconds: math.min(delay.toInt(), maxReconnectDelay.inMilliseconds));
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null || _currentState != WebSocketConnectionState.error && _currentState != WebSocketConnectionState.disconnected) {
      return;
    }

    _reconnectAttempts++;

    if (_reconnectAttempts > maxReconnectAttempts) {
      debugPrint('Max reconnect attempts reached: $maxReconnectAttempts');
      _errorStream.add('连接失败，已达到最大重试次数');
      return;
    }

    final delay = _calculateReconnectDelay();
    _updateState(WebSocketConnectionState.reconnecting);

    debugPrint('Scheduling reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s');

    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      _connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (timer) {
      if (isConnected && _webSocket != null) {
        try {
          _webSocket!.send('ping');
        } catch (e) {
          debugPrint('Heartbeat failed: $e');
        }
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _updateState(WebSocketConnectionState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _connectionState.add(newState);
      debugPrint('WebSocket state changed to: $newState');
    }
  }

  /// 构建WebSocket URL
  Future<String> _buildWebSocketUrl(String sessionId) async {
    // 解析基础URL并转换为WebSocket协议
    final uri = Uri.parse(ApiConstants.baseUrl);

    String wsScheme;
    if (uri.scheme == 'https') {
      wsScheme = 'wss';
    } else {
      wsScheme = 'ws';
    }

    const baseUrl = 'wss://assistant.pami-ai.com';
    // 获取token
    final token = await _apiClient.getAccessToken();

    // 构建完整的WebSocket URL
    String wsUrl = '$wsScheme://${uri.host}';

    // 添加端口（如果不是默认端口）
    if (uri.hasPort) {
      wsUrl += ':${uri.port}';
    }

    // 添加路径和session ID
    wsUrl = '$baseUrl:443/api/chat/ws/$sessionId';
    print(wsUrl);

    // 添加token参数
    if (token != null && token.isNotEmpty) {
      wsUrl += '?token=$token';
    }
    
    debugPrint('🔗 Built WebSocket URL: ${wsUrl.replaceAll(RegExp(r'token=[^&]*'), 'token=***')}');
    
    return wsUrl;
  }
  
  /// 检查token有效性
  Future<void> checkTokenValidity() async {
    try {
      debugPrint('🔑 Checking token validity...');
      final token = await _apiClient.getAccessToken();
      if (token == null) {
        debugPrint('🔑 No access token found');
        return;
      }
      
      debugPrint('🔑 Access token found (length: ${token.length})');
      
      // 尝试验证token
      final isValid = await _apiClient.validateCurrentToken();
      debugPrint('🔑 Token validation result: ${isValid ? 'VALID' : 'INVALID'}');
      
    } catch (e) {
      debugPrint('🔑 Token check failed: $e');
    }
  }
  
  /// 释放资源
  void dispose() {
    disconnect();
    _connectionState.close();
    _messageStream.close();
    _errorStream.close();
    _messageStatusStream.close();
  }
}
