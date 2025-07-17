import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/exam_taking_provider.dart';
import 'package:ckcandr/providers/exam_refresh_provider.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/models/exam_taking_model.dart';
import 'package:ckcandr/core/utils/responsive_helper.dart';
import 'package:ckcandr/core/widgets/error_dialog.dart';

/// Exam Taking Screen - Màn hình dự thi cho sinh viên với API thật
/// Sử dụng provider để quản lý state và kết nối với backend
class ExamTakingScreen extends ConsumerStatefulWidget {
  final String examId;
  
  const ExamTakingScreen({
    super.key,
    required this.examId,
  });

  @override
  ConsumerState<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends ConsumerState<ExamTakingScreen> with WidgetsBindingObserver {
  // Map để lưu TextEditingController cho từng câu tự luận
  final Map<int, TextEditingController> _essayControllers = {};

  // App lifecycle tracking - Enhanced như Vue.js
  DateTime? _lastPauseTime;
  bool _isExamActive = false;
  bool _isProcessingUnfocus = false; // Prevent duplicate unfocus calls
  bool _isShowingUnfocusDialog = false; // Prevent multiple dialogs
  static const Duration _debounceDelay = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeExam();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint('🔄 App lifecycle changed: $state');

    // Enhanced app lifecycle tracking như Vue.js
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _handleAppPause();
        break;
      case AppLifecycleState.resumed:
        _handleAppResume();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
  }

  /// Xử lý khi app bị pause/inactive (như Vue.js visibility change)
  void _handleAppPause() {
    if (!_isExamActive) return;

    final now = DateTime.now();

    // Debounce để tránh trigger nhiều lần
    if (_lastPauseTime != null && now.difference(_lastPauseTime!) < _debounceDelay) {
      return;
    }

    _lastPauseTime = now;
    debugPrint('📱 App paused - triggering unfocus warning');

    _handleAppUnfocus();
  }

  /// Xử lý khi app resume
  void _handleAppResume() {
    debugPrint('📱 App resumed');
    // Có thể thêm logic kiểm tra session validity
  }

  /// Xử lý khi app bị detached (kill)
  void _handleAppDetached() {
    debugPrint('📱 App detached (killed)');
    // App bị kill, không thể xử lý gì thêm
  }

  /// Xử lý khi app bị hidden
  void _handleAppHidden() {
    if (!_isExamActive) return;
    debugPrint('📱 App hidden - triggering unfocus warning');
    _handleAppUnfocus();
  }

  void _handleAppUnfocus() async {
    // Prevent duplicate unfocus processing
    if (_isProcessingUnfocus) {
      debugPrint('⚠️ Skipping unfocus - already processing');
      return;
    }

    final examState = ref.read(examTakingProvider);

    // Chỉ xử lý khi đang trong bài thi (chưa submit)
    if (examState.result != null || examState.isSubmitting) {
      debugPrint('⚠️ Skipping unfocus - exam already submitted or submitting');
      return;
    }

    // Kiểm tra ketQuaId
    if (examState.ketQuaId == null) {
      debugPrint('❌ Skipping unfocus - no ketQuaId available');
      return;
    }

    _isProcessingUnfocus = true;
    debugPrint('⚠️ App unfocus detected - ketQuaId: ${examState.ketQuaId}');
    debugPrint('⚠️ Current unfocus count: ${examState.unfocusCount}');

    try {
      // Sử dụng provider để increment và check auto submit
      final shouldAutoSubmit = await ref.read(examTakingProvider.notifier).incrementUnfocusCount();

      if (shouldAutoSubmit) {
        // Đã auto submit, không cần hiển thị dialog
        debugPrint('🚨 Auto submit triggered by unfocus count');
        return;
      } else {
        // Hiển thị cảnh báo (dialog sẽ lấy count từ state)
        final updatedState = ref.read(examTakingProvider);
        debugPrint('⚠️ Showing unfocus warning - Count: ${updatedState.unfocusCount}/5');
        _showUnfocusWarning();
      }
    } finally {
      _isProcessingUnfocus = false;
    }
  }

