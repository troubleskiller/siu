# 智能小助理 API 网络层

基于 Dio 构建的 Flutter API 网络层，为智能小助理应用提供完整的网络请求功能。

## 功能特性

- 🔐 **完整的认证系统** - 支持OAuth2、微信登录、Token自动刷新
- 💬 **聊天管理** - 会话创建、知识对话、消息管理
- 📚 **知识管理** - 知识CRUD、文件上传下载、标签管理
- 🔄 **自动重试** - Token过期自动刷新并重试请求
- 🛡️ **错误处理** - 统一的异常处理和错误分类
- 📱 **易于使用** - 简洁的API设计和完整的类型安全
- 🎯 **常量管理** - 统一管理所有魔法值，避免硬编码

## 项目结构

```
lib/
├── constants/                # 常量定义
│   └── api_constants.dart    # API相关常量
├── models/                   # 数据模型
│   ├── auth_models.dart      # 认证相关模型
│   ├── chat_models.dart      # 聊天相关模型
│   ├── knowledge_models.dart # 知识管理模型
│   └── error_models.dart     # 错误处理模型
└── services/
    └── api/                  # API服务层
        ├── api_client.dart           # 基础API客户端
        ├── auth_api_service.dart     # 认证API服务
        ├── chat_api_service.dart     # 聊天API服务
        ├── knowledge_api_service.dart # 知识管理API服务
        └── api_service_manager.dart  # API服务管理器
```

## 安装配置

### 1. 添加依赖

在 `pubspec.yaml` 中添加以下依赖：

```yaml
dependencies:
  dio: ^5.3.4
  shared_preferences: ^2.2.2
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

### 2. 配置API地址

在 `lib/constants/api_constants.dart` 中修改基础URL：

```dart
static const String baseUrl = 'https://your-api-domain.com'; // 替换为实际的API地址
```

### 3. 生成代码

运行以下命令生成JSON序列化代码：

```bash
flutter packages pub run build_runner build
```

## 快速开始

### 基本使用

```dart
import 'package:your_app/services/api/api_service_manager.dart';
import 'package:your_app/constants/api_constants.dart';

// 使用全局API服务实例
final api = apiService;

// 认证
await api.auth.login(loginRequest);

// 聊天
final session = await api.chat.createSession(ApiConstants.sourceTypeApp);

// 知识管理
final items = await api.knowledge.getItemsByCursor();
```

### 认证功能

```dart
// 用户名密码登录
final loginRequest = OAuth2LoginRequest(
  username: 'your_username',
  password: 'your_password',
);
final token = await apiService.auth.login(loginRequest);

// 微信登录
final wechatRequest = WechatLoginRequest(
  code: 'wechat_code',
  encryptedData: 'encrypted_data',
  iv: 'iv_string',
);
final result = await apiService.auth.wechatPhoneLogin(wechatRequest);

// 获取用户信息
final user = await apiService.auth.getUserInfo();

// 检查登录状态
final isLoggedIn = await apiService.auth.isLoggedIn();

// 登出
await apiService.auth.logout();
```

### 聊天功能

```dart
// 创建聊天会话
final session = await apiService.chat.createSession(ApiConstants.sourceTypeApp);

// 创建知识对话
final itemChatSessionId = await apiService.chat.createItemChatSession([
  'item_id_1',
  'item_id_2',
]);

// 进行知识对话
final queryRequest = QueryRequest(
  sessionId: itemChatSessionId,
  query: '请介绍一下这些知识内容',
);
final response = await apiService.chat.queryItemChat(queryRequest);
```

### 知识管理

```dart
// 获取知识列表（游标分页）
final items = await apiService.knowledge.getItemsByCursor(
  limit: 20,
  direction: ApiConstants.directionForward,
);

// 创建知识
final itemId = await apiService.knowledge.createItem(
  content: '知识内容',
  tags: 'tag1,tag2',
);

// 获取知识详情
final item = await apiService.knowledge.getItem(itemId);

// 更新知识
final updateData = CollectedInformationItemUpdate(
  content: '更新后的内容',
  tags: ['tag1', 'tag2', 'tag3'],
);
final updatedItem = await apiService.knowledge.updateItem(itemId, updateData);

