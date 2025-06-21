import 'package:ckcandr/core/constants/app_constants.dart';
import 'package:ckcandr/core/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/views/authentications/login_screen.dart';
import 'package:ckcandr/views/authentications/forgot_password_screen.dart';
import 'package:ckcandr/views/admin/dashboard_screen.dart';
import 'package:ckcandr/views/giangvien/dashboard_screen.dart';
import 'package:ckcandr/views/sinhvien/dashboard_screen.dart';
import 'package:ckcandr/views/sinhvien/bai_kiem_tra_screen.dart';
import 'package:ckcandr/screens/user_profile_screen.dart';
import 'package:ckcandr/providers/theme_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:ckcandr/services/http_client_service.dart';
import 'dart:async';

// Provider for shared preferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Should be overriden in main');
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  // Đọc theme mode từ SharedPreferences nếu có
  // Đảm bảo có giá trị mặc định cho isDarkMode
  if (!sharedPreferences.containsKey('isDarkMode')) {
    sharedPreferences.setBool('isDarkMode', false);
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ...AppProviders.overrides,
      ],
      child: const MyApp(),
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final userNotifier = ref.read(currentUserControllerProvider.notifier);

  return GoRouter(
    initialLocation: '/login', // Start with login, will redirect if authenticated
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
        builder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          int? initialTab;
          if (tabParam != null) {
            initialTab = int.tryParse(tabParam);
            debugPrint('🔄 SinhVien route with tab parameter: $tabParam -> $initialTab');
          } else {
            debugPrint('🔄 SinhVien route without tab parameter');
          }
          return SinhVienDashboardScreen(initialTab: initialTab);
        },
      ),
      GoRoute(
        path: '/sinhvien/dashboard',
        builder: (context, state) => const SinhVienDashboardScreen(),
      ),
      // Thêm route nhóm học phần cho sinh viên
      GoRoute(
        path: '/sinhvien/nhom-hoc-phan',
        builder: (context, state) => const SinhVienDashboardScreen(),
      ),
      // Thêm route danh mục bài kiểm tra cho sinh viên
      GoRoute(
        path: '/sinhvien/danh-muc-bai-kiem-tra',
        builder: (context, state) => const SinhVienDashboardScreen(),
      ),
      // Thêm route bài kiểm tra cho sinh viên
      GoRoute(
        path: '/sinhvien/bai-kiem-tra',
        builder: (context, state) => const BaiKiemTraScreen(),
      ),
      // Thêm route danh mục môn học cho sinh viên
      GoRoute(
        path: '/sinhvien/danh-muc-mon-hoc',
        builder: (context, state) => const SinhVienDashboardScreen(),
      ),
      // Thêm route thông báo cho sinh viên
      GoRoute(
        path: '/sinhvien/thong-bao',
        builder: (context, state) => const SinhVienDashboardScreen(),
      ),
      // Profile route (shared by all roles)
      GoRoute(
        path: '/profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = currentUser != null;
      final isLoginRoute = state.matchedLocation == '/login';
      final isForgotPasswordRoute = state.matchedLocation == '/forgot-password';
      final location = state.matchedLocation;

      // For web: Always require explicit login (security requirement)
      // For mobile: Allow persistent login
      final isWeb = kIsWeb;

      // If not logged in and not on auth routes
      if (!isLoggedIn && !isLoginRoute && !isForgotPasswordRoute) {
        return '/login';
      }

      // If logged in and on auth routes
      if (isLoggedIn && (isLoginRoute || isForgotPasswordRoute)) {
        // For web: Don't auto-redirect from login (user must explicitly navigate)
        if (isWeb && isLoginRoute) {
          return null; // Stay on login page
        }
        // For mobile: Auto-redirect to dashboard
        return _getInitialRoute(currentUser.quyen);
      }

      // Check role-based access
      if (isLoggedIn) {
        // Redirect to correct dashboard if accessing wrong role area
        if (location.startsWith('/admin') && currentUser.quyen != UserRole.admin) {
          return _getInitialRoute(currentUser.quyen);
        }
        if (location.startsWith('/giangvien') && currentUser.quyen != UserRole.giangVien) {
          return _getInitialRoute(currentUser.quyen);
        }
        if (location.startsWith('/sinhvien') && currentUser.quyen != UserRole.sinhVien) {
          return _getInitialRoute(currentUser.quyen);
        }

        // Handle root paths - redirect to appropriate dashboard
        // But preserve query parameters for /sinhvien route
        if (location == '/admin' || location == '/giangvien') {
          return _getInitialRoute(currentUser.quyen);
        }
        if (location == '/sinhvien' && state.uri.queryParameters.isEmpty) {
          return _getInitialRoute(currentUser.quyen);
        }
      }

      // No redirect needed
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
      return '/giangvien';
    case UserRole.sinhVien:
      return '/sinhvien';
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // Initialize providers and check for persistent login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        AppProviders.initializeProviders(ref);
        _initializePersistentLogin();
      } catch (e) {
        debugPrint('Error initializing providers: $e');
      }
    });
  }

  /// Initialize persistent login for mobile app
  Future<void> _initializePersistentLogin() async {
    try {
      // For web: Always start at login (security requirement)
      if (kIsWeb) {
        return;
      }

      // For mobile: Check for existing valid session
      final authService = ref.read(authServiceProvider);
      final userNotifier = ref.read(currentUserControllerProvider.notifier);
      final httpClient = ref.read(httpClientServiceProvider);

      // Validate existing session
      final user = await authService.validateSession();
      if (user != null) {
        // Check if we have cookies for API calls
        await Future.delayed(const Duration(milliseconds: 500)); // Wait for cookie loading

        // Test if we can make authenticated API calls
        final hasValidCookies = await _testApiAuthentication(httpClient);

        if (hasValidCookies) {
          // Set user in provider for persistent login
          userNotifier.setUser(user);
          debugPrint('✅ Persistent login successful for: ${user.email}');
        } else {
          debugPrint('⚠️ Valid session found but no API cookies - clearing session');
          // Clear the invalid session and force fresh login
          await authService.logout();
        }
      } else {
        debugPrint('ℹ️ No valid session found, user needs to login');
      }
    } catch (e) {
      debugPrint('Error during persistent login initialization: $e');
    }
  }

  /// Test if API authentication is working
  Future<bool> _testApiAuthentication(HttpClientService httpClient) async {
    try {
      // Make a simple API call to test authentication
      final response = await httpClient.getList(
        '/api/NguoiDung/roles',
        (json) => json.cast<String>(),
      );
      return response.success;
    } catch (e) {
      debugPrint('API authentication test failed: $e');
      return false;
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
