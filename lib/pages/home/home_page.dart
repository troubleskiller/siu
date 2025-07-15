import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/knowledge_controller.dart';
import '../../controllers/chat_controller.dart';
import 'widgets/sidebar.dart';
import 'widgets/knowledge_view.dart';
import 'widgets/chat_view.dart';
import 'widgets/timeline_view.dart';
import 'widgets/settings_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化控制器
    Get.put(MainController());
    Get.put(KnowledgeController());
    Get.put(ChatController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                // 左侧导航栏
                const Sidebar(),
                
                // 主内容区
                Expanded(
                  child: Obx(() {
                    final mainController = MainController.to;
                    switch (mainController.currentTab) {
                      case NavigationTab.chat:
                        return const ChatView();
                      case NavigationTab.knowledge:
                        return const KnowledgeView();
                      case NavigationTab.timeline:
                        return const TimelineView();
                      case NavigationTab.settings:
                        return const SettingsView();
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 