// 文件上传
final file = File('path/to/file.pdf');
final uploadResult = await apiService.knowledge.uploadFile(file, 'document.pdf');

// 获取签名URL
final signedUrl = await apiService.knowledge.getSignedMediaUrl(itemId);
```

## 常量管理

项目使用 `ApiConstants` 类统一管理所有常量，避免在代码中出现魔法值：

### 常量分类

- **基础配置**: 基础URL、超时时间等
- **HTTP相关**: 请求头、状态码、内容类型等
- **API端点**: 所有API路径统一管理
- **参数名称**: 请求参数、表单字段、JSON字段等
- **默认值**: 各种默认值设置
- **错误消息**: 统一的错误信息

### 使用示例

```dart
// 使用常量而不是魔法值
await apiService.chat.createSession(ApiConstants.sourceTypeApp);

// 而不是
await apiService.chat.createSession('app'); // ❌ 魔法值
```

## 错误处理

网络层提供了完善的错误处理机制：

```dart
try {
  final items = await apiService.knowledge.getItems();
} catch (e) {
  if (e is AuthException) {
    // 认证错误 - 需要重新登录
    print('认证失败: ${e.message}');
  } else if (e is ApiException) {
    // API错误 - 服务器返回错误
    print('API错误: ${e.message} (状态码: ${e.statusCode})');
    
    // 使用常量进行状态码判断
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
    }
  } else if (e is NetworkException) {
    // 网络错误 - 连接问题
    print('网络错误: ${e.message}');
  } else {
    // 其他未知错误
    print('未知错误: $e');
  }
}
```

## 自动Token管理

网络层自动处理Token的存储、刷新和重试：

- Token存储在本地SharedPreferences中
- 请求时自动添加Authorization头
- Token过期时自动刷新并重试原请求
- 刷新失败时自动清除Token

## API 端点覆盖

### 认证相关
- ✅ 微信小程序手机登录
- ✅ 绑定微信账号
- ✅ OAuth2登录
- ✅ 刷新Token
- ✅ 获取用户信息
- ✅ 创建用户

### 聊天相关
- ✅ 创建聊天session
- ✅ 获取当前session
- ✅ 创建知识对话
- ✅ 知识对话询问
- ✅ 获取会话消息

### 知识管理
- ✅ 文件上传/下载
- ✅ 知识列表获取（多种分页方式）
- ✅ 知识CRUD操作
- ✅ 标签管理
- ✅ 媒体文件处理
- ✅ 签名URL生成
- ✅ 额外信息管理

## 注意事项

1. **API地址配置**: 请确保在 `api_constants.dart` 中正确配置API基础URL
2. **代码生成**: 修改模型类后需要重新运行代码生成
3. **常量使用**: 避免在代码中使用魔法值，统一使用 `ApiConstants` 中定义的常量
4. **权限管理**: 某些API需要特定权限，请确保用户已正确认证
5. **文件大小**: 上传文件时注意大小限制
6. **网络状态**: 在网络不稳定环境下，建议添加重试机制

## 开发指南

### 添加新的API端点

1. 在 `api_constants.dart` 中添加相关常量
2. 在相应的模型文件中添加数据模型
3. 在对应的API服务类中添加方法
4. 运行代码生成更新序列化代码
5. 在示例文件中添加使用示例

### 自定义错误处理

可以在各个API服务类的 `_handleDioException` 方法中自定义错误处理逻辑。

### 扩展认证方式

可以在 `AuthApiService` 中添加新的认证方法，并相应更新Token管理逻辑。

### 添加新常量

在 `ApiConstants` 类中按分类添加新的常量，并在代码中引用：

```dart
// 在 api_constants.dart 中添加
static const String newApiEndpoint = '/new/endpoint';

// 在服务类中使用
await _apiClient.get(ApiConstants.newApiEndpoint);
```

## 许可证

[添加您的许可证信息]

## 贡献

欢迎提交 Issue 和 Pull Request！

## 更新日志

### v1.0.0
- 初始版本发布
- 完整的API端点覆盖
- 自动Token管理
- 完善的错误处理
- 统一的常量管理
