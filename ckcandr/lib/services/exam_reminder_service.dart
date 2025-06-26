import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/services/api_service.dart';

/// Service để quản lý thông báo tự động khi đến giờ thi
class ExamReminderService {
  final ApiService _apiService;
  Timer? _reminderTimer;
  List<ExamForClassModel> _trackedExams = [];
  final Set<int> _notifiedExams = {};
  BuildContext? _context;

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
      // Không cần currentUser cho local notification

      // Hiển thị thông báo local
      _showLocalNotification(
        title: '⏰ Sắp đến giờ thi',
        message: 'Đề thi "${exam.tende}" sẽ bắt đầu trong $timeRemaining',
        isUrgent: timeRemaining == '5 phút',
      );

      debugPrint('📢 Exam reminder sent: ${exam.tende} - $timeRemaining remaining');
    } catch (e) {
      debugPrint('Failed to send exam reminder: $e');
    }
  }

  /// Gửi thông báo khi đến giờ thi
  Future<void> _sendExamStartNotification(ExamForClassModel exam) async {
    try {
      // Không cần currentUser cho local notification

      // Hiển thị thông báo local
      _showLocalNotification(
        title: '🚨 Đã đến giờ thi!',
        message: 'Đề thi "${exam.tende}" đã bắt đầu. Nhấn để vào thi ngay!',
        isUrgent: true,
        examId: exam.made,
      );

      debugPrint('📢 Exam start notification sent: ${exam.tende}');
    } catch (e) {
      debugPrint('Failed to send exam start notification: $e');
    }
  }

  /// Hiển thị thông báo local (trong app)
  void _showLocalNotification({
    required String title,
    required String message,
    bool isUrgent = false,
    int? examId,
  }) {
    // Tìm context từ navigator
    final context = _getNavigatorContext();
    if (context == null) return;

    // Hiển thị SnackBar với style đặc biệt
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: isUrgent ? Colors.red : Colors.orange,
        duration: Duration(seconds: isUrgent ? 10 : 5),
        action: examId != null
            ? SnackBarAction(
                label: 'VÀO THI',
                textColor: Colors.white,
                onPressed: () => _navigateToExam(context, examId),
              )
            : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    // Hiển thị dialog cho thông báo quan trọng
    if (isUrgent && examId != null) {
      _showExamStartDialog(context, title, message, examId);
    }
  }

  /// Hiển thị dialog khi đến giờ thi
  void _showExamStartDialog(BuildContext context, String title, String message, int examId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.alarm, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              'Bạn có muốn vào thi ngay bây giờ?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Để sau'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToExam(context, examId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('VÀO THI NGAY'),
          ),
        ],
      ),
    );
  }

  /// Điều hướng đến màn hình thi
  void _navigateToExam(BuildContext context, int examId) {
    // TODO: Implement navigation to exam screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Điều hướng đến đề thi $examId'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Lấy context từ navigator
  BuildContext? _getNavigatorContext() {
    try {
      return WidgetsBinding.instance.rootElement?.findAncestorWidgetOfExactType<MaterialApp>()?.navigatorKey?.currentContext;
    } catch (e) {
      return null;
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
