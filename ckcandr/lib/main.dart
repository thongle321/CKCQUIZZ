import 'package:ckcandr/core/constants/app_constants.dart';
import 'package:ckcandr/core/providers/app_providers.dart';
import 'package:ckcandr/services/system_notification_service.dart';
import 'package:ckcandr/services/network_connectivity_service.dart';
import 'package:ckcandr/core/network/ssl_bypass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/views/authentications/login_screen.dart';
import 'package:ckcandr/views/authentications/forgot_password_screen.dart';
import 'package:ckcandr/views/authentications/verify_otp_screen.dart';
import 'package:ckcandr/views/authentications/reset_password_screen.dart';
import 'package:ckcandr/views/admin/dashboard_screen.dart';
import 'package:ckcandr/views/giangvien/dashboard_screen.dart';
import 'package:ckcandr/views/giangvien/exam_results_screen.dart';
import 'package:ckcandr/views/giangvien/teacher_student_result_detail_screen.dart';
import 'package:ckcandr/views/sinhvien/dashboard_screen.dart';
import 'package:ckcandr/views/sinhvien/bai_kiem_tra_screen.dart';
import 'package:ckcandr/views/sinhvien/class_detail_screen.dart';
import 'package:ckcandr/views/sinhvien/exam_result_screen.dart';
import 'package:ckcandr/views/sinhvien/exam_taking_screen.dart';
import 'package:ckcandr/views/sinhvien/student_notifications_screen.dart';
import 'package:ckcandr/screens/user_profile_screen.dart';
import 'package:ckcandr/views/debug/connection_debug_screen.dart';
import 'package:ckcandr/demo/auto_submit_demo.dart';
import 'package:ckcandr/demo/time_test_demo.dart';
import 'package:ckcandr/demo/network_error_demo.dart';
import 'package:ckcandr/providers/theme_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:ckcandr/services/http_client_service.dart';
import 'package:ckcandr/widgets/network_status_indicator.dart';
import 'dart:async';

