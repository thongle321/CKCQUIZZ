import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/exam_taking_provider.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/models/exam_taking_model.dart';
import 'package:ckcandr/core/utils/responsive_helper.dart';

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

class _ExamTakingScreenState extends ConsumerState<ExamTakingScreen> {
  @override
  void initState() {
    super.initState();
    _initializeExam();
  }

  /// khởi tạo bài thi
  void _initializeExam() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final examId = int.tryParse(widget.examId);
      if (examId != null) {
        ref.read(examTakingProvider.notifier).startExam(examId);
      } else {
        _showError('ID đề thi không hợp lệ');
      }
    });
  }

  @override
  void dispose() {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
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

      // Handle successful submission
      if (next.result != null && previous?.result != next.result) {
        _showExamResult(next.result!);
      }
    });

    return PopScope(
      canPop: false, // ngăn không cho thoát trong khi thi
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showError('Không thể thoát trong khi làm bài thi!');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(role, theme, examState),
        body: _buildBody(theme, isSmallScreen, examState),
        bottomNavigationBar: _buildBottomBar(theme, examState),
      ),
    );
  }

  /// hiển thị kết quả thi
  void _showExamResult(ExamResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.grade, color: Colors.green),
            SizedBox(width: 8),
            Text('Kết quả bài thi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Điểm số: ${result.score}/10',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text('Số câu đúng: ${result.correctAnswers}/${result.totalQuestions}'),
            Text('Thời gian làm bài: ${_formatDuration(result.duration)}'),
            Text('Đánh giá: ${result.grade}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/sinhvien'); // quay về dashboard
            },
            child: const Text('Về trang chủ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate đến màn hình kết quả chi tiết
              context.go('/sinhvien/exam-result/${result.examId}/${result.resultId}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xem kết quả'),
          ),
        ],
      ),
    );
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
      return const Center(
        child: Text('Đề thi không có câu hỏi'),
      );
    }

    final currentQuestion = ref.watch(currentQuestionProvider);
    if (currentQuestion == null) {
      return const Center(
        child: Text('Không thể tải câu hỏi'),
      );
    }

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
    final selectedAnswer = ref.watch(currentQuestionAnswerProvider);

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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _buildImageUrl(currentQuestion.imageUrl!),
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('❌ Error loading image: ${currentQuestion.imageUrl}');
                debugPrint('❌ Error: $error');
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Không thể tải hình ảnh'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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
                  ? () => ref.read(examTakingProvider.notifier).previousQuestion()
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
                    onPressed: () => ref.read(examTakingProvider.notifier).nextQuestion(),
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
            controller: TextEditingController(text: currentAnswer),
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
          'Số ký tự: ${currentAnswer.length}',
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

  /// hiển thị dialog xác nhận submit
  void _showSubmitConfirmation() {
    final examState = ref.read(examTakingProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận nộp bài'),
        content: Text(
          'Bạn có chắc chắn muốn nộp bài?\n\n'
          'Đã trả lời: ${examState.answeredCount}/${examState.questions.length} câu\n'
          'Thời gian còn lại: ${ref.read(timeRemainingFormattedProvider)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
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
            ),
            child: const Text('Nộp bài'),
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
}
