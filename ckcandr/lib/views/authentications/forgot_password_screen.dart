import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/views/authentications/responsive_layout.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController emailController;
  final isLoadingProvider = StateProvider<bool>((ref) => false);
  final errorMessageProvider = StateProvider<String?>((ref) => null);
  
  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }
  
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        // Màn hình di động
        mobileLayout: _buildMobileLayout(context, emailController),
        // Màn hình tablet
        tabletLayout: _buildTabletLayout(context, emailController),
        // Màn hình desktop
        desktopLayout: _buildDesktopLayout(context, emailController),
      ),
    );
  }

  // Xử lý khôi phục mật khẩu
  Future<void> _handleResetPassword(BuildContext context) async {
    final isLoading = ref.read(isLoadingProvider.notifier);
    final errorMessage = ref.read(errorMessageProvider.notifier);
    
    isLoading.state = true;
    errorMessage.state = null;
    
    try {
      // TODO: Implement password reset logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (emailController.text.isEmpty) {
        errorMessage.state = 'Vui lòng nhập email hợp lệ';
      } else {
        // Hiển thị thông báo thành công
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã gửi email khôi phục mật khẩu. Vui lòng kiểm tra hòm thư của bạn.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Chuyển về màn hình đăng nhập sau 3 giây
          Future.delayed(const Duration(seconds: 3), () {
            if (context.mounted) {
              context.go('/login');
            }
          });
        }
      }
    } catch (e) {
      errorMessage.state = 'Đã xảy ra lỗi: $e';
    } finally {
      isLoading.state = false;
    }
  }

  // Bố cục cho màn hình di động
  Widget _buildMobileLayout(BuildContext context, TextEditingController emailController) {
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Text(
              'CKC QUIZ',
              style: TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'QUÊN MẬT KHẨU',
              style: TextStyle(
                fontSize: 24, 
                color: Colors.grey,
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 40),
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
                labelText: 'Nhập email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            const Icon(Icons.cloud, size: 40),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock_open),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading 
                    ? null 
                    : () => _handleResetPassword(context),
                label: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('KHÔI PHỤC MẬT KHẨU'),
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('Quay lại đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }

  // Bố cục cho màn hình tablet
  Widget _buildTabletLayout(BuildContext context, TextEditingController emailController) {
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            const Text(
              'CKC QUIZ',
              style: TextStyle(
                fontSize: 36, 
                fontWeight: FontWeight.bold
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
                  const Text(
                    'QUÊN MẬT KHẨU',
                    style: TextStyle(
                      fontSize: 24, 
                      color: Colors.grey,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 40),
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
                      labelText: 'Nhập email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.cloud, size: 40),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.lock_open),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isLoading 
                          ? null 
                          : () => _handleResetPassword(context),
                      label: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('KHÔI PHỤC MẬT KHẨU'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    child: const Text('Quay lại đăng nhập'),
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
  Widget _buildDesktopLayout(BuildContext context, TextEditingController emailController) {
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'CKC QUIZ',
              style: TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'QUÊN MẬT KHẨU',
              style: TextStyle(
                fontSize: 24, 
                color: Colors.grey,
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 40),
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
                labelText: 'Nhập email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            const Icon(Icons.cloud, size: 40),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock_open),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading 
                    ? null 
                    : () => _handleResetPassword(context),
                label: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('KHÔI PHỤC MẬT KHẨU'),
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('Quay lại đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
} 