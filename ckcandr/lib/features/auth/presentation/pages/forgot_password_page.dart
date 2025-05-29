import 'package:ckcandr/features/auth/presentation/widgets/auth_button.dart';
import 'package:ckcandr/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleSendResetLink() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement send reset link logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Liên kết đặt lại mật khẩu đã được gửi (chưa triển khai)')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant, // Approximate background from image
      appBar: AppBar(
        title: const Text(
          'CKC QUIZ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surfaceVariant,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'QUÊN MẬT KHẨU',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                AuthTextField(
                  controller: _emailController,
                  labelText: 'Nhập email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email của bạn';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AuthButton(
                  onPressed: _handleSendResetLink,
                  text: 'KHÔI PHỤC MẬT KHẨU',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  icon: Icons.lock_outline, // Added icon
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 