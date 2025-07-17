import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/services/user_profile_service.dart';
import 'package:ckcandr/core/widgets/error_dialog.dart';

/// Dialog cho Reset Password Flow
class ResetPasswordDialog extends ConsumerStatefulWidget {
  const ResetPasswordDialog({super.key});

  @override
  ConsumerState<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends ConsumerState<ResetPasswordDialog> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Step 1: Verify current password
  final TextEditingController _currentPasswordController = TextEditingController();
  
  // Step 2: Enter new password
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Step 3: Enter OTP
  final TextEditingController _otpController = TextEditingController();
  
  bool _isLoading = false;
  String? _userEmail;
  String? _resetToken;

  @override
  void dispose() {
    _pageController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Bước 1: Verify current password
  Future<void> _verifyCurrentPassword() async {
    if (_currentPasswordController.text.isEmpty) {
      _showError('Vui lòng nhập mật khẩu hiện tại');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProfileService = ref.read(userProfileServiceProvider);
      
      // Get user email
      final currentUser = await userProfileService.getCurrentUserProfile();
      _userEmail = currentUser.email;
      
      // Verify current password
      final isValid = await userProfileService.verifyCurrentPassword(
        _currentPasswordController.text,
      );

      if (isValid) {
        _nextStep();
      } else {
        _showError('Mật khẩu hiện tại không đúng');
      }
    } catch (e) {
      _showError('Lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Bước 2: Request OTP
  Future<void> _requestOTP() async {
    if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      _showError('Vui lòng nhập đầy đủ mật khẩu mới');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Mật khẩu mới không khớp');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showError('Mật khẩu mới phải có ít nhất 6 ký tự');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProfileService = ref.read(userProfileServiceProvider);
      
      // Request OTP
      final success = await userProfileService.requestPasswordResetOTP(_userEmail!);
      
      if (success) {
        _nextStep();
        _showSuccess('Mã OTP đã được gửi đến email của bạn');
      } else {
        _showError('Không thể gửi OTP. Vui lòng thử lại');
      }
    } catch (e) {
      _showError('Lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Bước 3: Verify OTP và reset password
  Future<void> _verifyOTPAndResetPassword() async {
    if (_otpController.text.isEmpty) {
      _showError('Vui lòng nhập mã OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProfileService = ref.read(userProfileServiceProvider);
      
      // Verify OTP and get reset token
      final resetToken = await userProfileService.verifyOTPAndGetResetToken(_userEmail!, _otpController.text);
      
      if (resetToken != null) {
        _resetToken = resetToken;
        
        // Reset password with token
        final success = await userProfileService.changePasswordViaReset(
          _newPasswordController.text,
          _confirmPasswordController.text,
          _resetToken!,
        );

        if (success) {
          _showSuccess('Đổi mật khẩu thành công!');
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          _showError('Không thể đổi mật khẩu. Vui lòng thử lại');
        }
      } else {
        _showError('Mã OTP không đúng hoặc đã hết hạn');
      }
    } catch (e) {
      _showError('Lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showError(String message) {
    ErrorDialog.show(
      context,
      message: message,
    );
  }

  void _showSuccess(String message) {
    SuccessDialog.show(
      context,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đổi mật khẩu'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 16),
            
            // Step indicator
            Text(
              'Bước ${_currentStep + 1}/3: ${_getStepTitle()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Page view for steps
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_currentStep > 0)
          TextButton(
            onPressed: _isLoading ? null : _previousStep,
            child: const Text('Quay lại'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _getNextAction(),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_getNextButtonText()),
        ),
      ],
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Xác nhận mật khẩu hiện tại';
      case 1:
        return 'Nhập mật khẩu mới';
      case 2:
        return 'Nhập mã OTP';
      default:
        return '';
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Tiếp tục';
      case 1:
        return 'Gửi OTP';
      case 2:
        return 'Đổi mật khẩu';
      default:
        return 'Tiếp tục';
    }
  }

  VoidCallback? _getNextAction() {
    switch (_currentStep) {
      case 0:
        return _verifyCurrentPassword;
      case 1:
        return _requestOTP;
      case 2:
        return _verifyOTPAndResetPassword;
      default:
        return null;
    }
  }

  Widget _buildStep1() {
    return Column(
      children: [
        const Text(
          'Để bảo mật, vui lòng nhập mật khẩu hiện tại để xác nhận danh tính.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _currentPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mật khẩu hiện tại',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        const Text(
          'Nhập mật khẩu mới mà bạn muốn sử dụng.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mật khẩu mới',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Xác nhận mật khẩu mới',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        const Text(
          'Chúng tôi đã gửi mã OTP đến email của bạn. Vui lòng nhập mã để hoàn tất việc đổi mật khẩu.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'Mã OTP (6 số)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.security),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
