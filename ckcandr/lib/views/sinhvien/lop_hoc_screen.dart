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
  final _lyDoController = TextEditingController();

  @override
  void dispose() {
    _maLopController.dispose();
    _lyDoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    ref.watch(lopHocListProvider); // Watch for changes
    final lopHocCuaToi = ref.read(lopHocListProvider.notifier)
        .getLopHocBySinhVien(currentUser?.id ?? '');
    final yeuCauCuaToi = ref.watch(yeuCauThamGiaLopProvider)
        .where((yeuCau) => yeuCau.sinhVienId == currentUser?.id)
        .toList();
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
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: RoleTheme.getPrimaryColor(role),
                unselectedLabelColor: Colors.grey,
                indicatorColor: RoleTheme.getPrimaryColor(role),
                tabs: const [
                  Tab(text: 'Lớp đã tham gia'),
                  Tab(text: 'Yêu cầu của tôi'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildLopDaThamGia(lopHocCuaToi),
                    _buildYeuCauCuaToi(yeuCauCuaToi),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildYeuCauCuaToi(List<YeuCauThamGiaLop> yeuCauList) {
    if (yeuCauList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending_actions, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Bạn chưa có yêu cầu nào',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: yeuCauList.length,
      itemBuilder: (context, index) {
        final yeuCau = yeuCauList[index];
        return _buildYeuCauCard(yeuCau);
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

  Widget _buildYeuCauCard(YeuCauThamGiaLop yeuCau) {
    return UnifiedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  yeuCau.lopHocTen,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTrangThaiYeuCauChip(yeuCau.trangThai),
            ],
          ),
          const SizedBox(height: 12),
          if (yeuCau.lyDo.isNotEmpty) ...[
            Text('Lý do: ${yeuCau.lyDo}'),
            const SizedBox(height: 8),
          ],
          Text(
            'Ngày yêu cầu: ${_formatDate(yeuCau.ngayYeuCau)}',
            style: TextStyle(color: Colors.grey[600]),
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

  Widget _buildTrangThaiYeuCauChip(TrangThaiYeuCau trangThai) {
    Color color;
    String text;
    switch (trangThai) {
      case TrangThaiYeuCau.choXuLy:
        color = Colors.orange;
        text = 'Chờ xử lý';
        break;
      case TrangThaiYeuCau.chapNhan:
        color = Colors.green;
        text = 'Chấp nhận';
        break;
      case TrangThaiYeuCau.tuChoi:
        color = Colors.red;
        text = 'Từ chối';
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
            const SizedBox(height: 16),
            TextField(
              controller: _lyDoController,
              decoration: const InputDecoration(
                labelText: 'Lý do tham gia (tùy chọn)',
                hintText: 'Nhập lý do muốn tham gia lớp',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _maLopController.clear();
              _lyDoController.clear();
              Navigator.pop(context);
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => _submitYeuCauThamGia(),
            child: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );
  }

  void _submitYeuCauThamGia() {
    final maLop = _maLopController.text.trim();
    if (maLop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã lớp')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    // Tìm lớp học theo mã lớp
    final danhSachLopHoc = ref.read(lopHocListProvider);
    final lopHoc = danhSachLopHoc.firstWhere(
      (lop) => lop.maLop.toUpperCase() == maLop.toUpperCase(),
      orElse: () => throw Exception('Không tìm thấy lớp học'),
    );

    try {
      // Tạo yêu cầu tham gia
      final yeuCau = YeuCauThamGiaLop(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sinhVienId: currentUser.id,
        sinhVienTen: currentUser.hoVaTen,
        sinhVienMSSV: currentUser.mssv,
        lopHocId: lopHoc.id,
        lopHocTen: lopHoc.tenLop,
        lyDo: _lyDoController.text.trim(),
        ngayYeuCau: DateTime.now(),
      );

      ref.read(yeuCauThamGiaLopProvider.notifier).addYeuCau(yeuCau);

      _maLopController.clear();
      _lyDoController.clear();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã gửi yêu cầu tham gia lớp "${lopHoc.tenLop}"')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy lớp học với mã này')),
      );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}


