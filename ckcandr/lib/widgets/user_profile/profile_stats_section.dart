import 'package:flutter/material.dart';
import 'package:ckcandr/providers/user_profile_provider.dart';

/// Widget hiển thị thống kê của người dùng theo role
class ProfileStatsSection extends StatelessWidget {
  final UserStats stats;
  final String userRole;

  const ProfileStatsSection({
    super.key,
    required this.stats,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thống kê',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Thống kê theo role
            _buildStatsContent(context),
          ],
        ),
      ),
    );
  }

  /// Xây dựng nội dung thống kê theo role
  Widget _buildStatsContent(BuildContext context) {
    switch (userRole.toLowerCase()) {
      case 'teacher':
        return _buildTeacherStats(context);
      case 'student':
        return _buildStudentStats(context);
      case 'admin':
        return _buildAdminStats(context);
      default:
        return _buildDefaultStats(context);
    }
  }

  /// Thống kê cho giảng viên
  Widget _buildTeacherStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.class_,
            title: 'Lớp học',
            value: stats.totalClasses.toString(),
            subtitle: 'Đang quản lý',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.people,
            title: 'Sinh viên',
            value: stats.totalStudents.toString(),
            subtitle: 'Tổng số',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.quiz,
            title: 'Bài kiểm tra',
            value: stats.totalQuizzes.toString(),
            subtitle: 'Đã tạo',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  /// Thống kê cho sinh viên
  Widget _buildStudentStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.class_,
            title: 'Lớp học',
            value: stats.totalClasses.toString(),
            subtitle: 'Đang tham gia',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.quiz,
            title: 'Bài kiểm tra',
            value: stats.totalQuizzes.toString(),
            subtitle: 'Có thể làm',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.check_circle,
            title: 'Hoàn thành',
            value: stats.completedQuizzes.toString(),
            subtitle: 'Bài đã làm',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  /// Thống kê cho admin
  Widget _buildAdminStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.class_,
            title: 'Lớp học',
            value: stats.totalClasses.toString(),
            subtitle: 'Tổng số',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.people,
            title: 'Người dùng',
            value: stats.totalStudents.toString(),
            subtitle: 'Tổng số',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.quiz,
            title: 'Bài kiểm tra',
            value: stats.totalQuizzes.toString(),
            subtitle: 'Tổng số',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  /// Thống kê mặc định
  Widget _buildDefaultStats(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Chưa có dữ liệu thống kê',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng card thống kê
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget hiển thị progress bar với thông tin
class ProgressStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int current;
  final int total;
  final Color color;

  const ProgressStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.current,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 8),
          Text(
            '$current / $total',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
