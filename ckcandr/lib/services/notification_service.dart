/// Notification Service for Exam Management
/// 
/// This service handles notifications for exam-related events like:
/// - Exam creation
/// - Upcoming exam reminders
/// - Exam status changes

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:intl/intl.dart';

class NotificationService {
  final ApiService _apiService;
  Timer? _reminderTimer;

  NotificationService(this._apiService);

  /// Send notification when exam is created
  /// Note: This method needs the class IDs to send notifications to students
  Future<void> notifyExamCreated(DeThiModel deThi, {List<int>? classIds}) async {
    try {
      print('🔔 DEBUG: Starting notification for exam: ${deThi.tende}');
      print('🔔 DEBUG: Class IDs provided: $classIds');

      // Skip if no classes provided
      if (classIds == null || classIds.isEmpty) {
        print('❌ DEBUG: No classes provided for exam notification, skipping');
        return;
      }

      // Create notification using the correct API format
      final notification = CreateThongBaoRequest(
        noiDung: '📝 Đề thi mới: "${deThi.tende}" đã được tạo. Thời gian thi: ${_formatDateTime(deThi.thoigianbatdau)} - ${_formatDateTime(deThi.thoigianketthuc)}',
        nhomIds: classIds,
      );

      print('🔔 DEBUG: Notification payload: ${notification.toJson()}');

      final success = await _apiService.sendNotification(notification);
      if (success) {
        print('✅ DEBUG: Successfully sent exam creation notification for exam: ${deThi.tende}');
      } else {
        print('❌ DEBUG: Failed to send notification - API returned false');
      }
    } catch (e) {
      // Log error but don't throw to avoid disrupting main flow
      print('❌ DEBUG: Exception when sending exam creation notification: $e');
    }
  }

  /// Send notification for upcoming exams
  Future<void> notifyUpcomingExam(DeThiModel deThi, Duration timeUntilExam, {List<int>? classIds}) async {
    try {
      if (classIds == null || classIds.isEmpty) {
        print('No classes provided for upcoming exam notification, skipping');
        return;
      }

      String timeMessage;
      if (timeUntilExam.inDays > 0) {
        timeMessage = 'trong ${timeUntilExam.inDays} ngày';
      } else if (timeUntilExam.inHours > 0) {
        timeMessage = 'trong ${timeUntilExam.inHours} giờ';
      } else {
        timeMessage = 'trong ${timeUntilExam.inMinutes} phút';
      }

      final notification = CreateThongBaoRequest(
        noiDung: '⏰ Sắp có bài kiểm tra: "${deThi.tende}" sẽ bắt đầu $timeMessage.',
        nhomIds: classIds,
      );

      await _apiService.sendNotification(notification);
    } catch (e) {
      print('Failed to send upcoming exam notification: $e');
    }
  }

  /// Start monitoring for upcoming exams
  void startExamReminders(List<DeThiModel> exams) {
    _reminderTimer?.cancel();
    
    _reminderTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _checkUpcomingExams(exams);
    });
    
    // Check immediately
    _checkUpcomingExams(exams);
  }

  /// Check for exams that are coming up soon
  void _checkUpcomingExams(List<DeThiModel> exams) {
    final now = DateTime.now();
    
    for (final exam in exams) {
      if (exam.thoigianbatdau == null) continue;
      
      final timeUntilExam = exam.thoigianbatdau!.difference(now);
      
      // Send notifications at different intervals
      if (_shouldSendReminder(timeUntilExam)) {
        notifyUpcomingExam(exam, timeUntilExam);
      }
    }
  }

  /// Determine if we should send a reminder for this time interval
  bool _shouldSendReminder(Duration timeUntilExam) {
    final minutes = timeUntilExam.inMinutes;
    
    // Send reminders at: 1 day, 1 hour, 30 minutes, 10 minutes
    return minutes == 1440 || // 1 day
           minutes == 60 ||   // 1 hour
           minutes == 30 ||   // 30 minutes
           minutes == 10;     // 10 minutes
  }

  /// Stop exam reminders
  void stopExamReminders() {
    _reminderTimer?.cancel();
    _reminderTimer = null;
  }

  /// Send notification when exam is updated
  Future<void> notifyExamUpdated(DeThiModel deThi, {List<int>? classIds}) async {
    try {
      if (classIds == null || classIds.isEmpty) {
        print('No classes provided for exam update notification, skipping');
        return;
      }

      final notification = CreateThongBaoRequest(
        noiDung: '✏️ Đề thi "${deThi.tende}" đã được cập nhật. Vui lòng kiểm tra lại thông tin.',
        nhomIds: classIds,
      );

      await _apiService.sendNotification(notification);
    } catch (e) {
      print('Failed to send exam update notification: $e');
    }
  }

  /// Send notification when exam is deleted
  Future<void> notifyExamDeleted(String examName, {List<int>? classIds}) async {
    try {
      if (classIds == null || classIds.isEmpty) {
        print('No classes provided for exam deletion notification, skipping');
        return;
      }

      final notification = CreateThongBaoRequest(
        noiDung: '🗑️ Đề thi "$examName" đã được xóa.',
        nhomIds: classIds,
      );

      await _apiService.sendNotification(notification);
    } catch (e) {
      print('Failed to send exam deletion notification: $e');
    }
  }

  void dispose() {
    stopExamReminders();
  }

  /// Helper method to format DateTime for notifications
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Chưa xác định';
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(dateTime);
  }
}



/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return NotificationService(apiService);
});
