import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/services/user_profile_service.dart';
import 'package:ckcandr/providers/user_provider.dart';

/// Provider cho thông tin chi tiết hồ sơ người dùng
final userProfileProvider = FutureProvider<CurrentUserProfileDTO?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final userProfileService = ref.watch(userProfileServiceProvider);

  if (currentUser == null) {
    return null;
  }

  try {
    debugPrint('🔄 UserProfile - Đang tải thông tin chi tiết cho user: ${currentUser.email}');
    final userProfile = await userProfileService.getCurrentUserProfile();

    // Ưu tiên avatar từ server response, fallback to local storage nếu server không có
    String finalAvatarUrl = userProfile.avatar;

    if (finalAvatarUrl.isEmpty) {
      final localAvatarUrl = await userProfileService.getLocalAvatarUrl();
      if (localAvatarUrl != null && localAvatarUrl.isNotEmpty) {
        debugPrint('📱 UserProfile - Using local avatar URL as fallback: $localAvatarUrl');
        finalAvatarUrl = localAvatarUrl;
      }
    } else {
      debugPrint('🌐 UserProfile - Using server avatar URL: $finalAvatarUrl');
      // Lưu avatar URL từ server vào local storage để cache
      await userProfileService.saveAvatarUrlLocally(finalAvatarUrl);
    }

    // Tạo profile với avatar URL đã được xử lý
    final updatedProfile = CurrentUserProfileDTO(
      mssv: userProfile.mssv,
      avatar: finalAvatarUrl,
      username: userProfile.username,
      fullname: userProfile.fullname,
      email: userProfile.email,
      phonenumber: userProfile.phonenumber,
      gender: userProfile.gender,
      dob: userProfile.dob,
      roles: userProfile.roles,
    );

    debugPrint('✅ UserProfile - Tải thành công thông tin user: ${updatedProfile.fullname}');
    debugPrint('📋 UserProfile - Chi tiết: fullname=${updatedProfile.fullname}, roles=${updatedProfile.roles}, avatar=${updatedProfile.avatar}');
    return updatedProfile;
  } catch (e) {
    debugPrint('❌ UserProfile - Lỗi khi tải thông tin user: $e');
    rethrow;
  }
});

/// Provider cho thống kê người dùng theo role
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final userProfileService = ref.watch(userProfileServiceProvider);
  
  if (currentUser == null) {
    return UserStats.empty();
  }
  
  try {
    debugPrint('🔄 UserStats - Đang tải thống kê cho user: ${currentUser.email}');
    final stats = await userProfileService.getUserStats(currentUser.id, currentUser.quyen.name);
    debugPrint('✅ UserStats - Tải thành công thống kê user');
    return stats;
  } catch (e) {
    debugPrint('❌ UserStats - Lỗi khi tải thống kê user: $e');
    return UserStats.empty();
  }
});

/// Model cho thống kê người dùng
class UserStats {
  final int totalClasses;      // Tổng số lớp (Teacher: lớp quản lý, Student: lớp tham gia)
  final int totalStudents;     // Tổng số sinh viên (chỉ cho Teacher)
  final int totalQuizzes;      // Tổng số bài kiểm tra
  final int completedQuizzes;  // Số bài kiểm tra đã hoàn thành (chỉ cho Student)
  final String description;    // Mô tả thống kê

  UserStats({
    required this.totalClasses,
    required this.totalStudents,
    required this.totalQuizzes,
    required this.completedQuizzes,
    required this.description,
  });

  factory UserStats.empty() {
    return UserStats(
      totalClasses: 0,
      totalStudents: 0,
      totalQuizzes: 0,
      completedQuizzes: 0,
      description: 'Chưa có dữ liệu thống kê',
    );
  }

  factory UserStats.forTeacher({
    required int totalClasses,
    required int totalStudents,
    required int totalQuizzes,
  }) {
    return UserStats(
      totalClasses: totalClasses,
      totalStudents: totalStudents,
      totalQuizzes: totalQuizzes,
      completedQuizzes: 0,
      description: 'Thống kê giảng viên',
    );
  }

  factory UserStats.forStudent({
    required int totalClasses,
    required int totalQuizzes,
    required int completedQuizzes,
  }) {
    return UserStats(
      totalClasses: totalClasses,
      totalStudents: 0,
      totalQuizzes: totalQuizzes,
      completedQuizzes: completedQuizzes,
      description: 'Thống kê sinh viên',
    );
  }

  factory UserStats.forAdmin({
    required int totalClasses,
    required int totalStudents,
    required int totalQuizzes,
  }) {
    return UserStats(
      totalClasses: totalClasses,
      totalStudents: totalStudents,
      totalQuizzes: totalQuizzes,
      completedQuizzes: 0,
      description: 'Thống kê quản trị viên',
    );
  }
}
