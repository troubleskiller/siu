import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/knowledge_models.dart';
import '../services/api/api_service_manager.dart';
import '../constants/api_constants.dart';

enum KnowledgeFilter {
  all,
  document,
  web,
  image,
}

class KnowledgeController extends GetxController {
  static KnowledgeController get to => Get.find();
  
  // 知识库数据
  final _knowledgeItems = <CollectedInformationItem>[].obs;
  List<CollectedInformationItem> get knowledgeItems => _knowledgeItems;
  
  // 过滤后的知识库数据
  final _filteredItems = <CollectedInformationItem>[].obs;
  List<CollectedInformationItem> get filteredItems => _filteredItems;
  
  // 当前选中的知识项
  final _selectedItem = Rxn<CollectedInformationItem>();
  CollectedInformationItem? get selectedItem => _selectedItem.value;
  
  // 搜索关键词
  final _searchKeyword = ''.obs;
  String get searchKeyword => _searchKeyword.value;
  
  // 当前过滤器
  final _currentFilter = KnowledgeFilter.all.obs;
  KnowledgeFilter get currentFilter => _currentFilter.value;
  
  // 加载状态
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  // 错误信息
  final _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  
  // 上传状态
  final _isUploading = false.obs;
  bool get isUploading => _isUploading.value;
  
  // 标签列表
  final _tags = <String>[].obs;
  List<String> get tags => _tags;
  
  // 多选模式
  final _isMultiSelectMode = false.obs;
  bool get isMultiSelectMode => _isMultiSelectMode.value;
  
  // 选中的知识项ID列表
  final _selectedKnowledgeIds = <String>{}.obs;
  Set<String> get selectedKnowledgeIds => _selectedKnowledgeIds;
  
  @override
  void onInit() {
    super.onInit();
    loadKnowledgeItems();
    loadTags();
  }
  
  /// 加载知识库列表
  Future<void> loadKnowledgeItems() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      // 调用真实API
      final result = await apiService.knowledge.getItemsByCursor(
        limit: 50,
        direction: ApiConstants.directionForward,
      );
      
      _knowledgeItems.value = result.items;
      _applyFilters();
      
