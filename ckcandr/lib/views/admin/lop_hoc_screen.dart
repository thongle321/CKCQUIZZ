import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/core/widgets/role_themed_screen.dart';

class AdminLopHocScreen extends ConsumerStatefulWidget {
  const AdminLopHocScreen({super.key});

  @override
  ConsumerState<AdminLopHocScreen> createState() => _AdminLopHocScreenState();
}

class _AdminLopHocScreenState extends ConsumerState<AdminLopHocScreen> {
  String _searchQuery = '';
  bool? _selectedTrangThai;

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
          child: Row(
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
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Refresh data
                  setState(() {});
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
              _buildTrangThaiChip(lopHoc.trangthai),
            ],
          ),
          const SizedBox(height: 12),
          Text('Môn học: ${lopHoc.monhocs.isNotEmpty ? lopHoc.monhocs.first : "Chưa có"}'),
          const SizedBox(height: 4),
          Text('Năm học: ${lopHoc.namhoc ?? "Chưa có"}'),
          const SizedBox(height: 4),
          Text('Học kỳ: ${lopHoc.hocky ?? "Chưa có"}'),
          const SizedBox(height: 4),
          Text('Sĩ số: ${lopHoc.siso ?? "Chưa có"}'),
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
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Xóa'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => _confirmDelete(lopHoc),
              ),
            ],
          ),
        ],
      ),
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

      return matchesSearch && matchesTrangThai;
    }).toList();
  }

  void _showLopHocDetail(LopHoc lopHoc) {
    // TODO: Implement detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chi tiết lớp: ${lopHoc.tenlop}')),
    );
  }

  void _showAddEditDialog(BuildContext context, {LopHoc? lopHoc}) {
    // TODO: Implement form dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form thêm/sửa lớp học sẽ được triển khai sau')),
    );
  }

  void _confirmDelete(LopHoc lopHoc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa lớp "${lopHoc.tenlop}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              ref.read(lopHocListProvider.notifier).deleteLopHoc(lopHoc.malop);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa lớp "${lopHoc.tenlop}"')),
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


