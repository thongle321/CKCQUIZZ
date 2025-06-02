import 'package:ckcandr/config/routes/router_provider.dart';
import 'package:ckcandr/config/themes/app_theme.dart';
import 'package:ckcandr/config/themes/theme_provider.dart';
import 'package:ckcandr/features/dashboard/presentation/widgets/dashboard_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('CKC QUIZ'),
        automaticallyImplyLeading: !isLargeScreen, // Hiển thị nút menu trên màn hình nhỏ
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              context.goNamed(AppRoutes.thongBao);
            },
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 20, color: AppTheme.primaryColor),
            ),
            offset: const Offset(0, 56),
            onSelected: (value) {
              if (value == 'logout') {
                context.goNamed(AppRoutes.login);
              }
              // Xử lý các tùy chọn khác nếu cần
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Hồ sơ'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Cài đặt'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: isLargeScreen ? null : const DashboardDrawer(isPermanent: false),
      body: Row(
        children: <Widget>[
          // Hiển thị drawer cố định trên màn hình lớn
          if (isLargeScreen)
            const DashboardDrawer(isPermanent: true),
          
          // Khu vực nội dung chính
          Expanded(
            child: child, // Hiển thị nội dung từ ShellRoute
          ),
        ],
      ),
      bottomNavigationBar: isLargeScreen ? BottomAppBar(
        color: Colors.white,
        height: 50.0,
        elevation: 0,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Copyright 2025 © CKCQUIZZ. All rights reserved.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ) : null, // Chỉ hiển thị footer trên màn hình lớn
    );
  }
}