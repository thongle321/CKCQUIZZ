import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/dashboard_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/dashboard_provider.dart';
import 'package:ckcandr/widgets/dashboard/dashboard_stat_card.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
// REMOVED: import 'package:ckcandr/services/system_notification_service.dart';


/// Universal Dashboard Widget cho tất cả các role
class UniversalDashboard extends ConsumerWidget {
  final UserRole userRole;
  final String? userName;

  const UniversalDashboard({
    super.key,
    required this.userRole,
    this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardStats = ref.watch(dashboardStatisticsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        refreshDashboard(ref);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(context),
            const SizedBox(height: 24),

            // Statistics Cards
            _buildStatisticsSection(context, dashboardStats),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final roleColor = RoleTheme.getPrimaryColor(userRole);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            roleColor.withValues(alpha: 0.1),
            roleColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: roleColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to CKCQuizz!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: roleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bạn đang đăng nhập với quyền ${_getRoleDisplayName()}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, AsyncValue<DashboardStatistics> statsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống kê tổng quan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        statsAsync.when(
          data: (stats) => _buildStatisticsGrid(context, stats),
          loading: () => _buildLoadingStatistics(context),
          error: (error, stack) => _buildErrorStatistics(context, error.toString()),
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, DashboardStatistics stats) {
    final statCards = _getStatCardsForRole(stats);
    final screenWidth = MediaQuery.of(context).size.width;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 600 ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: screenWidth > 600 ? 1.3 : 1.5, // Tăng tỷ lệ cho mobile
      ),
      itemCount: statCards.length,
      itemBuilder: (context, index) {
        final card = statCards[index];
        return DashboardStatCard(
          title: card.title,
          value: card.value,
          icon: _getIconFromString(card.icon),
          color: _getColorFromString(card.color),
          subtitle: card.subtitle,
          onTap: card.onTap,
        );
      },
    );
  }

  Widget _buildLoadingStatistics(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 600 ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: screenWidth > 600 ? 1.3 : 1.5,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const DashboardStatCard(
          title: '',
          value: '',
          icon: Icons.info,
          color: Colors.grey,
          isLoading: true,
        );
      },
    );
  }

  Widget _buildErrorStatistics(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Không thể tải thống kê',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  List<DashboardCardItem> _getStatCardsForRole(DashboardStatistics stats) {
    switch (userRole) {
      case UserRole.admin:
        return [
          DashboardCardItem(
            title: 'Tổng người dùng',
            value: stats.totalUsers.toString(),
            icon: 'people',
            color: 'blue',
          ),
          DashboardCardItem(
            title: 'Sinh viên',
            value: stats.totalStudents.toString(),
            icon: 'school',
            color: 'green',
          ),
          DashboardCardItem(
            title: 'Đề thi',
            value: stats.totalExams.toString(),
            icon: 'quiz',
            color: 'orange',
          ),
          DashboardCardItem(
            title: 'Câu hỏi',
            value: stats.totalQuestions.toString(),
            icon: 'help',
            color: 'purple',
          ),
        ];
      case UserRole.giangVien:
        return [
          DashboardCardItem(
            title: 'Đề thi của tôi',
            value: stats.totalExams.toString(),
            icon: 'quiz',
            color: 'blue',
          ),
          DashboardCardItem(
            title: 'Câu hỏi',
            value: stats.totalQuestions.toString(),
            icon: 'help',
            color: 'green',
          ),
          DashboardCardItem(
            title: 'Đang thi',
            value: stats.activeExams.toString(),
            icon: 'timer',
            color: 'orange',
          ),
          DashboardCardItem(
            title: 'Hoàn thành',
            value: stats.completedExams.toString(),
            icon: 'check_circle',
            color: 'purple',
          ),
        ];
      case UserRole.sinhVien:
        return [
          DashboardCardItem(
            title: 'Bài thi khả dụng',
            value: stats.totalExams.toString(),
            icon: 'assignment',
            color: 'blue',
          ),
          DashboardCardItem(
            title: 'Đã hoàn thành',
            value: stats.completedExams.toString(),
            icon: 'check_circle',
            color: 'green',
          ),
          DashboardCardItem(
            title: 'Đang làm',
            value: stats.activeExams.toString(),
            icon: 'timer',
            color: 'orange',
          ),
          DashboardCardItem(
            title: 'Lớp học',
            value: '0', // TODO: Add class count for student
            icon: 'class',
            color: 'purple',
          ),
        ];
    }
  }


  String _getRoleDisplayName() {
    switch (userRole) {
      case UserRole.admin:
        return 'Quản trị viên';
      case UserRole.giangVien:
        return 'Giảng viên';
      case UserRole.sinhVien:
        return 'Sinh viên';
    }
  }

  // REMOVED: _getRoleIcon method không sử dụng nữa

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'people':
        return Icons.people;
      case 'school':
        return Icons.school;
      case 'quiz':
        return Icons.quiz;
      case 'help':
        return Icons.help_outline;
      case 'timer':
        return Icons.timer;
      case 'check_circle':
        return Icons.check_circle;
      case 'assignment':
        return Icons.assignment;
      case 'class':
        return Icons.class_;
      case 'person_add':
        return Icons.person_add;
      case 'book':
        return Icons.book;
      case 'security':
        return Icons.security;
      case 'analytics':
        return Icons.analytics;
      case 'group_add':
        return Icons.group_add;
      case 'edit':
        return Icons.edit;
      case 'score':
        return Icons.score;
      case 'notifications':
        return Icons.notifications;
      case 'grade':
        return Icons.grade;
      default:
        return Icons.info;
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
