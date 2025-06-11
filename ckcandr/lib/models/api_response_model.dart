/// API Response Models for CKC Quiz Application
/// 
/// This file contains models for handling API responses from the
/// ASP.NET Core backend, including authentication responses,
/// error handling, and data transfer objects.

import 'dart:convert';

/// Generic API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
    this.errors,
  });

  factory ApiResponse.success(T data, {int statusCode = 200, String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int statusCode = 400, Map<String, dynamic>? errors}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }
}

/// Authentication Response Model (matches backend response)
class AuthResponse {
  final String email;
  final List<String> roles;

  AuthResponse({
    required this.email,
    required this.roles,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      email: json['email'] as String,
      roles: List<String>.from(json['roles'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'roles': roles,
    };
  }
}

/// Sign In Request Model (matches backend SignInDTO)
class SignInRequest {
  final String email;
  final String password;

  SignInRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// Token Response Model (matches backend TokenResponse)
class TokenResponse {
  final String accessToken;
  final String refreshToken;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

/// Forgot Password Request Model
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

/// Verify OTP Request Model
class VerifyOtpRequest {
  final String email;
  final String otp;

  VerifyOtpRequest({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}

/// Reset Password Request Model
class ResetPasswordRequest {
  final String email;
  final String newPassword;
  final String passwordResetToken;

  ResetPasswordRequest({
    required this.email,
    required this.newPassword,
    required this.passwordResetToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'newPassword': newPassword,
      'passwordResetToken': passwordResetToken,
    };
  }
}

/// API Error Response Model
class ApiError {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? details;

  ApiError({
    required this.message,
    required this.statusCode,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] as String? ?? json['title'] as String? ?? 'Unknown error',
      statusCode: json['status'] as int? ?? 400,
      details: json['errors'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'ApiError(message: $message, statusCode: $statusCode)';
  }
}

/// User Role Enum (matching backend roles)
enum UserApiRole {
  admin('Admin'),
  teacher('Teacher'),
  student('Student');

  const UserApiRole(this.value);
  final String value;

  static UserApiRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserApiRole.admin;
      case 'teacher':
        return UserApiRole.teacher;
      case 'student':
        return UserApiRole.student;
      default:
        return UserApiRole.student;
    }
  }
}

/// Refresh Token Request Model
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }
}
