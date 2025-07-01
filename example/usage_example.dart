import 'dart:io';
import '../lib/services/api/api_service_manager.dart';
import '../lib/models/auth_models.dart';
import '../lib/models/chat_models.dart';
import '../lib/models/knowledge_models.dart';
import '../lib/models/error_models.dart';
import '../lib/constants/api_constants.dart';

/// 使用示例
class ApiUsageExample {
  
  /// 认证相关示例
  static Future<void> authExamples() async {
    print('=== 认证功能示例 ===');
    
    try {
      // 1. 用户名密码登录
      final loginRequest = OAuth2LoginRequest(
        username: 'your_username',
        password: 'your_password',
      );
      
      final token = await apiService.auth.login(loginRequest);
      print('登录成功: ${token.accessToken}');
      
      // 2. 获取用户信息
      final user = await apiService.auth.getUserInfo();
      print('用户信息: ${user.username}');
      
      // 3. 微信登录
      final wechatRequest = WechatLoginRequest(
        code: 'wechat_code',
        encryptedData: 'encrypted_data',
        iv: 'iv_string',
      );
      
      final wechatResult = await apiService.auth.wechatPhoneLogin(wechatRequest);
      print('微信登录结果: $wechatResult');
      
      // 4. 检查登录状态
      final isLoggedIn = await apiService.auth.isLoggedIn();
      print('是否已登录: $isLoggedIn');
      
    } catch (e) {
      if (e is AuthException) {
        print('认证错误: ${e.message}');
      } else if (e is ApiException) {
        print('API错误: ${e.message} (状态码: ${e.statusCode})');
      } else if (e is NetworkException) {
        print('网络错误: ${e.message}');
      } else {
        print('未知错误: $e');
      }
    }
  }
  
  /// 聊天相关示例
  static Future<void> chatExamples() async {
    print('\n=== 聊天功能示例 ===');
    
    try {
      // 1. 创建聊天会话
      final session = await apiService.chat.createSession(ApiConstants.sourceTypeApp);
      print('创建会话成功: ${session.sessionId}');
      
      // 2. 获取当前会话
      final currentSession = await apiService.chat.getCurrentSession(ApiConstants.sourceTypeApp);
      print('当前会话: ${currentSession.sessionId}');
      
      // 3. 创建知识对话会话
      final itemChatSessionId = await apiService.chat.createItemChatSession([
        'item_id_1',
        'item_id_2',
      ]);
      print('知识对话会话创建成功: $itemChatSessionId');
      
      // 4. 进行知识对话询问
      final queryRequest = QueryRequest(
        sessionId: itemChatSessionId,
        query: '请介绍一下这些知识内容',
      );
      
      final queryResult = await apiService.chat.queryItemChat(queryRequest);
      print('询问结果: $queryResult');
      
      // 5. 获取会话消息
      final messages = await apiService.chat.getMessagesBySessionId(itemChatSessionId);
      print('会话消息: $messages');
      
    } catch (e) {
      print('聊天功能错误: $e');
    }
  }
  
