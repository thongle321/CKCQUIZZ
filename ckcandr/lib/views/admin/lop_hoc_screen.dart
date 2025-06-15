import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/views/admin/lop_hoc_detail_screen.dart';
import 'package:ckcandr/views/admin/lop_hoc_form_dialog.dart';
import 'package:ckcandr/core/widgets/role_themed_screen.dart';
import 'package:ckcandr/core/theme/role_theme.dart';

class AdminLopHocScreen extends ConsumerStatefulWidget {
  const AdminLopHocScreen({super.key});

  @override
  ConsumerState<AdminLopHocScreen> createState() => _AdminLopHocScreenState();
}

class _AdminLopHocScreenState extends ConsumerState<AdminLopHocScreen> {
  String _searchQuery = '';
  TrangThaiLop? _selectedTrangThai;

  @override
  Widget build(BuildContext context) {
    final danhSachLopHoc = ref.watch(lopHocListProvider);
    final filteredLopHoc = _filterLopHoc(danhSachLopHoc);
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.admin;

    return RoleThemedWidget(
      role: role,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý lớp học'),
          backgroundColor: RoleTheme.getPrimaryColor(role),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddEditDialog(context),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: filteredLopHoc.isEmpty
                  ? const Center(
                      child: Text(
                        'Không có lớp học nào',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredLopHoc.length,
                      itemBuilder: (context, index) {
                        final lopHoc = filteredLopHoc[index];
                        return _buildLopHocCard(lopHoc);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.admin;

    return Container(
      padding: const EdgeInsets.all(16),
      color: RoleTheme.getAccentColor(role),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm lớp học...',
              prefixIcon: Icon(Icons.search, color: RoleTheme.getPrimaryColor(role)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: RoleTheme.getPrimaryColor(role), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TrangThaiLop?>(
            value: _selectedTrangThai,
            decoration: InputDecoration(
              labelText: 'Trạng thái',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: RoleTheme.getPrimaryColor(role), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tất cả')),
              ...TrangThaiLop.values.map((trangThai) => DropdownMenuItem(
                    value: trangThai,
                    child: Text(_getTrangThaiText(trangThai)),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedTrangThai = value;
              });
            },
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
                      lopHoc.tenLop,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mã lớp: ${lopHoc.maLop}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildTrangThaiChip(lopHoc.trangThai),
            ],
          ),
          const SizedBox(height: 12),
          Text('Môn học: ${lopHoc.monHocTen}'),
          const SizedBox(height: 4),
          Text('Giảng viên: ${lopHoc.giangVienTen}'),
          const SizedBox(height: 4),
          Text('Sĩ số: ${lopHoc.siSoHienTai}/${lopHoc.siSo}'),
          const SizedBox(height: 12),
          UnifiedProgressIndicator(
            value: lopHoc.phanTramDayLop / 100,
            label: 'Tỷ lệ đầy lớp',
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

  Widget _buildTrangThaiChip(TrangThaiLop trangThai) {
    Color color;
    switch (trangThai) {
      case TrangThaiLop.hoatDong:
        color = Colors.green;
        break;
      case TrangThaiLop.tamDung:
        color = Colors.orange;
        break;
      case TrangThaiLop.ketThuc:
        color = Colors.red;
        break;
    }

    return UnifiedStatusChip(
      label: _getTrangThaiText(trangThai),
      backgroundColor: color,
    );
  }

  String _getTrangThaiText(TrangThaiLop trangThai) {
    switch (trangThai) {
      case TrangThaiLop.hoatDong:
        return 'Hoạt động';
      case TrangThaiLop.tamDung:
        return 'Tạm dừng';
      case TrangThaiLop.ketThuc:
        return 'Kết thúc';
    }
  }

  List<LopHoc> _filterLopHoc(List<LopHoc> danhSach) {
    return danhSach.where((lopHoc) {
      final matchesSearch = _searchQuery.isEmpty ||
          lopHoc.tenLop.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lopHoc.maLop.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lopHoc.monHocTen.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lopHoc.giangVienTen.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesTrangThai = _selectedTrangThai == null || lopHoc.trangThai == _selectedTrangThai;

      return matchesSearch && matchesTrangThai;
    }).toList();
  }

  void _showLopHocDetail(LopHoc lopHoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminLopHocDetailScreen(lopHoc: lopHoc),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {LopHoc? lopHoc}) {
    showDialog(
      context: context,
      builder: (context) => AdminLopHocFormDialog(lopHoc: lopHoc),
    );
  }

  void _confirmDelete(LopHoc lopHoc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa lớp "${lopHoc.tenLop}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              ref.read(lopHocListProvider.notifier).deleteLopHoc(lopHoc.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa lớp "${lopHoc.tenLop}"')),
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


