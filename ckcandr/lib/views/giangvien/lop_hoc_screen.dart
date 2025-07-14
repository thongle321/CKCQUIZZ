import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/core/widgets/role_themed_screen.dart';
import 'package:ckcandr/views/giangvien/widgets/teacher_lop_hoc_form_dialog.dart';
import 'package:ckcandr/views/admin/class_detail_screen.dart';

class TeacherLopHocScreen extends ConsumerStatefulWidget {
  const TeacherLopHocScreen({super.key});

  @override
  ConsumerState<TeacherLopHocScreen> createState() => _TeacherLopHocScreenState();
}

class _TeacherLopHocScreenState extends ConsumerState<TeacherLopHocScreen> {
  String _searchQuery = '';
  bool? _selectedHienThi;

  @override
  Widget build(BuildContext context) {
    final danhSachLopHocAsync = ref.watch(lopHocListProvider);
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.giangVien;

    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: danhSachLopHocAsync.when(
              data: (danhSachLopHoc) {
                final filteredLopHoc = _filterLopHocForTeacher(danhSachLopHoc, currentUser);
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
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Lỗi: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(lopHocListProvider),
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<bool?>(
                  decoration: const InputDecoration(
                    labelText: 'Hiển thị',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedHienThi,
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
                onPressed: () => ref.refresh(lopHocListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Làm mới'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLopHocCard(LopHoc lopHoc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showLopHocDetail(lopHoc),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showAddEditDialog(context, lopHoc: lopHoc);
                          break;
                        case 'delete':
                          _confirmDelete(lopHoc);
                          break;
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
              const SizedBox(height: 8),
              if (lopHoc.ghichu?.isNotEmpty == true) ...[
                Text(
                  lopHoc.ghichu!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  if (lopHoc.namhoc != null) ...[
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Năm học: ${lopHoc.namhoc}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (lopHoc.hocky != null) ...[
                    Icon(Icons.school, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Học kỳ: ${lopHoc.hocky}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Sĩ số: ${lopHoc.siso ?? 0}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              if (lopHoc.monhocs.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: lopHoc.monhocs.map((monhoc) => Chip(
                    label: Text(monhoc, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrangThaiChip(bool? trangThai) {
    final isActive = trangThai ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Hoạt động' : 'Không hoạt động',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<LopHoc> _filterLopHocForTeacher(List<LopHoc> danhSach, User? currentUser) {
    return danhSach.where((lopHoc) {
      // So sánh với user ID từ JWT token (currentUser.id)
      // Backend trả về giangvien field chứa user ID từ JWT
      final isTeacherClass = lopHoc.magiangvien == currentUser?.id;

      final matchesSearch = _searchQuery.isEmpty ||
          lopHoc.tenlop.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (lopHoc.mamoi?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          lopHoc.monhocs.any((monhoc) => monhoc.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesHienThi = _selectedHienThi == null || (lopHoc.hienthi ?? true) == _selectedHienThi;

      final result = isTeacherClass && matchesSearch && matchesHienThi;

      return result;
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
      builder: (context) => TeacherLopHocFormDialog(lopHoc: lopHoc),
    );
  }

  void _confirmDelete(LopHoc lopHoc) {
    // Xác định trạng thái hiện tại và hành động tương ứng
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
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Text('Lưu ý:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Nếu lớp đã có học sinh hoặc đề thi, bạn nên ẨN lớp thay vì xóa để tránh lỗi.',
                    style: TextStyle(fontSize: 13),
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
              Navigator.of(context).pop();

              // Toggle visibility status
              try {
                await ref.read(lopHocListProvider.notifier).toggleClassStatus(lopHoc.malop, newStatus);
                if (mounted) {
                  _showSuccessDialog('Đã $actionText lớp "${lopHoc.tenlop}" thành công!');
                }
              } catch (e) {
                if (mounted) {
                  _showErrorDialog('Lỗi khi $actionText lớp: $e');
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: isCurrentlyVisible ? Colors.orange : Colors.green,
            ),
            child: Text('$actionTextCapitalized lớp'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(lopHocListProvider.notifier).deleteLopHoc(lopHoc.malop);
                if (mounted) {
                  _showSuccessDialog('Đã xóa lớp "${lopHoc.tenlop}" thành công!');
                }
              } catch (e) {
                if (mounted) {
                  _showErrorDialog('Lỗi khi xóa lớp: $e');
                }
              }
            },
            child: const Text('Vẫn xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Thành công'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Lỗi'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
