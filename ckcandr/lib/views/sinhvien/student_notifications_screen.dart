import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/student_notification_provider.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/core/utils/responsive_helper.dart';
import 'package:ckcandr/views/sinhvien/widgets/notification_debug_panel.dart';

/// Student Notifications Screen - Màn hình thông báo nâng cao cho sinh viên
/// Sử dụng API thật và state management chuyên nghiệp với Riverpod
class StudentNotificationsScreen extends ConsumerWidget {
  const StudentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;
    final notificationState = ref.watch(studentNotificationProvider);
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context, theme, role, notificationState, ref),
      body: _buildBody(context, theme, notificationState, ref, isSmallScreen).withNotificationDebug(),
      floatingActionButton: _buildFloatingActionButton(context, role, ref),
    );
  }

  /// xây dựng app bar với thông tin thống kê và search
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    UserRole role,
    NotificationState notificationState,
    WidgetRef ref,
  ) {
    return AppBar(
      backgroundColor: RoleTheme.getPrimaryColor(role),
      foregroundColor: Colors.white,
      elevation: 2,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông báo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (notificationState.unreadCount > 0)
            Text(
              '${notificationState.unreadCount} thông báo chưa đọc',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          if (notificationState.totalCount > 0)
            Text(
              'Tổng: ${notificationState.totalCount} thông báo',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white60,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showSearchDialog(context, ref),
          icon: const Icon(Icons.search),
          tooltip: 'Tìm kiếm',
        ),
        if (notificationState.unreadCount > 0)
          IconButton(
            onPressed: () => ref.read(studentNotificationProvider.notifier).markAllAsRead(),
            icon: const Icon(Icons.done_all),
            tooltip: 'Đánh dấu tất cả đã đọc',
          ),
        IconButton(
          onPressed: () => ref.read(studentNotificationProvider.notifier).refresh(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Làm mới',
        ),
      ],
    );
  }

  /// xây dựng body chính
  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    NotificationState notificationState,
    WidgetRef ref,
    bool isSmallScreen,
  ) {
    if (notificationState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải thông báo...'),
          ],
        ),
      );
    }

    if (notificationState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              notificationState.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(studentNotificationProvider.notifier).refresh(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (notificationState.notifications.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      children: [
        // Search indicator
        if (notificationState.searchQuery != null && notificationState.searchQuery!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.amber[50],
            child: Row(
              children: [
                const Icon(Icons.search, size: 18, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kết quả tìm kiếm cho: "${notificationState.searchQuery}"',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.amber[800],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => ref.read(studentNotificationProvider.notifier).clearSearch(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Xóa tìm kiếm',
                ),
              ],
            ),
          ),

        // Main list with refresh indicator
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(studentNotificationProvider.notifier).refresh(),
            child: ListView.builder(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              itemCount: notificationState.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationState.notifications[index];
                return _buildNotificationCard(context, theme, notification, ref);
              },
            ),
          ),
        ),

        // Pagination controls
        if (notificationState.totalCount > notificationState.pageSize)
          _buildPaginationControls(context, notificationState, ref),
      ],
    );
  }

  /// xây dựng trạng thái rỗng
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có thông báo nào',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thông báo mới sẽ xuất hiện ở đây',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// xây dựng card thông báo
  Widget _buildNotificationCard(
    BuildContext context,
    ThemeData theme,
    ThongBao notification,
    WidgetRef ref,
  ) {
    final notificationIcon = _getNotificationIcon(notification.type);
    final notificationColor = _getNotificationColor(notification.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(context, notification, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification.isRead ? null : notificationColor.withValues(alpha: 0.05),
            border: notification.isRead
                ? null
                : Border.all(color: notificationColor.withValues(alpha: 0.2), width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header với icon và thời gian
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: notificationColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      notificationIcon,
                      color: notificationColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông báo từ giáo viên',
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 16,
                            color: notification.isRead ? Colors.grey[700] : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTimeAgo(notification.thoiGianTao),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: notificationColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // nội dung thông báo
              Text(
                notification.noiDung,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),

              // thông tin người gửi
              if (notification.hoTenNguoiTao != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, size: 16, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Từ: ${notification.hoTenNguoiTao}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],

              // nút hành động cho thông báo thi
              if (notification.isExamNotification) ...[
                const SizedBox(height: 12),
                _buildExamActionButton(context, notification, notificationColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// xây dựng nút hành động cho thông báo thi
  Widget _buildExamActionButton(
    BuildContext context,
    ThongBao notification,
    Color buttonColor,
  ) {
    final canTakeExam = notification.canTakeExam;
    final isExpired = notification.isExamExpired;
    final timeUntilExam = notification.timeUntilExam;

    String buttonText;
    IconData buttonIcon;
    VoidCallback? onPressed;

    if (isExpired) {
      buttonText = 'Đã hết hạn';
      buttonIcon = Icons.access_time;
      onPressed = null;
    } else if (canTakeExam) {
      buttonText = 'Vào thi ngay';
      buttonIcon = Icons.play_arrow;
      onPressed = () => _navigateToExam(context, notification);
    } else if (timeUntilExam != null) {
      final hours = timeUntilExam.inHours;
      final minutes = timeUntilExam.inMinutes % 60;
      buttonText = 'Còn ${hours}h ${minutes}m';
      buttonIcon = Icons.schedule;
      onPressed = null;
    } else {
      buttonText = 'Xem chi tiết';
      buttonIcon = Icons.info_outline;
      onPressed = () => _showExamDetails(context, notification);
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(buttonIcon, size: 18),
        label: Text(buttonText),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? buttonColor : Colors.grey[400],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// xây dựng floating action button
  Widget? _buildFloatingActionButton(
    BuildContext context,
    UserRole role,
    WidgetRef ref,
  ) {
    return FloatingActionButton(
      onPressed: () => ref.read(studentNotificationProvider.notifier).refresh(),
      backgroundColor: RoleTheme.getPrimaryColor(role),
      child: const Icon(Icons.refresh, color: Colors.white),
    );
  }

  /// xử lý khi tap vào thông báo
  void _handleNotificationTap(
    BuildContext context,
    ThongBao notification,
    WidgetRef ref,
  ) {
    // đánh dấu đã đọc
    if (!notification.isRead && notification.maTb != null) {
      ref.read(studentNotificationProvider.notifier).markAsRead(notification.maTb!);
    }

    // hiển thị chi tiết hoặc thực hiện hành động
    if (notification.isExamNotification) {
      _showExamDetails(context, notification);
    } else {
      _showNotificationDetails(context, notification);
    }
  }

  /// điều hướng đến màn hình thi
  void _navigateToExam(BuildContext context, ThongBao notification) {
    if (notification.examId != null) {
      // điều hướng đến màn hình thi với exam ID
      context.push('/sinhvien/exam/${notification.examId}');
    } else {
      // fallback: điều hướng đến danh sách bài kiểm tra
      context.push('/sinhvien/class-exams');
    }
  }

  /// hiển thị chi tiết đề thi
  void _showExamDetails(BuildContext context, ThongBao notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.quiz,
              color: _getNotificationColor(notification.type),
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('Chi tiết bài kiểm tra')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.examName != null) ...[
              Text(
                'Tên bài thi:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(notification.examName!),
              const SizedBox(height: 12),
            ],
            Text(
              'Nội dung:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            Text(notification.noiDung),
            if (notification.examStartTime != null) ...[
              const SizedBox(height: 12),
              Text(
                'Thời gian bắt đầu:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(_formatDateTime(notification.examStartTime!)),
            ],
            if (notification.examEndTime != null) ...[
              const SizedBox(height: 8),
              Text(
                'Thời gian kết thúc:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(_formatDateTime(notification.examEndTime!)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          if (notification.canTakeExam)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToExam(context, notification);
              },
              child: const Text('Vào thi'),
            ),
        ],
      ),
    );
  }

  /// hiển thị chi tiết thông báo thường
  void _showNotificationDetails(BuildContext context, ThongBao notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('Chi tiết thông báo')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nội dung:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            Text(notification.noiDung),
            if (notification.tenMonHoc != null) ...[
              const SizedBox(height: 12),
              Text(
                'Môn học:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(notification.tenMonHoc!),
            ],
            if (notification.hoTenNguoiTao != null) ...[
              const SizedBox(height: 12),
              Text(
                'Người gửi:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(notification.hoTenNguoiTao!),
            ],
            if (notification.thoiGianTao != null) ...[
              const SizedBox(height: 12),
              Text(
                'Thời gian:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(_formatDateTime(notification.thoiGianTao!)),
            ],
          ],
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

  /// lấy icon cho loại thông báo
  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.examNew:
        return Icons.assignment_add;
      case NotificationType.examReminder:
        return Icons.alarm;
      case NotificationType.examUpdate:
        return Icons.edit_note;
      case NotificationType.examResult:
        return Icons.grade;
      case NotificationType.classInfo:
        return Icons.class_;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  /// lấy màu cho loại thông báo
  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.examNew:
        return Colors.blue;
      case NotificationType.examReminder:
        return Colors.orange;
      case NotificationType.examUpdate:
        return Colors.purple;
      case NotificationType.examResult:
        return Colors.green;
      case NotificationType.classInfo:
        return Colors.teal;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.general:
        return Colors.indigo;
    }
  }

  /// lấy tiêu đề thông báo
  String _getNotificationTitle(ThongBao notification) {
    switch (notification.type) {
      case NotificationType.examNew:
        return 'Đề thi mới';
      case NotificationType.examReminder:
        return 'Nhắc nhở thi';
      case NotificationType.examUpdate:
        return 'Cập nhật đề thi';
      case NotificationType.examResult:
        return 'Kết quả thi';
      case NotificationType.classInfo:
        return 'Thông báo lớp học';
      case NotificationType.system:
        return 'Thông báo hệ thống';
      case NotificationType.general:
        return 'Thông báo';
    }
  }

  /// format thời gian hiển thị
  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Không rõ';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  /// format ngày giờ đầy đủ
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// xây dựng pagination controls như Vue.js
  Widget _buildPaginationControls(
    BuildContext context,
    NotificationState notificationState,
    WidgetRef ref
  ) {
    final totalPages = (notificationState.totalCount / notificationState.pageSize).ceil();
    final currentPage = notificationState.currentPage;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page info
          Text(
            'Trang $currentPage/$totalPages (${notificationState.totalCount} thông báo)',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),

          // Navigation buttons
          Row(
            children: [
              IconButton(
                onPressed: currentPage > 1
                  ? () => ref.read(studentNotificationProvider.notifier).changePage(currentPage - 1)
                  : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Trang trước',
              ),
              const SizedBox(width: 8),
              Text(
                '$currentPage',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: currentPage < totalPages
                  ? () => ref.read(studentNotificationProvider.notifier).changePage(currentPage + 1)
                  : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Trang sau',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// hiển thị dialog search như Vue.js
  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    final notificationState = ref.read(studentNotificationProvider);
    final controller = TextEditingController(text: notificationState.searchQuery ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.search),
            SizedBox(width: 8),
            Text('Tìm kiếm thông báo'),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nhập nội dung cần tìm...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.of(context).pop();
            ref.read(studentNotificationProvider.notifier).searchNotifications(
              value.trim().isEmpty ? null : value.trim()
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(studentNotificationProvider.notifier).clearSearch();
            },
            child: const Text('Xóa bộ lọc'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(studentNotificationProvider.notifier).searchNotifications(
                controller.text.trim().isEmpty ? null : controller.text.trim()
              );
            },
            child: const Text('Tìm kiếm'),
          ),
        ],
      ),
    );
  }
}
