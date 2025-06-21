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
        
        // Trạng thái tài khoản
        const Divider(height: 1),
        ProfileInfoRow(
          icon: Icons.verified_user,
          label: 'Trạng thái',
          value: _getAccountStatus(),
        ),
      ],
    );
  }

  /// Lấy tên người dùng
  String _getUserName() {
    return user.hoVaTen;
  }

  /// Lấy email người dùng
  String _getUserEmail() {
    return user.email;
  }

  /// Lấy mã người dùng (MSSV/MSGV)
  String _getUserCode() {
    return user.mssv;
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
    // User model không có sodienthoai, trả về empty
    return '';
  }

  /// Lấy giới tính
  String _getGender() {
    return user.gioiTinh ? 'Nam' : 'Nữ';
  }

  /// Lấy ngày sinh
  String _getBirthDate() {
    if (user.ngaySinh != null) {
      return DateFormat('dd/MM/yyyy').format(user.ngaySinh!);
    }
    return '';
  }

  /// Lấy ngày tham gia
  String _getJoinDate() {
    return DateFormat('dd/MM/yyyy').format(user.ngayTao);
  }

  /// Lấy role người dùng
  String _getUserRole() {
    return user.tenQuyen;
  }

  /// Lấy tên hiển thị của role
  String _getRoleDisplayName() {
    return _getUserRole();
  }

  /// Lấy trạng thái tài khoản
  String _getAccountStatus() {
    return user.tenTrangThai;
  }
}
