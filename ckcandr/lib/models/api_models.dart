/// API Models for CKC Quiz Application
///
/// This file contains all models used for API communication
/// with the ASP.NET Core backend server.
library;

// Manual JSON serialization instead of code generation

/// Paged result wrapper for API responses
class PagedResult<T> {
  final int totalCount;
  final List<T> items;

  PagedResult({
    required this.totalCount,
    required this.items,
  });

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return PagedResult<T>(
      totalCount: json['totalCount'] as int,
      items: (json['items'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T value) toJsonT) {
    return {
      'TotalCount': totalCount,
      'Items': items.map(toJsonT).toList(),
    };
  }
}

/// User DTO for API responses
class GetNguoiDungDTO {
  final String mssv;
  final String userName;
  final String email;
  final String hoten;
  final DateTime? ngaysinh;
  final String phoneNumber;
  final bool? trangthai;
  final String? currentRole;
  final bool? gioitinh; // true = Nam, false = Nữ

  GetNguoiDungDTO({
    required this.mssv,
    required this.userName,
    required this.email,
    required this.hoten,
    this.ngaysinh,
    required this.phoneNumber,
    this.trangthai,
    this.currentRole,
    this.gioitinh,
  });

  factory GetNguoiDungDTO.fromJson(Map<String, dynamic> json) {
    try {
      return GetNguoiDungDTO(
        mssv: json['mssv']?.toString() ?? '',
        userName: json['userName']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        hoten: json['hoten']?.toString() ?? '',
        ngaysinh: json['ngaysinh'] != null
            ? DateTime.tryParse(json['ngaysinh'].toString())
            : null,
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        trangthai: json['trangthai'] as bool? ?? true,
        currentRole: json['currentRole']?.toString(),
        gioitinh: json['gioitinh'] as bool?,
      );
    } catch (e) {
      // Error parsing - log for debugging
      // print('Error parsing GetNguoiDungDTO: $e');
      // print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'MSSV': mssv,
      'UserName': userName,
      'Email': email,
      'Hoten': hoten,
      'Ngaysinh': ngaysinh?.toIso8601String(),
      'PhoneNumber': phoneNumber,
      'Trangthai': trangthai,
      'CurrentRole': currentRole,
      'Gioitinh': gioitinh,
    };
  }
}

/// Current User Profile DTO for API responses
class CurrentUserProfileDTO {
  final String mssv;
  final String avatar;
  final String username;
  final String fullname;
  final String email;
  final String phonenumber;
  final bool? gender;
  final DateTime? dob;
  final List<String> roles;

  CurrentUserProfileDTO({
    required this.mssv,
    required this.avatar,
    required this.username,
    required this.fullname,
    required this.email,
    required this.phonenumber,
    this.gender,
    this.dob,
    required this.roles,
  });

  factory CurrentUserProfileDTO.fromJson(Map<String, dynamic> json) {
    try {
      return CurrentUserProfileDTO(
        mssv: json['mssv']?.toString() ?? '',
        avatar: json['avatar']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        fullname: json['fullname']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phonenumber: json['phonenumber']?.toString() ?? '',
        gender: json['gender'] as bool?,
        dob: json['dob'] != null
            ? DateTime.tryParse(json['dob'].toString())
            : null,
        roles: (json['roles'] as List<dynamic>?)
            ?.map((role) => role.toString())
            .toList() ?? [],
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'mssv': mssv,
      'avatar': avatar,
      'username': username,
      'fullname': fullname,
      'email': email,
      'phonenumber': phonenumber,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'roles': roles,
    };
  }
}

/// Update User Profile DTO for API requests
class UpdateUserProfileDTO {
  final String username;
  final String fullname;
  final String email;
  final bool gender;
  final DateTime? dob;
  final String phoneNumber;
  final String avatar;

  UpdateUserProfileDTO({
    required this.username,
    required this.fullname,
    required this.email,
    required this.gender,
    this.dob,
    required this.phoneNumber,
    required this.avatar,
  });

