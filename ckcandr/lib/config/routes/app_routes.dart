import 'package:ckcandr/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:ckcandr/features/auth/presentation/pages/login_page.dart';
import 'package:ckcandr/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:ckcandr/features/lop_hoc_phan/presentation/pages/chi_tiet_lop_hoc_phan_page.dart';
import 'package:ckcandr/features/lop_hoc_phan/presentation/pages/lop_hoc_phan_page.dart';
import 'package:ckcandr/features/lop_hoc_phan/presentation/pages/them_lop_hoc_phan_page.dart';
import 'package:ckcandr/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot_password';
  static const String dashboard = '/dashboard';
  static const String lopHocPhan = '/lop_hoc_phan';
  static const String themLopHocPhan = '/them_lop_hoc_phan';
  static const String chiTietLopHocPhan = '/chi_tiet_lop_hoc_phan'; // Nên truyền ID lớp

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case lopHocPhan:
        return MaterialPageRoute(builder: (_) => const LopHocPhanPage());
      case themLopHocPhan:
        return MaterialPageRoute(builder: (_) => const ThemLopHocPhanPage());
      case chiTietLopHocPhan:
        // Ví dụ: final int lopHocPhanId = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => const ChiTietLopHocPhanPage(/* lopHocPhanId: lopHocPhanId */));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 