import 'package:ckcandr/core/constants/app_constants.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ckcandr/views/giangvien/components/custom_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/views/authentications/login_screen.dart';
import 'package:ckcandr/views/authentications/forgot_password_screen.dart';
import 'package:ckcandr/views/admin/dashboard_screen.dart';
import 'package:ckcandr/views/giangvien/dashboard_screen.dart';
import 'package:ckcandr/views/sinhvien/dashboard_screen.dart';

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
  final savedThemeMode = sharedPreferences.getString('theme_mode');
  final initialThemeMode = savedThemeMode == 'dark' 
      ? ThemeMode.dark 
      : ThemeMode.light;
  
  runApp(
    ProviderScope(
      parent: container,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        // Khởi tạo themeProvider với giá trị đã lưu
        themeProvider.overrideWith((ref) => initialThemeMode),
      ],
      child: MyApp(initialUser: user),
    ),
  );
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
    
    // Lưu theme mode mỗi khi thay đổi
    ref.listen(themeProvider, (previous, next) {
      if (previous != next) {
        final prefs = ref.read(sharedPreferencesProvider);
        prefs.setString('theme_mode', next == ThemeMode.dark ? 'dark' : 'light');
      }
    });
    
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
      routerConfig: _buildRouter(),
    );
  }
  
  GoRouter _buildRouter() {
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
          path: '/sinhvien/dashboard',
          builder: (context, state) => const SinhVienDashboardScreen(),
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
  }
  
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
}
