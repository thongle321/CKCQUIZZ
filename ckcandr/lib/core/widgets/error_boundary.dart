import 'package:flutter/material.dart';

/// Widget để bắt và xử lý lỗi trong ứng dụng
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return widget.child;
  }

  Widget _buildErrorWidget() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'Đã xảy ra lỗi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.errorMessage ?? 'Có lỗi không mong muốn xảy ra. Vui lòng thử lại.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('Chi tiết lỗi'),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error.toString(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Về trang chủ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _error = null;
    });
    
    if (widget.onRetry != null) {
      widget.onRetry!();
    }
  }

  void _handleError(Object error) {
    setState(() {
      _hasError = true;
      _error = error;
    });
    
    debugPrint('ErrorBoundary caught error: $error');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Bắt lỗi từ widget tree
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleError(details.exception);
    };
  }
}

/// Extension để wrap widget với ErrorBoundary dễ dàng hơn
extension ErrorBoundaryExtension on Widget {
  Widget withErrorBoundary({
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    return ErrorBoundary(
      errorMessage: errorMessage,
      onRetry: onRetry,
      child: this,
    );
  }
}
