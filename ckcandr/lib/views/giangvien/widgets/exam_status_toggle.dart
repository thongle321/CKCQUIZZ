import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

/// Widget đơn giản để toggle exam status (bật/tắt đề thi)
/// Có thể sử dụng trong exam creation, editing, hoặc exam results screen
class ExamStatusToggle extends ConsumerStatefulWidget {
  final int examId;
  final bool initialStatus;
  final VoidCallback? onStatusChanged;
  final bool isCompact; // Hiển thị compact cho không tốn diện tích
  final bool showLabel; // Hiển thị label hay không

  const ExamStatusToggle({
    super.key,
    required this.examId,
    required this.initialStatus,
    this.onStatusChanged,
    this.isCompact = false,
    this.showLabel = true,
  });

  @override
  ConsumerState<ExamStatusToggle> createState() => _ExamStatusToggleState();
}

class _ExamStatusToggleState extends ConsumerState<ExamStatusToggle> {
  late bool _currentStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
  }

  @override
  void didUpdateWidget(ExamStatusToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatus != widget.initialStatus) {
      setState(() {
        _currentStatus = widget.initialStatus;
      });
    }
  }

  Future<void> _toggleStatus() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newStatus = !_currentStatus;

      // Call API to toggle exam status
      final apiService = ref.read(apiServiceProvider);
      await apiService.toggleExamStatus(widget.examId, newStatus);

      setState(() {
        _currentStatus = newStatus;
        _isLoading = false;
      });

      // Notify parent widget
      widget.onStatusChanged?.call();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus ? 'Đã mở đề thi' : 'Đã đóng đề thi',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: newStatus ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      debugPrint('🔄 Exam ${widget.examId} status changed to: $newStatus');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật trạng thái: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      debugPrint('❌ Error toggling exam status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isCompact) {
      return _buildCompactToggle(theme);
    } else {
      return _buildFullToggle(theme);
    }
  }

  Widget _buildCompactToggle(ThemeData theme) {
    return InkWell(
      onTap: _isLoading ? null : _toggleStatus,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _currentStatus ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _currentStatus ? Colors.green : Colors.red,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading) ...[
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _currentStatus ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ] else ...[
              Icon(
                _currentStatus ? Icons.play_circle : Icons.stop_circle,
                size: 14,
                color: _currentStatus ? Colors.green : Colors.red,
              ),
            ],
            if (widget.showLabel) ...[
              const SizedBox(width: 4),
              Text(
                _currentStatus ? 'Mở' : 'Đóng',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _currentStatus ? Colors.green : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _currentStatus ? Icons.visibility : Icons.visibility_off,
            color: _currentStatus ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trạng thái đề thi',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentStatus
                    ? 'Sinh viên có thể thi'
                    : 'Cấm sinh viên thi',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (_isLoading) ...[
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ] else ...[
            Switch(
              value: _currentStatus,
              onChanged: (_) => _toggleStatus(),
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red.withValues(alpha: 0.3),
            ),
          ],
        ],
      ),
    );
  }
}

/// Extension methods để dễ sử dụng
extension ExamStatusToggleExtension on Widget {
  /// Wrap widget với exam status toggle ở góc phải trên
  Widget withExamStatusToggle({
    required int examId,
    required bool initialStatus,
    VoidCallback? onStatusChanged,
  }) {
    return Stack(
      children: [
        this,
        Positioned(
          top: 8,
          right: 8,
          child: ExamStatusToggle(
            examId: examId,
            initialStatus: initialStatus,
            onStatusChanged: onStatusChanged,
            isCompact: true,
            showLabel: false,
          ),
        ),
      ],
    );
  }
}
