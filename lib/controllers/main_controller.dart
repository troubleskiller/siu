import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

enum NavigationTab {
  chat,
  knowledge,
  timeline,
  settings,
}

class MainController extends GetxController {
  static MainController get to => Get.find();
  
  // 存储实例
  final _storage = GetStorage();
  
  // 当前选中的导航标签
  final _currentTab = NavigationTab.knowledge.obs;
  NavigationTab get currentTab => _currentTab.value;
  
  // 语言设置
  final _locale = const Locale('zh', 'CN').obs;
  Locale get locale => _locale.value;
  
  // 主题设置
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;
  
  // 用户信息
  final _userName = '用户'.obs;
  String get userName => _userName.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }
  
  /// 切换导航标签
  void changeTab(NavigationTab tab) {
    _currentTab.value = tab;
  }
  
  /// 切换语言
  void changeLanguage(String languageCode) {
    final newLocale = Locale(languageCode);
    _locale.value = newLocale;
    Get.updateLocale(newLocale);
    _storage.write('language', languageCode);
  }
  
  /// 切换主题
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _storage.write('isDarkMode', _isDarkMode.value);
  }
  
  /// 设置用户名
  void setUserName(String name) {
    _userName.value = name;
    _storage.write('userName', name);
  }
  
  /// 加载设置
  void _loadSettings() {
    // 加载语言设置
    final savedLanguage = _storage.read('language') ?? 'zh';
    _locale.value = Locale(savedLanguage);
    
    // 加载主题设置
    _isDarkMode.value = _storage.read('isDarkMode') ?? false;
    
    // 加载用户名
    _userName.value = _storage.read('userName') ?? '用户';
  }
  
  /// 获取导航图标
  String getNavigationIcon(NavigationTab tab) {
    switch (tab) {
      case NavigationTab.chat:
        return '💬';
      case NavigationTab.knowledge:
        return '📚';
      case NavigationTab.timeline:
        return '📊';
      case NavigationTab.settings:
        return '⚙️';
    }
  }
  
  /// 获取导航标题
  String getNavigationTitle(NavigationTab tab) {
    switch (tab) {
      case NavigationTab.chat:
        return 'navChat'.tr;
      case NavigationTab.knowledge:
        return 'navKnowledge'.tr;
      case NavigationTab.timeline:
        return 'navTimeline'.tr;
      case NavigationTab.settings:
        return 'navSettings'.tr;
    }
  }
} 