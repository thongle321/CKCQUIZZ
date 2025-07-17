import 'package:flutter/material.dart';

class AiErrorDialog extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final VoidCallback? onSettings;

  const AiErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Lỗi AI Assistant',
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
            _buildErrorMessage(),
            const SizedBox(height: 16),
            _buildSuggestions(),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            if (onSettings != null)
              Expanded(
                child: TextButton.icon(
                  onPressed: onSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Cài đặt'),
                ),
              ),
            if (onSettings != null) const SizedBox(width: 8),
            if (onRetry != null)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            if (onRetry == null)
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    String userFriendlyMessage = _getUserFriendlyMessage(error);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Chi tiết lỗi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            userFriendlyMessage,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    List<String> suggestions = _getSuggestions(error);
    
    if (suggestions.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Gợi ý khắc phục',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(suggestion, style: const TextStyle(fontSize: 13))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _getUserFriendlyMessage(String error) {
    if (error.contains('Permission denied') || error.contains('Consumer api_key')) {
      return 'API key không hợp lệ hoặc đã bị vô hiệu hóa. Vui lòng kiểm tra lại API key của bạn.';
    } else if (error.contains('network') || error.contains('timeout')) {
      return 'Không thể kết nối đến máy chủ AI. Vui lòng kiểm tra kết nối mạng của bạn.';
    } else if (error.contains('quota') || error.contains('limit')) {
      return 'Đã vượt quá giới hạn sử dụng API. Vui lòng kiểm tra quota của API key.';
    } else if (error.contains('model') || error.contains('not found')) {
      return 'Model AI không khả dụng. Vui lòng thử lại sau.';
    } else {
      return 'Đã xảy ra lỗi không xác định khi giao tiếp với AI. Vui lòng thử lại.';
    }
  }

  List<String> _getSuggestions(String error) {
    if (error.contains('Permission denied') || error.contains('Consumer api_key')) {
      return [
        'Kiểm tra lại API key trong cài đặt AI',
        'Đảm bảo API key chưa hết hạn',
        'Tạo API key mới từ Google AI Studio',
        'Kiểm tra quyền truy cập của API key',
      ];
    } else if (error.contains('network') || error.contains('timeout')) {
      return [
        'Kiểm tra kết nối WiFi hoặc dữ liệu di động',
        'Thử kết nối mạng khác',
        'Đợi một lúc rồi thử lại',
      ];
    } else if (error.contains('quota') || error.contains('limit')) {
      return [
        'Đợi đến chu kỳ làm mới quota tiếp theo',
        'Kiểm tra giới hạn sử dụng trong Google AI Studio',
        'Nâng cấp gói sử dụng nếu cần',
      ];
    } else {
      return [
        'Thử lại sau vài phút',
        'Kiểm tra cài đặt AI',
        'Khởi động lại ứng dụng',
      ];
    }
  }
}