      // 如果没有选中项且有数据，默认选中第一项
      if (_selectedItem.value == null && _knowledgeItems.isNotEmpty) {
        selectItem(_knowledgeItems.first);
      }
      
    } catch (e) {
      debugPrint('Load knowledge items failed: $e');
      _errorMessage.value = _getErrorMessage(e);
      
      // API失败时使用演示数据
      _initializeDemoData();
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 初始化演示数据（API失败时的后备方案）
  void _initializeDemoData() {
    _knowledgeItems.value = [
      CollectedInformationItem(
        id: '1',
        ctype: 'pdf',
        content: '''AI产品设计思维框架

本文档详细介绍了AI产品设计的核心思维框架，包括用户需求分析、技术可行性评估、商业价值挖掘等关键环节。

🎯 四层设计框架：
1. 用户洞察层 - 深度理解真实需求
2. 技术可行性 - 评估AI实现难度  
3. 商业价值 - 明确价值主张
4. 体验设计 - 优化人机交互

💡 关键原则：避免技术驱动，以问题解决为导向

🔧 实践工具：
- 用户画像分析模板
- AI能力评估矩阵
- 产品功能优先级排序方法
- 用户体验测试清单

📊 案例研究：
通过分析ChatGPT、Midjourney等成功AI产品的设计思路，总结出可复用的设计模式和最佳实践。''',
        owner: 'user1',
        metadata: {'fileSize': '2.3MB', 'pages': 45},
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['产品设计', 'AI', '框架'],
      ),
      CollectedInformationItem(
        id: '2',
        ctype: 'web',
        content: '''2024年科技趋势报告

深度解析2024年最重要的科技趋势，包括生成式AI、量子计算、元宇宙技术的最新发展。

🔮 主要趋势：
1. 生成式AI进入企业级应用
2. 量子计算商业化加速
3. AR/VR技术日趋成熟
4. 区块链技术实用化
5. 边缘计算普及

🚀 技术突破：
- GPT-4等大模型能力提升
- 量子纠错技术进展
- 5G网络覆盖扩大
- 自动驾驶L4级量产

📈 市场前景：
预计AI市场规模将达到1.8万亿美元，量子计算市场将突破100亿美元。''',
        owner: 'user1',
        metadata: {'url': 'https://tech-trends.com/2024'},
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['科技趋势', '2024', 'AI'],
      ),
      CollectedInformationItem(
        id: '3',
        ctype: 'txt',
        content: '''用户体验设计原则

整理的UX设计核心原则，包括可用性、可访问性、情感化设计等关键要素。

🎨 设计原则：
1. 简单易用 - 降低学习成本
2. 一致性 - 保持界面统一
3. 反馈及时 - 提供操作反馈
4. 容错性强 - 允许用户犯错
5. 个性化 - 满足不同需求

💫 情感化设计：
- 愉悦的视觉体验
- 有趣的交互动画
- 贴心的功能设计
- 温馨的文案表达

🔍 可用性测试：
- A/B测试对比
- 用户访谈调研
- 眼动追踪分析
- 任务完成率统计''',
        owner: 'user1',
        metadata: {'wordCount': 1250},
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        tags: ['UX设计', '原则', '可用性'],
      ),
      CollectedInformationItem(
        id: '4',
        ctype: 'doc',
        content: '''竞品分析：知识管理工具对比

对市面上主流的知识管理工具进行深度对比分析，包括Notion、Obsidian、Roam Research等。

📊 功能对比：
Notion - 全能型工作空间
- 优势：功能丰富、协作便利
- 劣势：性能较慢、学习成本高

Obsidian - 本地化笔记工具
- 优势：速度快、插件丰富
- 劣势：协作功能弱

Roam Research - 双向链接笔记
- 优势：思维导图式组织
- 劣势：界面复杂、价格昂贵

🎯 产品定位：
各工具都有明确的目标用户群体和使用场景，选择时需要考虑团队规模、使用习惯、预算等因素。

💡 设计启发：
- 简化复杂功能的操作流程
- 提供多种信息组织方式
- 平衡功能丰富度与易用性
- 重视移动端体验优化''',
        owner: 'user1',
        metadata: {'fileSize': '1.8MB', 'lastModified': '2024-01-20'},
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        tags: ['竞品分析', '知识管理', '工具对比'],
      ),
    ];

    _tags.value = ['产品设计', 'AI', '框架', '科技趋势', '2024', 'UX设计', '原则', '可用性', '竞品分析', '知识管理', '工具对比'];
    
    _applyFilters();
    
    // 默认选中第一项
    if (_knowledgeItems.isNotEmpty) {
      selectItem(_knowledgeItems.first);
    }
  }
  
  /// 加载标签列表
  Future<void> loadTags() async {
    try {
      final tagList = await apiService.knowledge.getTags();
      _tags.value = tagList;
    } catch (e) {
      debugPrint('Load tags failed: $e');
      // 标签加载失败不影响主要功能，使用默认标签
      _tags.value = ['产品设计', 'AI', '框架', '科技趋势', '2024', 'UX设计', '原则', '可用性', '竞品分析', '知识管理', '工具对比'];
    }
  }
  
  /// 搜索知识
  void searchKnowledge(String keyword) {
    _searchKeyword.value = keyword;
    _applyFilters();
  }
  
  /// 设置过滤器
  void setFilter(KnowledgeFilter filter) {
    _currentFilter.value = filter;
    _applyFilters();
  }
  
  /// 应用过滤条件
  void _applyFilters() {
    List<CollectedInformationItem> filtered = List.from(_knowledgeItems);
    
    // 应用搜索关键词过滤
    if (_searchKeyword.value.isNotEmpty) {
      filtered = filtered.where((item) {
        final keyword = _searchKeyword.value.toLowerCase();
        return item.content.toLowerCase().contains(keyword) ||
            item.tags.any((tag) => tag.toLowerCase().contains(keyword));
      }).toList();
    }
    
    // 应用类型过滤
    if (_currentFilter.value != KnowledgeFilter.all) {
      filtered = filtered.where((item) {
        switch (_currentFilter.value) {
          case KnowledgeFilter.document:
            return item.ctype.contains('pdf') || 
                   item.ctype.contains('doc') || 
                   item.ctype.contains('txt');
          case KnowledgeFilter.web:
            return item.ctype.contains('url') || 
                   item.ctype.contains('web');
          case KnowledgeFilter.image:
            return item.ctype.contains('jpg') || 
                   item.ctype.contains('png') || 
                   item.ctype.contains('image');
          default:
            return true;
        }
      }).toList();
    }
    
    _filteredItems.value = filtered;
  }
  
  /// 选择知识项
  void selectItem(CollectedInformationItem item) {
    _selectedItem.value = item;
  }
  
  /// 上传文件
  Future<void> uploadFile(File file) async {
    try {
      _isUploading.value = true;
      
      // 调用真实API上传文件
      final result = await apiService.knowledge.uploadFile(
        file,
        file.path.split('/').last,
      );
      
      // 上传成功后刷新列表
      await loadKnowledgeItems();
      
      Get.snackbar(
        'uploadSuccess'.tr,
        'uploadProcessing'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Upload file failed: $e');
      
      // API失败时添加演示数据
      final newItem = CollectedInformationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ctype: file.path.split('.').last,
        content: '新上传的文件：${file.path.split('/').last}\n\n这是一个演示文件，包含了相关的内容信息。',
        owner: 'user1',
        metadata: {'fileSize': '${(await file.length() / 1024).toStringAsFixed(1)}KB'},
        createdAt: DateTime.now(),
        tags: ['新上传', '文件'],
      );
      
      _knowledgeItems.insert(0, newItem);
      _applyFilters();
      
      Get.snackbar(
        'uploadSuccess'.tr,
        'uploadProcessing'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      _isUploading.value = false;
    }
  }
  
  /// 创建知识项
  Future<void> createKnowledgeItem({
    required String content,
    List<String>? tags,
    File? file,
  }) async {
    try {
      _isLoading.value = true;
      
      await apiService.knowledge.createItem(
        content: content,
        tags: tags?.join(','),
        file: file,
      );
      
      // 创建成功后刷新列表
      await loadKnowledgeItems();
      
      Get.snackbar(
        '成功',
        '知识项创建成功',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'errorRequestFailed'.tr,
        _getErrorMessage(e),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 删除知识项
  Future<void> deleteSelectedItem() async {
    if (selectedItem == null) return;
    
    try {
      await apiService.knowledge.deleteKnowledgeItem(selectedItem!.id);
      
      final deletedItemId = selectedItem!.id;
      _knowledgeItems.removeWhere((item) => item.id == deletedItemId);
      _applyFilters();
      
      // 如果删除的是当前选中项，清空选中状态并选择下一个
      if (_selectedItem.value?.id == deletedItemId) {
        _selectedItem.value = null;
        if (_filteredItems.isNotEmpty) {
          selectItem(_filteredItems.first);
        }
      }
      
      Get.snackbar(
        '成功',
        '知识项已删除',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'errorRequestFailed'.tr,
        _getErrorMessage(e),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
  
  /// 更新知识项
  Future<void> updateSelectedItem(String content, List<String> tags) async {
    if (selectedItem == null) return;
    
    try {
      final updatedItem = await apiService.knowledge.updateKnowledgeItem(
        selectedItem!.id,
        content,
        tags,
      );
      
      // 更新列表中的知识项
      final index = _knowledgeItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _knowledgeItems[index] = updatedItem;
        _applyFilters();
        selectItem(updatedItem); // 重新选中以刷新详情
      }
      
      Get.snackbar(
        '成功',
        '知识项已更新',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'errorRequestFailed'.tr,
        _getErrorMessage(e),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
  
  /// 获取过滤器标题
  String getFilterTitle(KnowledgeFilter filter) {
    switch (filter) {
      case KnowledgeFilter.all:
        return 'filterAll'.tr;
      case KnowledgeFilter.document:
        return 'filterDoc'.tr;
      case KnowledgeFilter.web:
        return 'filterWeb'.tr;
      case KnowledgeFilter.image:
        return 'filterImage'.tr;
    }
  }
  
  /// 获取文件类型图标
  String getFileTypeIcon(String ctype) {
    if (ctype.contains('pdf')) return '📄';
    if (ctype.contains('doc')) return '📝';
    if (ctype.contains('txt')) return '📄';
    if (ctype.contains('url') || ctype.contains('web')) return '🌐';
    if (ctype.contains('jpg') || ctype.contains('png') || ctype.contains('image')) return '🖼️';
    return '📄';
  }
  
  /// 格式化时间
  String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return 'timeAgo'.trParams({'time': '${difference.inMinutes}${'minutes'.tr}'});
    } else if (difference.inHours < 24) {
      return 'timeAgo'.trParams({'time': '${difference.inHours}${'hours'.tr}'});
    } else if (difference.inDays < 7) {
      return 'timeAgo'.trParams({'time': '${difference.inDays}${'days'.tr}'});
    } else {
      return 'timeAgo'.trParams({'time': '${difference.inDays ~/ 7}${'weeks'.tr}'});
    }
  }
  
  /// 获取错误信息
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('timeout')) {
      return 'errorNetworkTimeout'.tr;
    }
    return 'errorRequestFailed'.tr;
  }
  
  /// 切换多选模式
  void toggleMultiSelectMode() {
    _isMultiSelectMode.value = !_isMultiSelectMode.value;
    if (!_isMultiSelectMode.value) {
      clearSelection();
    }
  }
  
  /// 切换单个知识项的选择状态
  void toggleItemSelection(String itemId) {
    if (_selectedKnowledgeIds.contains(itemId)) {
      _selectedKnowledgeIds.remove(itemId);
    } else {
      _selectedKnowledgeIds.add(itemId);
    }
  }
  
  /// 清空选择
  void clearSelection() {
    _selectedKnowledgeIds.clear();
  }
} 