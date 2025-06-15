import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';

class GiangVienQuanLySinhVienScreen extends ConsumerStatefulWidget {
  final LopHoc lopHoc;

  const GiangVienQuanLySinhVienScreen({super.key, required this.lopHoc});

  @override
  ConsumerState<GiangVienQuanLySinhVienScreen> createState() => _GiangVienQuanLySinhVienScreenState();
}

class _GiangVienQuanLySinhVienScreenState extends ConsumerState<GiangVienQuanLySinhVienScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final lopHoc = ref.watch(lopHocListProvider)
        .firstWhere((lop) => lop.id == widget.lopHoc.id, orElse: () => widget.lopHoc);
    final danhSachUser = ref.watch(userListProvider);
    final sinhVienTrongLop = danhSachUser
        .where((user) => lopHoc.danhSachSinhVienIds.contains(user.id))
        .toList();
    final filteredSinhVien = _filterSinhVien(sinhVienTrongLop);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sinh viên'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddStudentDialog(lopHoc),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsCard(lopHoc, sinhVienTrongLop),
          Expanded(
            child: filteredSinhVien.isEmpty
                ? const Center(
                    child: Text(
                      'Không tìm thấy sinh viên nào',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSinhVien.length,
                    itemBuilder: (context, index) {
                      final sinhVien = filteredSinhVien[index];
                      return _buildSinhVienCard(sinhVien, lopHoc);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm sinh viên...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildStatsCard(LopHoc lopHoc, List<User> sinhVienList) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thống kê lớp học',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Tổng sinh viên',
                      '${sinhVienList.length}',
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Sĩ số tối đa',
                      '${lopHoc.siSo}',
                      Icons.group,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Còn trống',
                      '${lopHoc.siSo - sinhVienList.length}',
                      Icons.person_add,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Tỷ lệ đầy lớp: ${lopHoc.phanTramDayLop.toStringAsFixed(1)}%'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: lopHoc.phanTramDayLop / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  lopHoc.phanTramDayLop > 80 ? Colors.red : Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSinhVienCard(User sinhVien, LopHoc lopHoc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Text(
                    sinhVien.hoVaTen[0].toUpperCase(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sinhVien.hoVaTen,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MSSV: ${sinhVien.mssv}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditStudentDialog(sinhVien);
                        break;
                      case 'remove':
                        _confirmRemoveStudent(sinhVien, lopHoc);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
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
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.remove_circle, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa khỏi lớp', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sinhVien.email,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  sinhVien.gioiTinh ? 'Nam' : 'Nữ',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<User> _filterSinhVien(List<User> danhSach) {
    if (_searchQuery.isEmpty) return danhSach;
    
    final lowerQuery = _searchQuery.toLowerCase();
    return danhSach.where((sinhVien) {
      return sinhVien.hoVaTen.toLowerCase().contains(lowerQuery) ||
             sinhVien.mssv.toLowerCase().contains(lowerQuery) ||
             sinhVien.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void _showAddStudentDialog(LopHoc lopHoc) {
    final danhSachUser = ref.read(userListProvider);
    final sinhVienChuaThamGia = danhSachUser
        .where((user) => 
            user.quyen == UserRole.sinhVien && 
            !lopHoc.danhSachSinhVienIds.contains(user.id))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm sinh viên vào lớp'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: sinhVienChuaThamGia.isEmpty
              ? const Center(
                  child: Text('Không có sinh viên nào để thêm'),
                )
              : ListView.builder(
                  itemCount: sinhVienChuaThamGia.length,
                  itemBuilder: (context, index) {
                    final sinhVien = sinhVienChuaThamGia[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(sinhVien.hoVaTen[0].toUpperCase()),
                      ),
                      title: Text(sinhVien.hoVaTen),
                      subtitle: Text('MSSV: ${sinhVien.mssv}'),
                      onTap: () {
                        ref.read(lopHocListProvider.notifier)
                            .addSinhVienToLop(lopHoc.id, sinhVien.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm ${sinhVien.hoVaTen} vào lớp'),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showEditStudentDialog(User sinhVien) {
    // TODO: Implement edit student functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chỉnh sửa thông tin ${sinhVien.hoVaTen}')),
    );
  }

  void _confirmRemoveStudent(User sinhVien, LopHoc lopHoc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${sinhVien.hoVaTen}" khỏi lớp?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              ref.read(lopHocListProvider.notifier)
                  .removeSinhVienFromLop(lopHoc.id, sinhVien.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa "${sinhVien.hoVaTen}" khỏi lớp')),
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
