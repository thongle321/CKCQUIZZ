import 'package:flutter/material.dart';
import 'package:ckcandr/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/theme_provider.dart';
import 'package:ckcandr/core/utils/responsive_helper.dart';

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

class SinhVienSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SinhVienSidebar({
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

    // Sử dụng ResponsiveHelper để kiểm tra
    final isInDrawer = context.shouldUseDrawer;

    // Điều chỉnh chiều rộng responsive
    final sidebarWidth = isInDrawer
        ? double.infinity
        : ResponsiveHelper.getSidebarWidth(context);
    
    final List<SidebarItem> menuItems = [
      SidebarItem(
        title: 'Tổng quan',
        icon: Icons.dashboard,
        route: '/sinhvien/dashboard',
        selected: selectedIndex == 0,
      ),
      SidebarItem(
        title: 'Nhóm học phần',
        icon: Icons.group_work_outlined,
        route: '/sinhvien/nhom-hoc-phan',
        selected: selectedIndex == 1,
      ),
      SidebarItem(
        title: 'Môn học',
        icon: Icons.book_outlined,
        route: '/sinhvien/danh-muc-mon-hoc',
        selected: selectedIndex == 2,
      ),
      SidebarItem(
        title: 'Bài kiểm tra',
        icon: Icons.assignment_outlined,
        route: '/sinhvien/danh-muc-bai-kiem-tra',
        selected: selectedIndex == 3,
      ),
      SidebarItem(
        title: 'Thông báo',
        icon: Icons.notifications_outlined,
        route: '/sinhvien/thong-bao',
        selected: selectedIndex == 4,
      ),
    ];

    return Container(
      width: sidebarWidth,
      color: listBackgroundColor,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.getResponsiveValue(
                context,
                mobile: 24,
                tablet: 20,
                desktop: 16,
              ),
              horizontal: ResponsiveHelper.getResponsiveValue(
                context,
                mobile: 20,
                tablet: 16,
                desktop: 12,
              ),
            ),
            color: backgroundColor,
            width: double.infinity,
            child: Column(
              children: [
                Icon(
                  Icons.school,
                  color: textColor,
                  size: ResponsiveHelper.getIconSize(context, baseSize: 28),
                ),
                SizedBox(height: 8),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 17,
                      desktop: 16,
                    ),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Sinh viên',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 11,
                      desktop: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuItem(context, item, index, isDarkMode, isInDrawer);
              },
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
        ? Colors.blue.withValues(alpha: 0.2)
        : Colors.blue.withValues(alpha: 0.1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onItemSelected(index);
        },
        borderRadius: context.responsiveBorderRadius,
        child: Container(
          margin: context.responsiveMargin.copyWith(
            top: 4,
            bottom: 4,
          ),
          decoration: BoxDecoration(
            borderRadius: context.responsiveBorderRadius,
            color: item.selected ? selectedBackgroundColor : Colors.transparent,
          ),
          child: ListTile(
            leading: Icon(
              item.icon,
              color: item.selected ? selectedColor : unselectedIconColor,
              size: ResponsiveHelper.getIconSize(
                context,
                baseSize: isInDrawer ? 24 : 20,
              ),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                color: item.selected ? selectedColor : unselectedTextColor,
                fontWeight: item.selected ? FontWeight.bold : FontWeight.normal,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 15,
                  desktop: 14,
                ),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveValue(
                context,
                mobile: 20,
                tablet: 16,
                desktop: 12,
              ),
              vertical: ResponsiveHelper.getResponsiveValue(
                context,
                mobile: 12,
                tablet: 8,
                desktop: 4,
              ),
            ),
            minLeadingWidth: ResponsiveHelper.getResponsiveValue(
              context,
              mobile: 40,
              tablet: 35,
              desktop: 30,
            ),
          ),
        ),
      ),
    );
  }
}
