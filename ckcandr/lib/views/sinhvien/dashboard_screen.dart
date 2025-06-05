import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:ckcandr/views/sinhvien/danh_muc_mon_hoc_screen.dart';

class SinhVienDashboardScreen extends ConsumerWidget {
  final Widget? child;
  
  const SinhVienDashboardScreen({this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 600;
    
    // Lấy đường dẫn hiện tại để xác định menu nào đang active
    final String currentPath = GoRouterState.of(context).matchedLocation;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('CKC QUIZ'),
        automaticallyImplyLeading: !isLargeScreen, // Hiển thị nút menu trên màn hình nhỏ
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purple.shade100,
              child: user?.avatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      user!.avatar!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : 'S',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
            ),
            offset: const Offset(0, 56),
            onSelected: (value) async {
              if (value == 'logout') {
                final authService = ref.read(authServiceProvider);
                await authService.logout();
                ref.read(currentUserProvider.notifier).state = null;
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Sinh viên',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
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
                    Icon(Icons.logout_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: isLargeScreen ? null : _buildDrawer(context, ref, currentPath),
      body: Row(
        children: <Widget>[
          // Hiển thị drawer cố định trên màn hình lớn
          if (isLargeScreen)
            _buildDrawer(context, ref, currentPath, isPermanent: true),
          
          // Khu vực nội dung chính
          Expanded(
            child: child ?? _buildDashboardContent(context),
          ),
        ],
      ),
      bottomNavigationBar: isLargeScreen ? BottomAppBar(
        color: Colors.white,
        height: 50.0,
        elevation: 0,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Copyright 2025 © CKC QUIZZ. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ) : null, // Chỉ hiển thị footer trên màn hình lớn
    );
  }
  
  /// Xây dựng drawer cho thanh bên
  Widget _buildDrawer(BuildContext context, WidgetRef ref, String currentPath, {bool isPermanent = false}) {
    // Kiểm tra trang hiện tại để đánh dấu menu active
    final bool isDashboardActive = currentPath == '/sinhvien/dashboard';
    final bool isNhomHocPhanActive = currentPath == '/sinhvien/nhom-hoc-phan';
    final bool isMonHocActive = currentPath.contains('/sinhvien/mon-hoc');
    final bool isBaiKiemTraActive = currentPath.contains('/sinhvien/bai-kiem-tra');
    final bool isThongBaoActive = currentPath.contains('/sinhvien/thong-bao');

    Widget drawerContent = Column(
      children: <Widget>[
        // Header drawer
        Container(
          height: 120,
          color: isPermanent ? Colors.white : Colors.purple.shade50,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CKC QUIZ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.purple, 
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sinh viên',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _buildDrawerItem(
                icon: Icons.grid_view_outlined,
                text: 'Tổng quan',
                context: context,
                selected: isDashboardActive,
                onTap: () {
                  // Chuyển về trang dashboard chính
                  context.go('/sinhvien/dashboard');
                  if (!isPermanent && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'QUẢN LÝ',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              _buildDrawerItem(
                icon: Icons.folder_copy_outlined,
                text: 'Nhóm học phần',
                context: context,
                selected: isNhomHocPhanActive,
                onTap: () {
                  context.go('/sinhvien/nhom-hoc-phan');
                  if (!isPermanent && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              _buildDrawerItem(
                icon: Icons.book_outlined,
                text: 'Môn học',
                context: context,
                selected: isMonHocActive,
                onTap: () {
                  context.go('/sinhvien/danh-muc-mon-hoc');
                  if (!isPermanent && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              _buildDrawerItem(
                icon: Icons.assignment_outlined,
                text: 'Bài kiểm tra',
                context: context,
                selected: isBaiKiemTraActive,
                onTap: () {
                  context.go('/sinhvien/danh-muc-bai-kiem-tra');
                  if (!isPermanent && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              _buildDrawerItem(
                icon: Icons.notifications_active_outlined,
                text: 'Thông báo',
                context: context,
                selected: isThongBaoActive,
                onTap: () {
                  // TODO: Navigate to notifications
                  context.go('/sinhvien/thong-bao');
                  if (!isPermanent && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );

    if (isPermanent) {
      return Container(
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: drawerContent,
      );
    }
    
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 1,
      child: drawerContent,
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required BuildContext context,
    required VoidCallback onTap,
    required bool selected,
  }) {
    return ListTile(
      leading: Icon(
        icon, 
        color: selected ? Colors.purple : Colors.grey[600],
        size: 22,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.purple : Colors.grey[800],
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      tileColor: selected ? Colors.purple.withOpacity(0.1) : null,
      selected: selected,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      minLeadingWidth: 20,
    );
  }

  /// Widget nội dung chính của dashboard
  Widget _buildDashboardContent(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: const Text(
          'Nội dung trang tổng quan',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
} 