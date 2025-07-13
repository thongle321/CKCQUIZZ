import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/ai_provider.dart';
import 'package:ckcandr/views/shared/ai_chat_sessions_screen.dart';
import 'package:ckcandr/widgets/ai_api_key_required_dialog.dart';

class AiChatWrapper extends ConsumerStatefulWidget {
  const AiChatWrapper({super.key});

  @override
  ConsumerState<AiChatWrapper> createState() => _AiChatWrapperState();
}

class _AiChatWrapperState extends ConsumerState<AiChatWrapper> {
  bool _hasCheckedApiKey = false;
  bool _isCheckingApiKey = true;

  @override
  void initState() {
    super.initState();
    // Check API key after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkApiKeyRequired();
    });
  }

  Future<void> _checkApiKeyRequired() async {
    if (_hasCheckedApiKey) return;
    
    try {
      final aiService = ref.read(aiServiceProvider);
      final settings = await aiService.getSettings();
      
      if (!settings.hasApiKey && mounted) {
        _hasCheckedApiKey = true;
        await _showApiKeyRequiredDialog();
      } else {
        _hasCheckedApiKey = true;
      }
    } catch (e) {
      debugPrint('Error checking API key: $e');
      _hasCheckedApiKey = true;
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingApiKey = false;
        });
      }
    }
  }

  Future<void> _showApiKeyRequiredDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AiApiKeyRequiredDialog(),
    );

    if (result == true) {
      // API key was saved successfully, refresh the screen
      setState(() {
        _hasCheckedApiKey = false;
        _isCheckingApiKey = true;
      });
      _checkApiKeyRequired();
    } else {
      // User skipped or cancelled, mark as checked to avoid showing again
      setState(() {
        _hasCheckedApiKey = true;
        _isCheckingApiKey = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingApiKey) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang kiểm tra cấu hình AI...'),
            ],
          ),
        ),
      );
    }

    return const AiChatSessionsScreen();
  }
}
