import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/models/dashboard_model.dart';
import 'package:ckcandr/services/api_service.dart';

/// Service để quản lý Dashboard data
class DashboardService {
  final ApiService _apiService;

  DashboardService(this._apiService);

  /// Lấy thống kê dashboard từ API
  Future<DashboardStatistics> getDashboardStatistics() async {
    try {
      debugPrint('🔄 DashboardService - Gọi API lấy thống kê dashboard');

      final jsonData = await _apiService.getDashboardStatistics();
      final statistics = DashboardStatistics.fromJson(jsonData);

      debugPrint('✅ DashboardService - Nhận được thống kê dashboard');
      return statistics;
    } on SocketException {
      debugPrint('❌ DashboardService - Lỗi kết nối mạng');
      throw ApiException('Không có kết nối internet');
    } catch (e) {
      debugPrint('❌ DashboardService - Lỗi khi lấy thống kê dashboard: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Lỗi khi lấy thống kê dashboard: $e');
    }
  }

  /// Lấy hoạt động gần đây (mock data cho demo)
  Future<List<RecentActivityItem>> getRecentActivities() async {
    try {
      debugPrint('🔄 DashboardService - Lấy hoạt động gần đây');
      
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock data - có thể thay thế bằng API thật sau
      final activities = [
        const RecentActivityItem(
          title: 'Đề thi mới được tạo',
          subtitle: 'Cấu trúc dữ liệu - Giữa kỳ',
          time: '2 phút trước',
          type: 'exam',
        ),
        const RecentActivityItem(
          title: 'Sinh viên hoàn thành bài thi',
          subtitle: 'Nguyễn Văn A - Lập trình Java',
          time: '5 phút trước',
          type: 'result',
        ),
        const RecentActivityItem(
          title: 'Câu hỏi mới được thêm',
          subtitle: 'Môn: Cơ sở dữ liệu',
          time: '10 phút trước',
          type: 'question',
        ),
        const RecentActivityItem(
          title: 'Lớp học mới được tạo',
          subtitle: 'Lớp Toán cao cấp A1',
          time: '15 phút trước',
          type: 'class',
        ),
      ];

      debugPrint('✅ DashboardService - Lấy được ${activities.length} hoạt động');
      return activities;
    } catch (e) {
      debugPrint('❌ DashboardService - Lỗi khi lấy hoạt động gần đây: $e');
      throw ApiException('Lỗi khi lấy hoạt động gần đây: $e');
    }
  }

  /// Lấy quick actions theo role với navigation thực sự
  List<QuickActionItem> getQuickActionsByRole(String role, BuildContext context) {
    switch (role.toLowerCase()) {
      case 'admin':
        return [
          QuickActionItem(
            title: 'Quản lý người dùng',
            icon: 'person_add',
            color: 'blue',
            onTap: () => context.push('/admin/users'),
            description: 'Thêm/sửa người dùng',
          ),
          QuickActionItem(
            title: 'Quản lý môn học',
            icon: 'book',
            color: 'green',
            onTap: () => context.push('/admin/subjects'),
            description: 'Thêm/sửa môn học',
          ),
          QuickActionItem(
            title: 'Phân quyền',
            icon: 'security',
            color: 'orange',
            onTap: () => context.push('/admin/permissions'),
            description: 'Cấp quyền người dùng',
          ),
          QuickActionItem(
            title: 'Phân công',
            icon: 'assignment_ind',
            color: 'purple',
            onTap: () => context.push('/admin/assignments'),
            description: 'Phân công giảng dạy',
          ),
        ];
      case 'teacher':
      case 'giangvien':
        return [
          QuickActionItem(
            title: 'Quản lý đề thi',
            icon: 'quiz',
            color: 'blue',
            onTap: () => context.go('/giangvien?tab=1'), // Tab đề thi
            description: 'Tạo/sửa đề thi',
          ),
          QuickActionItem(
            title: 'Quản lý câu hỏi',
            icon: 'help',
            color: 'green',
            onTap: () => context.go('/giangvien?tab=2'), // Tab câu hỏi
            description: 'Tạo/sửa câu hỏi',
          ),
          QuickActionItem(
            title: 'Quản lý lớp học',
            icon: 'class',
            color: 'orange',
            onTap: () => context.go('/giangvien?tab=3'), // Tab lớp học
            description: 'Xem lớp học',
          ),
          QuickActionItem(
            title: 'Xem kết quả',
            icon: 'grade',
            color: 'purple',
            onTap: () => context.go('/giangvien?tab=4'), // Tab kết quả
            description: 'Điểm số sinh viên',
          ),
        ];
      case 'student':
      case 'sinhvien':
        return [
          QuickActionItem(
            title: 'Danh sách lớp',
            icon: 'class',
            color: 'blue',
            onTap: () => context.go('/sinhvien?tab=0'), // Tab lớp học
            description: 'Xem lớp đã tham gia',
          ),
          QuickActionItem(
            title: 'Làm bài thi',
            icon: 'edit',
            color: 'green',
            onTap: () => context.go('/sinhvien?tab=1'), // Tab bài thi
            description: 'Bài thi có sẵn',
          ),
          QuickActionItem(
            title: 'Xem điểm',
            icon: 'score',
            color: 'orange',
            onTap: () => context.go('/sinhvien?tab=2'), // Tab kết quả
            description: 'Kết quả thi',
          ),
          QuickActionItem(
            title: 'Thông báo',
            icon: 'notifications',
            color: 'purple',
            onTap: () => context.push('/sinhvien/notifications'),
            description: 'Tin tức mới',
          ),
        ];
      default:
        return [];
    }
  }
}
