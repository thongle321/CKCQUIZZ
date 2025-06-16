/// API Models for CKC Quiz Application
/// 
/// This file contains all models used for API communication
/// with the ASP.NET Core backend server.

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
      print('Error parsing GetNguoiDungDTO: $e');
      print('JSON data: $json');
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

/// Create user request DTO
class CreateNguoiDungRequestDTO {
  final String mssv;
  final String userName;
  final String password;
  final String email;
  final String hoten;
  final DateTime ngaysinh;
  final String phoneNumber;
  final String role;

  CreateNguoiDungRequestDTO({
    required this.mssv,
    required this.userName,
    required this.password,
    required this.email,
    required this.hoten,
    required this.ngaysinh,
    required this.phoneNumber,
    required this.role,
  });

  factory CreateNguoiDungRequestDTO.fromJson(Map<String, dynamic> json) {
    return CreateNguoiDungRequestDTO(
      mssv: json['MSSV'] as String,
      userName: json['UserName'] as String,
      password: json['Password'] as String,
      email: json['Email'] as String,
      hoten: json['Hoten'] as String,
      ngaysinh: DateTime.parse(json['Ngaysinh'] as String),
      phoneNumber: json['PhoneNumber'] as String,
      role: json['Role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MSSV': mssv,
      'UserName': userName,
      'Password': password,
      'Email': email,
      'Hoten': hoten,
      'Ngaysinh': ngaysinh.toIso8601String(),
      'PhoneNumber': phoneNumber,
      'Role': role,
    };
  }
}

/// Update user request DTO
class UpdateNguoiDungRequestDTO {
  final String userName;
  final String email;
  final String fullName;
  final DateTime dob;
  final String phoneNumber;
  final bool status;
  final String role;

  UpdateNguoiDungRequestDTO({
    required this.userName,
    required this.email,
    required this.fullName,
    required this.dob,
    required this.phoneNumber,
    required this.status,
    required this.role,
  });

  factory UpdateNguoiDungRequestDTO.fromJson(Map<String, dynamic> json) {
    return UpdateNguoiDungRequestDTO(
      userName: json['UserName'] as String,
      email: json['Email'] as String,
      fullName: json['FullName'] as String,
      dob: DateTime.parse(json['Dob'] as String),
      phoneNumber: json['PhoneNumber'] as String,
      status: json['Status'] as bool,
      role: json['Role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserName': userName,
      'Email': email,
      'FullName': fullName,
      'Dob': dob.toIso8601String(),
      'PhoneNumber': phoneNumber,
      'Status': status,
      'Role': role,
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
