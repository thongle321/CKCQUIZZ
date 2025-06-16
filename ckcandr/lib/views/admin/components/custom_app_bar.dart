import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/services/auth_service.dart' as auth_service;
import 'package:ckcandr/views/admin/dashboard_screen.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  
  const CustomAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isSidebarVisible = ref.watch(sidebarVisibleProvider);

    return AppBar(
      title: Text(title),
      backgroundColor: Colors.blue[600], // Màu xanh dương đậm hơn
      foregroundColor: Colors.white, // Text và icon màu trắng
      leading: isSmallScreen
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
            )
          : IconButton(
              icon: Icon(
                isSidebarVisible ? Icons.menu_open : Icons.menu,
              ),
              onPressed: () {
                ref.read(sidebarVisibleProvider.notifier).state = !isSidebarVisible;
              },
            ),
      actions: [
        // Thông tin người dùng đăng nhập
        if (!isSmallScreen) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Text(
                    currentUser?.hoVaTen.isNotEmpty == true 
                        ? currentUser!.hoVaTen[0].toUpperCase() 
                        : 'A',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currentUser?.hoVaTen ?? 'Administrator',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Menu thêm
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'profile') {
              // TODO: Navigate to profile
            } else if (value == 'settings') {
              // TODO: Navigate to settings
            } else if (value == 'logout') {
              try {
                // Đăng xuất từ authService
                final authService = ref.read(auth_service.authServiceProvider);
                await authService.logout();
                
                // Cập nhật Provider để xóa user hiện tại
                ref.read(currentUserControllerProvider.notifier).setUser(null);
                
                // Chuyển hướng
                if (context.mounted) {
                  GoRouter.of(context).go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi đăng xuất: ${e.toString()}')),
                  );
                }
              }
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'profile',
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Hồ sơ'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Cài đặt'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 