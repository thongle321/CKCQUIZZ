/// Student Notifications Screen - Basic Version
/// 
/// Màn hình hiển thị danh sách thông báo cho sinh viên - phiên bản đơn giản như admin

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/providers/student_notification_provider.dart';
import 'package:ckcandr/core/utils/timezone_helper.dart';

class StudentNotificationsBasicScreen extends ConsumerStatefulWidget {
  const StudentNotificationsBasicScreen({super.key});

  @override
  ConsumerState<StudentNotificationsBasicScreen> createState() => _StudentNotificationsBasicScreenState();
}

class _StudentNotificationsBasicScreenState extends ConsumerState<StudentNotificationsBasicScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateNotificationDialog(BuildContext context) {
    // TODO: Implement create notification dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng tạo thông báo sẽ được thêm sau')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(studentNotificationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showCreateNotificationDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Tạo thông báo',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm thông báo',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Refresh button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(studentNotificationProvider.notifier).refresh();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notifications list
          Expanded(
            child: notificationState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : notificationState.notifications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Không có thông báo nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildNotificationsList(notificationState.notifications, theme),
          ),

          // Pagination
          if (notificationState.totalCount > notificationState.pageSize)
            _buildPagination(notificationState, theme),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<ThongBao> notifications, ThemeData theme) {
    // Filter notifications based on search query
    final filteredNotifications = notifications.where((notification) {
      if (_searchQuery.isEmpty) return true;
      return notification.noiDung.toLowerCase().contains(_searchQuery) ||
             (notification.hoTenNguoiTao?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _buildNotificationCard(notification, theme);
      },
    );
  }

  Widget _buildNotificationCard(ThongBao notification, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with menu button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      notification.noiDung.length > 50 
                          ? '${notification.noiDung.substring(0, 50)}...'
                          : notification.noiDung,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, notification),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('Xem chi tiết'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'mark_read',
                        child: Row(
                          children: [
                            Icon(Icons.mark_email_read),
                            SizedBox(width: 8),
                            Text('Đánh dấu đã đọc'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Metadata
              Row(
                children: [
                  Text(
                    'Học phần: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      notification.tenMonHoc ?? 'Không xác định',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Text(
                    'Thời gian: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    TimezoneHelper.formatDateTime(notification.thoiGianTao ?? DateTime.now()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Text(
                    'Nhóm: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'lớp ${notification.tenLop ?? 'Không xác định'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              // Pagination info at bottom
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Trang 1 / 2', // This will be dynamic in real implementation
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(NotificationState state, ThemeData theme) {
    final currentPage = state.currentPage;
    final totalPages = (state.totalCount / state.pageSize).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1
                ? () => ref.read(studentNotificationProvider.notifier).changePage(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            'Trang $currentPage / $totalPages',
            style: theme.textTheme.bodyMedium,
          ),
          IconButton(
            onPressed: currentPage < totalPages
                ? () => ref.read(studentNotificationProvider.notifier).changePage(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(ThongBao notification) {
    // Mark as read if not already read
    if (!notification.isRead && notification.maTb != null) {
      ref.read(studentNotificationProvider.notifier).markAsRead(notification.maTb!);
    }
    
    // Show details
    _showNotificationDetails(notification);
  }

  void _handleMenuAction(String action, ThongBao notification) {
    switch (action) {
      case 'view':
        _showNotificationDetails(notification);
        break;
      case 'mark_read':
        if (notification.maTb != null) {
          ref.read(studentNotificationProvider.notifier).markAsRead(notification.maTb!);
        }
        break;
    }
  }

  void _showNotificationDetails(ThongBao notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết thông báo'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nội dung:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(notification.noiDung),
              const SizedBox(height: 12),
              if (notification.hoTenNguoiTao != null) ...[
                Text(
                  'Người tạo:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(notification.hoTenNguoiTao!),
                const SizedBox(height: 12),
              ],
              Text(
                'Thời gian:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(TimezoneHelper.formatDateTime(notification.thoiGianTao ?? DateTime.now())),
            ],
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
}
