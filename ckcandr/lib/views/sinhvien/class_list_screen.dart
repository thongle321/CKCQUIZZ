import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';

import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/views/sinhvien/widgets/join_class_dialog.dart';

/// Student Class List Screen - Danh sách lớp học của sinh viên
/// Tương đương với Vue.js classlist.vue
class StudentClassListScreen extends ConsumerStatefulWidget {
  const StudentClassListScreen({super.key});

  @override
  ConsumerState<StudentClassListScreen> createState() => _StudentClassListScreenState();
}

class _StudentClassListScreenState extends ConsumerState<StudentClassListScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final lopHocAsyncValue = ref.watch(lopHocListProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;

    return RoleThemedWidget(
      role: role,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: lopHocAsyncValue.when(
          data: (lopHocList) => _buildClassGrid(lopHocList, role),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorWidget(error),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showJoinClassDialog,
          backgroundColor: RoleTheme.getPrimaryColor(role),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Tham gia lớp',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildClassGrid(List<LopHoc> lopHocList, UserRole role) {
    if (lopHocList.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: lopHocList.length,
        itemBuilder: (context, index) {
          final lopHoc = lopHocList[index];
          return _buildClassCard(lopHoc, role);
        },
      ),
    );
  }

  Widget _buildClassCard(LopHoc lopHoc, UserRole role) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToClassDetail(lopHoc.malop),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với background màu
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: RoleTheme.getPrimaryColor(role).withValues(alpha: 0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lopHoc.tenlop,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lopHoc.monhocs.isNotEmpty 
                            ? lopHoc.monhocs.first 
                            : 'Chưa có môn học',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Avatar giảng viên
                  Positioned(
                    right: 12,
                    bottom: -20,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: RoleTheme.getPrimaryColor(role).withValues(alpha: 0.9),
                        // TODO: Có thể thêm avatar giảng viên từ API sau
                        child: Text(
                          _getTeacherInitials(lopHoc.tengiangvien),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20), // Space for avatar
                    Row(
                      children: [
                        const Text(
                          'Năm học: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          lopHoc.namhoc?.toString() ?? 'N/A',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'HK: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          lopHoc.hocky?.toString() ?? 'N/A',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'GV: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            lopHoc.tengiangvien ?? 'Chưa cập nhật',
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Bạn chưa tham gia lớp học nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Liên hệ giảng viên để được thêm vào lớp',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Không thể tải danh sách lớp học',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(lopHocListProvider),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _navigateToClassDetail(int classId) {
    // SỬA: Dùng push thay vì go để tạo navigation stack đúng cách
    context.push('/sinhvien/class-detail/$classId');
  }

  void _showJoinClassDialog() {
    showDialog(
      context: context,
      builder: (context) => const JoinClassDialog(),
    ).then((_) {
      // Refresh class list after joining
      ref.refresh(lopHocListProvider);
    });
  }

  /// Lấy chữ cái đầu của tên giảng viên để hiển thị trong avatar
  String _getTeacherInitials(String? teacherName) {
    if (teacherName == null || teacherName.isEmpty) {
      return 'GV';
    }

    // Tách tên thành các từ
    final words = teacherName.trim().split(' ');
    if (words.isEmpty) return 'GV';

    // Lấy chữ cái đầu của từ đầu tiên và từ cuối cùng
    String initials = '';
    if (words.length == 1) {
      // Nếu chỉ có 1 từ, lấy 2 chữ cái đầu
      initials = words[0].length >= 2
        ? words[0].substring(0, 2).toUpperCase()
        : words[0].toUpperCase();
    } else {
      // Nếu có nhiều từ, lấy chữ cái đầu của từ đầu và từ cuối
      initials = (words.first[0] + words.last[0]).toUpperCase();
    }

    return initials;
  }
}
