import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/views/giangvien/dashboard_screen.dart'; // Import để lấy scaffoldKey
import 'package:ckcandr/providers/theme_provider.dart'; // Import theme provider từ providers

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
        const SizedBox(width: 10),
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 