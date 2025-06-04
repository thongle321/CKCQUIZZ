import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/views/authentications/responsive_layout.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:ckcandr/models/user_model.dart';

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

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
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
      final user = await authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      
      // Nếu đăng nhập thành công, cập nhật user hiện tại
      if (user != null) {
        ref.read(currentUserProvider.notifier).state = user;
        
        // Chuyển hướng dựa trên vai trò
        if (context.mounted) {
          switch (user.role) {
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
      } else {
        // Hiển thị thông báo lỗi nếu đăng nhập thất bại
        ref.read(errorMessageProvider.notifier).state = 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.';
      }
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Đã xảy ra lỗi: $e';
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
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
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                hintText: 'Nhập mật khẩu',
                border: OutlineInputBorder(),
              ),
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
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        // TODO: Implement Google login
                      },
                child: const Text('ĐĂNG NHẬP BẰNG GOOGLE'),
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
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu',
                      border: OutlineInputBorder(),
                    ),
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
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              // TODO: Implement Google login
                            },
                      child: const Text('ĐĂNG NHẬP BẰNG GOOGLE'),
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
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
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
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu',
                      border: OutlineInputBorder(),
                    ),
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
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              // TODO: Implement Google login
                            },
                      child: const Text('ĐĂNG NHẬP BẰNG GOOGLE'),
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