import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/main_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = MainController.to;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'navSettings'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          
          // 语言设置
          _SettingsSection(
            title: '语言设置',
            children: [
              Obx(() {
                return Row(
                  children: [
                    const Text('界面语言：'),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: mainController.locale.languageCode,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          mainController.changeLanguage(newValue);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'zh',
                          child: Text('中文'),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 主题设置
          _SettingsSection(
            title: '主题设置',
            children: [
              Obx(() {
                return SwitchListTile(
                  title: const Text('深色模式'),
                  subtitle: const Text('开启后界面将使用深色主题'),
                  value: mainController.isDarkMode,
                  onChanged: (_) => mainController.toggleTheme(),
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 用户设置
          _SettingsSection(
            title: '用户设置',
            children: [
              Row(
                children: [
                  const Text('用户名：'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController()
                        ..text = mainController.userName,
                      onSubmitted: mainController.setUserName,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 关于信息
          _SettingsSection(
            title: '关于',
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline),
                title: Text('咻咻小助理'),
                subtitle: Text('版本 1.0.0'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.description_outlined),
                title: Text('使用说明'),
                subtitle: Text('查看应用使用指南'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.privacy_tip_outlined),
                title: Text('隐私政策'),
                subtitle: Text('了解我们如何保护您的隐私'),
              ),
            ],
          ),
          
          const Spacer(),
          
          // 底部按钮
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.find<MainController>().changeTab(NavigationTab.knowledge);
                },
                child: const Text('返回知识库'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  // 重置设置
                  Get.dialog(
                    AlertDialog(
                      title: const Text('重置设置'),
                      content: const Text('确定要重置所有设置吗？'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            // 重置逻辑
                            mainController.changeLanguage('zh');
                            mainController.setUserName('用户');
                            Get.back();
                            Get.snackbar(
                              '设置重置',
                              '设置已重置为默认值',
                              snackPosition: SnackPosition.TOP,
                            );
                          },
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('重置设置'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
} 