import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/core/widgets/error_dialog.dart';

class JoinClassDialog extends ConsumerStatefulWidget {
  const JoinClassDialog({super.key});

  @override
  ConsumerState<JoinClassDialog> createState() => _JoinClassDialogState();
}

class _JoinClassDialogState extends ConsumerState<JoinClassDialog> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tham gia lớp học'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nhập mã mời để tham gia lớp học:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _inviteCodeController,
              decoration: const InputDecoration(
                labelText: 'Mã mời',
                hintText: 'Ví dụ: ABC123',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mã mời';
                }
                if (value.trim().length < 3) {
                  return 'Mã mời phải có ít nhất 3 ký tự';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleJoinClass,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Tham gia'),
        ),
      ],
    );
  }

  Future<void> _handleJoinClass() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final inviteCode = _inviteCodeController.text.trim().toUpperCase();
      final message = await ref.read(apiServiceProvider).joinClassByInviteCode(inviteCode);
      
      if (mounted) {
        Navigator.pop(context);
        await SuccessDialog.show(
          context,
          message: message,
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Lỗi: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
