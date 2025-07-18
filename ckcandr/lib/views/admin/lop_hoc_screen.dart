import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/core/widgets/role_themed_screen.dart';
import 'package:ckcandr/views/admin/widgets/lop_hoc_form_dialog.dart';
import 'package:ckcandr/views/admin/class_detail_screen.dart';
import 'package:ckcandr/services/api_service.dart';

class AdminLopHocScreen extends ConsumerStatefulWidget {
  const AdminLopHocScreen({super.key});

  @override
  ConsumerState<AdminLopHocScreen> createState() => _AdminLopHocScreenState();
}

class _AdminLopHocScreenState extends ConsumerState<AdminLopHocScreen> {
  String _searchQuery = '';
  bool? _selectedTrangThai;
  bool? _selectedHienThi;

  @override
  Widget build(BuildContext context) {
    final danhSachLopHocAsync = ref.watch(lopHocListProvider);
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.admin;

    return Scaffold(
      
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: danhSachLopHocAsync.when(
              data: (danhSachLopHoc) {
                final filteredLopHoc = _filterLopHoc(danhSachLopHoc);
                if (filteredLopHoc.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không có lớp học nào',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLopHoc.length,
                  itemBuilder: (context, index) {
                    final lopHoc = filteredLopHoc[index];
                    return _buildLopHocCard(lopHoc);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi: $error'),
                    ElevatedButton(
                      onPressed: () => ref.read(lopHocListProvider.notifier).loadClasses(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm lớp học...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Filter and refresh
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<bool?>(
                      value: _selectedTrangThai,
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả')),
                        DropdownMenuItem(value: true, child: Text('Hoạt động')),
                        DropdownMenuItem(value: false, child: Text('Tạm dừng')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTrangThai = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<bool?>(
                      value: _selectedHienThi,
                      decoration: const InputDecoration(
                        labelText: 'Hiển thị',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả')),
                        DropdownMenuItem(value: true, child: Text('Hiển thị')),
                        DropdownMenuItem(value: false, child: Text('Ẩn')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedHienThi = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(lopHocListProvider.notifier).loadClasses();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Làm mới'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLopHocCard(LopHoc lopHoc) {

    return UnifiedCard(
      onTap: () => _showLopHocDetail(lopHoc),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lopHoc.tenlop,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mã mời: ${lopHoc.mamoi ?? "Chưa có"}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPendingRequestsBadge(lopHoc),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTrangThaiChip(lopHoc.trangthai),
                  const SizedBox(width: 4),
                  // Icon mắt hiển thị trạng thái hiển thị
                  Icon(
                    (lopHoc.hienthi ?? true) ? Icons.visibility : Icons.visibility_off,
                    size: 16,
                    color: (lopHoc.hienthi ?? true) ? Colors.green : Colors.orange,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Môn học: ${lopHoc.monhocs.isNotEmpty ? lopHoc.monhocs.first : "Chưa có"}'),
          const SizedBox(height: 4),
          Text('Năm học: ${lopHoc.namhoc ?? "Chưa có"}'),
          const SizedBox(height: 4),
          Text('Học kỳ: ${lopHoc.hocky ?? "Chưa có"}'),
          const SizedBox(height: 4),
          FutureBuilder<int>(
            future: ref.read(apiServiceProvider).getPendingRequestCount(lopHoc.malop),
            builder: (context, snapshot) {
              final pendingCount = snapshot.data ?? 0;
              return Text('Sĩ số: ${lopHoc.siso ?? 0} - Yêu cầu: $pendingCount');
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              UnifiedButton(
                text: 'Sửa',
                icon: Icons.edit,
                isText: true,
                onPressed: () => _showAddEditDialog(context, lopHoc: lopHoc),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: Icon(
                  (lopHoc.hienthi ?? true) ? Icons.visibility_off : Icons.visibility,
                  size: 16,
                ),
                label: Text((lopHoc.hienthi ?? true) ? 'Ẩn' : 'Hiện'),
                style: TextButton.styleFrom(
                  foregroundColor: (lopHoc.hienthi ?? true) ? Colors.orange : Colors.green,
                ),
                onPressed: () => _toggleClassVisibility(lopHoc),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsBadge(LopHoc lopHoc) {
    return FutureBuilder<int>(
      future: ref.read(apiServiceProvider).getPendingRequestCount(lopHoc.malop),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data ?? 0;

        if (pendingCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.notifications,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                pendingCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrangThaiChip(bool? trangThai) {
    Color color;
    String text;

    if (trangThai == true) {
      color = Colors.green;
      text = 'Hoạt động';
    } else {
      color = Colors.orange;
      text = 'Tạm dừng';
    }

    return UnifiedStatusChip(
      label: text,
      backgroundColor: color,
    );
  }

  List<LopHoc> _filterLopHoc(List<LopHoc> danhSach) {
    return danhSach.where((lopHoc) {
      final matchesSearch = _searchQuery.isEmpty ||
          lopHoc.tenlop.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (lopHoc.mamoi?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          lopHoc.monhocs.any((monhoc) => monhoc.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesTrangThai = _selectedTrangThai == null || lopHoc.trangthai == _selectedTrangThai;
      final matchesHienThi = _selectedHienThi == null || (lopHoc.hienthi ?? true) == _selectedHienThi;

      return matchesSearch && matchesTrangThai && matchesHienThi;
    }).toList();
  }

  void _showLopHocDetail(LopHoc lopHoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassDetailScreen(lopHoc: lopHoc),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {LopHoc? lopHoc}) {
    showDialog(
      context: context,
      builder: (context) => LopHocFormDialog(lopHoc: lopHoc),
    );
  }

  void _toggleClassVisibility(LopHoc lopHoc) {
    final isCurrentlyVisible = lopHoc.hienthi ?? true;
    final actionText = isCurrentlyVisible ? 'ẩn' : 'hiện';
    final actionTextCapitalized = isCurrentlyVisible ? 'Ẩn' : 'Hiện';
    final newStatus = !isCurrentlyVisible;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận $actionText lớp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc chắn muốn $actionText lớp "${lopHoc.tenlop}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      const Text('Thông tin:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCurrentlyVisible
                      ? 'Lớp sẽ bị ẩn khỏi danh sách của sinh viên nhưng vẫn giữ nguyên dữ liệu.'
                      : 'Lớp sẽ hiển thị trở lại trong danh sách của sinh viên.',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              navigator.pop();

              try {
                await ref.read(lopHocListProvider.notifier).toggleClassStatus(lopHoc.malop, newStatus);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Đã $actionText lớp "${lopHoc.tenlop}" thành công!'),
                    backgroundColor: isCurrentlyVisible ? Colors.orange : Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Lỗi khi $actionText lớp: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: isCurrentlyVisible ? Colors.orange : Colors.green,
            ),
            child: Text(actionTextCapitalized),
          ),
        ],
      ),
    );
  }
}


