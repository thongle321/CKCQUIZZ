import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/core/utils/responsive_helper.dart';
import 'package:ckcandr/views/sinhvien/widgets/feature_removal_dialog.dart';
import 'package:ckcandr/services/exam_reminder_service.dart';
import 'package:ckcandr/services/api_service.dart';


class DashboardContent extends ConsumerStatefulWidget {
  const DashboardContent({super.key});

  @override
  ConsumerState<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends ConsumerState<DashboardContent> {
  @override
  void initState() {
    super.initState();
    _checkAndShowFeatureRemovalDialog();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final lopHocAsyncValue = ref.watch(lopHocListProvider);

    return SingleChildScrollView(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Chào mừng ${currentUser?.hoVaTen ?? 'Sinh viên'}!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 24,
                tablet: 26,
                desktop: 28,
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveValue(
            context,
            mobile: 8,
            tablet: 10,
            desktop: 12,
          )),
          Text(
            'Hệ thống quản lý bài kiểm tra trực tuyến',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 17,
                desktop: 18,
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveValue(
            context,
            mobile: 24,
            tablet: 28,
            desktop: 32,
          )),

          // Statistics cards
          lopHocAsyncValue.when(
            data: (lopHocList) => GridView.count(
              crossAxisCount: ResponsiveHelper.getGridColumns(context),
              crossAxisSpacing: ResponsiveHelper.getResponsiveValue(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
              mainAxisSpacing: ResponsiveHelper.getResponsiveValue(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(context, 'Lớp học', lopHocList.length.toString(), Icons.class_, Colors.blue),
                _buildStatCard(context, 'Bài kiểm tra', '0', Icons.assignment_outlined, Colors.green),
                _buildStatCard(context, 'Điểm trung bình', 'N/A', Icons.grade, Colors.orange),
                _buildStatCard(context, 'Hoạt động', '0', Icons.timeline, Colors.purple),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Lỗi: $error'),
          ),

          const SizedBox(height: 32),

          // Upcoming exams section
          _buildUpcomingExamsSection(),
          const SizedBox(height: 32),

          // Recent activities section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông báo hệ thống',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNotificationItem(
                    'Cập nhật ứng dụng',
                    'Ứng dụng đã được cập nhật với giao diện mới, tập trung vào các tính năng cốt lõi cho sinh viên.',
                    Icons.update,
                    Colors.blue,
                  ),
                  _buildNotificationItem(
                    'Hướng dẫn sử dụng',
                    'Sử dụng menu bên trái để điều hướng giữa các tính năng: Danh sách lớp, Bài kiểm tra, và Hồ sơ.',
                    Icons.help,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ),
          

        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: context.responsiveElevation,
      shape: RoundedRectangleBorder(
        borderRadius: context.responsiveBorderRadius,
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveValue(
          context,
          mobile: 12,
          tablet: 14,
          desktop: 16,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ResponsiveHelper.getIconSize(context, baseSize: 28),
              color: color,
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveValue(
              context,
              mobile: 6,
              tablet: 7,
              desktop: 8,
            )),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 20,
                  tablet: 22,
                  desktop: 24,
                ),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveValue(
              context,
              mobile: 2,
              tablet: 3,
              desktop: 4,
            )),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String content, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
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

  Widget _buildUpcomingExamsSection() {
    return FutureBuilder(
      future: _loadUpcomingExams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final upcomingExams = snapshot.data ?? [];

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Đề thi sắp diễn ra',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (upcomingExams.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.event_available, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Không có đề thi nào sắp diễn ra',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...upcomingExams.take(3).map((exam) => _buildUpcomingExamItem(exam)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingExamItem(dynamic exam) {
    final timeUntilExam = exam.thoigiantbatdau?.difference(DateTime.now());
    final timeText = _formatTimeUntilExam(timeUntilExam);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.quiz, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.tende ?? 'Đề thi không có tên',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  String _formatTimeUntilExam(Duration? duration) {
    if (duration == null) return 'Thời gian không xác định';

    if (duration.inDays > 0) {
      return 'Còn ${duration.inDays} ngày';
    } else if (duration.inHours > 0) {
      return 'Còn ${duration.inHours} giờ';
    } else if (duration.inMinutes > 0) {
      return 'Còn ${duration.inMinutes} phút';
    } else {
      return 'Đã bắt đầu';
    }
  }

  Future<List<dynamic>> _loadUpcomingExams() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final allExams = await apiService.getAllExamsForStudent();

      final now = DateTime.now();
      final upcomingExams = allExams.where((exam) {
        if (exam.thoigiantbatdau == null) return false;
        final timeUntilExam = exam.thoigiantbatdau!.difference(now);
        return timeUntilExam.inMinutes > 0 && timeUntilExam.inDays <= 7; // Trong vòng 7 ngày tới
      }).toList();

      // Sắp xếp theo thời gian bắt đầu
      upcomingExams.sort((a, b) => a.thoigiantbatdau!.compareTo(b.thoigiantbatdau!));

      return upcomingExams;
    } catch (e) {
      debugPrint('Error loading upcoming exams: $e');
      return [];
    }
  }

  Future<void> _checkAndShowFeatureRemovalDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownDialog = prefs.getBool('has_shown_feature_removal_dialog') ?? false;

    if (!hasShownDialog && mounted) {
      // Delay to ensure the widget is fully built
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          FeatureRemovalDialog.show(context);
          prefs.setBool('has_shown_feature_removal_dialog', true);
        }
      });
    }
  }
}
