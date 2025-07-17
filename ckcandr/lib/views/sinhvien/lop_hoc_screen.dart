import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/core/widgets/role_themed_screen.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/core/widgets/error_dialog.dart';

// Provider để cache thông tin giảng viên theo class ID
final teacherInfoProvider = FutureProvider.family<String?, int>((ref, classId) async {
  try {
    final apiService = ref.watch(apiServiceProvider);
    final teachers = await apiService.getTeachersInClass(classId);

    if (teachers.isNotEmpty) {
      return teachers.first.hoten;
    }
    return null;
  } catch (e) {
    return null;
  }
});

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
      onTap: () => _navigateToClassDetail(lopHoc),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với tên lớp và trạng thái
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RoleTheme.getPrimaryColor(UserRole.sinhVien),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lopHoc.tenlop,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lopHoc.malop} - ${lopHoc.monhocs.isNotEmpty ? lopHoc.monhocs.first : "Chưa có môn học"}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Avatar placeholder cho giảng viên
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),

          // Thông tin chi tiết
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin năm học và học kỳ
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Năm học: ${lopHoc.namhoc ?? "N/A"}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      'HK: ${lopHoc.hocky ?? "N/A"}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Thông tin giảng viên
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildTeacherInfo(lopHoc.malop),
                    ),
                    _buildTrangThaiChip(lopHoc.trangthai ?? false),
                  ],
                ),
              ],
            ),
          ),
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
              await ErrorDialog.show(
                context,
                message: 'Lớp học không còn hoạt động!',
              );
            }
            return;
          }

          // TODO: Gọi API để thêm sinh viên vào lớp
          // Hiện tại chỉ hiển thị thông báo thành công
          _maLopController.clear();

          if (mounted) {
            Navigator.pop(context);
            await SuccessDialog.show(
              context,
              message: 'Tham gia lớp "${lopHoc.tenlop}" thành công!',
            );
          }
        },
        loading: () {
          if (mounted) {
            // Loading state - no action needed
          }
        },
        error: (error, stack) {
          if (mounted) {
            ErrorDialog.show(
              context,
              message: 'Lỗi khi tải dữ liệu',
            );
          }
        },
      );
    } catch (e) {
      _maLopController.clear();

      if (mounted) {
        Navigator.pop(context);
        await ErrorDialog.show(
          context,
          message: 'Không tìm thấy lớp học với mã mời này',
        );
      }
    }
  }

  void _navigateToClassDetail(LopHoc lopHoc) {
    context.push('/student/class-detail/${lopHoc.malop}');
  }

  Widget _buildTeacherInfo(int classId) {
    return Consumer(
      builder: (context, ref, child) {
        final teacherAsync = ref.watch(teacherInfoProvider(classId));

        return teacherAsync.when(
          data: (teacherName) {
            if (teacherName != null && teacherName.isNotEmpty) {
              return Text(
                'GV: $teacherName',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              );
            }
            return SizedBox.shrink(); // Không hiển thị gì nếu không có thông tin
          },
          loading: () => SizedBox.shrink(), // Không hiển thị loading
          error: (error, stack) => SizedBox.shrink(), // Không hiển thị lỗi
        );
      },
    );
  }


}


