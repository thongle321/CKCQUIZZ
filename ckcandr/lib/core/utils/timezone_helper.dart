import 'package:intl/intl.dart';

/// Helper class để xử lý timezone conversion
class TimezoneHelper {
  /// Convert UTC time từ database sang GMT+7 (Vietnam timezone)
  static DateTime toLocal(DateTime utcTime) {
    // Database lưu UTC, cần convert sang GMT+7
    return utcTime.add(const Duration(hours: 7));
  }

  /// Convert local time (GMT+7) sang UTC để lưu database
  static DateTime toUtc(DateTime localTime) {
    // Convert từ GMT+7 về UTC
    return localTime.subtract(const Duration(hours: 7));
  }

  /// Get current time in GMT+7
  static DateTime nowLocal() {
    return DateTime.now().toUtc().add(const Duration(hours: 7));
  }

  /// Format thời gian hiển thị "x giờ trước", "x ngày trước"
  static String formatTimeAgo(DateTime? utcTime) {
    if (utcTime == null) return 'Không rõ';

    final localTime = toLocal(utcTime);
    final now = nowLocal();
    final difference = now.difference(localTime);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(localTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  /// Format ngày giờ đầy đủ
  static String formatDateTime(DateTime utcTime) {
    final localTime = toLocal(utcTime);
    return DateFormat('dd/MM/yyyy HH:mm').format(localTime);
  }

  /// Format thời gian cho notification popup
  static String formatNotificationTime(DateTime utcTime) {
    final localTime = toLocal(utcTime);
    final now = nowLocal();
    final difference = now.difference(localTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(localTime);
    }
  }
}
