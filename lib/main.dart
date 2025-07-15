import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_share_receiver/flutter_share_receiver.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'routes/app_pages.dart';
import 'controllers/main_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/knowledge_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化GetStorage
  await GetStorage.init();
  
  // 初始化所有核心控制器
  Get.put(MainController());
  Get.put(AuthController());
  Get.put(KnowledgeController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    _initReceiveSharingIntent();
  }

  final MainController mainController = Get.find();
  final AuthController authController = Get.find();
  // final KnowledgeController knowledgeController = Get.find(); // 已在main中初始化

  /// 初始化分享意图监听
  Future<void> _initReceiveSharingIntent() async {
    // 监听应用在后台时分享的文件
    ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      _handleSharedFiles(value);
    }, onError: (err) {
      debugPrint("getMediaStream error: $err");
    });

    // 监听应用被关闭后，通过分享启动时携带的文件
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      _handleSharedFiles(value);
    });
  }

  /// 处理分享的文件
  void _handleSharedFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) return;

    final knowledgeController = Get.find<KnowledgeController>();
    final mainController = Get.find<MainController>();

    // 切换到知识库页面
    mainController.changeTab(NavigationTab.knowledge);

    // 循环上传所有文件
    for (var file in files) {
      knowledgeController.uploadFile(File(file.path));
    }

    // 清除意图，防止重复处理
    ReceiveSharingIntent.instance.reset();
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        title: 'SIU Assistant',
        debugShowCheckedModeBanner: false,
        
        // 国际化配置
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('en', 'US'),
        ],
        locale: mainController.locale,
        fallbackLocale: const Locale('zh', 'CN'),
        
        // GetX翻译
        translations: AppTranslations(),
        
        // 主题配置
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF007AFF),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF007AFF),
            brightness: Brightness.dark,
          ),
        ),
        themeMode: mainController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        
        // 首页配置 - 根据认证状态动态决定
        home: AuthInitializer(),
        getPages: AppPages.routes,
      );
    });
  }
}

/// 认证初始化器 - 在认证状态检查完成前显示启动画面
class AuthInitializer extends StatelessWidget {
  const AuthInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authController = AuthController.to;
      
      // 如果还在初始化中，显示启动画面
      if (authController.isInitializing) {
        return const SplashScreen();
      }
      
      // 初始化完成，根据认证状态跳转
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (authController.isAuthenticated) {
          Get.offAllNamed(Routes.home);
        } else {
          Get.offAllNamed(Routes.auth);
        }
      });
      
      // 在路由跳转期间显示启动画面
      return const SplashScreen();
    });
  }
}

/// 启动画面
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF007AFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 应用Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '咻',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 应用名称
            const Text(
              'SIU Assistant',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 应用副标题
            const Text(
              'AI 知识工作站',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // 加载指示器
            Obx(() {
              final authController = AuthController.to;
              
              return Column(
                children: [
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    authController.isInitializing ? '正在验证身份...' : '正在加载...',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_CN': {
      'appTitle': '咻咻小助理',
      'appSubtitle': 'AI 知识工作站',
      'navChat': 'AI 对话',
      'navKnowledge': '知识库',
      'navTimeline': '知识动态',
      'navSettings': '设置中心',
      'knowledgeTitle': '我的知识库',
      'searchKnowledge': '搜索知识...',
      'filterAll': '全部',
      'filterDoc': '文档',
      'filterWeb': '网页',
      'filterImage': '图片',
      'dropZoneTitle': '拖拽文件到此处快速添加到知识库',
      'dropZoneSubtitle': '支持 PDF、TXT、JPG、PNG、网页链接等',
      'uploadSuccess': '文件上传成功！AI正在处理中...',
      'uploadProcessing': '预计2-3分钟完成智能解析',
      'actionEdit': '编辑',
      'actionShare': '分享',
      'actionChatWithAI': '与AI对话',
      'aiSummaryTitle': 'AI智能摘要',
      'coreFramework': '核心框架',
      'keyInsights': '关键洞察',
      'practicalTools': '实践工具',
      'caseStudies': '案例研究',
      'chatHistory': '对话历史',
      'newChat': '新建对话',
      'chatInputPlaceholder': '输入你的问题...',
      'aiGreeting': '你好！我是你的AI知识助手。我可以帮你分析知识库中的内容，回答问题，或者协助你整理思路。有什么我可以帮助你的吗？',
      'timeAgo': '{time}前',
      'minutes': '分钟',
      'hours': '小时',
      'days': '天',
      'weeks': '周',
      'fileSize': '文件大小: {size}',
      'addedAt': '添加于 {date}',
      'errorNetworkTimeout': '网络连接超时',
      'errorRequestFailed': '请求失败',
      'errorAuthFailed': '认证失败',
      'loading': '加载中...',
      'noData': '暂无数据',
      'retry': '重试',
      'logout': '退出登录',
      'user': '用户',
    },
    'en_US': {
      'appTitle': 'SIU Assistant',
      'appSubtitle': 'AI Knowledge Workstation',
      'navChat': 'AI Chat',
      'navKnowledge': 'Knowledge Base',
      'navTimeline': 'Knowledge Timeline',
      'navSettings': 'Settings',
      'knowledgeTitle': 'My Knowledge Base',
      'searchKnowledge': 'Search knowledge...',
      'filterAll': 'All',
      'filterDoc': 'Documents',
      'filterWeb': 'Web',
      'filterImage': 'Images',
      'dropZoneTitle': 'Drag files here to quickly add to knowledge base',
      'dropZoneSubtitle': 'Supports PDF, TXT, JPG, PNG, web links, etc.',
      'uploadSuccess': 'File uploaded successfully! AI is processing...',
      'uploadProcessing': 'Estimated 2-3 minutes to complete intelligent analysis',
      'actionEdit': 'Edit',
      'actionShare': 'Share',
      'actionChatWithAI': 'Chat with AI',
      'aiSummaryTitle': 'AI Smart Summary',
      'coreFramework': 'Core Framework',
      'keyInsights': 'Key Insights',
      'practicalTools': 'Practical Tools',
      'caseStudies': 'Case Studies',
      'chatHistory': 'Chat History',
      'newChat': 'New Chat',
      'chatInputPlaceholder': 'Type your question...',
      'aiGreeting': 'Hello! I\'m your AI knowledge assistant. I can help you analyze content in your knowledge base, answer questions, or assist you in organizing your thoughts. How can I help you?',
      'timeAgo': '{time} ago',
      'minutes': 'minutes',
      'hours': 'hours',
      'days': 'days',
      'weeks': 'weeks',
      'fileSize': 'File size: {size}',
      'addedAt': 'Added at {date}',
      'errorNetworkTimeout': 'Network connection timeout',
      'errorRequestFailed': 'Request failed',
      'errorAuthFailed': 'Authentication failed',
      'loading': 'Loading...',
      'noData': 'No data',
      'retry': 'Retry',
      'logout': 'Logout',
      'user': 'User',
    },
  };
}
