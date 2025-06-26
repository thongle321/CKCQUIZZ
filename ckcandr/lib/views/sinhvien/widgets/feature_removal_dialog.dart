import 'package:flutter/material.dart';

/// Dialog thông báo về việc xóa các tính năng không cần thiết
class FeatureRemovalDialog extends StatelessWidget {
  const FeatureRemovalDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.info, color: Colors.blue),
          SizedBox(width: 8),
          Text('Cập nhật ứng dụng'),
        ],
      ),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chúng tôi đã cập nhật ứng dụng để tập trung vào các tính năng cốt lõi cho sinh viên:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            
            // Kept features
            Text(
              '✅ Các tính năng được giữ lại:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text('• Tổng quan (Dashboard)'),
            Text('• Danh sách lớp học'),
            Text('• Bài kiểm tra và xem kết quả'),
            Text('• Quản lý hồ sơ cá nhân'),
            SizedBox(height: 16),
            
            // Removed features
            Text(
              '❌ Các tính năng đã được xóa:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text('• Nhóm học phần (không cần thiết cho sinh viên)'),
            Text('• Danh mục môn học (đã tích hợp vào lớp học)'),
            SizedBox(height: 16),
            
            Text(
              'Những thay đổi này giúp ứng dụng trở nên đơn giản và dễ sử dụng hơn.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đã hiểu'),
        ),
      ],
    );
  }

  /// Show the dialog
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FeatureRemovalDialog(),
    );
  }
}
