import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/ai_provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiApiKeyRequiredDialog extends ConsumerStatefulWidget {
  const AiApiKeyRequiredDialog({super.key});

  @override
  ConsumerState<AiApiKeyRequiredDialog> createState() => _AiApiKeyRequiredDialogState();
}

class _AiApiKeyRequiredDialogState extends ConsumerState<AiApiKeyRequiredDialog> {
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  String? _errorMessage;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey({bool skipValidation = false}) async {
    final apiKey = _apiKeyController.text.trim();

    if (apiKey.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập API key';
      });
      return;
    }

    if (!_isValidApiKeyFormat(apiKey)) {
      setState(() {
        _errorMessage = 'API key không đúng định dạng (phải bắt đầu bằng AIzaSy và có ít nhất 20 ký tự)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool success;
      if (skipValidation) {
        // Save without validation - directly update database
        final aiService = ref.read(aiServiceProvider);
        final settings = await aiService.getSettings();
        final newSettings = settings.copyWith(apiKey: apiKey);
        await aiService.updateSettings(newSettings);
        success = true;
      } else {
        // Save with validation
        success = await ref.read(aiSettingsControllerProvider.notifier).updateApiKey(apiKey);
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(skipValidation
                ? '✅ API key đã được lưu (bỏ qua kiểm tra)!'
                : '✅ API key đã được lưu và xác thực thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'API key không hợp lệ hoặc không thể kết nối đến Google AI.\n\n'
              'Vui lòng:\n'
              '• Kiểm tra lại API key từ Google AI Studio\n'
              '• Đảm bảo API key chưa hết hạn\n'
              '• Thử "Lưu không kiểm tra" nếu mạng có vấn đề\n\n'
              'API key hiện tại: ${apiKey.substring(0, 10)}... (${apiKey.length} ký tự)';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Có lỗi xảy ra: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isValidApiKeyFormat(String apiKey) {
    debugPrint('🔍 Checking API key format: length=${apiKey.length}, starts with AIzaSy=${apiKey.startsWith('AIzaSy')}');
    // Google AI API keys can have different formats:
    // - AIzaSy... (most common, 39-40 chars)
    // - Some newer keys might be shorter or longer
    // Let's be very flexible with validation
    return apiKey.startsWith('AIzaSy') && apiKey.length >= 20 && apiKey.length <= 50;
  }

  void _copyApiKeyUrl() {
    const url = 'https://aistudio.google.com/apikey';
    Clipboard.setData(const ClipboardData(text: url));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Đã sao chép link! Mở trình duyệt và dán link để lấy API key'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _testApiKeyOnly() async {
    final apiKey = _apiKeyController.text.trim();

    if (apiKey.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập API key để test';
      });
      return;
    }

    if (!_isValidApiKeyFormat(apiKey)) {
      setState(() {
        _errorMessage = 'API key không đúng định dạng (phải bắt đầu bằng AIzaSy và có ít nhất 20 ký tự)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Test API key without saving - try multiple models
      final modelNames = ['gemini-1.5-flash', 'gemini-pro', 'gemini-1.5-pro'];
      String? successResponse;
      String? lastError;

      for (final modelName in modelNames) {
        try {
          setState(() {
            _errorMessage = '🔄 Testing với model: $modelName...';
          });

          final testModel = GenerativeModel(
            model: modelName,
            apiKey: apiKey,
          );

          final testResponse = await testModel.generateContent([
            Content.text('Hi')
          ]).timeout(const Duration(seconds: 20));

          if (testResponse.text != null && testResponse.text!.isNotEmpty) {
            successResponse = testResponse.text!;
            final displayText = successResponse.length > 100 ? successResponse.substring(0, 100) : successResponse;
            setState(() {
              _errorMessage = '✅ API key hợp lệ với model $modelName!\n\nResponse: $displayText...';
            });
            return; // Success, exit early
          }
        } catch (e) {
          lastError = e.toString();
          debugPrint('❌ Model $modelName failed: $e');
          continue;
        }
      }

      // If we get here, all models failed
      setState(() {
        _errorMessage = '❌ API key test failed với tất cả models.\n\nLỗi cuối: $lastError\n\nHãy thử:\n• Kiểm tra API key từ Google AI Studio\n• Đảm bảo API key chưa hết hạn\n• Thử "Lưu không kiểm tra" nếu chắc chắn key đúng';
      });
    } catch (e) {
      setState(() {
        _errorMessage = '❌ Lỗi không xác định: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearOldApiKey() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Clear API key from database
      final aiService = ref.read(aiServiceProvider);
      await aiService.clearApiKey();

      setState(() {
        _errorMessage = '🗑️ Đã xóa API key cũ. Hãy nhập API key mới và test lại.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = '❌ Lỗi khi xóa API key: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Cho phép đóng dialog
      child: AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Cài đặt AI Assistant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Để sử dụng AI Assistant, bạn cần cung cấp Google AI API Key.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              // Hướng dẫn lấy API Key
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Hướng dẫn lấy API Key',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Nhấn nút "Lấy API Key" bên dưới'),
                    const Text('2. Đăng nhập Google và tạo API key mới'),
                    const Text('3. Sao chép API key và dán vào ô bên dưới'),
                    const Text('4. Nhấn "Lưu" để hoàn tất'),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Nút lấy API Key
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _copyApiKeyUrl,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Lấy API Key'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Input API Key
              TextField(
                controller: _apiKeyController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Google AI API Key',
                  hintText: 'AIzaSy...',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.key),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  errorText: _errorMessage,
                ),
                onChanged: (value) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Thông tin bổ sung
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Bảo mật',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'API key được lưu trữ an toàn trên thiết bị của bạn và chỉ được sử dụng để giao tiếp với Google AI.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveApiKey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Lưu và Kiểm tra API Key',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading ? null : _testApiKeyOnly,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Chỉ test',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading ? null : _clearOldApiKey,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Xóa key cũ',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextButton(
                      onPressed: _isLoading ? null : () => _saveApiKey(skipValidation: true),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Lưu không kiểm tra',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Bỏ qua (sử dụng sau)',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
