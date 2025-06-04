import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/services/auth_service.dart';

class SinhVienDashboardScreen extends ConsumerWidget {
  const SinhVienDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinh viên - Dashboard'),
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
                      'Xin chào, ${user?.name ?? "Sinh viên"}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${user?.email ?? "sv@ckcquizz.com"}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vai trò: Sinh viên',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Bài thi sắp tới'),
                        Tab(text: 'Lịch sử làm bài'),
                      ],
                      labelColor: Colors.black,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildUpcomingExams(context),
                          _buildExamHistory(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Lớp học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
        onTap: (index) {
          // TODO: Implement navigation
        },
      ),
    );
  }
  
  /// Xây dựng danh sách bài thi sắp tới
  Widget _buildUpcomingExams(BuildContext context) {
    // Dữ liệu mẫu cho bài thi sắp tới
    final upcomingExams = [
      {
        'title': 'Bài kiểm tra giữa kỳ',
        'subject': 'Lập trình di động',
        'date': '05/06/2025',
        'time': '08:00 - 09:30',
      },
      {
        'title': 'Bài thi thực hành',
        'subject': 'Cơ sở dữ liệu',
        'date': '10/06/2025',
        'time': '13:30 - 15:00',
      },
      {
        'title': 'Bài kiểm tra cuối kỳ',
        'subject': 'Lập trình web',
        'date': '15/06/2025',
        'time': '09:30 - 11:00',
      },
    ];

    return ListView.builder(
      itemCount: upcomingExams.length,
      itemBuilder: (context, index) {
        final exam = upcomingExams[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(exam['title']!),
            subtitle: Text('${exam['subject']} • ${exam['date']} • ${exam['time']}'),
            trailing: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to exam details
              },
              child: const Text('Xem chi tiết'),
            ),
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.assignment, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
  
  /// Xây dựng lịch sử làm bài
  Widget _buildExamHistory(BuildContext context) {
    // Dữ liệu mẫu cho lịch sử bài thi
    final examHistory = [
      {
        'title': 'Bài kiểm tra thường kỳ',
        'subject': 'Lập trình di động',
        'date': '01/05/2025',
        'score': '85/100',
      },
      {
        'title': 'Bài thi thực hành',
        'subject': 'Cơ sở dữ liệu',
        'date': '15/04/2025',
        'score': '92/100',
      },
      {
        'title': 'Bài kiểm tra lý thuyết',
        'subject': 'Lập trình web',
        'date': '20/03/2025',
        'score': '78/100',
      },
    ];

    return ListView.builder(
      itemCount: examHistory.length,
      itemBuilder: (context, index) {
        final exam = examHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(exam['title']!),
            subtitle: Text('${exam['subject']} • ${exam['date']}'),
            trailing: Text(
              exam['score']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.check_circle, color: Colors.white),
            ),
            onTap: () {
              // TODO: Navigate to exam result details
            },
          ),
        );
      },
    );
  }
} 