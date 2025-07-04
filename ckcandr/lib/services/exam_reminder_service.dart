import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/services/api_service.dart';
import 'system_notification_service.dart';

/// Service để quản lý thông báo tự động khi đến giờ thi
class ExamReminderService {
  final ApiService _apiService;
  Timer? _reminderTimer;
  List<ExamForClassModel> _trackedExams = [];
  final Set<int> _notifiedExams = {};

  // System notification service
  final SystemNotificationService _systemNotificationService = SystemNotificationService();

  ExamReminderService(this._apiService);

  /// Bắt đầu theo dõi các đề thi và gửi thông báo
  void startExamReminders() {
    // Kiểm tra mỗi phút
    _reminderTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkUpcomingExams();
    });
    
    // Kiểm tra ngay lập tức
    _checkUpcomingExams();
  }

  /// Dừng theo dõi thông báo
  void stopExamReminders() {
    _reminderTimer?.cancel();
    _reminderTimer = null;
  }

  /// Cập nhật danh sách đề thi cần theo dõi
  void updateTrackedExams(List<ExamForClassModel> exams) {
    _trackedExams = exams;
  }

  /// Kiểm tra các đề thi sắp diễn ra và gửi thông báo
  Future<void> _checkUpcomingExams() async {
    try {
      final now = DateTime.now();
      
      for (final exam in _trackedExams) {
        if (exam.thoigiantbatdau == null) continue;
        
        final timeUntilExam = exam.thoigiantbatdau!.difference(now);
        
        // Thông báo 30 phút trước
        if (timeUntilExam.inMinutes <= 30 && 
            timeUntilExam.inMinutes > 25 && 
            !_notifiedExams.contains(exam.made)) {
          await _sendExamReminderNotification(exam, '30 phút');
          _notifiedExams.add(exam.made);
        }
        
        // Thông báo 10 phút trước
        else if (timeUntilExam.inMinutes <= 10 && 
                 timeUntilExam.inMinutes > 5 && 
                 !_notifiedExams.contains(exam.made + 1000)) {
          await _sendExamReminderNotification(exam, '10 phút');
          _notifiedExams.add(exam.made + 1000);
        }
        
        // Thông báo 5 phút trước
        else if (timeUntilExam.inMinutes <= 5 && 
                 timeUntilExam.inMinutes > 0 && 
                 !_notifiedExams.contains(exam.made + 2000)) {
          await _sendExamReminderNotification(exam, '5 phút');
          _notifiedExams.add(exam.made + 2000);
        }
        
        // Thông báo khi đến giờ thi
        else if (timeUntilExam.inMinutes <= 0 && 
                 timeUntilExam.inMinutes > -5 && 
                 !_notifiedExams.contains(exam.made + 3000)) {
          await _sendExamStartNotification(exam);
          _notifiedExams.add(exam.made + 3000);
        }
      }
    } catch (e) {
      debugPrint('Error checking upcoming exams: $e');
    }
  }

  /// Gửi thông báo nhắc nhở trước giờ thi
  Future<void> _sendExamReminderNotification(ExamForClassModel exam, String timeRemaining) async {
    try {
      // Hiển thị system notification
      await _systemNotificationService.showExamReminder(
        examName: exam.tende ?? 'Đề thi',
        timeRemaining: timeRemaining,
        examId: exam.made,
      );

      debugPrint('📢 Exam reminder sent: ${exam.tende} - $timeRemaining remaining');
    } catch (e) {
      debugPrint('Failed to send exam reminder: $e');
    }
  }

  /// Gửi thông báo khi đến giờ thi
  Future<void> _sendExamStartNotification(ExamForClassModel exam) async {
    try {
      // Hiển thị system notification
      await _systemNotificationService.showExamStartNotification(
        examName: exam.tende ?? 'Đề thi',
        examId: exam.made,
      );

      debugPrint('📢 Exam start notification sent: ${exam.tende}');
    } catch (e) {
      debugPrint('Failed to send exam start notification: $e');
    }
  }




  /// Xóa cache thông báo đã gửi (gọi khi cần reset)
  void clearNotificationCache() {
    _notifiedExams.clear();
  }

  /// Kiểm tra xem có đề thi nào sắp diễn ra không
  bool hasUpcomingExams() {
    final now = DateTime.now();
    return _trackedExams.any((exam) {
      if (exam.thoigiantbatdau == null) return false;
      final timeUntilExam = exam.thoigiantbatdau!.difference(now);
      return timeUntilExam.inMinutes <= 30 && timeUntilExam.inMinutes > 0;
    });
  }

  /// Lấy đề thi sắp diễn ra nhất
  ExamForClassModel? getNextUpcomingExam() {
    final now = DateTime.now();
    ExamForClassModel? nextExam;
    Duration? shortestTime;

    for (final exam in _trackedExams) {
      if (exam.thoigiantbatdau == null) continue;
      
      final timeUntilExam = exam.thoigiantbatdau!.difference(now);
      if (timeUntilExam.inMinutes > 0) {
        if (shortestTime == null || timeUntilExam < shortestTime) {
          shortestTime = timeUntilExam;
          nextExam = exam;
        }
      }
    }

    return nextExam;
  }
}

/// Provider cho ExamReminderService
final examReminderServiceProvider = Provider<ExamReminderService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ExamReminderService(apiService);
});
