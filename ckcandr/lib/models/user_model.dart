import 'package:flutter/foundation.dart';

/// Danh sách các vai trò người dùng trong hệ thống
enum UserRole {
  admin,
  giangVien,
  sinhVien,
}

/// Model dữ liệu người dùng
class User {
  final String id;
  final String mssv; // Mã số sinh viên hoặc mã số giảng viên
  final String hoVaTen;
  final bool gioiTinh; // true = Nam, false = Nữ
  final DateTime? ngaySinh;
  final String email;
  final String? matKhau; // Có thể null khi hiển thị thông tin người dùng
  final UserRole quyen;
  final bool trangThai; // true = Hoạt động, false = Khóa
  final DateTime ngayTao;
  final DateTime ngayCapNhat;
  final String? anhDaiDien;

  User({
    required this.id,
    required this.mssv,
    required this.hoVaTen,
    required this.gioiTinh,
    this.ngaySinh,
    required this.email,
    this.matKhau,
    required this.quyen,
    this.trangThai = true,
    required this.ngayTao,
    required this.ngayCapNhat,
    this.anhDaiDien,
  });

  User copyWith({
    String? id,
    String? mssv,
    String? hoVaTen,
    bool? gioiTinh,
    DateTime? ngaySinh,
    String? email,
    String? matKhau,
    UserRole? quyen,
    bool? trangThai,
    DateTime? ngayTao,
    DateTime? ngayCapNhat,
    String? anhDaiDien,
  }) {
    return User(
      id: id ?? this.id,
      mssv: mssv ?? this.mssv,
      hoVaTen: hoVaTen ?? this.hoVaTen,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      email: email ?? this.email,
      matKhau: matKhau ?? this.matKhau,
      quyen: quyen ?? this.quyen,
      trangThai: trangThai ?? this.trangThai,
      ngayTao: ngayTao ?? this.ngayTao,
      ngayCapNhat: ngayCapNhat ?? this.ngayCapNhat,
      anhDaiDien: anhDaiDien ?? this.anhDaiDien,
    );
  }

  /// Tạo User từ JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      mssv: json['mssv'] as String,
      hoVaTen: json['hoVaTen'] as String,
      gioiTinh: json['gioiTinh'] as bool,
      ngaySinh: json['ngaySinh'] != null ? DateTime.parse(json['ngaySinh'] as String) : null,
      email: json['email'] as String,
      matKhau: json['matKhau'] as String?,
      quyen: _getRoleFromString(json['quyen'] as String),
      trangThai: json['trangThai'] as bool,
      ngayTao: DateTime.parse(json['ngayTao'] as String),
      ngayCapNhat: DateTime.parse(json['ngayCapNhat'] as String),
      anhDaiDien: json['anhDaiDien'] as String?,
    );
  }

  /// Chuyển User sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mssv': mssv,
      'hoVaTen': hoVaTen,
      'gioiTinh': gioiTinh,
      'ngaySinh': ngaySinh?.toIso8601String(),
      'email': email,
      'matKhau': matKhau,
      'quyen': describeEnum(quyen),
      'trangThai': trangThai,
      'ngayTao': ngayTao.toIso8601String(),
      'ngayCapNhat': ngayCapNhat.toIso8601String(),
      'anhDaiDien': anhDaiDien,
    };
  }

  /// Hàm phụ trợ để lấy role từ chuỗi
  static UserRole _getRoleFromString(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'giangvien':
        return UserRole.giangVien;
      case 'sinhvien':
        return UserRole.sinhVien;
      default:
        return UserRole.sinhVien;
    }
  }

  // Hàm helper để hiển thị tên quyền người dùng
  String get tenQuyen {
    switch (quyen) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.giangVien:
        return 'Giảng viên';
      case UserRole.sinhVien:
        return 'Sinh viên';
      default:
        return 'Không xác định';
    }
  }

  // Hàm helper để hiển thị trạng thái
  String get tenTrangThai {
    return trangThai ? 'Hoạt động' : 'Khóa';
  }
} 