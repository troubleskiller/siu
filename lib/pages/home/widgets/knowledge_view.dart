import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../controllers/knowledge_controller.dart';
import '../../../controllers/main_controller.dart';
import '../../../controllers/chat_controller.dart';
import '../../../models/knowledge_models.dart';

class KnowledgeView extends StatelessWidget {
  const KnowledgeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: const Row(
        children: [
          // 中间栏 - 知识列表
          KnowledgeList(),
          
          // 右侧详情面板
          KnowledgeDetail(),
        ],
      ),
    );
  }
}

class KnowledgeList extends StatelessWidget {
  const KnowledgeList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = KnowledgeController.to;

    return Container(
      width: 320,
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
                        'knowledgeTitle'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1d1d1f),
                        ),
                      ),
                    ),
                    // 批量对话按钮
                    Obx(() {
                      final selectedCount = controller.selectedKnowledgeIds.length;
                      if (selectedCount > 0) {
                        return IconButton(
                          onPressed: () => _startBatchChat(controller),
                          icon: Badge(
                            label: Text('$selectedCount'),
                            child: const Icon(Icons.chat_bubble),
                          ),
                          tooltip: '与选中知识对话',
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 搜索框
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFf9f9f9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFd2d2d7)),
                  ),
                  child: TextField(
                    onChanged: controller.searchKnowledge,
                    decoration: InputDecoration(
                      hintText: 'searchKnowledge'.tr,
                      hintStyle: const TextStyle(fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      suffixIcon: const Icon(
                        Icons.search,
                        size: 16,
                        color: Color(0xFF86868b),
                      ),
                    ),
                  ),
                ),
                
                // 过滤标签
                const SizedBox(height: 12),
                Obx(() {
                  return Wrap(
                    spacing: 8,
                    children: KnowledgeFilter.values.map((filter) {
                      final isActive = controller.currentFilter == filter;
                      return GestureDetector(
                        onTap: () => controller.setFilter(filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive 
                                ? const Color(0xFF007AFF)
                                : const Color(0xFFf0f0f0),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            controller.getFilterTitle(filter),
                            style: TextStyle(
                              fontSize: 12,
                              color: isActive ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
                
                // 多选模式控制
                const SizedBox(height: 12),
                Obx(() {
                  return Row(
                    children: [
                      Checkbox(
                        value: controller.isMultiSelectMode,
                        onChanged: (value) {
                          if (value != null) {
                            controller.toggleMultiSelectMode();
                          }
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => controller.toggleMultiSelectMode(),
                        child: const Text(
                          '多选模式',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const Spacer(),
                      if (controller.isMultiSelectMode && controller.selectedKnowledgeIds.isNotEmpty)
                        TextButton(
                          onPressed: () => controller.clearSelection(),
                          child: const Text(
                            '清空',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),

          // 列表内容
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(controller.errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.loadKnowledgeItems,
                        child: Text('retry'.tr),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  // 拖拽上传区域
                  const DropZoneWidget(),
                  
                  // 知识列表
                  ...controller.filteredItems.map((item) {
                    final isSelected = controller.selectedItem?.id == item.id;
                    final isChecked = controller.selectedKnowledgeIds.contains(item.id);
                    
                    return KnowledgeListItem(
                      item: item,
                      isSelected: isSelected,
                      isChecked: isChecked,
                      isMultiSelectMode: controller.isMultiSelectMode,
                      onTap: () => controller.selectItem(item),
                      onChecked: (checked) {
                        if (checked != null) {
                          controller.toggleItemSelection(item.id);
                        }
                      },
                    );
                  }),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
  
  void _startBatchChat(KnowledgeController controller) {
    if (controller.selectedKnowledgeIds.isEmpty) return;
    
    // 切换到聊天页面
    Get.find<MainController>().changeTab(NavigationTab.chat);
    
    // 延迟一下确保页面切换完成，然后发送知识对话
    Future.delayed(const Duration(milliseconds: 100), () {
      final chatController = Get.find<ChatController>();
      chatController.sendKnowledgeMessage(
        '请基于选中的${controller.selectedKnowledgeIds.length}个知识项，帮我总结核心内容',
        controller.selectedKnowledgeIds.toList(),
      );
    });
    
    // 清空选择状态
    controller.clearSelection();
  }
}

class DropZoneWidget extends StatefulWidget {
  const DropZoneWidget({super.key});

  @override
  State<DropZoneWidget> createState() => _DropZoneWidgetState();
}

class _DropZoneWidgetState extends State<DropZoneWidget> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final controller = KnowledgeController.to;

    return Obx(() {
      if (controller.isUploading) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                'uploadSuccess'.tr,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'uploadProcessing'.tr,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return DropTarget(
        onDragDone: (details) async {
          for (final file in details.files) {
            if (file.path.isNotEmpty) {
              await controller.uploadFile(File(file.path));
            }
          }
        },
        onDragEntered: (details) {
          setState(() {
            _isDragOver = true;
          });
        },
        onDragExited: (details) {
          setState(() {
            _isDragOver = false;
          });
        },
        child: GestureDetector(
          onTap: _pickFile,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: _isDragOver ? const Color(0xFFf0f8ff) : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isDragOver 
                    ? const Color(0xFF007AFF)
                    : const Color(0xFFd2d2d7),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                const Text('📁', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 12),
                Text(
                  'dropZoneTitle'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isDragOver ? const Color(0xFF007AFF) : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'dropZoneSubtitle'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      await KnowledgeController.to.uploadFile(file);
    }
  }
}

class KnowledgeListItem extends StatelessWidget {
  final CollectedInformationItem item;
  final bool isSelected;
  final bool isChecked;
  final bool isMultiSelectMode;
  final VoidCallback onTap;
  final ValueChanged<bool?> onChecked;

  const KnowledgeListItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isChecked,
    required this.isMultiSelectMode,
    required this.onTap,
    required this.onChecked,
  });

  @override
  Widget build(BuildContext context) {
    final controller = KnowledgeController.to;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFe3f2fd) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF2196F3)
                : isChecked
                    ? const Color(0xFF007AFF)
                    : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 多选模式下显示复选框
                if (isMultiSelectMode) ...[
                  Checkbox(
                    value: isChecked,
                    onChanged: onChecked,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    _extractTitle(item.content),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1d1d1f),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            
            Row(
              children: [
                Text(
                  controller.getFileTypeIcon(item.ctype),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 4),
                Text(
                  item.ctype,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF86868b),
                  ),
                ),
                const Spacer(),
                Text(
                  controller.formatTime(item.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF86868b),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              item.content,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF515154),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: item.tags.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf0f0f0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF666),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _extractTitle(String content) {
    final lines = content.split('\n');
    final firstLine = lines.first.trim();
    if (firstLine.length > 50) {
      return firstLine.substring(0, 50) + '...';
    }
    return firstLine.isNotEmpty ? firstLine : '无标题';
  }
}

class KnowledgeDetail extends StatelessWidget {
  const KnowledgeDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = KnowledgeController.to;

    return Expanded(
      child: Container(
        color: Colors.white,
        child: Obx(() {
          final selectedItem = controller.selectedItem;
          if (selectedItem == null) {
            return Center(
              child: Text(
                'noData'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return Column(
            children: [
              // 详情头部
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFe5e5e7)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _extractTitle(selectedItem.content),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1d1d1f),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${controller.getFileTypeIcon(selectedItem.ctype)} ${selectedItem.ctype} • ${'addedAt'.trParams({'date': _formatDate(selectedItem.createdAt)})}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF86868b),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 操作按钮
                    Row(
                      children: [
                        _ActionButton(
                          text: 'actionEdit'.tr,
                          icon: Icons.edit,
                          isPrimary: true,
                          onPressed: () => _showEditDialog(context, controller, selectedItem),
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          text: 'actionDelete'.tr,
                          icon: Icons.delete,
                          isPrimary: true,
                          onPressed: () => _showDeleteDialog(context, controller),
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          text: 'actionChatWithAI'.tr,
                          isPrimary: true,
                          icon: Icons.chat_bubble,
                          onPressed: () {
                            // 切换到聊天页面并开始知识对话
                            Get.find<MainController>().changeTab(NavigationTab.chat);
                            
                            // 延迟一下确保页面切换完成，然后发送知识对话
                            Future.delayed(const Duration(milliseconds: 100), () {
                              final chatController = Get.find<ChatController>();
                              chatController.sendKnowledgeMessage(
                                '请介绍一下这个知识的内容',
                                [selectedItem.id],
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 详情内容
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(title: 'aiSummaryTitle'.tr),
                      Text(
                        selectedItem.content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF515154),
                          height: 1.6,
                        ),
                      ),
                      
                      if (selectedItem.tags.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _SectionTitle(title: '标签'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedItem.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFf0f0f0),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFf0f8ff),
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(
                              color: Color(0xFF007AFF),
                              width: 4,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text('💬', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 8),
                                Text(
                                  'AI助手建议',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF007AFF),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '这份内容包含了丰富的信息。你可以尝试问我"如何将这些内容应用到我的项目中？"来获得更具体的指导。',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showEditDialog(BuildContext context, KnowledgeController controller, CollectedInformationItem item) {
    final contentController = TextEditingController(text: item.content);
    final tagsController = TextEditingController(text: item.tags.join(', '));
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('编辑知识项'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contentController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    labelText: '内容',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: '标签（用逗号分隔）',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final content = contentController.text;
                final tags = tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                controller.updateSelectedItem(content, tags);
                Navigator.of(context).pop();
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, KnowledgeController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这个知识项吗？此操作无法撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.deleteSelectedItem();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  String _extractTitle(String content) {
    final lines = content.split('\n');
    final firstLine = lines.first.trim();
    if (firstLine.length > 80) {
      return firstLine.substring(0, 80) + '...';
    }
    return firstLine.isNotEmpty ? firstLine : '无标题';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;
  final IconData? icon;

  const _ActionButton({
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = icon != null
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 14),
            label: Text(text, style: const TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrimary ? const Color(0xFF007AFF) : const Color(0xFFf0f0f0),
              foregroundColor: isPrimary ? Colors.white : const Color(0xFF333),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrimary ? const Color(0xFF007AFF) : const Color(0xFFf0f0f0),
              foregroundColor: isPrimary ? Colors.white : const Color(0xFF333),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(text, style: const TextStyle(fontSize: 13)),
          );
    
    return buttonContent;
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1d1d1f),
        ),
      ),
    );
  }
} 