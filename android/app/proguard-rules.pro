# 保留 Flutter 和 Dart 相关类
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.protobuf.** { *; }

# 保留网络请求库 Dio 的所有类
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# 保留 JSON 序列化相关类 (json_annotation 和 json_serializable)
-keep class com.google.gson.** { *; }
-keep class javax.annotation.** { *; }
-keep class json_annotation.** { *; }
-keep class **$$JsonClass { *; }

# 保留 GetX 状态管理库的所有类
-keep class **.get.** { *; }

# 保留共享偏好相关类 (shared_preferences)
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# 保留国际化支持类 (intl)
-keep class **.intl.** { *; }

# 保留 UUID 工具库的所有类
-keep class java.util.UUID { *; }

# 保留文件选择器（file_picker）的所有类
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# 保留 WebSocket 客户端的相关类
-keep class **.web_socket_client.** { *; }

# 保留 URL Launcher 插件相关类
-keep class io.flutter.plugins.urllauncher.** { *; }

# 保留 Logger 日志库的所有类
-keep class com.orhanobut.logger.** { *; }

# 保留 cached_network_image 的相关类
-keep class com.baseflow.cached_network_image.** { *; }

# 保留 SVG 支持相关类 (flutter_svg)
-keep class com.example.flutter_svg.** { *; }

# 防止裁剪带主方法的类（避免与 Flutter 入口文件冲突）
-keep public class * extends io.flutter.app.FlutterApplication
-keep public class * extends io.flutter.embedding.android.FlutterActivity
-keep public class * extends io.flutter.embedding.android.FlutterFragmentActivity

# 保留注解信息
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes Exceptions

# 防止裁剪泛型类型
-keepattributes Signature
-keepattributes *Annotation*

# 禁用 R8 的代码优化（如果需要调试问题）
-dontoptimize

# 日志相关规则（仅在调试时启用）
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}
