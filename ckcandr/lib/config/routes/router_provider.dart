import 'package:ckcandr/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:ckcandr/features/auth/presentation/pages/login_page.dart';
import 'package:ckcandr/features/cau_hoi/presentation/pages/cau_hoi_page.dart';
import 'package:ckcandr/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:ckcandr/features/de_thi/presentation/pages/de_thi_page.dart';
import 'package:ckcandr/features/lop_hoc_phan/presentation/pages/chi_tiet_lop_hoc_phan_page.dart';
import 'package:ckcandr/features/lop_hoc_phan/presentation/pages/lop_hoc_phan_page.dart';
import 'package:ckcandr/features/lop_hoc_phan/presentation/pages/them_lop_hoc_phan_page.dart';
import 'package:ckcandr/features/nguoi_dung/presentation/pages/nguoi_dung_page.dart';
import 'package:ckcandr/features/splash/presentation/pages/splash_page.dart';
import 'package:ckcandr/features/thong_bao/presentation/pages/thong_bao_page.dart';
import 'package:flutter/material.dart'; // Add this import
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add this import
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router_provider.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(RouterRef ref) {
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/forgot_password',
        name: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => DashboardPage(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: '/dashboard',
            name: AppRoutes.dashboard,
            builder: (context, state) => const DashboardContent(
                content: Text('Trang Tổng quan (chưa triển khai)')), // Default content
          ),
          GoRoute(
            path: '/lop_hoc_phan',
            name: AppRoutes.lopHocPhan,
            builder: (context, state) => const DashboardContent(
                content: LopHocPhanPage()), // Assuming LopHocPhanPage can be a direct child
            routes: [
              GoRoute(
                path: 'them_lop_hoc_phan',
                name: AppRoutes.themLopHocPhan,
                builder: (context, state) => const DashboardContent(
                    content: ThemLopHocPhanPage()),
              ),
              GoRoute(
                path: 'chi_tiet_lop_hoc_phan/:id', // Changed to ':id' for dynamic routing
                name: AppRoutes.chiTietLopHocPhan,
                builder: (context, state) {
                  final String? id = state.pathParameters['id'];
                  return DashboardContent(
                    content: ChiTietLopHocPhanPage(lopHocPhanId: id),
                  );
                },
              ),
            ],
          ),
          // Thêm các GoRoute khác cho từng tab của Dashboard
          GoRoute(
            path: '/cau_hoi',
            name: 'cauHoi',
            builder: (context, state) =>
                const DashboardContent(content: CauHoiPage()),
          ),
          GoRoute(
            path: '/de_thi',
            name: 'deThi',
            builder: (context, state) =>
                const DashboardContent(content: DeThiPage()),
          ),
          GoRoute(
            path: '/nguoi_dung',
            name: 'nguoiDung',
            builder: (context, state) =>
                const DashboardContent(content: NguoiDungPage()),
          ),
          GoRoute(
            path: '/bao_cao',
            name: 'baoCao', // Example for 'Báo cáo' tab
            builder: (context, state) =>
                const DashboardContent(content: Text('Trang Báo cáo')),
          ),
          GoRoute(
            path: '/thong_bao',
            name: 'thongBao',
            builder: (context, state) =>
                const DashboardContent(content: ThongBaoPage()),
          ),
        ],
      ),
    ],
    initialLocation: '/',
    debugLogDiagnostics: true,
  );
}

// Giữ lại AppRoutes để dễ sử dụng tên route thay vì string path
class AppRoutes {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String forgotPassword = 'forgotPassword';
  static const String dashboard = 'dashboard';
  static const String lopHocPhan = 'lopHocPhan';
  static const String themLopHocPhan = 'themLopHocPhan';
  static const String chiTietLopHocPhan = 'chiTietLopHocPhan';

  // Thêm các route name khác cho các tab Dashboard
  static const String cauHoi = 'cauHoi';
  static const String deThi = 'deThi';
  static const String nguoiDung = 'nguoiDung';
  static const String baoCao = 'baoCao';
  static const String thongBao = 'thongBao';
}

/// Helper widget to display content within the Dashboard layout.
/// This is needed because DashboardPage now contains a ShellRoute's child.
class DashboardContent extends StatelessWidget {
  const DashboardContent({required this.content, super.key});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return content;
  }
}