import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/core/utils/timezone_helper.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/student_notification_provider.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/core/utils/responsive_helper.dart';

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
      body: _buildBody(context, theme, notificationState, ref, isSmallScreen),
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
        // BỎ button "Đánh dấu tất cả đã đọc"
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

        // Main list with refresh indicator - CẢI THIỆN PULL-TO-REFRESH
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(studentNotificationProvider.notifier).refresh(),
            displacement: 20, // Đẩy refresh indicator xuống để không che content
            color: Theme.of(context).primaryColor,
            backgroundColor: Colors.white,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(), // Cho phép scroll ngay cả khi ít item
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
      elevation: 2, // Đồng nhất elevation cho tất cả thông báo
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(context, notification, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // Bỏ màu nền khác biệt cho đã đọc/chưa đọc
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
                          'Thông báo',
                          style: TextStyle(
                            fontWeight: FontWeight.w600, // Đồng nhất font weight
                            fontSize: 16,
                            color: Colors.black87, // Đồng nhất màu chữ
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
                      // BỎ indicator chấm tròn cho thông báo chưa đọc
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


            ],
          ),
        ),
      ),
    );
  }





  /// xử lý khi tap vào thông báo
  void _handleNotificationTap(
    BuildContext context,
    ThongBao notification,
    WidgetRef ref,
  ) {
    // BỎ logic đánh dấu đã đọc tự động

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
      // fallback: điều hướng đến tab bài kiểm tra trong dashboard
      _navigateToExamsTab(context);
    }
  }

  /// điều hướng đến tab bài kiểm tra trong dashboard
  void _navigateToExamsTab(BuildContext context) {
    // Sử dụng GoRouter để điều hướng đến dashboard với tab bài kiểm tra (index 2)
    context.go('/sinhvien/dashboard?tab=2');
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



  /// format thời gian hiển thị
  String _formatTimeAgo(DateTime? dateTime) {
    return TimezoneHelper.formatTimeAgo(dateTime);
  }

  /// format ngày giờ đầy đủ
  String _formatDateTime(DateTime dateTime) {
    return TimezoneHelper.formatDateTime(dateTime);
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
