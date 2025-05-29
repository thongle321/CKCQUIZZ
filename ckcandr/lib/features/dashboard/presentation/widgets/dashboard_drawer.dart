import 'package:ckcandr/config/routes/app_routes.dart';
import 'package:flutter/material.dart';

class DashboardDrawer extends StatelessWidget {
  final Function(int) onSelectItem;
  final int selectedIndex;
  final bool isPermanent;

  const DashboardDrawer({
    super.key,
    required this.onSelectItem,
    required this.selectedIndex,
    this.isPermanent = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget drawerContent = ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        SizedBox(
          height: 120, // Adjust height as needed
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                'CKC QUIZ',
                style: theme.textTheme.headlineSmall?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        _buildDrawerItem(
          icon: Icons.grid_view_outlined,
          text: 'Tổng quan',
          index: 0,
          context: context,
          onTap: () {
            onSelectItem(0);
            final String? currentRouteName = ModalRoute.of(context)?.settings.name;
            if (currentRouteName != AppRoutes.dashboard) {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
            } else if (!isPermanent) {
              Navigator.pop(context); // Close drawer on non-permanent drawer if already on the page
            }
          },
        ),
        _buildDrawerSectionTitle('QUẢN LÝ', theme),
        _buildDrawerItem(
          icon: Icons.folder_copy_outlined, 
          text: 'Nhóm học phần',
          index: 1,
          context: context,
          onTap: () {
            onSelectItem(1);
            final String? currentRouteName = ModalRoute.of(context)?.settings.name;
            if (currentRouteName != AppRoutes.lopHocPhan) {
              Navigator.pushReplacementNamed(context, AppRoutes.lopHocPhan);
            } else if (!isPermanent) {
              Navigator.pop(context); // Close drawer on non-permanent drawer if already on the page
            }
          },
        ),
        _buildDrawerItem(
          icon: Icons.question_answer_outlined,
          text: 'Câu hỏi',
          index: 2,
          context: context,
          onTap: () {
            onSelectItem(2);
            // Add navigation logic for 'Câu hỏi' if it has a dedicated page
            // Example: Navigator.pushReplacementNamed(context, AppRoutes.cauHoiPage);
            if (!isPermanent) Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          icon: Icons.people_outline,
          text: 'Người dùng',
          index: 3,
          context: context,
          onTap: () {
            onSelectItem(3);
            // Add navigation logic for 'Người dùng'
            if (!isPermanent) Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          icon: Icons.book_outlined,
          text: 'Môn học',
          index: 4,
          context: context,
          onTap: () {
            onSelectItem(4);
            // Add navigation logic for 'Môn học'
            if (!isPermanent) Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          icon: Icons.assignment_outlined,
          text: 'Đề kiểm tra',
          index: 5,
          context: context,
          onTap: () {
            onSelectItem(5);
            // Add navigation logic for 'Đề kiểm tra'
            if (!isPermanent) Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          icon: Icons.notifications_active_outlined,
          text: 'Thông báo',
          index: 6,
          context: context,
          onTap: () {
            onSelectItem(6);
            // Add navigation logic for 'Thông báo'
            if (!isPermanent) Navigator.pop(context);
          },
        ),
      ],
    );

    if (isPermanent) {
      return Container(
        width: 250, // Standard drawer width
        decoration: BoxDecoration(
          color: theme.canvasColor,
          border: Border(right: BorderSide(color: theme.dividerColor, width: 1)),
        ),
        child: drawerContent,
      );
    }
    return Drawer(
      child: drawerContent,
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required int index,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    final ThemeData theme = Theme.of(context);
    final bool isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? theme.primaryColor : theme.iconTheme.color),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
      selected: isSelected,
      onTap: onTap,
    );
  }

  Widget _buildDrawerSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 