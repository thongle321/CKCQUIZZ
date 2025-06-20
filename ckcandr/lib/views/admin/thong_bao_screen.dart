import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/services/thong_bao_service.dart';
import 'package:ckcandr/views/admin/widgets/thong_bao_form_dialog.dart';
import 'package:intl/intl.dart';

class ThongBaoScreen extends ConsumerStatefulWidget {
  const ThongBaoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ThongBaoScreen> createState() => _ThongBaoScreenState();
}

class _ThongBaoScreenState extends ConsumerState<ThongBaoScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(thongBaoNotifierProvider);
    final notifier = ref.read(thongBaoNotifierProvider.notifier);
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

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
                      'Thông báo',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateNotificationDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo thông báo'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Thanh tìm kiếm
              isSmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Tìm kiếm thông báo',
                          hintText: 'Nhập nội dung thông báo...',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    notifier.search('');
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (value) => notifier.search(value),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => notifier.loadNotifications(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Làm mới'),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Tìm kiếm thông báo',
                            hintText: 'Nhập nội dung thông báo...',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      notifier.search('');
                                    },
                                  )
                                : null,
                          ),
                          onSubmitted: (value) => notifier.search(value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => notifier.loadNotifications(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Làm mới'),
                      ),
                    ],
                  ),
            ],
          ),
        ),
        
        // Danh sách thông báo
        Expanded(
          child: notificationsAsync.when(
            data: (response) {
              if (response.items.isEmpty) {
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
                        'Không có thông báo nào',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: isSmallScreen
                        ? _buildMobileList(response.items, theme)
                        : _buildDesktopList(response.items, theme),
                  ),
                  
                  // Phân trang
                  _buildPagination(response, notifier, theme),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
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
                    'Lỗi tải dữ liệu: $error',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.red[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => notifier.loadNotifications(),
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

  Widget _buildMobileList(List<ThongBao> notifications, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          _showEditNotificationDialog(context, notification);
                        } else if (value == 'delete') {
                          _confirmDeleteNotification(context, notification);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Chỉnh sửa'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
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
                _buildNotificationInfoRow('Học phần:', '${notification.tenMonHoc} - NH${notification.namHoc} - HK${notification.hocKy}'),
                _buildNotificationInfoRow('Thời gian:', notification.thoiGianTao != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(notification.thoiGianTao!)
                    : 'Chưa xác định'),
                if (notification.nhom != null && notification.nhom!.isNotEmpty)
                  _buildNotificationInfoRow('Nhóm:', notification.nhom!.join(', ')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopList(List<ThongBao> notifications, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.noiDung,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gửi cho học phần ${notification.tenMonHoc} - NH${notification.namHoc} - HK${notification.hocKy}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        notification.thoiGianTao != null
                            ? DateFormat('dd/MM/yyyy HH:mm').format(notification.thoiGianTao!)
                            : 'Chưa xác định',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                          onPressed: () => _showEditNotificationDialog(context, notification),
                          tooltip: 'Chỉnh sửa',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _confirmDeleteNotification(context, notification),
                          tooltip: 'Xóa',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(ThongBaoPagedResponse response, ThongBaoNotifier notifier, ThemeData theme) {
    final totalPages = (response.totalCount / notifier.pageSize).ceil();
    final currentPage = notifier.currentPage;

    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: currentPage > 1
                ? () => notifier.changePage(currentPage - 1)
                : null,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Trang $currentPage / $totalPages',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: currentPage < totalPages
                ? () => notifier.changePage(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateNotificationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => const Dialog(
        child: ThongBaoFormDialog(),
      ),
    );
  }

  Future<void> _showEditNotificationDialog(BuildContext context, ThongBao notification) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ThongBaoFormDialog(notification: notification),
      ),
    );
  }

  void _confirmDeleteNotification(BuildContext context, ThongBao notification) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa thông báo này không?\n\n'
          '"${notification.noiDung}"'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
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
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
