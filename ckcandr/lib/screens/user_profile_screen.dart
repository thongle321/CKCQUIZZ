import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/providers/user_profile_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/widgets/user_profile/profile_header.dart';
import 'package:ckcandr/widgets/user_profile/profile_info_section.dart';
import 'package:ckcandr/widgets/user_profile/profile_stats_section.dart';
import 'package:ckcandr/widgets/user_profile/profile_actions_section.dart';
import 'package:ckcandr/core/theme/role_theme.dart';

/// Màn hình hồ sơ người dùng
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final userStatsAsync = ref.watch(userStatsProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return RoleThemedWidget(
      role: currentUser.quyen,
      child: Builder(
        builder: (themedContext) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Hồ sơ cá nhân'),
              backgroundColor: Theme.of(themedContext).primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _openSidebar(context, ref),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    // Refresh dữ liệu
                    ref.invalidate(userProfileProvider);
                    ref.invalidate(userStatsProvider);
                  },
                ),
              ],
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh dữ liệu khi pull to refresh
          ref.invalidate(userProfileProvider);
          ref.invalidate(userStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với avatar và thông tin cơ bản
              userProfileAsync.when(
                data: (userProfile) => ProfileHeader(
                  user: userProfile ?? currentUser!,
                  onAvatarTap: () => _showAvatarOptions(context, ref),
                ),
                loading: () => const ProfileHeaderSkeleton(),
                error: (error, stack) => ProfileHeader(
                  user: currentUser!,
                  onAvatarTap: () => _showAvatarOptions(context, ref),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Thông tin chi tiết
              userProfileAsync.when(
                data: (userProfile) => ProfileInfoSection(
                  user: userProfile ?? currentUser!,
                  onEditPressed: () => _showEditDialog(context, ref, userProfile ?? currentUser!),
                ),
                loading: () => const ProfileInfoSkeleton(),
                error: (error, stack) => ProfileInfoSection(
                  user: currentUser!,
                  onEditPressed: () => _showEditDialog(context, ref, currentUser!),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Thống kê theo role
              userStatsAsync.when(
                data: (stats) => ProfileStatsSection(
                  stats: stats,
                  userRole: currentUser?.quyen.name ?? '',
                ),
                loading: () => const ProfileStatsSkeleton(),
                error: (error, stack) => const SizedBox.shrink(),
              ),
              
              const SizedBox(height: 24),
              
              // Các hành động
              ProfileActionsSection(
                onLogout: () => _showLogoutDialog(context, ref),
                onChangePassword: () => _showChangePasswordDialog(context, ref),
                onSettings: () => _navigateToSettings(context),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
          );
        },
      ),
    );
  }

  /// Hiển thị tùy chọn avatar
  void _showAvatarOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto(ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Xóa ảnh'),
              onTap: () {
                Navigator.pop(context);
                _removeAvatar(ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Chụp ảnh từ camera
  void _takePhoto(WidgetRef ref) {
    // TODO: Implement camera functionality
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(content: Text('Chức năng chụp ảnh đang được phát triển')),
    );
  }

  /// Chọn ảnh từ thư viện
  void _pickFromGallery(WidgetRef ref) {
    // TODO: Implement gallery picker
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(content: Text('Chức năng chọn ảnh đang được phát triển')),
    );
  }

  /// Xóa avatar
  void _removeAvatar(WidgetRef ref) {
    // TODO: Implement remove avatar
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(content: Text('Chức năng xóa ảnh đang được phát triển')),
    );
  }

  /// Hiển thị dialog chỉnh sửa thông tin
  void _showEditDialog(BuildContext context, WidgetRef ref, dynamic user) {
    // TODO: Implement edit profile dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng chỉnh sửa đang được phát triển')),
    );
  }

  /// Mở sidebar để điều hướng
  void _openSidebar(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return RoleThemedWidget(
          role: currentUser.quyen,
          child: Builder(
            builder: (sidebarThemedContext) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Header với gradient
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(sidebarThemedContext).primaryColor,
                              Theme.of(sidebarThemedContext).primaryColor.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.school,
                                color: Theme.of(sidebarThemedContext).primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CKC QUIZZ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Sinh viên',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menu items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        _buildDrawerMenuItem(
                          sidebarThemedContext,
                          icon: Icons.dashboard,
                          title: 'Tổng quan',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/sinhvien?tab=0');
                          },
                        ),
                        _buildDrawerMenuItem(
                          sidebarThemedContext,
                          icon: Icons.school,
                          title: 'Lớp học',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/sinhvien?tab=1');
                          },
                          isSelected: false,
                        ),
                        _buildDrawerMenuItem(
                          sidebarThemedContext,
                          icon: Icons.group,
                          title: 'Nhóm học phần',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/sinhvien?tab=2');
                          },
                        ),
                        _buildDrawerMenuItem(
                          sidebarThemedContext,
                          icon: Icons.book,
                          title: 'Môn học',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/sinhvien?tab=3');
                          },
                        ),
                        _buildDrawerMenuItem(
                          sidebarThemedContext,
                          icon: Icons.quiz,
                          title: 'Bài kiểm tra',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/sinhvien?tab=4');
                          },
                        ),
                        _buildDrawerMenuItem(
                          sidebarThemedContext,
                          icon: Icons.notifications,
                          title: 'Thông báo',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/sinhvien?tab=5');
                          },
                        ),
                        _buildDrawerMenuItem(
                          sidebarThemedContext,
                          icon: Icons.person,
                          title: 'Hồ sơ',
                          onTap: () {
                            Navigator.pop(context);
                            // Đã ở trang profile rồi
                          },
                          isSelected: true,
                        ),
                        _buildDrawerMenuItem(
                          sidebarThemedContext,
                          icon: Icons.lock,
                          title: 'Đổi mật khẩu',
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chức năng đổi mật khẩu đang được phát triển')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }

  /// Tạo drawer menu item
  Widget _buildDrawerMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  /// Hiển thị dialog đăng xuất
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(currentUserControllerProvider.notifier).clearUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  /// Hiển thị dialog đổi mật khẩu
  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement change password dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng đổi mật khẩu đang được phát triển')),
    );
  }

  /// Điều hướng đến màn hình cài đặt
  void _navigateToSettings(BuildContext context) {
    // TODO: Implement settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng cài đặt đang được phát triển')),
    );
  }
}

/// Skeleton loading cho header
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: 150, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Container(height: 16, width: 200, color: Colors.grey[300]),
                  const SizedBox(height: 4),
                  Container(height: 16, width: 100, color: Colors.grey[300]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading cho thông tin
class ProfileInfoSkeleton extends StatelessWidget {
  const ProfileInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(height: 20, width: double.infinity, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Container(height: 16, width: double.infinity, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Container(height: 16, width: double.infinity, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Container(height: 16, width: double.infinity, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading cho thống kê
class ProfileStatsSkeleton extends StatelessWidget {
  const ProfileStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(height: 60, width: 80, color: Colors.grey[300]),
            Container(height: 60, width: 80, color: Colors.grey[300]),
            Container(height: 60, width: 80, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
