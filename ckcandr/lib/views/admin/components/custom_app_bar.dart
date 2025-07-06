import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/views/admin/dashboard_screen.dart';
import 'package:ckcandr/providers/user_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.scaffoldKey,
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
                scaffoldKey?.currentState?.openDrawer();
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
        // Profile button
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            context.go('/profile');
          },
          tooltip: 'Hồ sơ cá nhân',
        ),
        // Thông tin người dùng đăng nhập
        if (!isSmallScreen) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 