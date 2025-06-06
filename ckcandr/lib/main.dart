import 'package:ckcandr/core/constants/app_constants.dart';
import 'package:ckcandr/services/auth_service.dart' hide currentUserProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/views/authentications/login_screen.dart';
import 'package:ckcandr/views/authentications/forgot_password_screen.dart';
import 'package:ckcandr/views/admin/dashboard_screen.dart';
import 'package:ckcandr/views/giangvien/dashboard_screen.dart';
import 'package:ckcandr/views/sinhvien/dashboard_screen.dart';
import 'package:ckcandr/views/sinhvien/nhom_hoc_phan_screen.dart';
import 'package:ckcandr/views/sinhvien/bai_kiem_tra_screen.dart';
import 'package:ckcandr/views/sinhvien/danh_muc_mon_hoc_screen.dart';
import 'package:ckcandr/views/sinhvien/thong_bao_screen.dart';
import 'package:ckcandr/views/sinhvien/danh_muc_bai_kiem_tra_screen.dart';
import 'package:ckcandr/providers/theme_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'dart:async';

// Provider for shared preferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Should be overriden in main');
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  
  final container = ProviderContainer();
  final authService = container.read(authServiceProvider);
  
  // Kiểm tra nếu người dùng đã đăng nhập trước đó
  final user = await authService.getCurrentUser();
  
  // Đọc theme mode từ SharedPreferences nếu có
  // Đảm bảo có giá trị mặc định cho isDarkMode
  if (!sharedPreferences.containsKey('isDarkMode')) {
    sharedPreferences.setBool('isDarkMode', false);
  }
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: MyApp(initialUser: user),
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final userNotifier = ref.read(currentUserControllerProvider.notifier);
  
  return GoRouter(
    initialLocation: currentUser == null ? '/login' : _getInitialRoute(currentUser.quyen),
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
        path: '/admin',
        redirect: (context, state) => '/admin/dashboard',
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      // Giảng viên routes
      GoRoute(
        path: '/giangvien',
        builder: (context, state) => const GiangVienDashboardScreen(),
      ),
      GoRoute(
        path: '/giangvien/dashboard',
        builder: (context, state) => const GiangVienDashboardScreen(),
      ),
      GoRoute(
        path: '/giangvien/hocphan',
        builder: (context, state) => const GiangVienDashboardScreen(),
      ),
      GoRoute(
        path: '/giangvien/cauhoi',
        builder: (context, state) => const GiangVienDashboardScreen(),
      ),
      GoRoute(
        path: '/giangvien/monhoc',
        builder: (context, state) => const GiangVienDashboardScreen(),
      ),
      GoRoute(
        path: '/giangvien/kiemtra',
        builder: (context, state) => const GiangVienDashboardScreen(),
      ),
      GoRoute(
        path: '/giangvien/thongbao',
        builder: (context, state) => const GiangVienDashboardScreen(),
      ),
      // Sinh viên routes
      GoRoute(
        path: '/sinhvien',
        builder: (context, state) => const SinhVienDashboardScreen(),
      ),
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
        return _getInitialRoute(currentUser.quyen);
      }
      
      // Kiểm tra quyền truy cập route
      final location = state.matchedLocation;
      if (isLoggedIn) {
        if (location.startsWith('/admin') && currentUser.quyen != UserRole.admin) {
          return _getInitialRoute(currentUser.quyen);
        }
        if (location.startsWith('/giangvien') && currentUser.quyen != UserRole.giangVien) {
          return _getInitialRoute(currentUser.quyen);
        }
        if (location.startsWith('/sinhvien') && currentUser.quyen != UserRole.sinhVien) {
          return _getInitialRoute(currentUser.quyen);
        }
      }
      
      // Không cần redirect
      return null;
    },
    refreshListenable: GoRouterRefreshStream(userNotifier.stream),
  );
});

String _getInitialRoute(UserRole quyen) {
  switch (quyen) {
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
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
      ),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

// Lớp để lắng nghe sự thay đổi của stream và refresh router
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
