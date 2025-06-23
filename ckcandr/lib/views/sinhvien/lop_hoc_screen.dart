import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
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
    final lopHocAsyncValue = ref.watch(lopHocListProvider);
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
        body: lopHocAsyncValue.when(
          data: (lopHocList) => _buildLopDaThamGia(lopHocList),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: $error',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
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
                      lopHoc.tenlop,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mã lớp: ${lopHoc.malop}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildTrangThaiChip(lopHoc.trangthai ?? false),
            ],
          ),
          const SizedBox(height: 12),
          if (lopHoc.monhocs.isNotEmpty)
            Text('Môn học: ${lopHoc.monhocs.join(", ")}'),
          const SizedBox(height: 4),
          if (lopHoc.ghichu != null && lopHoc.ghichu!.isNotEmpty)
            Text('Ghi chú: ${lopHoc.ghichu}'),
          const SizedBox(height: 4),
          if (lopHoc.siso != null)
            Text('Sĩ số: ${lopHoc.siso}'),
          const SizedBox(height: 4),
          Text('Năm học: ${lopHoc.namhoc ?? "N/A"} - Học kỳ: ${lopHoc.hocky ?? "N/A"}'),
        ],
      ),
    );
  }



  Widget _buildTrangThaiChip(bool trangThai) {
    final color = trangThai ? Colors.green : Colors.red;
    final text = trangThai ? 'Hoạt động' : 'Tạm dừng';

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
                labelText: 'Mã mời',
                hintText: 'Nhập mã mời từ giảng viên',
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
        const SnackBar(content: Text('Vui lòng nhập mã mời')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    try {
      // Tìm lớp học theo mã mời
      final lopHocAsyncValue = ref.read(lopHocListProvider);
      await lopHocAsyncValue.when(
        data: (lopHocList) async {
          final lopHoc = lopHocList.firstWhere(
            (lop) => lop.mamoi?.toUpperCase() == maLop.toUpperCase(),
            orElse: () => throw Exception('Không tìm thấy lớp học'),
          );

          // Kiểm tra xem lớp có thể thêm sinh viên không
          if (!lopHoc.coTheThemSinhVien) {
            _maLopController.clear();
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lớp học không còn hoạt động!')),
              );
            }
            return;
          }

          // TODO: Gọi API để thêm sinh viên vào lớp
          // Hiện tại chỉ hiển thị thông báo thành công
          _maLopController.clear();

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tham gia lớp "${lopHoc.tenlop}" thành công!')),
            );
          }
        },
        loading: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đang tải dữ liệu...')),
            );
          }
        },
        error: (error, stack) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lỗi khi tải dữ liệu')),
            );
          }
        },
      );
    } catch (e) {
      _maLopController.clear();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy lớp học với mã mời này')),
        );
      }
    }
  }

  void _showLopHocDetail(LopHoc lopHoc) {
    // TODO: Tạo màn hình chi tiết lớp học cho sinh viên
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lopHoc.tenlop),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã lớp: ${lopHoc.malop}'),
            const SizedBox(height: 8),
            if (lopHoc.ghichu != null && lopHoc.ghichu!.isNotEmpty)
              Text('Ghi chú: ${lopHoc.ghichu}'),
            const SizedBox(height: 8),
            Text('Trạng thái: ${lopHoc.tenTrangThai}'),
            const SizedBox(height: 8),
            Text('Năm học: ${lopHoc.namhoc ?? "N/A"}'),
            const SizedBox(height: 8),
            Text('Học kỳ: ${lopHoc.hocky ?? "N/A"}'),
            if (lopHoc.monhocs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Môn học: ${lopHoc.monhocs.join(", ")}'),
            ],
          ],
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


}


