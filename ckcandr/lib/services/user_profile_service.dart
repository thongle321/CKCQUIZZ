import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ckcandr/core/config/api_config.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/providers/user_profile_provider.dart';
import 'package:ckcandr/services/api_service.dart';

/// Provider cho UserProfileService
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserProfileService(apiService);
});

/// Service để quản lý thông tin hồ sơ người dùng
class UserProfileService {
  final ApiService _apiService;

  UserProfileService(this._apiService);

  /// Lấy thông tin chi tiết người dùng hiện tại
  Future<CurrentUserProfileDTO> getCurrentUserProfile() async {
    try {
      debugPrint('🔄 UserProfileService - Gọi API lấy thông tin user hiện tại');

      // Gọi API lấy thông tin người dùng hiện tại
      final userProfile = await _apiService.getCurrentUserProfile();

      debugPrint('✅ UserProfileService - Nhận được thông tin user: ${userProfile.fullname}');
      return userProfile;
    } catch (e) {
      debugPrint('❌ UserProfileService - Lỗi khi lấy thông tin user: $e');
      rethrow;
    }
  }

  /// Lấy thông tin chi tiết người dùng theo ID (deprecated - sử dụng getCurrentUserProfile thay thế)
  @Deprecated('Use getCurrentUserProfile() instead')
  Future<dynamic> getUserProfile(String userId) async {
    try {
      debugPrint('🔄 UserProfileService - Gọi API lấy thông tin user: $userId');

      // Gọi API lấy thông tin người dùng chi tiết
      final userDetail = await _apiService.getUserById(userId);

      debugPrint('✅ UserProfileService - Nhận được thông tin user: ${userDetail.hoten}');
      return userDetail;
    } catch (e) {
      debugPrint('❌ UserProfileService - Lỗi khi lấy thông tin user: $e');
      rethrow;
    }
  }

  /// Lấy thống kê người dùng theo role
  Future<UserStats> getUserStats(String userId, String role) async {
    try {
      debugPrint('🔄 UserProfileService - Gọi API lấy thống kê user: $userId, role: $role');
      
      switch (role.toLowerCase()) {
        case 'teacher':
          return await _getTeacherStats(userId);
        case 'student':
          return await _getStudentStats(userId);
        case 'admin':
          return await _getAdminStats(userId);
        default:
          return UserStats.empty();
      }
    } catch (e) {
      debugPrint('❌ UserProfileService - Lỗi khi lấy thống kê user: $e');
      return UserStats.empty();
    }
  }

  /// Lấy thống kê cho giảng viên
  Future<UserStats> _getTeacherStats(String teacherId) async {
    try {
      // Lấy danh sách lớp học của giảng viên
      final classes = await _apiService.getClasses(hienthi: true);
      
      // Tính tổng số sinh viên trong các lớp
      int totalStudents = 0;
      for (final cls in classes) {
        totalStudents += cls.siso ?? 0;
      }
      
      // TODO: Lấy số bài kiểm tra khi API có sẵn
      const totalQuizzes = 0;
      
      debugPrint('📊 Teacher Stats - Classes: ${classes.length}, Students: $totalStudents');
      
      return UserStats.forTeacher(
        totalClasses: classes.length,
        totalStudents: totalStudents,
        totalQuizzes: totalQuizzes,
      );
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy thống kê teacher: $e');
      return UserStats.empty();
    }
  }

  /// Lấy thống kê cho sinh viên
  Future<UserStats> _getStudentStats(String studentId) async {
    try {
      // TODO: Implement khi có API cho sinh viên
      // Hiện tại trả về dữ liệu mẫu
      debugPrint('📊 Student Stats - Placeholder data');
      
      return UserStats.forStudent(
        totalClasses: 0,
        totalQuizzes: 0,
        completedQuizzes: 0,
      );
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy thống kê student: $e');
      return UserStats.empty();
    }
  }

  /// Lấy thống kê cho admin
  Future<UserStats> _getAdminStats(String adminId) async {
    try {
      // TODO: Implement khi có API cho admin
      // Hiện tại trả về dữ liệu mẫu
      debugPrint('📊 Admin Stats - Placeholder data');
      
      return UserStats.forAdmin(
        totalClasses: 0,
        totalStudents: 0,
        totalQuizzes: 0,
      );
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy thống kê admin: $e');
      return UserStats.empty();
    }
  }

  /// Cập nhật thông tin người dùng
  Future<bool> updateUserProfile(UpdateUserProfileDTO updateRequest) async {
    try {
      debugPrint('🔄 UserProfileService - Cập nhật thông tin user: ${updateRequest.fullname}');

      // Gọi API cập nhật thông tin người dùng
      await _apiService.updateCurrentUserProfile(updateRequest);

      debugPrint('✅ UserProfileService - Cập nhật thành công');
      return true;
    } catch (e) {
      debugPrint('❌ UserProfileService - Lỗi khi cập nhật: $e');
      return false;
    }
  }

