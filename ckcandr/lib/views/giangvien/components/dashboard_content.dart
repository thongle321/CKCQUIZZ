import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/providers/nhom_hocphan_provider.dart'; // Đảm bảo tên file đúng
import 'package:ckcandr/providers/chuong_muc_provider.dart';
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
    final chuongMucCount = ref.watch(chuongMucListProvider).length;
    final cauHoiCount = ref.watch(cauHoiListProvider).length;
    // TODO: Add deKiemTraCount once its provider is available
    // final deKiemTraCount = ref.watch(deKiemTraListProvider).length;

    final recentActivities = ref.watch(hoatDongGanDayListProvider);
    // Sort activities by time, descending, and take the top 5 or 10
    final displayedActivities = List<HoatDongGanDay>.from(recentActivities)
      ..sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
    final topActivities = displayedActivities.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(
            'Thống kê nhanh',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(context, 'Môn học', monHocCount.toString(), Icons.library_books_outlined, Colors.orangeAccent),
              _buildStatCard(context, 'Nhóm học phần', nhomHocPhanCount.toString(), Icons.group_work_outlined, Colors.lightBlueAccent),
              _buildStatCard(context, 'Chương mục', chuongMucCount.toString(), Icons.account_tree_outlined, Colors.greenAccent),
              _buildStatCard(context, 'Câu hỏi', cauHoiCount.toString(), Icons.question_answer_outlined, Colors.purpleAccent),
              // _buildStatCard(context, 'Đề kiểm tra', deKiemTraCount.toString(), Icons.assignment_outlined, Colors.redAccent),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Hoạt động gần đây',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (topActivities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Chưa có hoạt động nào gần đây.',
                  style: theme.textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topActivities.length,
                itemBuilder: (context, index) {
                  final activity = topActivities[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.primaryColorLight.withOpacity(0.3),
                      child: Icon(activity.icon, color: theme.primaryColor, size: 20),
                    ),
                    title: Text(activity.noiDung, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(activity.thoiGian),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 12),
                    ),
                    // onTap: () {
                    //   // TODO: Navigate to related screen if activity.routeLienQuan is set
                    //   // if (activity.routeLienQuan != null) { GoRouter.of(context).go(activity.routeLienQuan!); }
                    // },
                  );
                },
                separatorBuilder: (context, index) => Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor.withOpacity(0.5)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count, IconData icon, Color iconColor) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(height: 12),
            Text(
              count,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: iconColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(color: theme.hintColor),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 