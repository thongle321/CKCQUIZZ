import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/views/giangvien/dashboard_screen.dart'; // Import để lấy scaffoldKey
import 'package:ckcandr/providers/theme_provider.dart'; // Import theme provider từ providers
// BỎ IMPORT AUTO-REFRESH THEO YÊU CẦU USER
// import 'package:ckcandr/services/auto_refresh_service.dart';
// import 'package:ckcandr/widgets/auto_refresh_indicator.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? currentScreenKey; // Key để xác định màn hình hiện tại cho auto-refresh

  const CustomAppBar({
    super.key,
    required this.title,
    this.currentScreenKey,
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
            isSmallScreen
              ? Icons.menu
              : (isSidebarVisible ? Icons.menu_open : Icons.menu),
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
          tooltip: isSmallScreen ? 'Menu' : (isSidebarVisible ? 'Ẩn sidebar' : 'Hiện sidebar'),
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
        // BỎ AUTO-REFRESH TOGGLE BUTTON THEO YÊU CẦU USER
        // Auto-refresh toggle button (chỉ hiển thị cho một số màn hình)
        // if (currentScreenKey != null) ...[
        //   AutoRefreshToggleButton(
        //     refreshKey: currentScreenKey!,
        //     onRefresh: () {
        //       // Callback sẽ được handle bởi màn hình tương ứng
        //       debugPrint('Manual refresh triggered for $currentScreenKey');
        //     },
        //     icon: Icons.autorenew,
        //     tooltip: 'Bật/tắt tự động làm mới',
        //     activeColor: Colors.green,
        //     inactiveColor: textColor.withValues(alpha: 0.7),
        //   ),
        // ],
        IconButton(
          icon: Icon(
            Icons.person,
            color: textColor,
          ),
          onPressed: () {
            context.go('/profile');
          },
          tooltip: 'Hồ sơ cá nhân',
        ),
        const SizedBox(width: 10),
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 