import 'package:get/get.dart';
import '../pages/home/home_page.dart';
import '../pages/auth/auth_page.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.auth;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: Routes.auth,
      page: () => const AuthPage(),
    ),
  ];
} 