// Provider for shared preferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Should be overriden in main');
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FORCE BYPASS ALL SSL CERTIFICATE VALIDATION FOR DEVELOPMENT
  SSLBypass.configureHttpOverrides();

  // Khởi tạo system notification service
  await SystemNotificationService().initialize();

  // Khởi tạo network connectivity service
  final networkService = NetworkConnectivityService();
  await networkService.initialize();

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
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyOtpScreen(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(email: email, token: token);
        },
      ),
      // Admin routes
      GoRoute(
        path: '/admin',
        redirect: (context, state) => '/admin/dashboard',
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          int? initialTab;
          if (tabParam != null) {
            initialTab = int.tryParse(tabParam);
            debugPrint('🔄 Admin route with tab parameter: $tabParam -> $initialTab');
          } else {
            debugPrint('🔄 Admin route without tab parameter');
          }
          return AdminDashboardScreen(initialTab: initialTab);
        },
      ),
      GoRoute(
        path: '/admin/users',
        redirect: (context, state) => '/admin/dashboard?tab=1',
      ),
      GoRoute(
        path: '/admin/subjects',
        redirect: (context, state) => '/admin/dashboard?tab=2',
      ),
      GoRoute(
        path: '/admin/classes',
        redirect: (context, state) => '/admin/dashboard?tab=3',
      ),
      GoRoute(
        path: '/admin/assignments',
        redirect: (context, state) => '/admin/dashboard?tab=4',
      ),
      GoRoute(
        path: '/admin/notifications',
        redirect: (context, state) => '/admin/dashboard?tab=5',
      ),
      GoRoute(
        path: '/admin/permissions',
        redirect: (context, state) => '/admin/dashboard?tab=6',
      ),
      GoRoute(
        path: '/admin/roles',
        redirect: (context, state) => '/admin/dashboard?tab=6',
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
      GoRoute(
        path: '/giangvien/exam-results/:examId',
        builder: (context, state) {
          final examId = int.tryParse(state.pathParameters['examId'] ?? '');
          final examName = state.uri.queryParameters['examName'];
          if (examId == null) {
            return const GiangVienDashboardScreen(); // Fallback to dashboard
          }
          return ExamResultsScreen(examId: examId, examName: examName);
        },
      ),

      // Route chi tiết kết quả bài thi của sinh viên cho giáo viên (màn hình mới)
      GoRoute(
        path: '/giangvien/student-result-detail/:examId/:studentId',
        builder: (context, state) {
          debugPrint('🎯 Route /giangvien/student-result-detail called');
          debugPrint('🎯 Path parameters: ${state.pathParameters}');
          final examIdStr = state.pathParameters['examId'] ?? '';
          final studentId = state.pathParameters['studentId'] ?? '';
          final studentName = state.uri.queryParameters['studentName'] ?? 'Sinh viên';
          final examName = state.uri.queryParameters['examName'] ?? 'Đề thi';
          debugPrint('🎯 examIdStr: "$examIdStr", studentId: "$studentId"');
          debugPrint('🎯 studentName: "$studentName", examName: "$examName"');
          final examId = int.tryParse(examIdStr);
          if (examId == null) {
            debugPrint('❌ Route fallback to GiangVienDashboardScreen - examId is null');
            return const GiangVienDashboardScreen(); // Fallback to dashboard
          }
          debugPrint('✅ Route creating TeacherStudentResultDetailScreen');
          return TeacherStudentResultDetailScreen(
            examId: examId,
            studentId: studentId,
            studentName: studentName,
            examName: examName,
          );
        },
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
        builder: (context, state) {
          int? initialTab;
          final tabParam = state.uri.queryParameters['tab'];
          if (tabParam != null) {
            initialTab = int.tryParse(tabParam);
            debugPrint('🔄 SinhVien dashboard route with tab parameter: $tabParam -> $initialTab');
          }
          return SinhVienDashboardScreen(initialTab: initialTab);
        },
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
        path: '/sinhvien/notifications',
        builder: (context, state) => const StudentNotificationsScreen(),
      ),
      // Route chi tiết lớp học cho sinh viên
      GoRoute(
        path: '/sinhvien/class-detail/:id',
        builder: (context, state) {
          final classId = int.tryParse(state.pathParameters['id'] ?? '');
          if (classId == null) {
            return const SinhVienDashboardScreen(); // Fallback to dashboard
          }
          return StudentClassDetailScreen(classId: classId);
        },
      ),
      // Route màn hình thi cho sinh viên
      GoRoute(
        path: '/sinhvien/exam/:examId',
        builder: (context, state) {
          final examId = state.pathParameters['examId'] ?? '';
          if (examId.isEmpty) {
            return const SinhVienDashboardScreen(); // Fallback to dashboard
          }
          return ExamTakingScreen(examId: examId);
        },
      ),
      // Route kết quả bài thi cho sinh viên
      GoRoute(
        path: '/sinhvien/exam-result/:examId/:resultId',
        builder: (context, state) {
          debugPrint('🎯 Route /sinhvien/exam-result called');
          debugPrint('🎯 Path parameters: ${state.pathParameters}');
          final examIdStr = state.pathParameters['examId'] ?? '';
          final resultIdStr = state.pathParameters['resultId'] ?? '';
          debugPrint('🎯 examIdStr: "$examIdStr", resultIdStr: "$resultIdStr"');
          final examId = int.tryParse(examIdStr);
          final resultId = int.tryParse(resultIdStr);
          debugPrint('🎯 Parsed examId: $examId, resultId: $resultId');
          if (examId == null || resultId == null) {
            debugPrint('❌ Route fallback to SinhVienDashboardScreen - examId or resultId is null');
            return const SinhVienDashboardScreen(); // Fallback to dashboard
          }
          debugPrint('✅ Route creating StudentExamResultScreen(examId: $examId, resultId: $resultId)');
          return StudentExamResultScreen(examId: examId, resultId: resultId);
        },
      ),

      // Profile route (shared by all roles)
      GoRoute(
        path: '/profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      // Debug route (development only)
      GoRoute(
        path: '/debug',
        builder: (context, state) => const ConnectionDebugScreen(),
      ),
      // Auto submit demo route
      GoRoute(
        path: '/demo/auto-submit',
        builder: (context, state) => const AutoSubmitDemo(),
      ),
      // Time test demo route
      GoRoute(
        path: '/demo/time-test',
        builder: (context, state) => const TimeTestDemo(),
      ),
      // Network error demo route
      GoRoute(
        path: '/demo/network-error',
        builder: (context, state) => const NetworkErrorDemoScreen(),
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

      final isVerifyOtpRoute = state.matchedLocation == '/verify-otp';
      final isResetPasswordRoute = state.matchedLocation == '/reset-password';
      final isAuthRoute = isLoginRoute || isForgotPasswordRoute || isVerifyOtpRoute || isResetPasswordRoute;

      // If not logged in and not on auth routes
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // If logged in and on auth routes
      if (isLoggedIn && isAuthRoute) {
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
