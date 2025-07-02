import 'package:flutter/material.dart';
import 'package:ckcandr/models/user_model.dart';

/// Widget header hiển thị avatar và thông tin cơ bản của người dùng
class ProfileHeader extends StatelessWidget {
  final dynamic user; // NguoiDung hoặc GetNguoiDungDTO
  final VoidCallback? onAvatarTap;

  const ProfileHeader({
    super.key,
    required this.user,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: onAvatarTap,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 42,
                      backgroundImage: _getAvatarImage(),
                      backgroundColor: Colors.grey[300],
                      child: _getAvatarImage() == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey[600],
                            )
                          : null,
                    ),
                  ),
                  if (onAvatarTap != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Thông tin cơ bản
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên
                  Text(
                    _getUserName(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Email
                  Text(
                    _getUserEmail(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getRoleDisplayName(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lấy ảnh avatar
  ImageProvider? _getAvatarImage() {
    String? avatarUrl;

    // Kiểm tra type của user và lấy avatar tương ứng
    try {
      final userType = user.runtimeType.toString();

      // Kiểm tra CurrentUserProfileDTO trước
      if (userType.contains('CurrentUserProfileDTO')) {
        avatarUrl = (user as dynamic).avatar;
      }
      // Kiểm tra GetNguoiDungDTO hoặc các model khác
      else if (user != null) {
        // Thử các thuộc tính avatar có thể có
        avatarUrl = (user as dynamic).avatar ??
                   (user as dynamic).anhDaiDien;
      }
    } catch (e) {
      // Nếu có lỗi, thử fallback
      try {
        avatarUrl = (user as dynamic).avatar ??
                   (user as dynamic).anhDaiDien;
      } catch (e2) {
        avatarUrl = null;
      }
    }

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return NetworkImage(avatarUrl);
    }

    return null;
  }

  /// Lấy tên người dùng
  String _getUserName() {
    try {
      final userType = user.runtimeType.toString();

      // Kiểm tra CurrentUserProfileDTO trước
      if (userType.contains('CurrentUserProfileDTO')) {
        return (user as dynamic).fullname ?? 'Không có tên';
      }
      // Kiểm tra GetNguoiDungDTO
      else if (userType.contains('GetNguoiDungDTO')) {
        return (user as dynamic).hoten ?? 'Không có tên';
      }
      // Đây là NguoiDung hoặc User model
      else {
        return (user as dynamic).hoVaTen ?? 'Không có tên';
      }
    } catch (e) {
      // Fallback: thử tất cả các thuộc tính có thể
      try {
        return (user as dynamic).fullname ??
               (user as dynamic).hoten ??
               (user as dynamic).hoVaTen ??
               'Không có tên';
      } catch (e2) {
        return 'Không có tên';
      }
    }
  }

  /// Lấy email người dùng
  String _getUserEmail() {
    try {
      return (user as dynamic).email ?? 'Không có email';
    } catch (e) {
      return 'Không có email';
    }
  }

  /// Lấy tên hiển thị của role
  String _getRoleDisplayName() {
    try {
      return (user as dynamic).tenQuyen ??
             (user as dynamic).currentRole ??
             (user as dynamic).quyen?.name ??
             'Không có quyền';
    } catch (e) {
      return 'Không có quyền';
    }
  }
}

/// Widget hiển thị thông tin cơ bản trong một row
class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor ?? Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget hiển thị badge với icon và text
class ProfileBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const ProfileBadge({
    super.key,
    required this.icon,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor ?? Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor ?? Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
