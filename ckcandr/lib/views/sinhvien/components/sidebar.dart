import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/student_notification_provider.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/services/auth_service.dart' as auth_service;

class SinhVienSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SinhVienSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final primaryColor = RoleTheme.getPrimaryColor(role);
    final accentColor = RoleTheme.getAccentColor(role);

    return Container(
      width: isSmallScreen ? double.infinity : 250,
      color: accentColor,
      child: SafeArea(
        child: Column(
          children: [
            // User info header
            if (isSmallScreen)
              UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountName: Text(
                  currentUser?.hoVaTen ?? 'Sinh viên',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                accountEmail: Text(
                  currentUser?.email ?? 'sv@ckcquiz.com',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: primaryColor.withValues(alpha: 0.8),
                  child: Text(
                    currentUser?.hoVaTen.isNotEmpty == true
                        ? currentUser!.hoVaTen[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: primaryColor.withValues(alpha: 0.8),
                      child: Text(
                        currentUser?.hoVaTen.isNotEmpty == true
                            ? currentUser!.hoVaTen[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentUser?.hoVaTen ?? 'Sinh viên',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      currentUser?.email ?? 'sv@ckcquiz.com',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        RoleTheme.getRoleName(role),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Divider(color: Colors.grey[300]),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    index: 0,
                    title: 'Tổng quan',
                    icon: Icons.dashboard,
                    selected: selectedIndex == 0,
                    onTap: () => onItemSelected(0),
                  ),
                  _buildMenuItem(
                    context,
                    index: 1,
                    title: 'Danh sách lớp',
                    icon: Icons.class_,
                    selected: selectedIndex == 1,
                    onTap: () => onItemSelected(1),
                  ),
                  _buildMenuItem(
                    context,
                    index: 2,
                    title: 'Bài kiểm tra',
                    icon: Icons.assignment_outlined,
                    selected: selectedIndex == 2,
                    onTap: () => onItemSelected(2),
                  ),
                  _buildNotificationMenuItem(
                    context,
                    index: 3,
                    title: 'Thông báo',
                    icon: Icons.notifications_outlined,
                    selected: selectedIndex == 3,
                    onTap: () => onItemSelected(3),
                  ),
                  Divider(color: Colors.grey[300]),

                  _buildMenuItem(
                    context,
                    index: 4,
                    title: 'Hồ sơ',
                    icon: Icons.person,
                    selected: selectedIndex == 4,
                    onTap: () => onItemSelected(4),
                  ),
                  _buildMenuItem(
                    context,
                    index: 5,
                    title: 'Đổi mật khẩu',
                    icon: Icons.lock,
                    selected: selectedIndex == 5,
                    onTap: () => onItemSelected(5),
                  ),
                  _buildMenuItem(
                    context,
                    index: 6,
                    title: 'Đăng xuất',
                    icon: Icons.logout,
                    selected: false,
                    onTap: () => _handleLogout(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
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

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final currentUser = ref.watch(currentUserProvider);
        final role = currentUser?.quyen ?? UserRole.sinhVien;
        final primaryColor = RoleTheme.getPrimaryColor(role);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected
                ? primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: selected ? primaryColor : Colors.grey[600],
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? primaryColor : Colors.grey[800],
              ),
            ),
            selected: selected,
            onTap: onTap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationMenuItem(
    BuildContext context, {
    required int index,
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final unreadCount = ref.watch(unreadNotificationCountProvider);

        return _buildMenuItemWithBadge(
          context,
          index: index,
          title: title,
          icon: icon,
          selected: selected,
          onTap: onTap,
          badgeCount: unreadCount,
        );
      },
    );
  }

  Widget _buildMenuItemWithBadge(
    BuildContext context, {
    required int index,
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required int badgeCount,
  }) {
    final primaryColor = RoleTheme.getPrimaryColor(UserRole.sinhVien);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: Stack(
            children: [
              Icon(
                icon,
                color: selected ? primaryColor : Colors.grey[600],
              ),
              if (badgeCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? primaryColor : Colors.grey[800],
            ),
          ),
          selected: selected,
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

}
