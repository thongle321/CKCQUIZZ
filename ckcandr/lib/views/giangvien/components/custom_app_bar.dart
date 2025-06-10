import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/views/giangvien/dashboard_screen.dart'; // Import để lấy scaffoldKey
import 'package:ckcandr/providers/theme_provider.dart'; // Import theme provider từ providers
import 'package:ckcandr/providers/user_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  
  const CustomAppBar({
    super.key,
    required this.title,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final isDarkMode = currentTheme == ThemeMode.dark;
    final isSidebarVisible = ref.watch(sidebarVisibleProvider);
    
    // Màu sắc phù hợp với chế độ dark/light
    final appBarColor = isDarkMode ? Colors.black : Colors.blue;
    final textColor = Colors.white;
    
    // Kiểm tra xem có đang ở thiết bị nhỏ không
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.menu,
            color: textColor,
          ),
          onPressed: () {
            try {
              // Mở drawer nếu trên thiết bị nhỏ, ngược lại toggle sidebar
              if (isSmallScreen) {
                // Sử dụng Scaffold.of(context) thay vì scaffoldKey để tránh lỗi
                Scaffold.of(context).openDrawer();
              } else {
                ref.read(sidebarVisibleProvider.notifier).state = !isSidebarVisible;
              }
            } catch (e) {
              // Xử lý lỗi nếu có
              debugPrint('Không thể mở drawer: $e');
            }
          },
          tooltip: 'Menu',
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: appBarColor,
      iconTheme: IconThemeData(color: textColor),
      actions: [
        PopupMenuButton<String>(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 15,
            child: Icon(Icons.person, color: Colors.blue, size: 20),
          ),
          offset: const Offset(0, 40),
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          onSelected: (value) async {
            switch (value) {
              case 'profile':
                // TODO: Navigate to profile
                break;
              case 'theme':
                // Sử dụng toggleTheme() từ ThemeNotifier
                ref.read(themeProvider.notifier).toggleTheme();
                break;
              case 'logout':
                final authService = ref.read(authServiceProvider);
                await authService.logout();
                ref.read(currentUserControllerProvider.notifier).setUser(null);
                if (context.mounted) {
                  context.go('/login');
                }
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(
                    Icons.person, 
                    color: isDarkMode ? Colors.white : Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Hồ sơ cá nhân',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'theme',
              child: Row(
                children: [
                  Icon(
                    currentTheme == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
                    color: isDarkMode ? Colors.white : Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    currentTheme == ThemeMode.light ? 'Chế độ tối' : 'Chế độ sáng',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: isDarkMode ? Colors.white : Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 