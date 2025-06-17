import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/views/sinhvien/lop_hoc_detail_screen.dart';
import 'package:ckcandr/core/widgets/role_themed_screen.dart';
import 'package:ckcandr/core/theme/role_theme.dart';

class SinhVienLopHocScreen extends ConsumerStatefulWidget {
  const SinhVienLopHocScreen({super.key});

  @override
  ConsumerState<SinhVienLopHocScreen> createState() => _SinhVienLopHocScreenState();
}

class _SinhVienLopHocScreenState extends ConsumerState<SinhVienLopHocScreen> {
  final _maLopController = TextEditingController();

  @override
  void dispose() {
    _maLopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final allLopHoc = ref.watch(lopHocListProvider);
    final lopHocCuaToi = ref.read(lopHocListProvider.notifier)
        .getLopHocBySinhVien(currentUser?.id ?? '');
    final role = currentUser?.quyen ?? UserRole.sinhVien;

    return RoleThemedWidget(
      role: role,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lớp học của tôi'),
          backgroundColor: RoleTheme.getPrimaryColor(role),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showThamGiaLopDialog(),
            ),
          ],
        ),
        body: _buildLopDaThamGia(lopHocCuaToi),
      ),
    );
  }

  Widget _buildLopDaThamGia(List<LopHoc> lopHocList) {
    if (lopHocList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Bạn chưa tham gia lớp học nào',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Nhấn nút + để tham gia lớp học',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lopHocList.length,
      itemBuilder: (context, index) {
        final lopHoc = lopHocList[index];
        return _buildLopHocCard(lopHoc);
      },
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



  void _showThamGiaLopDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tham gia lớp học'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _maLopController,
              decoration: const InputDecoration(
                labelText: 'Mã lớp',
                hintText: 'Nhập mã lớp học',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _maLopController.clear();
              Navigator.pop(context);
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => _submitYeuCauThamGia(),
            child: const Text('Tham gia'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitYeuCauThamGia() async {
    final maLop = _maLopController.text.trim();
    if (maLop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã lớp')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    try {
      // Tìm lớp học theo mã lớp
      final allLopHoc = ref.read(lopHocListProvider);
      final lopHoc = allLopHoc.firstWhere(
        (lop) => lop.maLop.toUpperCase() == maLop.toUpperCase(),
        orElse: () => throw Exception('Không tìm thấy lớp học'),
      );

      // Kiểm tra xem sinh viên đã tham gia chưa
      if (lopHoc.danhSachSinhVienIds.contains(currentUser.id)) {
        _maLopController.clear();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bạn đã tham gia lớp học này rồi!')),
          );
        }
        return;
      }

      // Kiểm tra xem lớp có thể thêm sinh viên không
      if (!lopHoc.coTheThemSinhVien) {
        _maLopController.clear();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lớp học đã đầy hoặc không còn hoạt động!')),
          );
        }
        return;
      }

      // Thêm sinh viên vào lớp
      ref.read(lopHocListProvider.notifier).addSinhVienToLop(lopHoc.id, currentUser.id);

      _maLopController.clear();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tham gia lớp "${lopHoc.tenLop}" thành công!')),
        );
      }
    } catch (e) {
      _maLopController.clear();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy lớp học với mã này')),
        );
      }
    }
  }

  void _showLopHocDetail(LopHoc lopHoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SinhVienLopHocDetailScreen(lopHoc: lopHoc),
      ),
    );
  }


}


