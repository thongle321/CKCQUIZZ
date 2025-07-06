import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/views/authentications/responsive_layout.dart';
import 'package:ckcandr/services/api_service.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({super.key, required this.email, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;
  final isLoadingProvider = StateProvider<bool>((ref) => false);
  final errorMessageProvider = StateProvider<String?>((ref) => null);
  final isNewPasswordVisibleProvider = StateProvider<bool>((ref) => false);
  final isConfirmPasswordVisibleProvider = StateProvider<bool>((ref) => false);
  
  @override
  void initState() {
    super.initState();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }
  
  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        // Màn hình di động
        mobileLayout: _buildMobileLayout(context),
        // Màn hình tablet
        tabletLayout: _buildTabletLayout(context),
        // Màn hình desktop
        desktopLayout: _buildDesktopLayout(context),
      ),
    );
  }

  // Xử lý đặt mật khẩu mới
  Future<void> _handleResetPassword(BuildContext context) async {
    final isLoading = ref.read(isLoadingProvider.notifier);
    final errorMessage = ref.read(errorMessageProvider.notifier);
    final apiService = ref.read(apiServiceProvider);

    isLoading.state = true;
    errorMessage.state = null;

    try {
      // Validate input
      if (newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
        errorMessage.state = 'Vui lòng nhập đầy đủ thông tin';
        return;
      }

      if (newPasswordController.text.length < 8) {
        errorMessage.state = 'Mật khẩu phải có ít nhất 8 ký tự';
        return;
      }

      if (newPasswordController.text != confirmPasswordController.text) {
        errorMessage.state = 'Mật khẩu xác nhận không khớp';
        return;
      }

      // Call API to reset password
      await apiService.resetPassword(
        widget.email,
        widget.token,
        newPasswordController.text,
        confirmPasswordController.text
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt lại mật khẩu thành công! Vui lòng đăng nhập với mật khẩu mới.'),
            backgroundColor: Colors.green,
          ),
        );

        // Chuyển về màn hình đăng nhập sau 2 giây
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            context.go('/login');
          }
        });
      }
    } catch (e) {
      errorMessage.state = e.toString().contains('ApiException')
          ? e.toString().replaceAll('ApiException: ', '')
          : 'Đã xảy ra lỗi. Vui lòng thử lại.';
    } finally {
      isLoading.state = false;
    }
  }

  // Widget tạo TextField mật khẩu với icon ẩn/hiện
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required StateProvider<bool> visibilityProvider,
  }) {
    final isVisible = ref.watch(visibilityProvider);
    
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            ref.read(visibilityProvider.notifier).state = !isVisible;
          },
        ),
      ),
    );
  }

  // Bố cục cho màn hình di động
  Widget _buildMobileLayout(BuildContext context) {
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
              'ĐẶT MẬT KHẨU MỚI',
              style: TextStyle(
                fontSize: 24, 
                color: Colors.grey,
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Đặt mật khẩu mới cho tài khoản:\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
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
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: newPasswordController,
              labelText: 'Mật khẩu mới',
              hintText: 'Nhập mật khẩu mới (tối thiểu 8 ký tự)',
              visibilityProvider: isNewPasswordVisibleProvider,
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: confirmPasswordController,
              labelText: 'Xác nhận mật khẩu mới',
              hintText: 'Nhập lại mật khẩu mới',
              visibilityProvider: isConfirmPasswordVisibleProvider,
            ),
            const SizedBox(height: 20),
            const Icon(Icons.lock_reset, size: 40),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading 
                    ? null 
                    : () => _handleResetPassword(context),
                label: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ĐẶT MẬT KHẨU MỚI'),
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
  Widget _buildTabletLayout(BuildContext context) {
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
                    'ĐẶT MẬT KHẨU MỚI',
                    style: TextStyle(
                      fontSize: 24, 
                      color: Colors.grey,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Đặt mật khẩu mới cho tài khoản:\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
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
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: newPasswordController,
                    labelText: 'Mật khẩu mới',
                    hintText: 'Nhập mật khẩu mới (tối thiểu 8 ký tự)',
                    visibilityProvider: isNewPasswordVisibleProvider,
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: confirmPasswordController,
                    labelText: 'Xác nhận mật khẩu mới',
                    hintText: 'Nhập lại mật khẩu mới',
                    visibilityProvider: isConfirmPasswordVisibleProvider,
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.lock_reset, size: 40),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isLoading 
                          ? null 
                          : () => _handleResetPassword(context),
                      label: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('ĐẶT MẬT KHẨU MỚI'),
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
  Widget _buildDesktopLayout(BuildContext context) {
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
              'ĐẶT MẬT KHẨU MỚI',
              style: TextStyle(
                fontSize: 24, 
                color: Colors.grey,
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Đặt mật khẩu mới cho tài khoản:\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
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
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: newPasswordController,
              labelText: 'Mật khẩu mới',
              hintText: 'Nhập mật khẩu mới (tối thiểu 8 ký tự)',
              visibilityProvider: isNewPasswordVisibleProvider,
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: confirmPasswordController,
              labelText: 'Xác nhận mật khẩu mới',
              hintText: 'Nhập lại mật khẩu mới',
              visibilityProvider: isConfirmPasswordVisibleProvider,
            ),
            const SizedBox(height: 20),
            const Icon(Icons.lock_reset, size: 40),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading 
                    ? null 
                    : () => _handleResetPassword(context),
                label: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ĐẶT MẬT KHẨU MỚI'),
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
