import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/core/widgets/role_themed_screen.dart';
import 'package:ckcandr/views/admin/class_detail_screen.dart';
import 'package:ckcandr/views/student/widgets/join_class_dialog.dart';

class StudentLopHocScreen extends ConsumerStatefulWidget {
  const StudentLopHocScreen({super.key});

  @override
  ConsumerState<StudentLopHocScreen> createState() => _StudentLopHocScreenState();
}

class _StudentLopHocScreenState extends ConsumerState<StudentLopHocScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final danhSachLopHocAsync = ref.watch(lopHocListProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: danhSachLopHocAsync.when(
              data: (danhSachLopHoc) {
                final filteredLopHoc = _filterLopHoc(danhSachLopHoc);
                if (filteredLopHoc.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Bạn chưa tham gia lớp học nào',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Nhấn nút + để tham gia lớp bằng mã mời',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
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
        onPressed: () => _showJoinClassDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Tham gia lớp học',
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
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
          const SizedBox(width: 16),
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
          Text('Sĩ số: ${lopHoc.siso ?? 0} sinh viên'),
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

      return matchesSearch;
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

  void _showJoinClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const JoinClassDialog(),
    ).then((_) {
      // Refresh class list after joining
      ref.read(lopHocListProvider.notifier).loadClasses();
    });
  }
}
