import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/exam_taking_model.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/providers/user_provider.dart';

/// Provider cho quản lý việc làm bài thi của sinh viên
/// Hỗ trợ timer, auto-submit, và state management chuyên nghiệp

/// Notifier cho exam taking
class ExamTakingNotifier extends StateNotifier<ExamTakingState> {
  final ApiService _apiService;
  final Ref _ref;
  Timer? _timer;
  DateTime? _examStartTime;

  ExamTakingNotifier(this._apiService, this._ref) : super(const ExamTakingState());

  /// bắt đầu làm bài thi
  Future<void> startExam(int examId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // lấy thông tin đề thi
      final exam = await _getExamById(examId);
      if (exam == null) {
        throw Exception('Không tìm thấy đề thi');
      }

      // kiểm tra có thể vào thi không
      if (!exam.canTakeExam) {
        throw Exception('Không thể vào thi lúc này');
      }

      // lấy câu hỏi
      final questions = await _apiService.getExamQuestions(examId);
      if (questions.isEmpty) {
        throw Exception('Đề thi không có câu hỏi');
      }

      // khởi tạo state
      _examStartTime = DateTime.now();
      state = state.copyWith(
        exam: exam,
        questions: questions,
        currentQuestionIndex: 0,
        studentAnswers: {},
        startTime: _examStartTime,
        timeRemaining: exam.duration != null ? Duration(minutes: exam.duration!) : null,
        isLoading: false,
        error: null,
      );

      // bắt đầu timer
      _startTimer();

      debugPrint('✅ Started exam: ${exam.examName} with ${questions.length} questions');
    } catch (e) {
      debugPrint('❌ Error starting exam: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// bắt đầu timer đếm ngược
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining != null && state.timeRemaining!.inSeconds > 0) {
        final newTimeRemaining = Duration(seconds: state.timeRemaining!.inSeconds - 1);
        state = state.copyWith(timeRemaining: newTimeRemaining);

        // cảnh báo khi còn 5 phút
        if (newTimeRemaining.inMinutes == 5 && newTimeRemaining.inSeconds == 0) {
          _showTimeWarning();
        }
      } else {
        // hết thời gian, auto submit
        _autoSubmitExam();
      }
    });
  }

  /// cảnh báo thời gian
  void _showTimeWarning() {
    debugPrint('⚠️ Time warning: 5 minutes remaining');
    // có thể emit event để UI hiển thị warning
  }

  /// auto submit khi hết thời gian
  Future<void> _autoSubmitExam() async {
    _timer?.cancel();
    debugPrint('⏰ Auto submitting exam due to timeout');
    await submitExam(isAutoSubmit: true);
  }

  /// chọn đáp án cho câu hỏi
  void selectAnswer(int questionId, String answerId) {
    final newAnswers = Map<int, String>.from(state.studentAnswers);
    newAnswers[questionId] = answerId;

    state = state.copyWith(studentAnswers: newAnswers);
    debugPrint('✅ Selected answer $answerId for question $questionId');
  }

  /// chuyển đến câu hỏi tiếp theo
  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  /// quay lại câu hỏi trước
  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  /// chuyển đến câu hỏi cụ thể
  void goToQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentQuestionIndex: index);
    }
  }

  /// submit bài thi
  Future<void> submitExam({bool isAutoSubmit = false}) async {
    if (state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser?.id == null) {
        throw Exception('User not authenticated');
      }

      if (state.exam == null || state.startTime == null) {
        throw Exception('Invalid exam state');
      }

      // tạo danh sách đáp án
      final answers = state.questions.map((question) {
        final selectedAnswer = state.studentAnswers[question.questionId];

        // Xử lý theo loại câu hỏi
        switch (question.questionType.toLowerCase()) {
          case 'single_choice':
            return StudentAnswer(
              questionId: question.questionId,
              selectedAnswerId: selectedAnswer != null ? int.tryParse(selectedAnswer) : null,
              answerTime: DateTime.now(),
            );

          case 'multiple_choice':
            final selectedIds = selectedAnswer?.split(',')
                .where((id) => id.isNotEmpty)
                .map((id) => int.tryParse(id))
                .where((id) => id != null)
                .cast<int>()
                .toList() ?? [];
            return StudentAnswer(
              questionId: question.questionId,
              selectedAnswerIds: selectedIds.isNotEmpty ? selectedIds : null,
              answerTime: DateTime.now(),
            );

          case 'essay':
            return StudentAnswer(
              questionId: question.questionId,
              essayAnswer: selectedAnswer?.isNotEmpty == true ? selectedAnswer : null,
              answerTime: DateTime.now(),
            );

          default:
            // Default to single choice
            return StudentAnswer(
              questionId: question.questionId,
              selectedAnswerId: selectedAnswer != null ? int.tryParse(selectedAnswer) : null,
              answerTime: DateTime.now(),
            );
        }
      }).toList();

      // tạo request
      final request = SubmitExamRequest(
        examId: state.exam!.examId,
        studentId: currentUser!.id,
        startTime: state.startTime!,
        endTime: DateTime.now(),
        answers: answers,
      );

      debugPrint('🔄 Submitting exam with ${answers.length} answers...');

      // submit
      final result = await _apiService.submitExam(request);

      // cập nhật state
      _timer?.cancel();
      state = state.copyWith(
        isSubmitting: false,
        result: result,
        error: null, // clear any previous errors
      );

      debugPrint('✅ Exam submitted successfully. Score: ${result.score}, ResultId: ${result.resultId}');
    } catch (e) {
      debugPrint('❌ Error submitting exam: $e');
      _timer?.cancel(); // stop timer on error too
      state = state.copyWith(
        isSubmitting: false,
        error: 'Lỗi nộp bài: ${e.toString()}',
      );

      // Rethrow để UI có thể handle
      rethrow;
    }
  }

  /// lấy thông tin đề thi theo ID
  Future<ExamForStudent?> _getExamById(int examId) async {
    try {
      // lấy tất cả đề thi của sinh viên và tìm theo ID
      final exams = await _apiService.getMyExams();
      return exams.firstWhere(
        (exam) => exam.examId == examId,
        orElse: () => throw Exception('Exam not found'),
      );
    } catch (e) {
      debugPrint('❌ Error getting exam by ID: $e');
      return null;
    }
  }

  /// reset state
  void reset() {
    _timer?.cancel();
    state = const ExamTakingState();
  }

  /// clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// pause timer (nếu cần)
  void pauseTimer() {
    _timer?.cancel();
  }

  /// resume timer (nếu cần)
  void resumeTimer() {
    if (state.timeRemaining != null && state.timeRemaining!.inSeconds > 0) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider chính cho exam taking
final examTakingProvider = StateNotifierProvider<ExamTakingNotifier, ExamTakingState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ExamTakingNotifier(apiService, ref);
});