  /// Verify current password only (for step 1 of reset flow)
  Future<bool> verifyCurrentPassword(String currentPassword) async {
    try {
      debugPrint('🔄 UserProfileService - Verify current password START');
      debugPrint('   Current password length: ${currentPassword.length}');

      // Validate inputs
      if (currentPassword.isEmpty) {
        debugPrint('❌ Current password is empty');
        throw Exception('Mật khẩu hiện tại không được để trống');
      }

      // Get current user email
      final currentUser = await getCurrentUserProfile();
      if (currentUser.email.isEmpty) {
        throw Exception('Không thể xác định email người dùng');
      }

      debugPrint('📧 UserProfileService - Verifying current password for: ${currentUser.email}');

      // Verify current password by attempting sign in
      final isCurrentPasswordValid = await _apiService.verifyCurrentPassword(currentUser.email, currentPassword);
      if (!isCurrentPasswordValid) {
        throw Exception('Mật khẩu hiện tại không đúng');
      }

      debugPrint('✅ UserProfileService - Current password verified');
      return true;
    } catch (e) {
      debugPrint('❌ UserProfileService - Lỗi khi verify mật khẩu hiện tại: $e');
      debugPrint('   Error type: ${e.runtimeType}');
      if (e is Exception) {
        debugPrint('   Exception message: ${e.toString()}');
      }
      return false;
    }
  }

  /// Đổi mật khẩu thông qua Reset Password Flow (complete flow)
  Future<bool> changePasswordViaReset(String newPassword, String confirmPassword, String resetToken) async {
    try {
      debugPrint('🔄 UserProfileService - Complete password reset START');
      debugPrint('   New password length: ${newPassword.length}');
      debugPrint('   Confirm password length: ${confirmPassword.length}');
      debugPrint('   Passwords match: ${newPassword == confirmPassword}');

      // Validate inputs
      if (newPassword.isEmpty) {
        debugPrint('❌ New password is empty');
        throw Exception('Mật khẩu mới không được để trống');
      }

      if (newPassword != confirmPassword) {
        debugPrint('❌ Passwords do not match');
        throw Exception('Mật khẩu mới và xác nhận không khớp');
      }

      if (newPassword.length < 8) {
        debugPrint('❌ New password too short');
        throw Exception('Mật khẩu mới phải có ít nhất 8 ký tự');
      }

      if (resetToken.isEmpty) {
        debugPrint('❌ Reset token is empty');
        throw Exception('Token reset không hợp lệ');
      }

      // Get current user email
      final currentUser = await getCurrentUserProfile();
      if (currentUser.email.isEmpty) {
        throw Exception('Không thể xác định email người dùng');
      }

      debugPrint('📧 UserProfileService - Resetting password for: ${currentUser.email}');

      // Reset password with token
      await _apiService.resetPassword(currentUser.email, resetToken, newPassword, confirmPassword);

      debugPrint('✅ UserProfileService - Password reset successful');
      return true;
    } catch (e) {
      debugPrint('❌ UserProfileService - Lỗi khi đổi mật khẩu: $e');
      debugPrint('   Error type: ${e.runtimeType}');
      if (e is Exception) {
        debugPrint('   Exception message: ${e.toString()}');
      }
      return false;
    }
  }

  /// Bước 2: Request OTP cho reset password
  Future<bool> requestPasswordResetOTP(String email) async {
    try {
      debugPrint('🔄 UserProfileService - Request OTP START');
      debugPrint('   Email: $email');

      await _apiService.forgotPassword(email);

      debugPrint('✅ UserProfileService - OTP requested successfully');
      return true;
    } catch (e) {
      debugPrint('❌ UserProfileService - Lỗi khi request OTP: $e');
      return false;
    }
  }

  /// Bước 3: Verify OTP và lấy reset token
  Future<String?> verifyOTPAndGetResetToken(String email, String otp) async {
    try {
      debugPrint('🔄 UserProfileService - Verify OTP START');
      debugPrint('   Email: $email');
      debugPrint('   OTP: $otp');

      final resetToken = await _apiService.verifyOTP(email, otp);

      debugPrint('✅ UserProfileService - OTP verified, reset token received');
      return resetToken;
    } catch (e) {
      debugPrint('❌ UserProfileService - Lỗi khi verify OTP: $e');
      return null;
    }
  }

