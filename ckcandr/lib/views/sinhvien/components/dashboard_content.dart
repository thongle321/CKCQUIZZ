import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/providers/nhom_hocphan_provider.dart';
import 'package:ckcandr/providers/cau_hoi_provider.dart';
import 'package:ckcandr/providers/hoat_dong_provider.dart';
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart';
import 'package:intl/intl.dart'; // For date formatting

class DashboardContent extends ConsumerWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch data for statistics
    final monHocCount = ref.watch(monHocListProvider).length;
    final nhomHocPhanCount = ref.watch(nhomHocPhanListProvider).length;
    final cauHoiCount = ref.watch(cauHoiListProvider).length;
    final hoatDongList = ref.watch(hoatDongGanDayListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Chào mừng bạn đến với CKC Quiz!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hệ thống quản lý bài kiểm tra trực tuyến',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Statistics cards
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(context, 'Môn học', monHocCount.toString(), Icons.library_books_outlined, Colors.orangeAccent),
              _buildStatCard(context, 'Nhóm học phần', nhomHocPhanCount.toString(), Icons.group_work_outlined, Colors.lightBlueAccent),
              _buildStatCard(context, 'Câu hỏi', cauHoiCount.toString(), Icons.quiz_outlined, Colors.greenAccent),
              _buildStatCard(context, 'Bài kiểm tra', '0', Icons.assignment_outlined, Colors.redAccent),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent activities section
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hoạt động gần đây',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (hoatDongList.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'Chưa có hoạt động nào',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        else
                          ...hoatDongList.take(5).map((activity) => _buildActivityItem(context, activity)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Quick actions
          Text(
            'Thao tác nhanh',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildQuickActionCard(
                context,
                'Xem môn học',
                Icons.book_outlined,
                Colors.blue,
                () {
                  // TODO: Navigate to subjects
                },
              ),
              _buildQuickActionCard(
                context,
                'Làm bài kiểm tra',
                Icons.assignment_outlined,
                Colors.green,
                () {
                  // TODO: Navigate to tests
                },
              ),
              _buildQuickActionCard(
                context,
                'Xem thông báo',
                Icons.notifications_outlined,
                Colors.orange,
                () {
                  // TODO: Navigate to notifications
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, HoatDongGanDay activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getActivityColor(activity.loaiHoatDong),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.noiDung,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(activity.thoiGian),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getActivityColor(LoaiHoatDong loaiHoatDong) {
    switch (loaiHoatDong) {
      case LoaiHoatDong.MON_HOC:
        return Colors.blue;
      case LoaiHoatDong.CAU_HOI:
        return Colors.green;
      case LoaiHoatDong.DE_THI:
        return Colors.orange;
      case LoaiHoatDong.THEM_THONG_BAO:
      case LoaiHoatDong.SUA_THONG_BAO:
      case LoaiHoatDong.XOA_THONG_BAO:
        return Colors.purple;
      case LoaiHoatDong.DANG_NHAP:
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}