/// Provider cho câu hỏi hiện tại
final currentQuestionProvider = Provider<ExamQuestion?>((ref) {
  final state = ref.watch(examTakingProvider);
  if (state.questions.isEmpty || state.currentQuestionIndex >= state.questions.length) {
    return null;
  }
  return state.questions[state.currentQuestionIndex];
});

/// Provider cho đáp án đã chọn của câu hiện tại
final currentQuestionAnswerProvider = Provider<String?>((ref) {
  final state = ref.watch(examTakingProvider);
  final currentQuestion = ref.watch(currentQuestionProvider);
  if (currentQuestion == null) return null;
  
  return state.studentAnswers[currentQuestion.questionId];
});

/// Provider cho tiến độ làm bài
final examProgressProvider = Provider<double>((ref) {
  final state = ref.watch(examTakingProvider);
  return state.progress;
});

/// Provider cho thời gian còn lại (formatted)
final timeRemainingFormattedProvider = Provider<String>((ref) {
  final state = ref.watch(examTakingProvider);
  if (state.timeRemaining == null) return '--:--';
  
  final duration = state.timeRemaining!;
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  final seconds = duration.inSeconds % 60;
  
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  } else {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
});

/// Provider cho việc kiểm tra có thể submit không
final canSubmitExamProvider = Provider<bool>((ref) {
  final state = ref.watch(examTakingProvider);
  return state.canSubmit;
});

/// Provider cho danh sách đề thi của sinh viên
final studentExamsProvider = FutureProvider<List<ExamForStudent>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getMyExams();
});

/// Provider cho đề thi của lớp học cụ thể
final classExamsProvider = FutureProvider.family<List<ExamForStudent>, int>((ref, classId) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getStudentExamsForClass(classId);
});
