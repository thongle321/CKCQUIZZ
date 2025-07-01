import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/views/sinhvien/dashboard_screen.dart';
import 'package:ckcandr/core/utils/responsive_helper.dart';
import 'package:ckcandr/providers/student_notification_provider.dart';
import 'package:ckcandr/services/realtime_notification_service.dart';

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
        // Profile button
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            context.go('/profile');
          },
          tooltip: 'Hồ sơ cá nhân',
        ),
        // Notification button with badge
        _buildNotificationButton(context, ref),
        const SizedBox(width: 16),
      ],
    );
  }

  /// Xây dựng notification button với badge
  Widget _buildNotificationButton(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(studentNotificationProvider);
    final unreadCount = notificationState.unreadCount;

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined),
          onPressed: () {
            // Điều hướng đến tab thông báo trong dashboard (index 3)
            context.go('/sinhvien/dashboard?tab=3');
          },
          tooltip: 'Thông báo',
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
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
                unreadCount > 99 ? '99+' : unreadCount.toString(),
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
    );
  }
}