  factory UpdateUserProfileDTO.fromJson(Map<String, dynamic> json) {
    return UpdateUserProfileDTO(
      username: json['username']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      gender: json['gender'] as bool? ?? true,
      dob: json['dob'] != null
          ? DateTime.tryParse(json['dob'].toString())
          : null,
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullname': fullname,
      'email': email,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'avatar': avatar,
    };
  }
}

/// Change Password DTO for API requests
class ChangePasswordDTO {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordDTO({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePasswordDTO.fromJson(Map<String, dynamic> json) {
    return ChangePasswordDTO(
      currentPassword: json['currentPassword']?.toString() ?? '',
      newPassword: json['newPassword']?.toString() ?? '',
      confirmPassword: json['confirmPassword']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

/// Create user request DTO
class CreateNguoiDungRequestDTO {
  final String mssv;
  final String password;
  final String email;
  final String hoten;
  final DateTime ngaysinh;
  final String phoneNumber;
  final String role;
  final bool? gioitinh;

  CreateNguoiDungRequestDTO({
    required this.mssv,
    required this.password,
    required this.email,
    required this.hoten,
    required this.ngaysinh,
    required this.phoneNumber,
    required this.role,
    this.gioitinh,
  });

  factory CreateNguoiDungRequestDTO.fromJson(Map<String, dynamic> json) {
    return CreateNguoiDungRequestDTO(
      mssv: json['MSSV'] as String,
      password: json['Password'] as String,
      email: json['Email'] as String,
      hoten: json['Hoten'] as String,
      ngaysinh: DateTime.parse(json['Ngaysinh'] as String),
      phoneNumber: json['PhoneNumber'] as String,
      role: json['Role'] as String,
      gioitinh: json['Gioitinh'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MSSV': mssv,
      'Password': password,
      'Email': email,
      'Hoten': hoten,
      'Ngaysinh': ngaysinh.toIso8601String(),
      'PhoneNumber': phoneNumber,
      'Role': role,
      'Gioitinh': gioitinh,
    };
  }
}

/// Update user request DTO
class UpdateNguoiDungRequestDTO {
  final String email;
  final String fullName;
  final DateTime dob;
  final String phoneNumber;
  final bool status;
  final String role;
  final bool? gioitinh;

  UpdateNguoiDungRequestDTO({
    required this.email,
    required this.fullName,
    required this.dob,
    required this.phoneNumber,
    required this.status,
    required this.role,
    this.gioitinh,
  });

  factory UpdateNguoiDungRequestDTO.fromJson(Map<String, dynamic> json) {
    return UpdateNguoiDungRequestDTO(
      email: json['Email'] as String,
      fullName: json['FullName'] as String,
      dob: DateTime.parse(json['Dob'] as String),
      phoneNumber: json['PhoneNumber'] as String,
      status: json['Status'] as bool,
      role: json['Role'] as String,
      gioitinh: json['Gioitinh'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'FullName': fullName,
      'Dob': dob.toIso8601String(),
      'PhoneNumber': phoneNumber,
      'Status': status,
      'Role': role,
      'Gioitinh': gioitinh,
    };
  }
}

/// API Error response
class ApiErrorResponse {
  final String? title;
  final int? status;
  final String? detail;
  final String? instance;
  final Map<String, List<String>>? errors;

  ApiErrorResponse({
    this.title,
    this.status,
    this.detail,
    this.instance,
    this.errors,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      title: json['title'] as String?,
      status: json['status'] as int?,
      detail: json['detail'] as String?,
      instance: json['instance'] as String?,
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              (json['errors'] as Map).map(
                (key, value) => MapEntry(
                  key.toString(),
                  List<String>.from(value as List),
                ),
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status,
      'detail': detail,
      'instance': instance,
      'errors': errors,
    };
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final ApiErrorResponse? error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, {ApiErrorResponse? error}) {
    return ApiResponse(
      success: false,
      message: message,
      error: error,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data'] as Map<String, dynamic>) : null,
      error: json['error'] != null
          ? ApiErrorResponse.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T value) toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': data != null ? toJsonT(data as T) : null,
      'error': error?.toJson(),
    };
  }
}

// ===== JOIN REQUEST DTOs =====

/// DTO for student join class request by invite code
class JoinClassRequestDTO {
  final String inviteCode;

  JoinClassRequestDTO({
    required this.inviteCode,
  });

  factory JoinClassRequestDTO.fromJson(Map<String, dynamic> json) {
    return JoinClassRequestDTO(
      inviteCode: json['inviteCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inviteCode': inviteCode,
    };
  }
}

/// DTO for pending student join requests
class PendingStudentDTO {
  final String manguoidung;
  final String hoten;
  final String email;
  final String mssv;
  final DateTime? ngayYeuCau;

  PendingStudentDTO({
    required this.manguoidung,
    required this.hoten,
    required this.email,
    required this.mssv,
    this.ngayYeuCau,
  });

  factory PendingStudentDTO.fromJson(Map<String, dynamic> json) {
    return PendingStudentDTO(
      manguoidung: json['manguoidung'] as String,
      hoten: json['hoten'] as String,
      email: json['email'] as String,
      mssv: json['mssv'] as String,
      ngayYeuCau: json['ngayYeuCau'] != null
          ? DateTime.tryParse(json['ngayYeuCau'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manguoidung': manguoidung,
      'hoten': hoten,
      'email': email,
      'mssv': mssv,
      'ngayYeuCau': ngayYeuCau?.toIso8601String(),
    };
  }
}

/// DTO for pending request count
class PendingRequestCountDTO {
  final int malop;
  final int pendingCount;

  PendingRequestCountDTO({
    required this.malop,
    required this.pendingCount,
  });

  factory PendingRequestCountDTO.fromJson(Map<String, dynamic> json) {
    return PendingRequestCountDTO(
      malop: json['malop'] as int,
      pendingCount: json['pendingCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'malop': malop,
      'pendingCount': pendingCount,
    };
  }
}

/// Model for subject with groups (for notifications)
class MonHocWithNhomLopDTO {
  final String mamonhoc;
  final String tenmonhoc;
  final int? namhoc;
  final int? hocky;
  final List<NhomLopInMonHocDTO> nhomLop;

  MonHocWithNhomLopDTO({
    required this.mamonhoc,
    required this.tenmonhoc,
    this.namhoc,
    this.hocky,
    required this.nhomLop,
  });

  factory MonHocWithNhomLopDTO.fromJson(Map<String, dynamic> json) {
    return MonHocWithNhomLopDTO(
      mamonhoc: json['mamonhoc'] as String,
      tenmonhoc: json['tenmonhoc'] as String,
      namhoc: json['namhoc'] as int?,
      hocky: json['hocky'] as int?,
      nhomLop: (json['nhomLop'] as List<dynamic>)
          .map((item) => NhomLopInMonHocDTO.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mamonhoc': mamonhoc,
      'tenmonhoc': tenmonhoc,
      'namhoc': namhoc,
      'hocky': hocky,
      'nhomLop': nhomLop.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model for group in subject
class NhomLopInMonHocDTO {
  final int manhom;
  final String tennhom;

  NhomLopInMonHocDTO({
    required this.manhom,
    required this.tennhom,
  });

  factory NhomLopInMonHocDTO.fromJson(Map<String, dynamic> json) {
    return NhomLopInMonHocDTO(
      manhom: json['manhom'] as int,
      tennhom: json['tennhom'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manhom': manhom,
      'tennhom': tennhom,
    };
  }
}

// ===== SUBJECT (MONHOC) MODELS =====

/// Model for Subject DTO from API (backend format)
class MonHocDTO {
  final int mamonhoc;
  final String tenmonhoc;
  final int sotinchi;
  final int sotietlythuyet;
  final int sotietthuchanh;
  final bool trangthai;

  MonHocDTO({
    required this.mamonhoc,
    required this.tenmonhoc,
    required this.sotinchi,
    required this.sotietlythuyet,
    required this.sotietthuchanh,
    required this.trangthai,
  });

  factory MonHocDTO.fromJson(Map<String, dynamic> json) {
    return MonHocDTO(
      mamonhoc: json['mamonhoc'] ?? 0,
      tenmonhoc: json['tenmonhoc'] ?? '',
      sotinchi: json['sotinchi'] ?? 0,
      sotietlythuyet: json['sotietlythuyet'] ?? 0,
      sotietthuchanh: json['sotietthuchanh'] ?? 0,
      trangthai: json['trangthai'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mamonhoc': mamonhoc,
      'tenmonhoc': tenmonhoc,
      'sotinchi': sotinchi,
      'sotietlythuyet': sotietlythuyet,
      'sotietthuchanh': sotietthuchanh,
      'trangthai': trangthai,
    };
  }
}

// ===== CHAPTER (CHUONG) MODELS =====

/// Model for Chapter DTO from API
class ChuongDTO {
  final int machuong;
  final String tenchuong;
  final int mamonhoc;
  final String? nguoitao;
  final bool? trangthai;

  ChuongDTO({
    required this.machuong,
    required this.tenchuong,
    required this.mamonhoc,
    this.nguoitao,
    this.trangthai,
  });

  factory ChuongDTO.fromJson(Map<String, dynamic> json) {
    return ChuongDTO(
      machuong: json['machuong'] ?? 0,
      tenchuong: json['tenchuong'] ?? '',
      mamonhoc: json['mamonhoc'] ?? 0,
      nguoitao: json['nguoitao'],
      trangthai: json['trangthai'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'machuong': machuong,
      'tenchuong': tenchuong,
      'mamonhoc': mamonhoc,
      'nguoitao': nguoitao,
      'trangthai': trangthai,
    };
  }
}

/// Model for creating new chapter
class CreateChuongRequestDTO {
  final String tenchuong;
  final int mamonhoc;
  final bool? trangthai;

  CreateChuongRequestDTO({
    required this.tenchuong,
    required this.mamonhoc,
    this.trangthai = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'tenchuong': tenchuong,
      'mamonhoc': mamonhoc,
      'trangthai': trangthai,
    };
  }
}

/// Model for updating chapter
class UpdateChuongRequestDTO {
  final String tenchuong;
  final int mamonhoc;
  final bool? trangthai;

  UpdateChuongRequestDTO({
    required this.tenchuong,
    required this.mamonhoc,
    this.trangthai,
  });

  Map<String, dynamic> toJson() {
    return {
      'tenchuong': tenchuong,
      'mamonhoc': mamonhoc,
      'trangthai': trangthai,
    };
  }
}
