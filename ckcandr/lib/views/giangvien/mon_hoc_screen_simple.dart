import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Temporary simple MonHocScreen for teacher to avoid compilation errors
class MonHocScreen extends ConsumerWidget {
  const MonHocScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Quản lý môn học (Giảng viên)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Tính năng đang được phát triển...'),
        ],
      ),
    );
  }
}
