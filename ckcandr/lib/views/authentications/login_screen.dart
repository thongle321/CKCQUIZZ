import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/views/authentications/responsive_layout.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/core/utils/responsive_helper.dart';
import 'package:ckcandr/providers/chuong_provider.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/api_user_provider.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/providers/nhom_hocphan_provider.dart';
import 'package:ckcandr/providers/de_kiem_tra_provider.dart';
import 'package:ckcandr/providers/de_thi_provider.dart';
import 'package:ckcandr/services/thong_bao_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  final isLoadingProvider = StateProvider<bool>((ref) => false);
  final errorMessageProvider = StateProvider<String?>((ref) => null);
  final isPasswordVisibleProvider = StateProvider<bool>((ref) => false);

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // SECURITY FIX: Only check stored credentials when user explicitly tries to login
    // This ensures the app always shows login screen first for security
    // Auto-login will happen only during the login process, not on app startup
    _checkForStoredCredentials();
  }

  // Check if there are stored credentials (for UI purposes only)
  Future<void> _checkForStoredCredentials() async {
    try {
      final authService = ref.read(authServiceProvider);
      final storedUser = await authService.getCurrentUser();

      if (storedUser != null && mounted) {
        // Pre-fill email field for convenience, but don't auto-login
        emailController.text = storedUser.email;
      }
    } catch (e) {
      // Ignore errors when checking stored credentials
      print('Error checking stored credentials: $e');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        // Màn hình di động
        mobileLayout: _buildMobileLayout(
          context, 
          emailController, 
          passwordController, 
          ref,
          isLoadingProvider,
          errorMessageProvider
        ),
        // Màn hình tablet
        tabletLayout: _buildTabletLayout(
          context, 
          emailController, 
          passwordController,
          ref,
          isLoadingProvider,
          errorMessageProvider
        ),
        // Màn hình desktop
        desktopLayout: _buildDesktopLayout(
          context, 
          emailController, 
          passwordController,
          ref,
          isLoadingProvider,
          errorMessageProvider
        ),
      ),
    );
  }
  
  // Xử lý đăng nhập
  Future<void> _handleLogin(
    BuildContext context,
    WidgetRef ref,
    TextEditingController emailController,
    TextEditingController passwordController,
    StateProvider<bool> isLoadingProvider,
    StateProvider<String?> errorMessageProvider,
  ) async {
    // Đặt trạng thái loading
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorMessageProvider.notifier).state = null;

    try {
      final authService = ref.read(authServiceProvider);

      // Validate input first
      if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
        ref.read(errorMessageProvider.notifier).state = 'Vui lòng nhập đầy đủ email và mật khẩu.';
        return;
      }

      // Proceed with normal login
      final user = await authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Nếu đăng nhập thành công, cập nhật user hiện tại
      if (user != null) {
        _handleSuccessfulLogin(context, user);
      } else {
        // Check for specific error messages from AuthService
        final specificError = authService.lastLoginError;
        if (specificError != null) {
          ref.read(errorMessageProvider.notifier).state = specificError;
        } else {
          // Default error message for other cases
          ref.read(errorMessageProvider.notifier).state = 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.';
        }
      }
    } catch (e) {
      // Handle unexpected errors
      ref.read(errorMessageProvider.notifier).state = 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.';
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  // Xử lý đăng nhập nhanh với stored credentials
  Future<void> _handleQuickLogin(
    BuildContext context,
    WidgetRef ref,
    StateProvider<bool> isLoadingProvider,
    StateProvider<String?> errorMessageProvider,
  ) async {
    // Đặt trạng thái loading
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorMessageProvider.notifier).state = null;

    try {
      final authService = ref.read(authServiceProvider);
      final storedUser = await authService.getCurrentUser();

      if (storedUser != null) {
        _handleSuccessfulLogin(context, storedUser);
      } else {
        ref.read(errorMessageProvider.notifier).state = 'Không tìm thấy thông tin đăng nhập đã lưu.';
      }
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11); // Remove "Exception: " prefix
      }
      ref.read(errorMessageProvider.notifier).state = errorMessage;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  // Xử lý chuyển hướng sau khi đăng nhập thành công
  void _handleSuccessfulLogin(BuildContext context, User user) {
    // Lưu thông tin người dùng vào provider
    ref.read(currentUserControllerProvider.notifier).setUser(user);

    // Invalidate all cached providers to force refresh with new user data
    _invalidateAllProviders();

    // Chuyển hướng dựa trên vai trò người dùng
    switch (user.quyen) {
      case UserRole.admin:
        context.go('/admin/dashboard');
        break;
      case UserRole.giangVien:
        context.go('/giangvien/dashboard');
        break;
      case UserRole.sinhVien:
        context.go('/sinhvien/dashboard');
        break;
    }
  }

  // Invalidate all providers to force refresh with new user data
  void _invalidateAllProviders() {
    try {
      // Invalidate subject-related providers
      ref.invalidate(assignedSubjectsProvider);

      // Invalidate class-related providers
      ref.invalidate(lopHocListProvider);

      // Invalidate API user providers
      ref.invalidate(apiUserProvider);
      ref.invalidate(rolesProvider);

      // Invalidate other data providers that depend on user
      ref.invalidate(monHocProvider);
      ref.invalidate(monHocListProvider);
      ref.invalidate(nhomHocPhanListProvider);
      ref.invalidate(deKiemTraListProvider);

      // 🔥 CRITICAL: Invalidate exam list provider to clear cache
      ref.invalidate(deThiListProvider);

      // 🔥 CRITICAL: Invalidate chapter providers (all instances)
      // Note: We can't invalidate family providers directly, they auto-invalidate when dependencies change

      // Invalidate notification providers
      ref.invalidate(thongBaoNotifierProvider);

      print('✅ All providers invalidated for fresh user data');
    } catch (e) {
      print('⚠️  Error invalidating providers: $e');
    }
  }


  
  // Bố cục cho màn hình di động
  Widget _buildMobileLayout(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
    WidgetRef ref,
    StateProvider<bool> isLoadingProvider,
    StateProvider<String?> errorMessageProvider
  ) {
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: context.responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: ResponsiveHelper.getResponsiveValue(
              context,
              mobile: 60,
              tablet: 80
            )),

            // Logo/Title
            Text(
              'CKC QUIZZ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 32,
                  tablet: 36,
                ),
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            SizedBox(height: ResponsiveHelper.getResponsiveValue(
              context,
              mobile: 40,
              tablet: 50
            )),

            // Login header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.login,
                  size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                Text(
                  'ĐĂNG NHẬP',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 20,
                      tablet: 22,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveValue(
              context,
              mobile: 24,
              tablet: 32
            )),

            // Error message
            if (errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: context.responsiveBorderRadius,
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Email field
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 17,
                ),
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Nhập địa chỉ email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: context.responsiveBorderRadius,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: ResponsiveHelper.getResponsiveValue(
                    context,
                    mobile: 16,
                    tablet: 20,
                  ),
                ),
              ),
            ),

            SizedBox(height: ResponsiveHelper.getResponsiveValue(
              context,
              mobile: 16,
              tablet: 20
            )),

            // Password field
            Consumer(
              builder: (context, ref, child) {
                final isPasswordVisible = ref.watch(isPasswordVisibleProvider);
                return TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 16,
                      tablet: 17,
                    ),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    hintText: 'Nhập mật khẩu',
                    prefixIcon: Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        ref.read(isPasswordVisibleProvider.notifier).state = !isPasswordVisible;
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: context.responsiveBorderRadius,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: ResponsiveHelper.getResponsiveValue(
                        context,
                        mobile: 16,
                        tablet: 20,
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: ResponsiveHelper.getResponsiveValue(
              context,
              mobile: 24,
              tablet: 32
            )),

            // Login button
            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.getResponsiveValue(
                context,
                mobile: 52,
                tablet: 56,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: context.responsiveElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: context.responsiveBorderRadius,
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () => _handleLogin(
                          context,
                          ref,
                          emailController,
                          passwordController,
                          isLoadingProvider,
                          errorMessageProvider,
                        ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'ĐĂNG NHẬP',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 17,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),


            SizedBox(height: ResponsiveHelper.getResponsiveValue(
              context,
              mobile: 20,
              tablet: 24
            )),

            // Forgot password
            TextButton(
              onPressed: () {
                context.go('/forgot-password');
              },
              child: Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 15,
                  ),
                  color: Colors.blue,
                ),
              ),
            ),

            SizedBox(height: ResponsiveHelper.getResponsiveValue(
              context,
              mobile: 24,
              tablet: 32
            )),

            SizedBox(height: ResponsiveHelper.getResponsiveValue(
              context,
              mobile: 40,
              tablet: 60
            )),
          ],
        ),
      ),
    );
  }
  
  // Bố cục cho màn hình tablet
  Widget _buildTabletLayout(
    BuildContext context, 
    TextEditingController emailController, 
    TextEditingController passwordController,
    WidgetRef ref,
    StateProvider<bool> isLoadingProvider,
    StateProvider<String?> errorMessageProvider
  ) {
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'CKC QUIZZ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_forward),
                      const SizedBox(width: 10),
                      Text(
                        'ĐĂNG NHẬP',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Gmail',
                      hintText: 'Nhập email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  Consumer(
                    builder: (context, ref, child) {
                      final isPasswordVisible = ref.watch(isPasswordVisibleProvider);
                      return TextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          hintText: 'Nhập mật khẩu',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              ref.read(isPasswordVisibleProvider.notifier).state = !isPasswordVisible;
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isLoading
                          ? null
                          : () => _handleLogin(
                                context,
                                ref,
                                emailController,
                                passwordController,
                                isLoadingProvider,
                                errorMessageProvider,
                              ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('ĐĂNG NHẬP'),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Navigate to forgot password
                      context.go('/forgot-password');
                    },
                    child: const Text('Quên mật khẩu'),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Bố cục cho màn hình desktop
  Widget _buildDesktopLayout(
    BuildContext context, 
    TextEditingController emailController, 
    TextEditingController passwordController,
    WidgetRef ref,
    StateProvider<bool> isLoadingProvider,
    StateProvider<String?> errorMessageProvider
  ) {
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'CKC QUIZZ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Icon(Icons.login, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(
                        'ĐĂNG NHẬP',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Gmail',
                      hintText: 'Nhập email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  Consumer(
                    builder: (context, ref, child) {
                      final isPasswordVisible = ref.watch(isPasswordVisibleProvider);
                      return TextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          hintText: 'Nhập mật khẩu',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              ref.read(isPasswordVisibleProvider.notifier).state = !isPasswordVisible;
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isLoading
                          ? null
                          : () => _handleLogin(
                                context,
                                ref,
                                emailController,
                                passwordController,
                                isLoadingProvider,
                                errorMessageProvider,
                              ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('ĐĂNG NHẬP'),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Navigate to forgot password
                      context.go('/forgot-password');
                    },
                    child: const Text('Quên mật khẩu'),
                  ),

                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://placehold.co/600x800/grey/white?text=CKC+QUIZ'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'WEB TRẮC NGHIỆM CKC QUIZZ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.cloud, 
                    color: Colors.white, 
                    size: 50
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 