/// API相关常量
class ApiConstants {
  // ==================== 基础配置 ====================
  static const String baseUrl = 'YOUR_API_BASE_URL'; // 替换为实际的API地址
  
  // ==================== 超时配置 ====================
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // ==================== 请求头 ====================
  static const String contentTypeKey = 'Content-Type';
  static const String acceptKey = 'Accept';
  static const String authorizationKey = 'Authorization';
  static const String rangeKey = 'Range';
  
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormUrlencoded = 'application/x-www-form-urlencoded';
  static const String contentTypeFormData = 'multipart/form-data';
  static const String bearerPrefix = 'Bearer ';
  
  // ==================== 本地存储键值 ====================
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  
  // ==================== HTTP状态码 ====================
  static const int statusUnauthorized = 401;
  static const int statusNotFound = 404;
  static const int statusForbidden = 403;
  static const int statusInternalServerError = 500;
  
  // ==================== 认证相关端点 ====================
  static const String authWechatPhoneLogin = '/auth/wechat_phone_login';
  static const String authBindWechatAccount = '/auth/bind_wechat_account';
  static const String authToken = '/auth/token';
  static const String authTokenRefresh = '/auth/token/refresh';
  static const String authUsersMe = '/auth/users/me';
  static const String authUser = '/auth/user';
  
  // ==================== 聊天相关端点 ====================
  static const String chatSession = '/chat/session';
  static const String chatCurrentSession = '/chat/current_session';
  static const String itemChatNewSession = '/item_chat/new_session';
  static const String itemChatMessagesBySessionId = '/item_chat/messages/by_session_id';
  static const String itemChatQuery = '/item_chat/query';
  
  // ==================== 知识管理相关端点 ====================
  static const String knowledgeUploadFile = '/collected_information/upload_file';
  static const String knowledgeImportFile = '/collected_information/import_file';
  static const String knowledgeFileInfo = '/collected_information/file_info';
  static const String knowledgeItemsByCursor = '/collected_information/items_by_cursor';
  static const String knowledgeItemsWithShortSummaryByCursor = '/collected_information/items_with_short_summary_by_cursor';
  static const String knowledgeItemsWithBaseInformationByCursor = '/collected_information/items_with_base_information_by_cursor';
  static const String knowledgeItems = '/collected_information/items';
  static const String knowledgeTags = '/collected_information/tags';
  static const String knowledgeItem = '/collected_information/item';
  static const String knowledgeItemAdditionalInfoList = '/collected_information/item/addtional_info_list';
  static const String knowledgeItemAdditionalInfoListByField = '/collected_information/item/additional_info_list_by_field';
  static const String knowledgeDownload = '/collected_information/download';
  static const String knowledgeMedia = '/collected_information/media';
  static const String knowledgeMediaSignedUrl = '/collected_information/media';
  static const String knowledgeDownloadSignedUrl = '/collected_information/download';
  static const String knowledgeMediaWithSignature = '/collected_information/media-with-signature';
  static const String knowledgeDownloadWithSignature = '/collected_information/download-with-signature';
  static const String knowledgeItemsSum = '/collected_information/items/sum';
  
  // ==================== 签名URL相关 ====================
  static const String signedUrlSuffix = '/signed_url';
  
  // ==================== 请求参数名 ====================
  static const String paramSourceType = 'source_type';
  static const String paramToken = 'token';
  static const String paramStartId = 'start_id';
  static const String paramLimit = 'limit';
  static const String paramTags = 'tags';
  static const String paramFilterMode = 'filter_mode';
  static const String paramStartDate = 'start_date';
  static const String paramEndDate = 'end_date';
  static const String paramDirection = 'direction';
  static const String paramCtypes = 'ctypes';
  static const String paramCytpes = 'cytpes'; // 注意：API文档中的拼写
  static const String paramPage = 'page';
  static const String paramPageSize = 'page_size';
  static const String paramFieldName = 'field_name';
  static const String paramSignature = 'signature';
  static const String paramExpires = 'expires';
  
  // ==================== 表单字段名 ====================
  static const String fieldFile = 'file';
  static const String fieldOriginalFilename = 'original_filename';
  static const String fieldContent = 'content';
  static const String fieldTags = 'tags';
  
  // ==================== JSON字段名 ====================
  static const String jsonRefreshToken = 'refresh_token';
  static const String jsonAccessToken = 'access_token';
  static const String jsonGrantType = 'grant_type';
  static const String jsonClientId = 'client_id';
  static const String jsonClientSecret = 'client_secret';
  static const String jsonSessionId = 'session_id';
  static const String jsonSum = 'sum';
  
  // ==================== 默认值 ====================
  static const String defaultShortSummary = '总结正在赶来中';
  
  // ==================== 方向值 ====================
  static const String directionForward = 'forward';
  static const String directionBackward = 'backward';
  
  // ==================== 来源类型 ====================
  static const String sourceTypeApp = 'app';
  static const String sourceTypeWeb = 'web';
  
  // ==================== 错误消息 ====================
  static const String errorNetworkTimeout = '网络连接超时';
  static const String errorRequestCanceled = '请求已取消';
  static const String errorNetworkFailed = '网络连接失败';
  static const String errorUnknownNetwork = '未知网络错误';
  static const String errorRequestFailed = '请求失败';
  static const String errorAccessTokenNotFound = '未找到访问令牌';
  
  // ==================== 错误字段名 ====================
  static const String errorFieldMessage = 'message';
  static const String errorFieldDetail = 'detail';
  static const String errorFieldError = 'error';
} 