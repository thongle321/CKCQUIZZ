import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/views/giangvien/components/custom_app_bar.dart';

class DashboardContent extends ConsumerWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final cardBackgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    
    // Responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final double cardPadding = isSmallScreen ? 12.0 : 16.0;
    
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng quan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: isSmallScreen ? 18 : 22,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatCards(context, cardPadding, cardBackgroundColor, textColor, subTextColor, isSmallScreen),
            const SizedBox(height: 16),
            _buildRecentActivity(context, cardBackgroundColor, textColor, subTextColor, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, double cardPadding, Color? cardBackgroundColor, 
      Color textColor, Color subTextColor, bool isSmallScreen) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isSmallScreen ? 1.3 : 1.6,
      children: [
        _buildStatCard(
          icon: Icons.class_,
          title: 'Lớp học',
          count: '12',
          color: Colors.blue,
          cardPadding: cardPadding,
          cardBackgroundColor: cardBackgroundColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isSmallScreen: isSmallScreen,
        ),
        _buildStatCard(
          icon: Icons.people,
          title: 'Sinh viên',
          count: '243',
          color: Colors.orange,
          cardPadding: cardPadding,
          cardBackgroundColor: cardBackgroundColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isSmallScreen: isSmallScreen,
        ),
        _buildStatCard(
          icon: Icons.question_answer,
          title: 'Câu hỏi',
          count: '182',
          color: Colors.green,
          cardPadding: cardPadding,
          cardBackgroundColor: cardBackgroundColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isSmallScreen: isSmallScreen,
        ),
        _buildStatCard(
          icon: Icons.assignment,
          title: 'Đề kiểm tra',
          count: '24',
          color: Colors.purple,
          cardPadding: cardPadding,
          cardBackgroundColor: cardBackgroundColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
    required double cardPadding,
    required Color? cardBackgroundColor,
    required Color textColor,
    required Color subTextColor,
    required bool isSmallScreen,
  }) {
    return Card(
      elevation: 2,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isSmallScreen ? 18 : 24),
                SizedBox(width: isSmallScreen ? 6 : 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              count,
              style: TextStyle(
                fontSize: isSmallScreen ? 22 : 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, Color? cardBackgroundColor, 
      Color textColor, Color subTextColor, bool isSmallScreen) {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Bài kiểm tra cuối kỳ LTDD',
        'subtitle': 'Đã tạo bài kiểm tra mới',
        'time': '10 phút trước',
        'icon': Icons.assignment,
        'color': Colors.blue,
      },
      {
        'title': 'Nhóm học phần CT299',
        'subtitle': 'Thêm 3 sinh viên mới',
        'time': '1 giờ trước',
        'icon': Icons.group_add,
        'color': Colors.green,
      },
      {
        'title': 'Câu hỏi tự luận',
        'subtitle': 'Đã cập nhật 5 câu hỏi',
        'time': '3 giờ trước',
        'icon': Icons.edit_note,
        'color': Colors.orange,
      },
      {
        'title': 'Bài tập về nhà',
        'subtitle': 'Đã chấm điểm 15 bài nộp',
        'time': '1 ngày trước',
        'icon': Icons.grading,
        'color': Colors.purple,
      },
    ];

    return Card(
      elevation: 2,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Text(
              'Hoạt động gần đây',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 4 : 8,
                ),
                leading: CircleAvatar(
                  radius: isSmallScreen ? 16 : 20,
                  backgroundColor: activity['color'].withOpacity(0.2),
                  child: Icon(
                    activity['icon'],
                    color: activity['color'],
                    size: isSmallScreen ? 16 : 20,
                  ),
                ),
                title: Text(
                  activity['title'],
                  style: TextStyle(
                    color: textColor,
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  activity['subtitle'],
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
                trailing: Text(
                  activity['time'],
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: isSmallScreen ? 10 : 11,
                  ),
                ),
                dense: isSmallScreen,
                visualDensity: isSmallScreen 
                    ? VisualDensity.compact 
                    : VisualDensity.standard,
              );
            },
          ),
        ],
      ),
    );
  }
} 