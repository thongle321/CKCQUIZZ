import 'package:flutter/material.dart';

/// Lớp chứa các hằng số và màu sắc sử dụng trong ứng dụng
class AppConstants {
  // Tiêu đề ứng dụng
  static const String appName = 'CKC QUIZZ';
  
  // Các chuỗi văn bản
  static const String loginTitle = 'ĐĂNG NHẬP';
  static const String forgotPasswordTitle = 'QUÊN MẬT KHẨU';
  static const String emailLabel = 'Gmail';
  static const String passwordLabel = 'Mật khẩu';
  static const String loginButton = 'ĐĂNG NHẬP';
  static const String googleLoginButton = 'ĐĂNG NHẬP BẰNG GOOGLE';
  static const String forgotPasswordButton = 'Quên mật khẩu';
  static const String backToLoginButton = 'Quay lại đăng nhập';
  static const String resetPasswordButton = 'KHÔI PHỤC MẬT KHẨU';
  static const String enterEmailLabel = 'Nhập email';
  static const String webAppTitle = 'WEB TRẮC NGHIỆM CKC QUIZZ';
  
  // Các routes
  static const String loginRoute = '/login';
  static const String forgotPasswordRoute = '/forgot-password';
  
  // Kích thước màn hình
  static const double mobileWidth = 600;
  static const double tabletWidth = 900;
  
  // Màu sắc
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.black;
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black;
  static const Color greyTextColor = Colors.grey;
  
  // Các padding và margin
  static const double defaultPadding = 20.0;
  static const double smallPadding = 15.0;
  static const double mediumPadding = 30.0;
  
  // Các kích thước font chữ
  static const double fontSizeHeading = 28.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeText = 16.0;
  static const double fontSizeSmall = 14.0;
} 