  void _showUnfocusWarning() {
    if (!mounted) return;

    // Prevent multiple dialogs
    if (_isShowingUnfocusDialog) {
      debugPrint('⚠️ Skipping unfocus dialog - already showing');
      return;
    }

    _isShowingUnfocusDialog = true;

    // Lấy thông báo từ API
    final examState = ref.read(examTakingProvider);
    final message = examState.unfocusMessage ??
      'Bạn đã rời khỏi ứng dụng trong khi làm bài thi. Vui lòng không rời khỏi ứng dụng để tránh vi phạm quy định thi.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final currentState = ref.watch(examTakingProvider);
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Cảnh báo vi phạm'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(currentState.unfocusMessage ?? message),
                const SizedBox(height: 8),
                Text(
                  'Số lần thoát: ${currentState.unfocusCount}/5',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  _isShowingUnfocusDialog = false; // Reset flag
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Đã hiểu'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBackButtonWarning() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Không thể thoát'),
          ],
        ),
        content: const Text(
          'Bạn không thể thoát khỏi bài thi khi đang làm bài.\n\nVui lòng hoàn thành bài thi hoặc nộp bài để thoát.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  /// khởi tạo bài thi
  void _initializeExam() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final examId = int.tryParse(widget.examId);
      if (examId != null) {
        _isExamActive = true; // Kích hoạt tracking
        ref.read(examTakingProvider.notifier).startExam(examId);
      } else {
        _showError('ID đề thi không hợp lệ');
      }
    });
  }

  @override
  void dispose() {
    // Remove observer
    WidgetsBinding.instance.removeObserver(this);

    // cleanup TextEditingController
    for (var controller in _essayControllers.values) {
      controller.dispose();
    }
    _essayControllers.clear();

    // cleanup khi thoát màn hình - check if mounted first
    if (mounted) {
      try {
        ref.read(examTakingProvider.notifier).reset();
      } catch (e) {
        // ignore error if widget is already disposed
      }
    }
    super.dispose();
  }

  /// hiển thị lỗi
  void _showError(String message) {
    if (mounted) {
      ErrorDialog.show(
        context,
        message: message,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;
    final examState = ref.watch(examTakingProvider);
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveHelper.isMobile(context);

    // listen to state changes
    ref.listen<ExamTakingState>(examTakingProvider, (previous, next) {
      // Handle errors
      if (next.error != null && previous?.error != next.error) {
        _showError(next.error!);
        // Clear error after showing
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            ref.read(examTakingProvider.notifier).clearError();
          }
        });
      }

      // Handle successful submission - SỬA: Không hiển thị điểm ngay, chỉ thông báo và redirect
      if (next.result != null && previous?.result != next.result) {
        _isExamActive = false; // Disable tracking khi đã submit
        _showSubmissionSuccess(autoSubmitReason: next.autoSubmitReason);
      }
    });

    return PopScope(
      canPop: false, // Hoàn toàn ngăn không cho thoát trong khi thi
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Không cho phép thoát khi đang thi - hiển thị cảnh báo
          _showBackButtonWarning();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(role, theme, examState),
        body: Stack(
          children: [
            _buildBody(theme, isSmallScreen, examState),
            // Saving indicator
            if (examState.isSaving)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: const SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(theme, examState),
      ),
    );
  }

  /// Professional submission success dialog - cứng và tự động navigate
  void _showSubmissionSuccess({String? autoSubmitReason}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho dismiss
      builder: (context) => PopScope(
        canPop: false, // Không cho back button
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nộp bài thành công!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bài thi của bạn đã được nộp thành công và đã được lưu vào hệ thống.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 24),
                    SizedBox(height: 8),
                    Text(
                      'Kết quả sẽ được công bố sau khi kỳ thi kết thúc và được sự cho phép của giảng viên.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (autoSubmitReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          autoSubmitReason,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Bạn sẽ được chuyển về trang chủ trong giây lát...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _handleSubmissionComplete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Về trang chủ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Tự động navigate sau 5 giây
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _handleSubmissionComplete();
      }
    });
  }

  /// Xử lý khi hoàn thành submit - navigate về trang chủ
  void _handleSubmissionComplete() {
    if (!mounted) return;

    // Close dialog if still open
    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);

    // Reset exam state
    ref.read(examTakingProvider.notifier).reset();

    // Navigate về trang chủ với refresh
    _navigateBackAndRefresh();
  }

  /// Navigate back và refresh danh sách bài thi
  void _navigateBackAndRefresh() {
    // Trigger refresh cho danh sách bài thi
    ref.read(examRefreshProvider.notifier).triggerRefresh();
    // Quay về trang danh sách bài thi
    context.go('/sinhvien');
    debugPrint('🔄 Triggered exam list refresh and navigating back after submission');
  }

  /// xây dựng app bar
  PreferredSizeWidget _buildAppBar(UserRole role, ThemeData theme, ExamTakingState examState) {
    final timeRemaining = ref.watch(timeRemainingFormattedProvider);
    
    return AppBar(
      backgroundColor: RoleTheme.getPrimaryColor(role),
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false, // không hiển thị nút back
      title: Text(
        examState.exam?.examName ?? 'Đang làm bài thi',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        // hiển thị số lần vi phạm (nếu có)
        if (examState.unfocusCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: examState.unfocusCount >= 4 ? Colors.red : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '${examState.unfocusCount}/5',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

        // hiển thị thời gian còn lại
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: examState.timeRemaining != null && examState.timeRemaining!.inMinutes <= 5
                ? Colors.red
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                timeRemaining,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// xây dựng body chính
  Widget _buildBody(ThemeData theme, bool isSmallScreen, ExamTakingState examState) {
    if (examState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải đề thi...'),
          ],
        ),
      );
    }

    if (examState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              examState.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/sinhvien'),
              child: const Text('Quay về'),
            ),
          ],
        ),
      );
    }

    if (examState.questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Đề thi rỗng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đề thi này chưa có câu hỏi nào',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/sinhvien'),
              child: const Text('Quay về'),
            ),
          ],
        ),
      );
    }

    final currentQuestion = ref.watch(currentQuestionProvider);
    if (currentQuestion == null) {
      return const Center(
        child: Text('Không thể tải câu hỏi'),
      );
    }

    // Mobile layout - single column với question navigation drawer
    if (isSmallScreen) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // progress indicator và question navigation button
            Row(
              children: [
                Expanded(child: _buildProgressIndicator(theme, examState)),
                const SizedBox(width: 12),
                // Question navigation button (mobile)
                ElevatedButton.icon(
                  onPressed: () => _showQuestionNavigationDialog(examState),
                  icon: const Icon(Icons.grid_view, size: 18),
                  label: Text('${examState.currentQuestionIndex + 1}/${examState.questions.length}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // câu hỏi
            Expanded(
              child: SingleChildScrollView(
                child: _buildQuestionContent(theme, currentQuestion, examState),
              ),
            ),
          ],
        ),
      );
    }

    // Desktop/Tablet layout - two columns như Vue.js
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question navigation sidebar (như Vue.js)
        Container(
          width: 250,
          margin: const EdgeInsets.all(24),
          child: _buildQuestionNavigationSidebar(theme, examState),
        ),

        // Main content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // progress indicator
                _buildProgressIndicator(theme, examState),
                const SizedBox(height: 24),

                // câu hỏi
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildQuestionContent(theme, currentQuestion, examState),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// xây dựng progress indicator
  Widget _buildProgressIndicator(ThemeData theme, ExamTakingState examState) {
    final progress = ref.watch(examProgressProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiến độ làm bài',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${examState.answeredCount}/${examState.questions.length} đã trả lời',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            RoleTheme.getPrimaryColor(UserRole.sinhVien),
          ),
        ),
      ],
    );
  }

  /// xây dựng nội dung câu hỏi
  Widget _buildQuestionContent(ThemeData theme, ExamQuestion currentQuestion, ExamTakingState examState) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // số thứ tự câu hỏi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Câu ${examState.currentQuestionIndex + 1}/${examState.questions.length}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // nội dung câu hỏi
        Text(
          currentQuestion.content,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),

        // hình ảnh nếu có
        if (currentQuestion.imageUrl != null && currentQuestion.imageUrl!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildQuestionImage(currentQuestion.imageUrl!),
        ],

        const SizedBox(height: 24),

        // Hiển thị câu hỏi theo loại
        _buildQuestionAnswers(currentQuestion, examState),
      ],
    );
  }

  /// xây dựng bottom bar
  Widget _buildBottomBar(ThemeData theme, ExamTakingState examState) {
    final canSubmit = ref.watch(canSubmitExamProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // nút câu trước
          Expanded(
            child: ElevatedButton.icon(
              onPressed: examState.currentQuestionIndex > 0
                  ? () async {
                      await ref.read(examTakingProvider.notifier).previousQuestion();
                    }
                  : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Câu trước'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // nút câu tiếp theo hoặc nộp bài
          Expanded(
            flex: 2,
            child: examState.currentQuestionIndex < examState.questions.length - 1
                ? ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(examTakingProvider.notifier).nextQuestion();
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Câu tiếp theo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RoleTheme.getPrimaryColor(UserRole.sinhVien),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: canSubmit && !examState.isSubmitting
                        ? () => _showSubmitConfirmation()
                        : null,
                    icon: examState.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(examState.isSubmitting ? 'Đang nộp...' : 'Nộp bài'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Build image URL with server base URL
  String _buildImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return imageUrl; // Already full URL
    }
    // Add server base URL
    return 'http://192.168.0.18:7255$imageUrl';
  }

  /// Build professional question image widget
  Widget _buildQuestionImage(String imageUrl) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 400,
        maxWidth: double.infinity,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _buildImageUrl(imageUrl),
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Đang tải hình ảnh...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (loadingProgress.expectedTotalBytes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${((loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('❌ Error loading image: $imageUrl');
            debugPrint('❌ Error: $error');

            return Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Không thể tải hình ảnh',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vui lòng kiểm tra kết nối mạng',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        // Trigger rebuild to retry loading
                        (context as Element).markNeedsBuild();
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Thử lại'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build question answers based on question type
  Widget _buildQuestionAnswers(ExamQuestion currentQuestion, ExamTakingState examState) {
    switch (currentQuestion.questionType.toLowerCase()) {
      case 'single_choice':
        return _buildSingleChoiceAnswers(currentQuestion, examState);
      case 'multiple_choice':
        return _buildMultipleChoiceAnswers(currentQuestion, examState);
      case 'essay':
        return _buildEssayAnswer(currentQuestion, examState);
      default:
        return _buildSingleChoiceAnswers(currentQuestion, examState); // Default to single choice
    }
  }

  /// Build single choice answers (radio buttons)
  Widget _buildSingleChoiceAnswers(ExamQuestion currentQuestion, ExamTakingState examState) {
    final selectedAnswer = ref.watch(currentQuestionAnswerProvider);

    return Column(
      children: currentQuestion.answers.asMap().entries.map((entry) {
        final index = entry.key;
        final answer = entry.value;
        final isSelected = selectedAnswer == answer.answerId.toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _selectSingleAnswer(currentQuestion.questionId, answer.answerId.toString()),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[400]!,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${String.fromCharCode(65 + index)}. ${answer.content}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.blue[800] : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build multiple choice answers (checkboxes)
  Widget _buildMultipleChoiceAnswers(ExamQuestion currentQuestion, ExamTakingState examState) {
    final selectedAnswers = examState.studentAnswers[currentQuestion.questionId]?.split(',') ?? [];

    return Column(
      children: [
        // Instruction for multiple choice
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Câu hỏi chọn nhiều đáp án. Bạn có thể chọn một hoặc nhiều đáp án.',
                  style: TextStyle(color: Colors.orange, fontSize: 14),
                ),
              ),
            ],
          ),
        ),

        // Answer options
        ...currentQuestion.answers.asMap().entries.map((entry) {
          final index = entry.key;
          final answer = entry.value;
          final isSelected = selectedAnswers.contains(answer.answerId.toString());

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _toggleMultipleAnswer(currentQuestion.questionId, answer.answerId.toString()),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green.withValues(alpha: 0.1) : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey[400]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4), // Square for checkbox
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${String.fromCharCode(65 + index)}. ${answer.content}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.green[800] : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Build essay answer (text field)
  Widget _buildEssayAnswer(ExamQuestion currentQuestion, ExamTakingState examState) {
    final currentAnswer = examState.studentAnswers[currentQuestion.questionId] ?? '';

    // Lấy hoặc tạo controller cho câu hỏi này
    final controller = _essayControllers.putIfAbsent(
      currentQuestion.questionId,
      () => TextEditingController(text: currentAnswer),
    );

    // Cập nhật text nếu khác với state hiện tại
    if (controller.text != currentAnswer) {
      controller.text = currentAnswer;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction for essay
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.edit, color: Colors.purple, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Câu hỏi tự luận. Hãy nhập câu trả lời của bạn vào ô bên dưới.',
                  style: TextStyle(color: Colors.purple, fontSize: 14),
                ),
              ),
            ],
          ),
        ),

        // Text field for essay answer
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Nhập câu trả lời của bạn...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: (value) => _updateEssayAnswer(currentQuestion.questionId, value),
          ),
        ),

        const SizedBox(height: 8),

        // Character count
        Text(
          'Số ký tự: ${controller.text.length}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Select single answer
  void _selectSingleAnswer(int questionId, String answerId) {
    ref.read(examTakingProvider.notifier).selectAnswer(questionId, answerId);
  }

  /// Toggle multiple answer
  void _toggleMultipleAnswer(int questionId, String answerId) {
    final currentAnswers = ref.read(examTakingProvider).studentAnswers[questionId]?.split(',') ?? [];

    if (currentAnswers.contains(answerId)) {
      currentAnswers.remove(answerId);
    } else {
      currentAnswers.add(answerId);
    }

    final newAnswer = currentAnswers.where((id) => id.isNotEmpty).join(',');
    ref.read(examTakingProvider.notifier).selectAnswer(questionId, newAnswer);
  }

  /// Update essay answer
  void _updateEssayAnswer(int questionId, String answer) {
    ref.read(examTakingProvider.notifier).selectAnswer(questionId, answer);
  }

  /// Professional submit confirmation dialog
  void _showSubmitConfirmation() {
    final examState = ref.read(examTakingProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.orange,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Xác nhận nộp bài',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bạn có chắc chắn muốn nộp bài thi?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Đã trả lời:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${examState.answeredCount}/${examState.questions.length} câu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: examState.answeredCount == examState.questions.length
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thời gian còn lại:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        ref.read(timeRemainingFormattedProvider),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sau khi nộp bài, bạn sẽ không thể thay đổi câu trả lời.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                  ),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await ref.read(examTakingProvider.notifier).submitExam();
                      // Success case will be handled by the listener
                    } catch (e) {
                      // Show error if submit fails
                      if (mounted) {
                        _showError('Không thể nộp bài: $e');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Nộp bài',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// format thời gian
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Build question navigation sidebar (như Vue.js layout)
  Widget _buildQuestionNavigationSidebar(ThemeData theme, ExamTakingState examState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách câu hỏi',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Question grid (như Vue.js)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: examState.questions.length,
            itemBuilder: (context, index) {
              final question = examState.questions[index];
              final isAnswered = examState.studentAnswers.containsKey(question.questionId) &&
                  examState.studentAnswers[question.questionId]!.isNotEmpty;
              final isCurrent = examState.currentQuestionIndex == index;

              return InkWell(
                onTap: () async {
                  await ref.read(examTakingProvider.notifier).goToQuestion(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.blue
                        : isAnswered
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isCurrent
                          ? Colors.blue
                          : isAnswered
                              ? Colors.green
                              : Colors.grey,
                      width: isCurrent ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCurrent
                            ? Colors.white
                            : isAnswered
                                ? Colors.green[800]
                                : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Submit button (như Vue.js)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: ref.watch(canSubmitExamProvider) && !examState.isSubmitting
                  ? () => _showSubmitConfirmation()
                  : null,
              icon: examState.isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(examState.isSubmitting ? 'Đang nộp...' : 'Nộp bài'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show question navigation dialog for mobile
  void _showQuestionNavigationDialog(ExamTakingState examState) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn câu hỏi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Question grid for mobile
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: examState.questions.length,
                  itemBuilder: (context, index) {
                    final question = examState.questions[index];
                    final isAnswered = examState.studentAnswers.containsKey(question.questionId) &&
                        examState.studentAnswers[question.questionId]!.isNotEmpty;
                    final isCurrent = examState.currentQuestionIndex == index;

                    return InkWell(
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        await ref.read(examTakingProvider.notifier).goToQuestion(index);
                        if (mounted) {
                          navigator.pop();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Colors.blue
                              : isAnswered
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.1),
                          border: Border.all(
                            color: isCurrent
                                ? Colors.blue
                                : isAnswered
                                    ? Colors.green
                                    : Colors.grey,
                            width: isCurrent ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isCurrent
                                  ? Colors.white
                                  : isAnswered
                                      ? Colors.green[800]
                                      : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem('Hiện tại', Colors.blue),
                  _buildLegendItem('Đã trả lời', Colors.green),
                  _buildLegendItem('Chưa trả lời', Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build legend item for question navigation
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
