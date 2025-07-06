/// Teacher Notifications Screen - Basic Version
/// 
/// Màn hình hiển thị danh sách thông báo cho giáo viên - phiên bản đơn giản như admin

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/services/thong_bao_service.dart';
import 'package:ckcandr/core/utils/timezone_helper.dart';

class TeacherNotificationsBasicScreen extends ConsumerStatefulWidget {
  const TeacherNotificationsBasicScreen({super.key});

  @override
  ConsumerState<TeacherNotificationsBasicScreen> createState() => _TeacherNotificationsBasicScreenState();
}

class _TeacherNotificationsBasicScreenState extends ConsumerState<TeacherNotificationsBasicScreen> {
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
    final notificationsAsync = ref.watch(thongBaoNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.green,
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
                    ref.read(thongBaoNotifierProvider.notifier).loadNotifications();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notifications list
          Expanded(
            child: notificationsAsync.when(
              data: (response) {
                if (response.items.isEmpty) {
                  return const Center(
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
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: _buildNotificationsList(response.items, theme),
                    ),
                    _buildPagination(response, theme),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: $error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(thongBaoNotifierProvider.notifier).loadNotifications();
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
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

  Widget _buildPagination(dynamic response, ThemeData theme) {
    // This is a simplified pagination - in real implementation, 
    // you would use the actual pagination data from the response
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              // TODO: Implement previous page
            },
            icon: const Icon(Icons.chevron_left),
          ),
          const Text('Trang 1 / 2'),
          IconButton(
            onPressed: () {
              // TODO: Implement next page
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(ThongBao notification) {
    _showNotificationDetails(notification);
  }

  void _handleMenuAction(String action, ThongBao notification) {
    switch (action) {
      case 'view':
        _showNotificationDetails(notification);
        break;
      case 'edit':
        // TODO: Implement edit functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chức năng chỉnh sửa sẽ được thêm sau')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(notification);
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

  void _showDeleteConfirmation(ThongBao notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa thông báo này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng xóa sẽ được thêm sau')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
