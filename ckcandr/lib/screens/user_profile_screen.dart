import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/providers/user_profile_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/widgets/user_profile/profile_header.dart';
import 'package:ckcandr/widgets/user_profile/profile_info_section.dart';
import 'package:ckcandr/widgets/user_profile/profile_actions_section.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/services/user_profile_service.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/widgets/user_profile/avatar_picker_dialog.dart';
import 'package:ckcandr/widgets/user_profile/reset_password_dialog.dart';

/// Màn hình hồ sơ người dùng
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _navigateBackToDashboard(context, ref),
              ),
              actions: [
                // Debug button for testing upload and change password
                // IconButton(
                //   icon: const Icon(Icons.bug_report),
                //   onPressed: () async {
                //     final userProfileService = ref.read(userProfileServiceProvider);
                //     await userProfileService.debugTestFunctions();

                //     if (context.mounted) {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(
                //           content: Text('Debug test completed. Check console logs.'),
                //           backgroundColor: Colors.blue,
                //         ),
                //       );
                //     }
                //   },
                // ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    // Refresh dữ liệu
                    ref.invalidate(userProfileProvider);
                  },
                ),
              ],
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh dữ liệu khi pull to refresh
          ref.invalidate(userProfileProvider);
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
              
              // Các hành động
              ProfileActionsSection(
                onChangePassword: () => _showResetPasswordDialog(context),
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
    final userProfileAsync = ref.watch(userProfileProvider);

    userProfileAsync.when(
      data: (userProfile) {
        final currentAvatarUrl = userProfile?.avatar ?? '';

        showDialog(
          context: context,
          builder: (context) => AvatarPickerDialog(
            currentAvatarUrl: currentAvatarUrl,
            onAvatarUpdated: (newAvatarUrl) {
              // Cập nhật avatar trong profile
              _updateAvatarInProfile(ref, newAvatarUrl);
            },
          ),
        );
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang tải thông tin người dùng...')),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $error')),
        );
      },
    );
  }

  /// Cập nhật avatar trong profile
  Future<void> _updateAvatarInProfile(WidgetRef ref, String newAvatarUrl) async {
    try {
      final userProfileAsync = ref.read(userProfileProvider);

      await userProfileAsync.when(
        data: (userProfile) async {
          if (userProfile != null) {
            // Tạo request cập nhật với avatar mới
            final updateRequest = UpdateUserProfileDTO(
              username: userProfile.username,
              fullname: userProfile.fullname,
              email: userProfile.email,
              gender: userProfile.gender ?? true,
              dob: userProfile.dob,
              phoneNumber: userProfile.phonenumber,
              avatar: newAvatarUrl,
            );

            // Gọi service để cập nhật
            final userProfileService = ref.read(userProfileServiceProvider);
            final success = await userProfileService.updateUserProfile(updateRequest);

            if (success) {
              // Refresh provider để cập nhật UI
              ref.invalidate(userProfileProvider);
            } else {
              throw Exception('Không thể cập nhật thông tin người dùng');
            }
          }
        },
        loading: () async {
          throw Exception('Đang tải thông tin người dùng');
        },
        error: (error, stack) async {
          throw Exception('Lỗi khi lấy thông tin người dùng: $error');
        },
      );
    } catch (e) {
      // Hiển thị lỗi nếu có
      if (ref.context.mounted) {
        _showErrorDialog(ref.context, 'Lỗi khi cập nhật avatar', e.toString());
      }
    }
  }

  /// Hiển thị dialog chỉnh sửa thông tin
  void _showEditDialog(BuildContext context, WidgetRef ref, dynamic user) {
    // Form controllers
    final nameController = TextEditingController(text: _getUserName(user));
    final phoneController = TextEditingController(text: _getUserPhone(user));
    bool? genderValue = _getUserGender(user);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<bool>(
                value: genderValue,
                decoration: const InputDecoration(
                  labelText: 'Giới tính',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: true,
                    child: Text('Nam'),
                  ),
                  DropdownMenuItem(
                    value: false,
                    child: Text('Nữ'),
                  ),
                ],
                onChanged: (value) {
                  genderValue = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateUserProfile(
                context, 
                ref, 
                user, 
                nameController.text, 
                phoneController.text, 
                genderValue,
              );
              Navigator.pop(context);
            },
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  /// Cập nhật thông tin người dùng
  void _updateUserProfile(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    String name,
    String phone,
    bool? gender,
  ) async {
    try {
      final userProfileService = ref.read(userProfileServiceProvider);

      // Tạo request update user profile
      final updateRequest = UpdateUserProfileDTO(
        username: _getUserEmail(user),
        email: _getUserEmail(user),
        fullname: name,
        dob: _getUserDob(user),
        phoneNumber: phone,
        gender: gender ?? true,
        avatar: _getUserAvatar(user),
      );

      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang cập nhật thông tin...')),
      );

      // Call API service
      final success = await userProfileService.updateUserProfile(updateRequest);

      if (success) {
        // Refresh data
        ref.invalidate(userProfileProvider);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công')),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thất bại')),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  /// Lấy tên người dùng
  String _getUserName(dynamic user) {
    try {
      if (user is CurrentUserProfileDTO) {
        return user.fullname;
      }
      return user.hoten ?? user.hoVaTen ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Lấy email người dùng
  String _getUserEmail(dynamic user) {
    try {
      return user.email ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Lấy số điện thoại người dùng
  String _getUserPhone(dynamic user) {
    try {
      if (user is CurrentUserProfileDTO) {
        return user.phonenumber;
      }
      return user.phoneNumber ?? user.soDienThoai ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Lấy giới tính người dùng
  bool? _getUserGender(dynamic user) {
    try {
      if (user is CurrentUserProfileDTO) {
        return user.gender;
      }
      return user.gioitinh ?? user.gioiTinh;
    } catch (e) {
      return true;
    }
  }

  /// Lấy ngày sinh người dùng
  DateTime? _getUserDob(dynamic user) {
    try {
      if (user is CurrentUserProfileDTO) {
        return user.dob;
      }
      final dob = user.ngaysinh ?? user.ngaySinh;
      if (dob == null) return null;

      if (dob is DateTime) {
        return dob;
      } else if (dob is String) {
        return DateTime.tryParse(dob);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Lấy avatar người dùng
  String _getUserAvatar(dynamic user) {
    try {
      if (user is CurrentUserProfileDTO) {
        return user.avatar;
      }
      return user.anhDaiDien ?? user.avatar ?? '';
    } catch (e) {
      return '';
    }
  }



  /// Hiển thị dialog đổi mật khẩu qua Reset Password Flow
  void _showResetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ResetPasswordDialog(),
    );
  }



  /// Điều hướng về trang tổng quan theo role
  void _navigateBackToDashboard(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      context.go('/login');
      return;
    }

    // Điều hướng về dashboard tương ứng với role
    switch (currentUser.quyen) {
      case UserRole.admin:
        context.go('/admin/dashboard');
        break;
      case UserRole.giangVien:
        context.go('/giangvien');
        break;
      case UserRole.sinhVien:
        context.go('/sinhvien');
        break;
    }
  }

  /// Hiển thị dialog lỗi thay vì SnackBar
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Đóng'),
            ),
          ],
        );
      },
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
