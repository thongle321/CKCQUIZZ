import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  /// Đổi mật khẩu
  Future<bool> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    try {
      debugPrint('🔄 UserProfileService - Đổi mật khẩu');

      // Tạo request đổi mật khẩu
      final changePasswordRequest = ChangePasswordDTO(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      // Gọi API đổi mật khẩu
      await _apiService.changePassword(changePasswordRequest);

      debugPrint('✅ UserProfileService - Đổi mật khẩu thành công');
      return true;
    } catch (e) {
      debugPrint('❌ UserProfileService - Lỗi khi đổi mật khẩu: $e');
      return false;
    }
  }

  /// Upload avatar mới
  Future<String?> uploadAvatar(String imagePath) async {
    try {
      debugPrint('🔄 UserProfileService - Upload avatar từ: $imagePath');

      // Gọi API upload avatar
      final avatarUrl = await _apiService.uploadAvatar(imagePath);

      debugPrint('✅ UserProfileService - Upload avatar thành công: $avatarUrl');
      return avatarUrl;
    } catch (e) {
      debugPrint('❌ UserProfileService - Lỗi khi upload avatar: $e');
      return null;
    }
  }
}
