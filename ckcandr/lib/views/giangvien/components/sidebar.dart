import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/views/giangvien/components/custom_app_bar.dart';
import 'package:ckcandr/providers/theme_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/services/auth_service.dart' as auth_service;

class SidebarItem {
  final String title;
  final IconData icon;
  final String route;
  final bool selected;

  const SidebarItem({
    required this.title,
    required this.icon,
    required this.route,
    this.selected = false,
  });
}

class GiangVienSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const GiangVienSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.blue;
    final textColor = Colors.white;
    final listBackgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    
    // Kiểm tra xem có đang ở trong drawer hay không
    final isInDrawer = Scaffold.of(context).hasDrawer && 
        MediaQuery.of(context).size.width < 600;
    
    // Điều chỉnh chiều rộng dựa trên thiết bị và vị trí
    final sidebarWidth = isInDrawer 
        ? double.infinity 
        : MediaQuery.of(context).size.width * 0.25;
    
    final List<SidebarItem> menuItems = [
      SidebarItem(
        title: 'Tổng quan',
        icon: Icons.dashboard,
        route: '/giangvien/dashboard',
        selected: selectedIndex == 0,
      ),
      SidebarItem(
        title: 'Lớp học',
        icon: Icons.class_,
        route: '/giangvien/lophoc',
        selected: selectedIndex == 1,
      ),
      SidebarItem(
        title: 'Nhóm học phần',
        icon: Icons.group_work_outlined,
        route: '/giangvien/hocphan',
        selected: selectedIndex == 2,
      ),
      SidebarItem(
        title: 'Môn học',
        icon: Icons.book_outlined,
        route: '/giangvien/monhoc',
        selected: selectedIndex == 3,
      ),
      SidebarItem(
        title: 'Chương mục',
        icon: Icons.topic_outlined,
        route: '/giangvien/chuongmuc',
        selected: selectedIndex == 4,
      ),
      SidebarItem(
        title: 'Câu hỏi',
        icon: Icons.quiz_outlined,
        route: '/giangvien/cauhoi',
        selected: selectedIndex == 5,
      ),
      SidebarItem(
        title: 'Đề kiểm tra',
        icon: Icons.assignment_outlined,
        route: '/giangvien/kiemtra',
        selected: selectedIndex == 6,
      ),
      SidebarItem(
        title: 'Thông báo',
        icon: Icons.notifications_outlined,
        route: '/giangvien/thongbao',
        selected: selectedIndex == 7,
      ),
    ];

    final List<SidebarItem> accountMenuItems = [
      SidebarItem(
        title: 'Hồ sơ',
        icon: Icons.person,
        route: '/giangvien/profile',
        selected: selectedIndex == 8,
      ),
      SidebarItem(
        title: 'Đổi mật khẩu',
        icon: Icons.lock,
        route: '/giangvien/change-password',
        selected: selectedIndex == 9,
      ),
      SidebarItem(
        title: 'Đăng xuất',
        icon: Icons.logout,
        route: '/logout',
        selected: false,
      ),
    ];

    return Container(
      width: sidebarWidth,
      color: listBackgroundColor,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: isInDrawer ? 20 : 15, 
              horizontal: isInDrawer ? 16 : 10
            ),
            color: backgroundColor,
            width: double.infinity,
            child: Text(
              AppConstants.appName,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: isInDrawer ? 18 : 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Main menu items
                ...menuItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildMenuItem(context, item, index, isDarkMode, isInDrawer);
                }),

                // Divider
                Divider(color: Colors.grey[300]),

                // Account menu items
                ...accountMenuItems.asMap().entries.map((entry) {
                  final index = entry.key + menuItems.length;
                  final item = entry.value;
                  if (item.title == 'Đăng xuất') {
                    return _buildLogoutMenuItem(context, item, isDarkMode, isInDrawer, ref);
                  }
                  return _buildMenuItem(context, item, index, isDarkMode, isInDrawer);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, SidebarItem item, int index, bool isDarkMode, bool isInDrawer) {
    final selectedColor = isDarkMode ? Colors.blue : Colors.blue;
    final unselectedIconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final unselectedTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final selectedBackgroundColor = isDarkMode 
        ? Colors.blue.withOpacity(0.2) 
        : Colors.blue.withOpacity(0.1);

    // Tăng diện tích vùng nhấp cho menu item
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Gọi callback để thay đổi tab
          onItemSelected(index);
          
          // Không điều hướng để tránh lỗi trong navigation stack
          // Thay vì dùng context.go, chúng ta đã xử lý việc hiển thị
          // trong dashboard_screen.dart
        },
        splashColor: selectedColor.withOpacity(0.1),
        highlightColor: selectedColor.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: item.selected ? selectedBackgroundColor : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: item.selected ? selectedColor : Colors.transparent,
                width: 4.0,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isInDrawer ? 12 : 8, 
            horizontal: isInDrawer ? 16 : 8
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: item.selected ? selectedColor : unselectedIconColor,
                size: isInDrawer ? 24 : 20,
              ),
              SizedBox(width: isInDrawer ? 16 : 8),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    color: item.selected ? selectedColor : unselectedTextColor,
                    fontWeight: item.selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: isInDrawer ? 14 : 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutMenuItem(BuildContext context, SidebarItem item, bool isDarkMode, bool isInDrawer, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
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
        },
        splashColor: Colors.red.withOpacity(0.1),
        highlightColor: Colors.red.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              left: BorderSide(
                color: Colors.transparent,
                width: 4.0,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isInDrawer ? 12 : 8,
            horizontal: isInDrawer ? 16 : 8
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: Colors.red,
                size: isInDrawer ? 24 : 20,
              ),
              SizedBox(width: isInDrawer ? 16 : 8),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.normal,
                    fontSize: isInDrawer ? 14 : 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}