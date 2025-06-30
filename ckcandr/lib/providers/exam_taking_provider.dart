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

  /// bắt đầu làm bài thi - Match Vue.js logic exactly
  Future<void> startExam(int examId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      debugPrint('🚀 Starting exam with ID: $examId');

      // Step 1: Start exam - gọi API /Exam/start như Vue.js
      final startResponse = await _apiService.startExam(examId);
      if (startResponse.isEmpty) {
        throw Exception('Không nhận được phản hồi từ server khi bắt đầu bài thi');
      }

      final ketQuaId = startResponse['ketQuaId'] as int?;
      final thoigianbatdauStr = startResponse['thoigianbatdau'] as String?;

      if (ketQuaId == null) {
        throw Exception('Không nhận được mã kết quả từ server');
      }

      // Parse start time từ server
      DateTime? serverStartTime;
      if (thoigianbatdauStr != null) {
        try {
          serverStartTime = DateTime.parse(thoigianbatdauStr);
        } catch (e) {
          debugPrint('⚠️ Could not parse server start time: $thoigianbatdauStr');
        }
      }
      _examStartTime = serverStartTime ?? DateTime.now();

      debugPrint('✅ Exam started. KetQuaId: $ketQuaId, StartTime: $_examStartTime');

      // Step 2: Get exam details - gọi API /Exam/{examId} như Vue.js
      final examDetailsResponse = await _apiService.getExamDetails(examId);
      if (examDetailsResponse.isEmpty) {
        throw Exception('Không nhận được phản hồi từ server khi lấy chi tiết đề thi');
      }

      // Parse exam data từ response
      final examData = _parseExamData(examDetailsResponse, examId);
      final questions = _parseQuestions(examDetailsResponse);

      if (questions.isEmpty) {
        throw Exception('Đề thi không có câu hỏi');
      }

      // khởi tạo state với dữ liệu từ server
      state = state.copyWith(
        exam: examData,
        questions: questions,
        currentQuestionIndex: 0,
        studentAnswers: {},
        startTime: _examStartTime,
        timeRemaining: examData.duration != null ? Duration(minutes: examData.duration!) : null,
        isLoading: false,
        ketQuaId: ketQuaId, // lưu ketQuaId để dùng cho update answer và submit
      );

      // bắt đầu timer
      _startTimer();

      debugPrint('✅ Exam initialized: ${examData.examName} with ${questions.length} questions');
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

  /// Parse exam data từ API response
  ExamForStudent _parseExamData(Map<String, dynamic> response, int examId) {
    return ExamForStudent(
      examId: examId,
      examName: response['tende'] as String?,
      subjectName: response['tenMonHoc'] as String?,
      duration: response['thoigianthi'] as int?,
      startTime: response['thoigiantbatdau'] != null
        ? DateTime.tryParse(response['thoigiantbatdau'] as String)
        : null,
      endTime: response['thoigianketthuc'] != null
        ? DateTime.tryParse(response['thoigianketthuc'] as String)
        : null,
      totalQuestions: response['tongSoCau'] as int? ?? 0,
      status: response['trangthaiThi'] as String? ?? 'DangDienRa',
      resultId: response['ketQuaId'] as int?,
    );
  }

  /// Parse questions từ API response
  List<ExamQuestion> _parseQuestions(Map<String, dynamic> response) {
    final questionsData = response['questions'] as List<dynamic>? ?? [];
    return questionsData.map((q) => ExamQuestion.fromJson(q as Map<String, dynamic>)).toList();
  }

  /// chọn đáp án cho câu hỏi với real-time update như Vue.js
  Future<void> selectAnswer(int questionId, String answerId) async {
    final newAnswers = Map<int, String>.from(state.studentAnswers);
    newAnswers[questionId] = answerId;

    // cập nhật local state ngay lập tức
    state = state.copyWith(studentAnswers: newAnswers);
    debugPrint('📝 Selected answer $answerId for question $questionId');

    // gọi API update answer real-time như Vue.js
    if (state.ketQuaId != null) {
      try {
        // Tìm question để check loại câu hỏi
        final question = state.questions.firstWhere((q) => q.questionId == questionId);

        if (question.questionType == 'essay') {
          // Câu tự luận - gửi text
          await _apiService.updateExamAnswer(
            ketQuaId: state.ketQuaId!,
            macauhoi: questionId,
            dapantuluansv: answerId,
          );
        } else {
          // Câu trắc nghiệm - gửi ID đáp án
          await _apiService.updateExamAnswer(
            ketQuaId: state.ketQuaId!,
            macauhoi: questionId,
            macautl: int.parse(answerId),
          );
        }
        debugPrint('✅ Answer saved to server: Q$questionId -> A$answerId');
      } catch (e) {
        debugPrint('❌ Error saving answer to server: $e');
        // Note: Không throw error để không làm gián đoạn UX
        // Sinh viên vẫn có thể tiếp tục làm bài
      }
    } else {
      debugPrint('⚠️ No ketQuaId available, answer not saved to server');
    }
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

      debugPrint('🔄 Submitting exam...');

      // submit exam với API mới như Vue.js
      if (state.ketQuaId == null) {
        throw Exception('Missing ketQuaId - cannot submit exam');
      }

      // tính thời gian làm bài như Vue.js
      final endTime = DateTime.now();
      final thoiGianLamBai = endTime.difference(state.startTime!).inSeconds;

      debugPrint('   StartTime: ${state.startTime}');
      debugPrint('   EndTime: $endTime');
      debugPrint('   Duration: $thoiGianLamBai seconds');
      debugPrint('   KetQuaId: ${state.ketQuaId}');

      final result = await _apiService.submitExam(
        ketQuaId: state.ketQuaId!,
        examId: state.exam!.examId,
        thoiGianLamBai: thoiGianLamBai,
      );

      // tạo ExamResult từ response
      final user = _ref.read(currentUserProvider);
      final completedAt = DateTime.now();

      // Server trả về format: {KetQuaId, DiemThi, SoCauDung, TongSoCau}
      final examResult = ExamResult(
        resultId: result['ketQuaId'] ?? state.ketQuaId!,
        examId: state.exam!.examId,
        studentId: user?.id ?? '',
        score: (result['diemThi'] ?? 0.0).toDouble(),
        correctAnswers: result['soCauDung'] ?? 0,
        totalQuestions: result['tongSoCau'] ?? state.questions.length,
        startTime: state.startTime!,
        endTime: endTime,
        completedTime: completedAt,
      );

      // cập nhật state với kết quả
      _timer?.cancel();
      state = state.copyWith(
        isSubmitting: false,
        error: null, // clear any previous errors
        result: examResult, // lưu kết quả vào state
      );

      debugPrint('✅ Exam submitted successfully!');
      debugPrint('   Result: $result');
      debugPrint('   ExamResult: ${examResult.toString()}');
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