  /// 知识管理相关示例
  static Future<void> knowledgeExamples() async {
    print('\n=== 知识管理功能示例 ===');
    
    try {
      // 1. 获取知识列表（游标分页）
      final itemsCursor = await apiService.knowledge.getItemsByCursor(
        limit: 20,
        direction: ApiConstants.directionForward,
      );
      print('知识列表数量: ${itemsCursor.totalItems}');
      
      // 2. 获取知识列表（页码分页）
      final itemsPage = await apiService.knowledge.getItems(
        page: 1,
        pageSize: 20,
      );
      print('分页知识列表: ${itemsPage.items.length}');
      
      // 3. 获取带摘要的知识列表
      final itemsWithSummary = await apiService.knowledge.getItemsWithShortSummaryByCursor(
        limit: 10,
      );
      print('带摘要的知识列表: ${itemsWithSummary.items.length}');
      
      // 4. 获取全部标签
      final tags = await apiService.knowledge.getTags();
      print('标签列表: $tags');
      
      // 5. 创建知识项
      final itemId = await apiService.knowledge.createItem(
        content: '这是一个测试知识内容',
        tags: 'tag1,tag2',
      );
      print('创建知识成功: $itemId');
      
      // 6. 获取知识详情
      final item = await apiService.knowledge.getItem(itemId);
      print('知识详情: ${item.content}');
      
      // 7. 更新知识
      final updateData = CollectedInformationItemUpdate(
        content: '更新后的内容',
        tags: ['tag1', 'tag2', 'tag3'],
      );
      
      final updatedItem = await apiService.knowledge.updateItem(itemId, updateData);
      print('更新后的知识: ${updatedItem.content}');
      
      // 8. 文件上传示例
      // final file = File('path/to/your/file.pdf');
      // final uploadResult = await apiService.knowledge.uploadFile(
      //   file,
      //   'example.pdf',
      // );
      // print('文件上传成功: ${uploadResult.fileId}');
      
      // 9. 获取文件信息
      // final fileInfo = await apiService.knowledge.getFileInfo(uploadResult.fileId);
      // print('文件信息: ${fileInfo.filename}');
      
      // 10. 获取签名URL
      final signedUrl = await apiService.knowledge.getSignedMediaUrl(itemId);
      print('签名URL: ${signedUrl.url}');
      
      // 11. 获取知识数量统计
      final count = await apiService.knowledge.getItemsCount();
      print('知识总数: $count');
      
      // 12. 删除知识
      final deleteResult = await apiService.knowledge.deleteItem(itemId);
      print('删除结果: $deleteResult');
      
    } catch (e) {
      print('知识管理功能错误: $e');
    }
  }
  
  /// 文件操作示例
  static Future<void> fileExamples() async {
    print('\n=== 文件操作示例 ===');
    
    try {
      // 注意：以下示例需要实际的文件路径
      // final file = File('path/to/your/document.pdf');
      // 
      // // 1. 上传文件
      // final uploadResult = await apiService.knowledge.uploadFile(
      //   file,
      //   'document.pdf',
      // );
      // print('文件上传成功: ${uploadResult.fileId}');
      // 
      // // 2. 下载文件
      // final downloadResponse = await apiService.knowledge.downloadFile(itemId);
      // final bytes = downloadResponse.data as List<int>;
      // 
      // // 保存到本地
      // final downloadedFile = File('downloaded_file.pdf');
      // await downloadedFile.writeAsBytes(bytes);
      // print('文件下载成功');
      // 
      // // 3. 获取媒体文件（如果是图片、视频）
      // final mediaResponse = await apiService.knowledge.getMediaFile(itemId);
      // print('媒体文件获取成功');
      
    } catch (e) {
      print('文件操作错误: $e');
    }
  }
  
  /// 错误处理示例
  static Future<void> errorHandlingExample() async {
    print('\n=== 错误处理示例 ===');
    
    try {
      // 故意调用一个不存在的知识项
      await apiService.knowledge.getItem('non_existent_id');
    } catch (e) {
      if (e is AuthException) {
        print('认证失败，需要重新登录');
        // 处理认证错误，比如跳转到登录页
      } else if (e is ApiException) {
        print('API请求失败: ${e.message}');
        print('状态码: ${e.statusCode}');
        
        switch (e.statusCode) {
          case ApiConstants.statusNotFound:
            print('资源不存在');
            break;
          case ApiConstants.statusForbidden:
            print('无权限访问');
            break;
          case ApiConstants.statusInternalServerError:
            print('服务器内部错误');
            break;
          default:
            print('其他API错误');
        }
      } else if (e is NetworkException) {
        print('网络连接失败: ${e.message}');
        // 提示用户检查网络连接
      } else {
        print('未知错误: $e');
      }
    }
  }
}

/// 主函数示例
void main() async {
  print('智能小助理API使用示例');
  
  // 运行各种示例
  await ApiUsageExample.authExamples();
  await ApiUsageExample.chatExamples();
  await ApiUsageExample.knowledgeExamples();
  await ApiUsageExample.fileExamples();
  await ApiUsageExample.errorHandlingExample();
  
  print('\n示例运行完成！');
} 