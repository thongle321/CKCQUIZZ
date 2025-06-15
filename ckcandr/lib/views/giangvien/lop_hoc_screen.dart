import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/views/giangvien/lop_hoc_detail_screen.dart';
import 'package:ckcandr/views/giangvien/quan_ly_sinh_vien_screen.dart';
import 'package:ckcandr/views/giangvien/yeu_cau_tham_gia_screen.dart';
import 'package:ckcandr/core/widgets/role_themed_screen.dart';
import 'package:ckcandr/core/theme/role_theme.dart';

class GiangVienLopHocScreen extends ConsumerStatefulWidget {
  const GiangVienLopHocScreen({super.key});

  @override
  ConsumerState<GiangVienLopHocScreen> createState() => _GiangVienLopHocScreenState();
}

class _GiangVienLopHocScreenState extends ConsumerState<GiangVienLopHocScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    ref.watch(lopHocListProvider); // Watch for changes
    final lopHocCuaToi = ref.read(lopHocListProvider.notifier)
        .getLopHocByGiangVien(currentUser?.id ?? '');
    final filteredLopHoc = _filterLopHoc(lopHocCuaToi);
    final role = currentUser?.quyen ?? UserRole.giangVien;

    return RoleThemedWidget(
      role: role,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lớp học của tôi'),
          backgroundColor: RoleTheme.getPrimaryColor(role),
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildStatsCards(lopHocCuaToi),
            Expanded(
              child: filteredLopHoc.isEmpty
                  ? const Center(
                      child: Text(
                        'Bạn chưa được phân công lớp học nào',
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

  Widget _buildSearchBar() {
    return UnifiedSearchBar(
      hintText: 'Tìm kiếm lớp học...',
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildStatsCards(List<LopHoc> lopHocList) {
    final tongLopHoc = lopHocList.length;
    final lopHoatDong = lopHocList.where((lop) => lop.trangThai == TrangThaiLop.hoatDong).length;
    final tongSinhVien = lopHocList.fold<int>(0, (sum, lop) => sum + lop.siSoHienTai);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: UnifiedStatsCard(
              title: 'Tổng lớp học',
              value: tongLopHoc.toString(),
              icon: Icons.class_,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: UnifiedStatsCard(
              title: 'Đang hoạt động',
              value: lopHoatDong.toString(),
              icon: Icons.play_circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: UnifiedStatsCard(
              title: 'Tổng sinh viên',
              value: tongSinhVien.toString(),
              icon: Icons.people,
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
                text: 'Quản lý SV',
                icon: Icons.people,
                isText: true,
                onPressed: () => _showQuanLySinhVien(lopHoc),
              ),
              const SizedBox(width: 8),
              UnifiedButton(
                text: 'Yêu cầu',
                icon: Icons.person_add,
                isText: true,
                onPressed: () => _showYeuCauThamGia(lopHoc),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrangThaiChip(TrangThaiLop trangThai) {
    Color color;
    String text;
    switch (trangThai) {
      case TrangThaiLop.hoatDong:
        color = Colors.green;
        text = 'Hoạt động';
        break;
      case TrangThaiLop.tamDung:
        color = Colors.orange;
        text = 'Tạm dừng';
        break;
      case TrangThaiLop.ketThuc:
        color = Colors.red;
        text = 'Kết thúc';
        break;
    }

    return UnifiedStatusChip(
      label: text,
      backgroundColor: color,
    );
  }

  List<LopHoc> _filterLopHoc(List<LopHoc> danhSach) {
    return danhSach.where((lopHoc) {
      return _searchQuery.isEmpty ||
          lopHoc.tenLop.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lopHoc.maLop.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lopHoc.monHocTen.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showLopHocDetail(LopHoc lopHoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiangVienLopHocDetailScreen(lopHoc: lopHoc),
      ),
    );
  }

  void _showQuanLySinhVien(LopHoc lopHoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiangVienQuanLySinhVienScreen(lopHoc: lopHoc),
      ),
    );
  }

  void _showYeuCauThamGia(LopHoc lopHoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiangVienYeuCauThamGiaScreen(lopHoc: lopHoc),
      ),
    );
  }
}


