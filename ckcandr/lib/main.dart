import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/views/authentications/login_screen.dart';
import 'package:ckcandr/views/authentications/forgot_password_screen.dart';
import 'package:ckcandr/views/admin/dashboard_screen.dart';
import 'package:ckcandr/views/giangvien/dashboard_screen.dart';
import 'package:ckcandr/views/sinhvien/dashboard_screen.dart';
import 'package:ckcandr/views/sinhvien/nhom_hoc_phan_screen.dart';
import 'package:ckcandr/views/sinhvien/bai_kiem_tra_screen.dart';
import 'package:ckcandr/views/sinhvien/danh_muc_mon_hoc_screen.dart';
import 'package:ckcandr/views/sinhvien/thong_bao_screen.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/views/sinhvien/danh_muc_bai_kiem_tra_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();
  final authService = container.read(authServiceProvider);
  
  // Kiểm tra nếu người dùng đã đăng nhập trước đó
  final user = await authService.getCurrentUser();
  
  runApp(
    ProviderScope(
      parent: container,
      child: MyApp(initialUser: user),
    ),
  );
}

final _routerProvider = Provider<GoRouter>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  
  return GoRouter(
    initialLocation: currentUser == null ? '/login' : _getInitialRoute(currentUser.role),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Admin routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      // Giảng viên routes
      GoRoute(
        path: '/giangvien/dashboard',
        builder: (context, state) => const GiangVienDashboardScreen(),
      ),
      // Sinh viên routes
      GoRoute(
        path: '/sinhvien/dashboard',
        builder: (context, state) => const SinhVienDashboardScreen(),
      ),
      // Thêm route nhóm học phần cho sinh viên
      GoRoute(
        path: '/sinhvien/nhom-hoc-phan',
        builder: (context, state) => const SinhVienDashboardScreen(
          child: NhomHocPhanScreen(),
        ),
      ),
      // Thêm route danh mục bài kiểm tra cho sinh viên
      GoRoute(
        path: '/sinhvien/danh-muc-bai-kiem-tra',
        builder: (context, state) => const SinhVienDashboardScreen(
          child: DanhMucBaiKiemTraScreen(),
        ),
      ),
      // Thêm route bài kiểm tra cho sinh viên
      GoRoute(
        path: '/sinhvien/bai-kiem-tra',
        builder: (context, state) => const BaiKiemTraScreen(),
      ),
      // Thêm route danh mục môn học cho sinh viên
      GoRoute(
        path: '/sinhvien/danh-muc-mon-hoc',
        builder: (context, state) => const SinhVienDashboardScreen(
          child: DanhMucMonHocScreen(),
        ),
      ),
      // Thêm route thông báo cho sinh viên
      GoRoute(
        path: '/sinhvien/thong-bao',
        builder: (context, state) => const SinhVienDashboardScreen(
          child: ThongBaoScreen(),
        ),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = currentUser != null;
      final isLoginRoute = state.matchedLocation == '/login';
      final isForgotPasswordRoute = state.matchedLocation == '/forgot-password';
      
      // Nếu không đăng nhập và không đang ở trang đăng nhập hoặc quên mật khẩu
      if (!isLoggedIn && !isLoginRoute && !isForgotPasswordRoute) {
        return '/login';
      }
      
      // Nếu đã đăng nhập và đang ở trang đăng nhập hoặc quên mật khẩu
      if (isLoggedIn && (isLoginRoute || isForgotPasswordRoute)) {
        return _getInitialRoute(currentUser.role);
      }
      
      // Kiểm tra quyền truy cập route
      final location = state.matchedLocation;
      if (isLoggedIn) {
        if (location.startsWith('/admin/') && currentUser.role != UserRole.admin) {
          return _getInitialRoute(currentUser.role);
        }
        if (location.startsWith('/giangvien/') && currentUser.role != UserRole.giangVien) {
          return _getInitialRoute(currentUser.role);
        }
        if (location.startsWith('/sinhvien/') && currentUser.role != UserRole.sinhVien) {
          return _getInitialRoute(currentUser.role);
        }
      }
      
      // Không cần redirect
      return null;
    },
  );
});

String _getInitialRoute(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return '/admin/dashboard';
    case UserRole.giangVien:
      return '/giangvien/dashboard';
    case UserRole.sinhVien:
      return '/sinhvien/dashboard';
    default:
      return '/login';
  }
}

class MyApp extends ConsumerStatefulWidget {
  final User? initialUser;
  
  const MyApp({super.key, this.initialUser});
  
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    if (widget.initialUser != null) {
      // Cập nhật Provider với user đã đăng nhập
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentUserProvider.notifier).state = widget.initialUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(_routerProvider);
    
    return MaterialApp.router(
      title: 'CKC Quiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
