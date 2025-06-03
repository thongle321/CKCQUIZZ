import 'package:ckcandr/config/themes/app_theme.dart';
import 'package:flutter/material.dart';

class ThongBaoPage extends StatefulWidget {
  const ThongBaoPage({super.key});

  @override
  State<ThongBaoPage> createState() => _ThongBaoPageState();
}

class _ThongBaoPageState extends State<ThongBaoPage> {
  final List<Map<String, dynamic>> mockNotifications = [
    {
      'id': 'N001',
      'title': 'Đề thi giữa kỳ Lập trình hướng đối tượng đã được phát hành',
      'message': 'Đề thi giữa kỳ Lập trình hướng đối tượng đã được phát hành. Vui lòng kiểm tra lịch thi của bạn.',
      'time': '09:30 - 20/09/2024',
      'isRead': false,
      'type': 'Học tập',
    },
    {
      'id': 'N002',
      'title': 'Cập nhật bảo mật hệ thống',
      'message': 'Hệ thống sẽ bảo trì từ 22:00 ngày 21/09/2024 đến 02:00 ngày 22/09/2024 để cập nhật bảo mật.',
      'time': '15:45 - 19/09/2024',
      'isRead': true,
      'type': 'Hệ thống',
    },
    {
      'id': 'N003',
      'title': 'Lịch học tuần 7 đã được cập nhật',
      'message': 'Lịch học tuần 7 đã được cập nhật. Vui lòng kiểm tra lịch học của bạn.',
      'time': '08:15 - 18/09/2024',
      'isRead': true,
      'type': 'Học tập',
    },
    {
      'id': 'N004',
      'title': 'Nhắc nhở nộp bài tập lớn',
      'message': 'Nhắc nhở: Thời hạn nộp bài tập lớn môn Cấu trúc dữ liệu và giải thuật là 23:59 ngày 25/09/2024.',
      'time': '10:00 - 17/09/2024',
      'isRead': false,
      'type': 'Học tập',
    },
    {
      'id': 'N005',
      'title': 'Phản hồi bài tập về nhà',
      'message': 'Giảng viên đã phản hồi bài tập về nhà của bạn trong môn Lập trình web.',
      'time': '14:20 - 16/09/2024',
      'isRead': true,
      'type': 'Học tập',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header area
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Thông báo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text('Đánh dấu đã đọc tất cả'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      // TODO: Đánh dấu đã đọc tất cả
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text('Xóa tất cả'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      // TODO: Xóa tất cả thông báo
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Chip(
                  label: const Text('Tất cả'),
                  backgroundColor: AppTheme.primaryColor,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: const Text('Học tập'),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: const Text('Hệ thống'),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Danh sách thông báo
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mockNotifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = mockNotifications[index];
              return Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                color: notification['isRead'] ? Colors.white : AppTheme.primaryLightColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: notification['type'] == 'Học tập'
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              notification['type'] == 'Học tập'
                                  ? Icons.school_outlined
                                  : Icons.settings_outlined,
                              color: notification['type'] == 'Học tập'
                                  ? Colors.blue
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification['title'],
                                        style: TextStyle(
                                          fontWeight: notification['isRead']
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (!notification['isRead'])
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notification['message'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification['time'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  notification['isRead']
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                onPressed: () {
                                  // TODO: Đánh dấu đã đọc
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 18,
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () {
                                  // TODO: Xóa thông báo
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}