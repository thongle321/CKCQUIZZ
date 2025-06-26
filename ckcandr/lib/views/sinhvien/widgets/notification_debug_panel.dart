import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/student_notification_provider.dart';
import 'package:ckcandr/utils/notification_test_helper.dart';
import 'package:ckcandr/views/sinhvien/widgets/notification_reminder_dialog.dart';

/// Debug panel để test tính năng thông báo trong development
/// Chỉ hiển thị khi ở debug mode
class NotificationDebugPanel extends ConsumerWidget {
  const NotificationDebugPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // chỉ hiển thị trong debug mode
    if (!_isDebugMode()) {
      return const SizedBox.shrink();
    }

    final notificationState = ref.watch(studentNotificationProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'DEBUG: Notification Panel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showDebugInfo(context, notificationState),
                icon: const Icon(Icons.info_outline, color: Colors.red),
                tooltip: 'Xem thông tin debug',
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // thông tin trạng thái hiện tại
          _buildStatusInfo(notificationState),
          
          const SizedBox(height: 12),
          
          // các nút test
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTestButton(
                'Refresh',
                Icons.refresh,
                () => ref.read(studentNotificationProvider.notifier).refresh(),
              ),
              _buildTestButton(
                'Mark All Read',
                Icons.done_all,
                () => ref.read(studentNotificationProvider.notifier).markAllAsRead(),
              ),
              _buildTestButton(
                'Show Dialog',
                Icons.notifications_active,
                () => NotificationReminderDialog.showIfNeeded(context),
              ),
              _buildTestButton(
                'Reset State',
                Icons.restore,
                () => _resetTestState(ref),
              ),
              _buildTestButton(
                'Run Tests',
                Icons.play_arrow,
                () => NotificationTestHelper.runAllTests(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// xây dựng thông tin trạng thái
  Widget _buildStatusInfo(NotificationState state) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📊 Trạng thái: ${state.isLoading ? "Đang tải..." : "Sẵn sàng"}'),
          Text('📝 Tổng số: ${state.notifications.length}'),
          Text('🔴 Chưa đọc: ${state.unreadCount}'),
          Text('✅ Đã đọc: ${state.notifications.length - state.unreadCount}'),
          if (state.error != null)
            Text('❌ Lỗi: ${state.error}', style: const TextStyle(color: Colors.red)),
          if (state.lastUpdated != null)
            Text('🕒 Cập nhật: ${_formatTime(state.lastUpdated!)}'),
        ],
      ),
    );
  }

  /// xây dựng nút test
  Widget _buildTestButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[100],
        foregroundColor: Colors.red[800],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  /// hiển thị thông tin debug chi tiết
  void _showDebugInfo(BuildContext context, NotificationState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Colors.red),
            SizedBox(width: 8),
            Text('Debug Information'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('State: ${state.toString()}'),
                const SizedBox(height: 16),
                const Text('Notifications:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...state.notifications.map((notification) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    '• ID ${notification.maTb}: ${notification.isRead ? "✅" : "🔴"} ${notification.type.name}',
                    style: const TextStyle(fontSize: 12),
                  ),
                )).toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// reset test state
  Future<void> _resetTestState(WidgetRef ref) async {
    await NotificationTestHelper.resetTestState();
    await NotificationReminderHelper.reset();
    ref.read(studentNotificationProvider.notifier).refresh();
  }

  /// kiểm tra debug mode
  bool _isDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  /// format thời gian
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}

/// Widget để hiển thị debug panel ở bottom của màn hình
class NotificationDebugOverlay extends StatelessWidget {
  final Widget child;

  const NotificationDebugOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: const NotificationDebugPanel(),
        ),
      ],
    );
  }
}

/// Extension để dễ dàng wrap widget với debug overlay
extension NotificationDebugExtension on Widget {
  Widget withNotificationDebug() {
    return NotificationDebugOverlay(child: this);
  }
}
