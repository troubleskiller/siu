# WebSocket聊天功能使用指南

## 概述

本应用已集成完整的WebSocket实时聊天功能，支持：
- 实时消息发送和接收
- 自动重连机制
- 知识对话（基于知识库）
- 知识卡片自动转换
- 多选知识项批量对话

## 核心功能

### 1. 实时聊天
- **WebSocket连接**: `wss://{BASE_URL}/ws/{sessionId}`
- **消息格式**: 完整的JSON结构支持
- **连接状态**: 实时显示连接状态指示器
- **自动重连**: 网络断开时自动重连

### 2. 消息类型支持
- **TEXT**: 文本消息
- **PICTURE**: 图片（预留）
- **VIDEO**: 视频（预留）
- **RECORDING**: 语音（预留）
- **SHARING**: 链接分享（预留）
- **ATTACHMENT**: 文件附件（预留）

### 3. 知识对话
- 从知识库页面选择知识项
- 单个知识项对话：点击"与AI对话"按钮
- 多选知识项对话：开启多选模式，选择多个知识项批量对话
- 消息自动带有`cited`字段标识引用的知识

### 4. 知识卡片功能
- 普通消息自动保存为知识
- 知识卡片特殊UI显示
- 支持查看知识详情

## 使用流程

### 基础聊天
1. 进入聊天页面
2. 系统自动获取/创建会话
3. WebSocket自动连接到会话
4. 输入消息发送

### 知识对话
1. 进入知识库页面
2. 选择要对话的知识项：
   - **单选**: 直接点击知识项，然后点击"与AI对话"
   - **多选**: 开启多选模式，勾选多个知识项，点击聊天图标
3. 系统自动切换到聊天页面
4. 自动发送知识对话消息

## 技术实现

### WebSocket服务 (`WebSocketService`)
```dart
// 连接到会话
await WebSocketService.instance.connect(sessionId);

// 发送普通消息
await WebSocketService.instance.sendMessage(
  content: '你好',
  ctype: MessageContentType.text,
);

// 发送知识对话消息
await WebSocketService.instance.sendKnowledgeMessage(
  content: '请介绍这个知识',
  citedKnowledgeIds: ['knowledge-id-1', 'knowledge-id-2'],
);
```

### 聊天控制器 (`ChatController`)
- 管理WebSocket连接
- 处理消息收发
- 管理会话列表
- 处理知识卡片转换

### 消息模型
```dart
// WebSocket消息
WebSocketMessage {
  messageId: String,
  type: MessageType?, // null时默认为ai
  ctype: MessageContentType,
  content: String,
  createdAt: DateTime,
  extra: Map<String, dynamic>?,
}

// 消息额外信息
MessageExtra {
  responseFor: String?,
  responseStatus: String?,
  noContent: bool?,
  changeToKnowledgeCard: bool?,
  knowledgeCardContent: String?,
  cited: List<String>?,
}
```

## 连接状态指示
- 🟢 绿色：已连接
- 🟠 橙色：连接中/重连中
- 🔴 红色：连接错误
- ⚪ 灰色：已断开

## 错误处理
- 自动重连（最多5次）
- 连接失败提示
- 消息发送失败处理
- 网络超时处理

## 配置说明

### API常量配置
```dart
// lib/constants/api_constants.dart
static const String baseUrl = 'https://ia.kldrgon.com';
static const int wsMaxReconnectAttempts = 5;
static const Duration wsReconnectDelay = Duration(seconds: 2);
static const Duration wsHeartbeatInterval = Duration(seconds: 30);
```

### 依赖包
```yaml
# pubspec.yaml
dependencies:
  web_socket_channel: ^2.4.0
  uuid: ^4.1.0
```

## 使用注意事项
1. 确保API地址配置正确
2. WebSocket URL会自动从HTTP/HTTPS转换为WS/WSS
3. 消息发送失败时会显示错误提示
4. 知识对话需要先选择知识项
5. 连接断开时会自动重连

## 开发调试
- 所有WebSocket事件都有详细的调试日志
- 可以通过连接状态指示器查看实时连接状态
- 错误信息会通过Snackbar提示用户 