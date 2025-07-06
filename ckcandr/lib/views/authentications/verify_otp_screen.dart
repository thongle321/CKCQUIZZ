import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/views/authentications/responsive_layout.dart';
import 'package:ckcandr/services/api_service.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String email;
  
  const VerifyOtpScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  late final TextEditingController otpController;
  final isLoadingProvider = StateProvider<bool>((ref) => false);
  final errorMessageProvider = StateProvider<String?>((ref) => null);
  
  @override
  void initState() {
    super.initState();
    otpController = TextEditingController();
  }
  
  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        // Màn hình di động
        mobileLayout: _buildMobileLayout(context, otpController),
        // Màn hình tablet
        tabletLayout: _buildTabletLayout(context, otpController),
        // Màn hình desktop
        desktopLayout: _buildDesktopLayout(context, otpController),
      ),
    );
  }

  // Xử lý xác nhận mã OTP
  Future<void> _handleVerifyOtp(BuildContext context) async {
    final isLoading = ref.read(isLoadingProvider.notifier);
    final errorMessage = ref.read(errorMessageProvider.notifier);
    final apiService = ref.read(apiServiceProvider);

    isLoading.state = true;
    errorMessage.state = null;

    try {
      if (otpController.text.isEmpty) {
        errorMessage.state = 'Vui lòng nhập mã xác nhận';
        return;
      } else if (otpController.text.length != 6) {
        errorMessage.state = 'Mã xác nhận phải có 6 chữ số';
        return;
      }

      // Call API to verify OTP and get reset token
      final resetToken = await apiService.verifyOTP(widget.email, otpController.text);

      // Navigate to reset password screen with token
      if (context.mounted) {
        context.go('/reset-password?email=${widget.email}&token=${Uri.encodeComponent(resetToken)}');
      }
    } catch (e) {
      errorMessage.state = e.toString().contains('ApiException')
          ? e.toString().replaceAll('ApiException: ', '')
          : 'Mã OTP không hợp lệ hoặc đã hết hạn';
    } finally {
      isLoading.state = false;
    }
  }

  // Gửi lại mã OTP
  Future<void> _handleResendOtp(BuildContext context) async {
    final apiService = ref.read(apiServiceProvider);

    try {
      // Call API to resend OTP
      await apiService.forgotPassword(widget.email);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi lại mã xác nhận. Vui lòng kiểm tra email của bạn.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi lại mã: ${e.toString().contains('ApiException') ? e.toString().replaceAll('ApiException: ', '') : e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Bố cục cho màn hình di động
  Widget _buildMobileLayout(BuildContext context, TextEditingController otpController) {
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
              'XÁC NHẬN MÃ',
              style: TextStyle(
                fontSize: 24, 
                color: Colors.grey,
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Mã xác nhận đã được gửi đến email:\n${widget.email}',
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
            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'Nhập mã xác nhận (6 chữ số)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.security, size: 40),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading 
                    ? null 
                    : () => _handleVerifyOtp(context),
                label: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('XÁC NHẬN'),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => _handleResendOtp(context),
              child: const Text('Gửi lại mã'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                context.go('/forgot-password');
              },
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  // Bố cục cho màn hình tablet
  Widget _buildTabletLayout(BuildContext context, TextEditingController otpController) {
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
                    'XÁC NHẬN MÃ',
                    style: TextStyle(
                      fontSize: 24, 
                      color: Colors.grey,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Mã xác nhận đã được gửi đến email:\n${widget.email}',
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
                  TextField(
                    controller: otpController,
                    decoration: const InputDecoration(
                      labelText: 'Nhập mã xác nhận (6 chữ số)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.security, size: 40),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isLoading 
                          ? null 
                          : () => _handleVerifyOtp(context),
                      label: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('XÁC NHẬN'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => _handleResendOtp(context),
                    child: const Text('Gửi lại mã'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      context.go('/forgot-password');
                    },
                    child: const Text('Quay lại'),
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
  Widget _buildDesktopLayout(BuildContext context, TextEditingController otpController) {
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
              'XÁC NHẬN MÃ',
              style: TextStyle(
                fontSize: 24, 
                color: Colors.grey,
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Mã xác nhận đã được gửi đến email:\n${widget.email}',
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
            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'Nhập mã xác nhận (6 chữ số)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.security, size: 40),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading 
                    ? null 
                    : () => _handleVerifyOtp(context),
                label: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('XÁC NHẬN'),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => _handleResendOtp(context),
              child: const Text('Gửi lại mã'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                context.go('/forgot-password');
              },
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}
