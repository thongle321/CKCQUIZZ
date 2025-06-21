import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/services/thong_bao_service.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/views/teacher/widgets/thong_bao_teacher_form_dialog.dart';

class ThongBaoTeacherScreen extends ConsumerStatefulWidget {
  const ThongBaoTeacherScreen({super.key});

  @override
  ConsumerState<ThongBaoTeacherScreen> createState() => _ThongBaoTeacherScreenState();
}

class _ThongBaoTeacherScreenState extends ConsumerState<ThongBaoTeacherScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => const ThongBaoTeacherFormDialog(),
    );
  }

  void _showEditNotificationDialog(ThongBao notification) {
    showDialog(
      context: context,
      builder: (context) => ThongBaoTeacherFormDialog(notification: notification),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(thongBaoNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Thông báo của tôi',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showCreateNotificationDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo thông báo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Thanh tìm kiếm
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm thông báo...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Nút làm mới
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(thongBaoNotifierProvider.notifier).loadNotifications();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[600],
                    side: BorderSide(color: Colors.green[600]!),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Danh sách thông báo
        Expanded(
          child: notificationsAsync.when(
            data: (response) {
              // Filter theo search query
              final filteredItems = _searchQuery.isEmpty
                  ? response.items
                  : response.items.where((item) =>
                      item.noiDung.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (item.tenMonHoc?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
                    ).toList();

              if (filteredItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty 
                            ? 'Chưa có thông báo nào'
                            : 'Không tìm thấy thông báo phù hợp',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_searchQuery.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Tạo thông báo đầu tiên của bạn',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final notification = filteredItems[index];
                  return _buildNotificationCard(notification, theme);
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Center(
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
                    'Lỗi tải dữ liệu',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(thongBaoNotifierProvider.notifier).loadNotifications();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(ThongBao notification, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEditNotificationDialog(notification),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với thời gian và menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      notification.noiDung,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditNotificationDialog(notification);
                      } else if (value == 'delete') {
                        _showDeleteConfirmDialog(notification);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Thông tin môn học và lớp
              if (notification.tenMonHoc != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    '${notification.tenMonHoc} - NH${notification.namHoc} - HK${notification.hocKy}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Danh sách lớp
              if (notification.nhom != null && notification.nhom!.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: notification.nhom!.map((lop) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      lop,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                        fontSize: 11,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 8),
              ],
              
              // Thời gian tạo
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    notification.thoiGianTao != null
                        ? _formatDateTime(notification.thoiGianTao!)
                        : 'Không xác định',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(ThongBao notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa thông báo "${notification.noiDung}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(thongBaoNotifierProvider.notifier)
                    .deleteNotification(notification.maTb!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa thông báo thành công!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi xóa thông báo: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
