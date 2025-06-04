import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/services/auth_service.dart';

class GiangVienDashboardScreen extends ConsumerWidget {
  const GiangVienDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giảng viên - Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.logout();
              ref.read(currentUserProvider.notifier).state = null;
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, ${user?.name ?? "Giảng viên"}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${user?.email ?? "gv@ckcquizz.com"}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vai trò: Giảng viên',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quản lý bài giảng và kiểm tra',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    title: 'Tạo đề thi mới',
                    icon: Icons.add_circle,
                    onTap: () {
                      // TODO: Navigate to create quiz
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Quản lý câu hỏi',
                    icon: Icons.question_answer,
                    onTap: () {
                      // TODO: Navigate to manage questions
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Kết quả bài thi',
                    icon: Icons.assessment,
                    onTap: () {
                      // TODO: Navigate to exam results
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Lớp học',
                    icon: Icons.class_,
                    onTap: () {
                      // TODO: Navigate to classes
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Quick action for creating new quiz
        },
        child: const Icon(Icons.add),
        tooltip: 'Tạo đề thi mới nhanh',
      ),
    );
  }
  
  /// Tạo card cho mỗi tính năng
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 