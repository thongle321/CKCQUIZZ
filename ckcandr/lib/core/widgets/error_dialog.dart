import 'package:flutter/material.dart';

/// Widget hiển thị dialog lỗi chuyên nghiệp
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  final bool showRetryButton;

  const ErrorDialog({
    super.key,
    this.title = 'Có lỗi xảy ra',
    required this.message,
    this.onRetry,
    this.onClose,
    this.showRetryButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
      actions: [
        if (showRetryButton && onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry?.call();
            },
            child: const Text(
              'Thử lại',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Đóng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Hiển thị error dialog
  static Future<void> show(
    BuildContext context, {
    String title = 'Có lỗi xảy ra',
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onClose,
    bool showRetryButton = false,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: title,
          message: message,
          onRetry: onRetry,
          onClose: onClose,
          showRetryButton: showRetryButton,
        );
      },
    );
  }
}

/// Widget hiển thị dialog thành công
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;

  const SuccessDialog({
    super.key,
    this.title = 'Thành công',
    required this.message,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade600,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Đóng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Hiển thị success dialog
  static Future<void> show(
    BuildContext context, {
    String title = 'Thành công',
    required String message,
    VoidCallback? onClose,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessDialog(
          title: title,
          message: message,
          onClose: onClose,
        );
      },
    );
  }
}
