import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/chat_controller.dart';
import '../../../models/chat_models.dart';
import '../../../services/websocket/websocket_service.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: const Row(
        children: [
          // 左侧会话列表
          // ChatSessionList(),

          // 右侧聊天窗口
          ChatWindow(),
        ],
      ),
    );
  }
}

class ChatSessionList extends StatelessWidget {
  const ChatSessionList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ChatController.to;

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFe5e5e7)),
        ),
      ),
      child: Column(
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFe5e5e7)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'chatHistory'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1d1d1f),
                        ),
                      ),
                    ),
                    // WebSocket连接状态指示器
                    Obx(() {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: controller.getConnectionStatusColor(),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ],
                ),

                // 连接状态文本和队列信息
                Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.connectionStatus.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            controller.connectionStatus,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],

                      // 消息队列指示器
                      if (controller.queuedMessageCount > 0) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '队列中: ${controller.queuedMessageCount}条消息',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                }),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.createNewSession,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text('newChat'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 会话列表
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView.builder(
                itemCount: controller.chatSessions.length,
                itemBuilder: (context, index) {
                  final session = controller.chatSessions[index];
                  final isSelected =
                      controller.currentSession?.id == session.id;

                  return ChatSessionItem(
                    session: session,
                    isSelected: isSelected,
                    onTap: () => controller.selectSession(session),
                    onDelete: () => controller.deleteSession(session.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ChatSessionItem extends StatelessWidget {
  final ChatSessionInfo session;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ChatSessionItem({
    super.key,
    required this.session,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFe3f2fd) : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFf0f0f0)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1d1d1f),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.lastMessage.isNotEmpty
                        ? session.lastMessage
                        : '暂无消息',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF86868b),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 16,
                  color: Color(0xFF86868b),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  } else if (value == 'reconnect') {
                    ChatController.to.reconnectWebSocket();
                  } else if (value == 'reset') {
                    ChatController.to.resetChat();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'reconnect',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 16),
                        SizedBox(width: 8),
                        Text('重新连接'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.reset_tv, size: 16),
                        SizedBox(width: 8),
                        Text('重置聊天'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16),
                        SizedBox(width: 8),
                        Text('删除'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ChatWindow extends StatelessWidget {
  const ChatWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ChatController.to;

    return Expanded(
      child: Container(
        color: Colors.grey[50],
        child: Obx(() {
          if (controller.currentSession == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '请选择一个对话或创建新对话',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 消息列表
              Expanded(child: MessageList()),

              // AI思考指示器
              Obx(() {
                if (controller.isAIThinking) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 20,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF007AFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'AI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey[400]!,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'AI正在思考中...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // 输入区域
              const ChatInputArea(),
            ],
          );
        }),
      ),
    );
  }
}

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ChatController.to;

    return Obx(() {
      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          return MessageBubble(message: message);
        },
      );
    });
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ChatController.to;

    // 如果是知识卡片，显示特殊样式
    if (message.isKnowledgeCard == true) {
      return KnowledgeCardWidget(message: message);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            // AI头像
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF007AFF),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // 消息内容
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF007AFF) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 如果是知识对话消息，显示引用的知识
                  if (message.extra?['cited'] != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? Colors.white.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: message.isUser ? Colors.white : Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                message.isUser ? '基于知识提问' : '基于知识回答',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: message.isUser
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // 显示引用的知识数量
                          if (message.extra!['cited'] is List) ...[
                            const SizedBox(height: 4),
                            Text(
                              '引用了 ${(message.extra!['cited'] as List).length} 个知识',
                              style: TextStyle(
                                fontSize: 10,
                                color: message.isUser
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.blue.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: message.isUser ? Colors.white : Colors.black87,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 消息时间和状态
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.formatMessageTime(
                            DateTime.parse(message.createdAt)),
                        style: TextStyle(
                          fontSize: 10,
                          color: message.isUser
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey[600],
                        ),
                      ),

                      // 消息状态指示器（仅用户消息）
                      if (message.isUser) ...[
                        GetBuilder<ChatController>(
                          builder: (controller) {
                            final statusIcon =
                                controller.getMessageStatusIcon(message.id);
                            final statusColor =
                                controller.getMessageStatusColor(message.id);
                            final status =
                                controller.getMessageStatus(message.id);

                            if (statusIcon == null) {
                              return const SizedBox.shrink();
                            }

                            return GestureDetector(
                              onTap: () {
                                if (status == MessageStatus.fail ||
                                    status == MessageStatus.timeout) {
                                  // 显示重试选项
                                  _showRetryDialog(
                                      context, controller, message.id);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                child: Icon(
                                  statusIcon,
                                  size: 12,
                                  color: statusColor?.withOpacity(0.8) ??
                                      Colors.white.withOpacity(0.8),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (message.isUser) ...[
            const SizedBox(width: 12),
            // 用户头像
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF34C759),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '我',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRetryDialog(
      BuildContext context, ChatController controller, String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('消息发送失败'),
          content: const Text('是否重新发送这条消息？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.retryMessage(messageId);
              },
              child: const Text('重试'),
            ),
          ],
        );
      },
    );
  }
}

// 知识卡片组件
class KnowledgeCardWidget extends StatelessWidget {
  final ChatMessage message;

  const KnowledgeCardWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 知识卡片标识
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '已保存为知识',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    message.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // 跳转到知识库查看
                          if (message.knowledgeCardId != null) {
                            Get.snackbar(
                              '知识卡片',
                              '知识ID: ${message.knowledgeCardId}',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.blue.withOpacity(0.8),
                              colorText: Colors.white,
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.visibility,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          '查看知识',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 用户头像
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF34C759),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '我',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatInputArea extends StatefulWidget {
  const ChatInputArea({super.key});

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ChatController.to;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFe5e5e7)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFd2d2d7)),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onChanged: controller.setInputMessage,
                onSubmitted: (_) {
                  _sendMessage();
                },
                decoration: InputDecoration(
                  hintText: 'chatInputPlaceholder'.tr,
                  hintStyle: const TextStyle(fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() {
            return GestureDetector(
              onTap: controller.isSending ? null : _sendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: controller.isSending
                      ? Colors.grey
                      : const Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
                child: controller.isSending
                    ? const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      ChatController.to.sendMessage();
      _textController.clear();
      _focusNode.requestFocus();
    }
  }
}
