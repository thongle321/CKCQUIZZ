import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/widgets/user_profile/profile_header.dart';

/// Widget hiển thị thông tin chi tiết của người dùng
class ProfileInfoSection extends StatelessWidget {
  final dynamic user; // NguoiDung hoặc GetNguoiDungDTO
  final VoidCallback? onEditPressed;

  const ProfileInfoSection({
    super.key,
    required this.user,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với tiêu đề và nút chỉnh sửa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thông tin cá nhân',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                if (onEditPressed != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEditPressed,
                    tooltip: 'Chỉnh sửa thông tin',
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Thông tin chi tiết
            _buildInfoRows(context),
          ],
        ),
      ),
    );
  }

  /// Xây dựng các hàng thông tin
  Widget _buildInfoRows(BuildContext context) {
    return Column(
      children: [
        // Họ tên
        ProfileInfoRow(
          icon: Icons.person,
          label: 'Họ tên',
          value: _getUserName(),
        ),
        
        const Divider(height: 1),
        
        // Email
        ProfileInfoRow(
          icon: Icons.email,
          label: 'Email',
          value: _getUserEmail(),
        ),
        
        const Divider(height: 1),
        
        // Vai trò
        ProfileInfoRow(
          icon: Icons.badge,
          label: 'Vai trò',
          value: _getRoleDisplayName(),
        ),
        
        // MSSV/MSGV (nếu có)
        if (_getUserCode().isNotEmpty) ...[
          const Divider(height: 1),
          ProfileInfoRow(
            icon: Icons.badge_outlined,
            label: _getCodeLabel(),
            value: _getUserCode(),
          ),
        ],
        
        // Số điện thoại (nếu có)
        if (_getPhoneNumber().isNotEmpty) ...[
          const Divider(height: 1),
          ProfileInfoRow(
            icon: Icons.phone,
            label: 'Số điện thoại',
            value: _getPhoneNumber(),
          ),
        ],
        
        // Giới tính (nếu có)
        if (_getGender().isNotEmpty) ...[
          const Divider(height: 1),
          ProfileInfoRow(
            icon: Icons.person_outline,
            label: 'Giới tính',
            value: _getGender(),
          ),
        ],
        
        // Ngày sinh (nếu có)
        if (_getBirthDate().isNotEmpty) ...[
          const Divider(height: 1),
          ProfileInfoRow(
            icon: Icons.cake,
            label: 'Ngày sinh',
            value: _getBirthDate(),
          ),
        ],
        
        // Ngày tham gia
        if (_getJoinDate().isNotEmpty) ...[
          const Divider(height: 1),
          ProfileInfoRow(
            icon: Icons.calendar_today,
            label: 'Ngày tham gia',
            value: _getJoinDate(),
          ),
        ],
        
        // Loại bỏ trạng thái tài khoản vì API không trả về
      ],
    );
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

  /// Lấy mã người dùng (MSSV/MSGV)
  String _getUserCode() {
    try {
      // Thử các thuộc tính có thể có
      return (user as dynamic).mssv ?? (user as dynamic).id ?? 'Không có mã';
    } catch (e) {
      return 'Không có mã';
    }
  }

  /// Lấy label cho mã người dùng
  String _getCodeLabel() {
    String role = _getUserRole();
    switch (role.toLowerCase()) {
      case 'giảng viên':
        return 'Mã giảng viên';
      case 'sinh viên':
        return 'Mã sinh viên';
      default:
        return 'Mã người dùng';
    }
  }

  /// Lấy số điện thoại
  String _getPhoneNumber() {
    try {
      final userType = user.runtimeType.toString();

      if (userType.contains('CurrentUserProfileDTO')) {
        return (user as dynamic).phonenumber ?? '';
      } else {
        return (user as dynamic).phoneNumber ?? (user as dynamic).soDienThoai ?? '';
      }
    } catch (e) {
      return '';
    }
  }

  /// Lấy giới tính
  String _getGender() {
    try {
      final userType = user.runtimeType.toString();
      bool? gioitinh;

      if (userType.contains('CurrentUserProfileDTO')) {
        gioitinh = (user as dynamic).gender;
      } else {
        gioitinh = (user as dynamic).gioitinh ?? (user as dynamic).gioiTinh;
      }

      if (gioitinh == null) return '';
      return gioitinh == true ? 'Nam' : 'Nữ';
    } catch (e) {
      return '';
    }
  }

  /// Lấy ngày sinh
  String _getBirthDate() {
    try {
      final userType = user.runtimeType.toString();
      dynamic ngaysinh;

      if (userType.contains('CurrentUserProfileDTO')) {
        ngaysinh = (user as dynamic).dob;
      } else {
        ngaysinh = (user as dynamic).ngaysinh ?? (user as dynamic).ngaySinh;
      }

      if (ngaysinh != null) {
        if (ngaysinh is DateTime) {
          return DateFormat('dd/MM/yyyy').format(ngaysinh);
        } else if (ngaysinh is String) {
          final date = DateTime.tryParse(ngaysinh);
          return date != null ? DateFormat('dd/MM/yyyy').format(date) : '';
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// Lấy ngày tham gia
  String _getJoinDate() {
    try {
      final ngaytao = (user as dynamic).ngayTao ?? (user as dynamic).ngaythamgia;
      if (ngaytao != null) {
        if (ngaytao is DateTime) {
          return DateFormat('dd/MM/yyyy').format(ngaytao);
        } else if (ngaytao is String) {
          final date = DateTime.tryParse(ngaytao);
          return date != null ? DateFormat('dd/MM/yyyy').format(date) : '';
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// Lấy role người dùng
  String _getUserRole() {
    try {
      final userType = user.runtimeType.toString();

      if (userType.contains('CurrentUserProfileDTO')) {
        final roles = (user as dynamic).roles as List<String>?;
        if (roles != null && roles.isNotEmpty) {
          return roles.first; // Lấy role đầu tiên
        }
        return 'Không có quyền';
      } else {
        return (user as dynamic).tenQuyen ??
               (user as dynamic).currentRole ??
               (user as dynamic).quyen?.name ??
               'Không có quyền';
      }
    } catch (e) {
      return 'Không có quyền';
    }
  }

  /// Lấy tên hiển thị của role
  String _getRoleDisplayName() {
    return _getUserRole();
  }


}
