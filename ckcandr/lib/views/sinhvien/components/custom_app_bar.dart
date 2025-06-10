import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/services/auth_service.dart' as auth_service;
import 'package:ckcandr/views/sinhvien/dashboard_screen.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/core/utils/responsive_helper.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  
  const CustomAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isSmallScreen = ResponsiveHelper.shouldUseDrawer(context);

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 18,
            tablet: 19,
            desktop: 20,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: context.responsiveElevation,
      shadowColor: Colors.grey.withValues(alpha: 0.3),
      toolbarHeight: ResponsiveHelper.getAppBarHeight(context),
      leading: isSmallScreen 
        ? IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
          )
        : IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Toggle sidebar visibility on large screens
              final currentVisibility = ref.read(sidebarVisibleProvider);
              ref.read(sidebarVisibleProvider.notifier).state = !currentVisibility;
            },
          ),
      actions: [
        // Notification button
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined),
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
        const SizedBox(width: 8),
        
        // User profile dropdown
        PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.purple.shade100,
            child: currentUser?.anhDaiDien != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    currentUser!.anhDaiDien!,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                )
              : Text(
                  currentUser?.hoVaTen.isNotEmpty == true
                    ? currentUser!.hoVaTen[0].toUpperCase()
                    : 'S',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
          ),
          offset: const Offset(0, 56),
          onSelected: (value) async {
            switch (value) {
              case 'profile':
                // TODO: Navigate to profile
                break;
              case 'settings':
                // TODO: Navigate to settings
                break;
              case 'logout':
                final authService = ref.read(auth_service.authServiceProvider);
                await authService.logout();
                ref.read(currentUserControllerProvider.notifier).setUser(null);
                if (context.mounted) {
                  context.go('/login');
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào, ${currentUser?.hoVaTen ?? "Sinh viên"}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser?.email ?? 'sv@ckcquizz.com',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Vai trò: Sinh viên',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
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
                  Icon(Icons.logout_outlined, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
