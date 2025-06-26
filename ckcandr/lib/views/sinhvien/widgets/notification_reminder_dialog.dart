import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/providers/student_notification_provider.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';

/// Dialog nhắc nhở kiểm tra thông báo khi mở app
/// Chỉ hiển thị một lần cho mỗi session và có thể đóng được
class NotificationReminderDialog extends ConsumerStatefulWidget {
  const NotificationReminderDialog({super.key});

  @override
  ConsumerState<NotificationReminderDialog> createState() => _NotificationReminderDialogState();

  /// hiển thị dialog nếu cần thiết
  static Future<void> showIfNeeded(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasShownToday = prefs.getBool('notification_reminder_shown_today') ?? false;
      final lastShownDate = prefs.getString('notification_reminder_last_date') ?? '';
      final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD

      // chỉ hiển thị nếu chưa hiển thị hôm nay
      if (!hasShownToday || lastShownDate != today) {
        // delay một chút để đảm bảo context đã sẵn sàng
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (context.mounted) {
          await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => const NotificationReminderDialog(),
          );

          // đánh dấu đã hiển thị hôm nay
          await prefs.setBool('notification_reminder_shown_today', true);
          await prefs.setString('notification_reminder_last_date', today);
        }
      }
    } catch (e) {
      debugPrint('❌ Error showing notification reminder dialog: $e');
    }
  }
}

class _NotificationReminderDialogState extends ConsumerState<NotificationReminderDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(studentNotificationProvider);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Kiểm tra thông báo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn có ${notificationState.unreadCount} thông báo chưa đọc.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hãy kiểm tra thông báo để không bỏ lỡ thông tin quan trọng về bài kiểm tra và lớp học.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  if (notificationState.unreadCount > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.priority_high,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Có thể có thông báo về bài kiểm tra cần chú ý!',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => _closeDialog(context),
                  child: Text(
                    'Để sau',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _goToNotifications(context),
                  icon: const Icon(Icons.notifications, size: 18),
                  label: const Text('Xem ngay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RoleTheme.getPrimaryColor(UserRole.sinhVien),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// đóng dialog
  void _closeDialog(BuildContext context) {
    _animationController.reverse().then((_) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  /// điều hướng đến màn hình thông báo
  void _goToNotifications(BuildContext context) {
    _animationController.reverse().then((_) {
      if (context.mounted) {
        Navigator.of(context).pop();
        // điều hướng đến màn hình thông báo
        context.push('/sinhvien/notifications');
      }
    });
  }
}

/// Widget helper để hiển thị dialog từ bất kỳ đâu
class NotificationReminderHelper {
  static const String _shownTodayKey = 'notification_reminder_shown_today';
  static const String _lastDateKey = 'notification_reminder_last_date';

  /// kiểm tra và hiển thị dialog nếu cần
  static Future<void> checkAndShow(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final lastShownDate = prefs.getString(_lastDateKey) ?? '';
      
      // reset flag nếu là ngày mới
      if (lastShownDate != today) {
        await prefs.setBool(_shownTodayKey, false);
      }

      final hasShownToday = prefs.getBool(_shownTodayKey) ?? false;

      if (!hasShownToday && context.mounted) {
        await NotificationReminderDialog.showIfNeeded(context);
      }
    } catch (e) {
      debugPrint('❌ Error in notification reminder helper: $e');
    }
  }

  /// đánh dấu đã hiển thị hôm nay
  static Future<void> markAsShownToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      await prefs.setBool(_shownTodayKey, true);
      await prefs.setString(_lastDateKey, today);
    } catch (e) {
      debugPrint('❌ Error marking notification reminder as shown: $e');
    }
  }

  /// reset trạng thái (để test)
  static Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_shownTodayKey);
      await prefs.remove(_lastDateKey);
    } catch (e) {
      debugPrint('❌ Error resetting notification reminder: $e');
    }
  }
}