  /// Bước 4: Reset password với token
  Future<bool> resetPasswordWithToken(String email, String token, String newPassword, String confirmPassword) async {
    try {
      debugPrint('🔄 UserProfileService - Reset password with token START');
      debugPrint('   Email: $email');
      debugPrint('   Token length: ${token.length}');
      debugPrint('   New password length: ${newPassword.length}');

      await _apiService.resetPassword(email, token, newPassword, confirmPassword);

      debugPrint('✅ UserProfileService - Password reset successfully');
      return true;
    } catch (e) {
      debugPrint('❌ UserProfileService - Lỗi khi reset password: $e');
      return false;
    }
  }

  /// Test network connectivity and authentication
  Future<bool> testNetworkAndAuth() async {
    try {
      debugPrint('🧪 Testing network connectivity and authentication...');

      // Test basic network connectivity
      final testUrl = Uri.parse('${ApiConfig.baseUrl}/api/Auth/validate-token');
      debugPrint('   Test URL: $testUrl');

      final response = await http.get(testUrl);
      debugPrint('   Network test status: ${response.statusCode}');
      debugPrint('   Network test body: ${response.body}');

      // Test current user endpoint
      final userResponse = await _apiService.getCurrentUserProfile();
      debugPrint('   Current user test: ${userResponse != null ? "SUCCESS" : "FAILED"}');

      return response.statusCode < 500; // Server reachable
    } catch (e) {
      debugPrint('❌ Network/Auth test failed: $e');
      return false;
    }
  }

  /// Upload avatar mới qua generic file upload
  Future<String?> uploadAvatar(String imagePath) async {
    try {
      debugPrint('🔄 UserProfileService - Upload avatar via generic upload START');
      debugPrint('   Image path: $imagePath');

      // Validate image path
      if (imagePath.isEmpty) {
        debugPrint('❌ Image path is empty');
        throw Exception('Đường dẫn ảnh không được để trống');
      }

      // Check if file exists
      final file = File(imagePath);
      final exists = await file.exists();
      debugPrint('   File exists: $exists');

      if (!exists) {
        debugPrint('❌ File does not exist at path: $imagePath');
        throw Exception('File không tồn tại');
      }

      // Get file info
      final fileSize = await file.length();
      final fileName = file.path.split('/').last;
      debugPrint('   File name: $fileName');
      debugPrint('   File size: $fileSize bytes');

      debugPrint('📤 UserProfileService - Calling generic file upload API');

      // Gọi API upload file generic
      final fileUrl = await _apiService.uploadFileGeneric(imagePath);

      if (fileUrl != null) {
        debugPrint('✅ UserProfileService - File uploaded successfully: $fileUrl');

        // Lưu avatar URL vào local storage để sử dụng
        await _saveAvatarUrlLocally(fileUrl);

        debugPrint('✅ UserProfileService - Avatar URL saved locally');
        return fileUrl;
      } else {
        throw Exception('Upload failed: no URL returned');
      }
    } catch (e) {
      debugPrint('❌ UserProfileService - Lỗi khi upload avatar: $e');
      debugPrint('   Error type: ${e.runtimeType}');
      if (e is Exception) {
        debugPrint('   Exception message: ${e.toString()}');
      }
      return null;
    }
  }

  /// Lưu avatar URL vào local storage
  Future<void> _saveAvatarUrlLocally(String avatarUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUser = await getCurrentUserProfile();
      final key = 'avatar_${currentUser.email}';
      await prefs.setString(key, avatarUrl);
      debugPrint('✅ Avatar URL saved to local storage: $key = $avatarUrl');
    } catch (e) {
      debugPrint('❌ Failed to save avatar URL locally: $e');
    }
  }

  /// Lấy avatar URL từ local storage
  Future<String?> getLocalAvatarUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUser = await getCurrentUserProfile();
      final key = 'avatar_${currentUser.email}';
      final avatarUrl = prefs.getString(key);
      debugPrint('📱 Local avatar URL for ${currentUser.email}: $avatarUrl');
      return avatarUrl;
    } catch (e) {
      debugPrint('❌ Failed to get local avatar URL: $e');
      return null;
    }
  }

  /// Lưu avatar URL vào local storage (public method)
  Future<void> saveAvatarUrlLocally(String avatarUrl) async {
    await _saveAvatarUrlLocally(avatarUrl);
  }

  /// Debug method to test both upload avatar and change password
  Future<void> debugTestFunctions() async {
    debugPrint('🔧 DEBUG TEST FUNCTIONS - START');

    // Test network and auth first
    final networkOk = await testNetworkAndAuth();
    debugPrint('🌐 Network test result: $networkOk');

    if (!networkOk) {
      debugPrint('❌ Network test failed, stopping debug tests');
      return;
    }

    debugPrint('✅ Network test passed, ready for function tests');
    debugPrint('🔧 DEBUG TEST FUNCTIONS - END');
  }
}
