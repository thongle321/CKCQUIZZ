import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ckcandr/models/exam_taking_model.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/models/de_thi_model.dart';

/// Provider cho quản lý việc làm bài thi của sinh viên
/// Hỗ trợ timer, auto-submit, và state management chuyên nghiệp

/// Notifier cho exam taking
class ExamTakingNotifier extends StateNotifier<ExamTakingState> {
  final ApiService _apiService;
  final Ref _ref;
  Timer? _timer;
  DateTime? _examStartTime;

  ExamTakingNotifier(this._apiService, this._ref) : super(const ExamTakingState());

  /// Lưu trạng thái exam vào local storage
  Future<void> _saveExamState() async {
    if (state.exam == null || state.ketQuaId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final examStateData = {
        'examId': state.exam!.examId,
        'ketQuaId': state.ketQuaId,
        'startTime': state.startTime?.toIso8601String(),
        'currentQuestionIndex': state.currentQuestionIndex,
        'studentAnswers': state.studentAnswers,
        'unfocusCount': 0, // Reset unfocus count on save
      };

      await prefs.setString('exam_state_${state.exam!.examId}', jsonEncode(examStateData));
      debugPrint('💾 Exam state saved for exam ${state.exam!.examId}');
    } catch (e) {
      debugPrint('❌ Error saving exam state: $e');
    }
  }

  /// Khôi phục trạng thái exam từ local storage
  Future<bool> _resumeExamState(int examId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString('exam_state_$examId');

      if (stateJson == null) return false;

      final stateData = jsonDecode(stateJson) as Map<String, dynamic>;
      final savedExamId = stateData['examId'] as int?;
      final ketQuaId = stateData['ketQuaId'] as int?;
      final startTimeStr = stateData['startTime'] as String?;

      if (savedExamId != examId || ketQuaId == null) return false;

      // Parse start time
      DateTime? startTime;
      if (startTimeStr != null) {
        startTime = DateTime.parse(startTimeStr);
      }

      debugPrint('🔄 Resuming exam state for exam $examId');
      debugPrint('   KetQuaId: $ketQuaId');
      debugPrint('   StartTime: $startTime');

      return true; // Có state để resume
    } catch (e) {
      debugPrint('❌ Error resuming exam state: $e');
      return false;
    }
  }

  /// Xóa trạng thái exam từ local storage
  Future<void> _clearExamState(int examId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('exam_state_$examId');
      debugPrint('🗑️ Exam state cleared for exam $examId');
    } catch (e) {
      debugPrint('❌ Error clearing exam state: $e');
    }
  }

  /// bắt đầu làm bài thi - Match Vue.js logic exactly
  Future<void> startExam(int examId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      debugPrint('🚀 Starting exam with ID: $examId');

      // Check if there's a saved exam state to resume
      final canResume = await _resumeExamState(examId);
      if (canResume) {
        debugPrint('🔄 Found saved exam state, attempting to resume...');
      }

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

      // khởi tạo state với dữ liệu cơ bản từ server
      state = state.copyWith(
        exam: examData,
        questions: questions,
        currentQuestionIndex: 0,
        studentAnswers: {},
        startTime: _examStartTime,
        timeRemaining: null, // Sẽ được tính toán trong _calculateExamEndTime
        isLoading: false,
        ketQuaId: ketQuaId, // lưu ketQuaId để dùng cho update answer và submit
      );

      // Tính toán thời gian kết thúc thông minh và start timer
      await _calculateExamEndTime();

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

    // Log thông tin ban đầu
    if (state.exam?.endTime != null) {
      final examEndTimeLocal = TimezoneHelper.toLocal(state.exam!.endTime!);
      final now = TimezoneHelper.nowInVietnam();
      debugPrint('⏰ Timer started:');
      debugPrint('   Current time (GMT+7): $now');
      debugPrint('   Exam end time (GMT+7): $examEndTimeLocal');
      debugPrint('   Time until exam ends: ${examEndTimeLocal.difference(now)}');
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Force check exam end time every tick - CRITICAL
      if (!_checkExamEndTime()) {
        return; // Exam ended, timer cancelled
      }

      // Kiểm tra hết thời gian làm bài (duration countdown) - PRIORITY 2

      // Kiểm tra hết thời gian làm bài (duration countdown) - PRIORITY 2
      if (state.timeRemaining != null && state.timeRemaining!.inSeconds > 0) {
        final newTimeRemaining = Duration(seconds: state.timeRemaining!.inSeconds - 1);
        state = state.copyWith(timeRemaining: newTimeRemaining);

        // cảnh báo khi còn 5 phút
        if (newTimeRemaining.inMinutes == 5 && newTimeRemaining.inSeconds == 0) {
          _showTimeWarning();
        }
      } else if (state.timeRemaining != null) {
        // hết thời gian làm bài, auto submit
        debugPrint('⏰ Exam duration ended, force submitting...');
        _autoSubmitExam(reason: 'Hết thời gian làm bài');
      }
    });
  }

  /// cảnh báo thời gian
  void _showTimeWarning() {
    debugPrint('⚠️ Time warning: 5 minutes remaining');
    // có thể emit event để UI hiển thị warning
  }

  /// Kiểm tra thời gian kết thúc exam - return false nếu đã hết thời gian
  bool _checkExamEndTime() {
    if (state.exam?.endTime == null) return true; // Không có end time, tiếp tục

    final now = TimezoneHelper.nowInVietnam();
    final examEndTimeLocal = TimezoneHelper.toLocal(state.exam!.endTime!);

    // Debug log mỗi 5 giây
    if (DateTime.now().second % 5 == 0) {
      debugPrint('⏰ Exam end time check:');
      debugPrint('   Current time (GMT+7): $now');
      debugPrint('   Exam end time (GMT+7): $examEndTimeLocal');
      debugPrint('   Time remaining: ${examEndTimeLocal.difference(now)}');
      debugPrint('   Is expired: ${now.isAfter(examEndTimeLocal)}');
    }

    if (now.isAfter(examEndTimeLocal) || now.isAtSameMomentAs(examEndTimeLocal)) {
      debugPrint('🚨 EXAM PERIOD ENDED - Auto submitting NOW!');
      debugPrint('   Current: $now');
      debugPrint('   End time: $examEndTimeLocal');
      debugPrint('   Diff (ms): ${now.millisecondsSinceEpoch - examEndTimeLocal.millisecondsSinceEpoch}');

      _autoSubmitExam(reason: 'Hết thời gian diễn ra bài thi');
      return false; // Exam ended
    }

    return true; // Exam still ongoing
  }

  /// auto submit khi hết thời gian
  Future<void> _autoSubmitExam({String? reason}) async {
    _timer?.cancel();
    debugPrint('⏰ Auto submitting exam: ${reason ?? "timeout"}');
    await submitExam(isAutoSubmit: true, autoSubmitReason: reason);
  }

  /// Parse exam data từ API response
  ExamForStudent _parseExamData(Map<String, dynamic> response, int examId) {
    // Debug log raw data
    debugPrint('🔍 Parsing exam data:');
    debugPrint('   Full response: $response');

    // API /Exam/{id} không trả về start/end time, cần lấy từ my-exams để có thông tin đầy đủ
    // Tạm thời return basic data, sẽ được update trong _calculateExamEndTime
    return ExamForStudent(
      examId: examId,
      examName: response['tende'] as String?,
      subjectName: response['tenMonHoc'] as String?,
      duration: response['thoigianthi'] as int?,
      startTime: null, // Sẽ được set trong _calculateExamEndTime
      endTime: null, // Sẽ được tính toán trong _calculateExamEndTime
      totalQuestions: response['tongSoCau'] as int? ?? 0,
      status: 'DangDienRa',
      resultId: null,
    );
  }

  /// Tính toán thời gian kết thúc bài thi thông minh
  /// Logic: Chọn thời gian nào đến trước giữa:
  /// 1. Thời gian kết thúc lịch thi (endTime từ giáo viên)
  /// 2. Thời gian bắt đầu + duration (thời gian cho phép làm bài)
  Future<void> _calculateExamEndTime() async {
    if (state.exam == null) return;

    try {
      // Lấy thông tin đầy đủ từ my-exams
      final exams = await _apiService.getMyExams();
      final examInfo = exams.firstWhere(
        (exam) => exam.examId == state.exam!.examId,
        orElse: () => throw Exception('Exam not found in my-exams'),
      );

      final now = TimezoneHelper.nowInVietnam();
      final startTime = _examStartTime ?? now; // Thời gian bắt đầu làm bài

      // Thời gian kết thúc theo lịch thi (từ giáo viên)
      DateTime? scheduleEndTime;
      if (examInfo.endTime != null) {
        scheduleEndTime = TimezoneHelper.toLocal(examInfo.endTime!);
      }

      // Thời gian kết thúc theo duration (thời gian cho phép làm bài)
      DateTime? durationEndTime;
      if (state.exam!.duration != null) {
        durationEndTime = startTime.add(Duration(minutes: state.exam!.duration!));
      }

      debugPrint('🧮 Calculating exam end time:');
      debugPrint('   Start time: $startTime');
      debugPrint('   Schedule end time: $scheduleEndTime');
      debugPrint('   Duration end time: $durationEndTime');

      // Chọn thời gian nào đến trước
      DateTime finalEndTime;
      String endTimeReason;

      if (scheduleEndTime != null && durationEndTime != null) {
        if (scheduleEndTime.isBefore(durationEndTime)) {
          finalEndTime = scheduleEndTime;
          endTimeReason = 'schedule end time (earlier than duration)';
        } else {
          finalEndTime = durationEndTime;
          endTimeReason = 'duration end time (earlier than schedule)';
        }
      } else if (scheduleEndTime != null) {
        finalEndTime = scheduleEndTime;
        endTimeReason = 'schedule end time (no duration)';
      } else if (durationEndTime != null) {
        finalEndTime = durationEndTime;
        endTimeReason = 'duration end time (no schedule)';
      } else {
        // Fallback: 1 giờ từ bây giờ
        finalEndTime = now.add(const Duration(hours: 1));
        endTimeReason = 'fallback (1 hour from now)';
      }

      debugPrint('   Final end time: $finalEndTime ($endTimeReason)');

      // Update exam với thời gian đã tính toán
      final updatedExam = ExamForStudent(
        examId: state.exam!.examId,
        examName: state.exam!.examName,
        subjectName: state.exam!.subjectName,
        duration: state.exam!.duration,
        startTime: TimezoneHelper.toUtc(startTime),
        endTime: TimezoneHelper.toUtc(finalEndTime),
        totalQuestions: state.exam!.totalQuestions,
        status: state.exam!.status,
        resultId: state.exam!.resultId,
      );

      // Tính toán thời gian còn lại
      Duration? timeRemaining;

      if (finalEndTime.isAfter(now)) {
        timeRemaining = finalEndTime.difference(now);
        debugPrint('   Time remaining: $timeRemaining');
      } else {
        timeRemaining = Duration.zero;
        debugPrint('   ⚠️ Exam time already expired!');
      }

      // Update state với exam đã có thời gian và time remaining
      state = state.copyWith(
        exam: updatedExam,
        timeRemaining: timeRemaining,
      );

      // Kiểm tra ngay xem có hết thời gian chưa
      if (timeRemaining.inSeconds <= 0) {
        debugPrint('⏰ Exam time expired immediately - auto submitting');
        _autoSubmitExam(reason: 'Hết thời gian diễn ra bài thi');
        return;
      }

      // Start timer với thời gian đã tính toán
      _startTimer();

    } catch (e) {
      debugPrint('❌ Error calculating exam end time: $e');
      // Fallback: sử dụng duration hoặc 1 giờ
      final now = TimezoneHelper.nowInVietnam();
      final fallbackDuration = state.exam!.duration ?? 60; // 60 phút mặc định
      final fallbackEndTime = now.add(Duration(minutes: fallbackDuration));

      final updatedExam = ExamForStudent(
        examId: state.exam!.examId,
        examName: state.exam!.examName,
        subjectName: state.exam!.subjectName,
        duration: state.exam!.duration,
        startTime: TimezoneHelper.toUtc(now),
        endTime: TimezoneHelper.toUtc(fallbackEndTime),
        totalQuestions: state.exam!.totalQuestions,
        status: state.exam!.status,
        resultId: state.exam!.resultId,
      );

      final timeRemaining = fallbackEndTime.difference(now);

      state = state.copyWith(
        exam: updatedExam,
        timeRemaining: timeRemaining,
      );

      _startTimer();
    }
  }

  /// Parse questions từ API response
  List<ExamQuestion> _parseQuestions(Map<String, dynamic> response) {
    final questionsData = response['questions'] as List<dynamic>? ?? [];
    return questionsData.map((q) => ExamQuestion.fromJson(q as Map<String, dynamic>)).toList();
  }

  // Map để lưu trữ câu trả lời chưa được lưu
  final Map<int, Map<String, dynamic>> _pendingAnswers = {};

  /// Chọn đáp án cho câu hỏi (chỉ cập nhật local state)
  void selectAnswer(int questionId, String answerId) {
    // Kiểm tra exam end time trước khi cho phép select answer
    if (!_checkExamEndTime()) {
      return; // Exam đã hết thời gian, không cho phép select
    }

    final newAnswers = Map<int, String>.from(state.studentAnswers);
    newAnswers[questionId] = answerId;

    // Cập nhật local state ngay lập tức
    state = state.copyWith(studentAnswers: newAnswers);

    // Lưu vào pending để gửi API sau
    final question = state.questions.firstWhere((q) => q.questionId == questionId);
    _pendingAnswers[questionId] = {
      'answerId': answerId,
      'questionType': question.questionType,
      'timestamp': DateTime.now(),
    };

    debugPrint('📝 Selected answer $answerId for question $questionId (pending save)');

    // Lưu state sau khi update answer
    _saveExamState();
  }

  /// Lưu câu trả lời hiện tại lên server
  Future<void> saveCurrentAnswer() async {
    if (state.ketQuaId == null || _pendingAnswers.isEmpty) return;

    final currentQuestionId = state.questions[state.currentQuestionIndex].questionId;
    final pendingAnswer = _pendingAnswers[currentQuestionId];

    if (pendingAnswer == null) return;

    // Set saving state
    state = state.copyWith(isSaving: true);

    try {
      debugPrint('💾 Saving answer for question $currentQuestionId to server...');

      final questionType = pendingAnswer['questionType'] as String;
      final answerId = pendingAnswer['answerId'] as String;

      if (questionType == 'essay') {
        // Câu tự luận - gửi text
        await _apiService.updateExamAnswer(
          ketQuaId: state.ketQuaId!,
          macauhoi: currentQuestionId,
          dapantuluansv: answerId,
        );
      } else if (questionType == 'multiple_choice') {
        // Câu nhiều đáp án - xử lý từng đáp án
        await _saveMultipleChoiceAnswer(currentQuestionId, answerId);
      } else {
        // Câu một đáp án - gửi ID đáp án
        await _apiService.updateExamAnswer(
          ketQuaId: state.ketQuaId!,
          macauhoi: currentQuestionId,
          macautl: int.parse(answerId),
        );
      }

      // Xóa khỏi pending sau khi lưu thành công
      _pendingAnswers.remove(currentQuestionId);
      debugPrint('✅ Answer saved successfully for question $currentQuestionId');

    } catch (e) {
      debugPrint('❌ Error saving answer to server: $e');
      // Giữ lại trong pending để thử lại sau
    } finally {
      // Clear saving state
      state = state.copyWith(isSaving: false);
    }
  }

  /// Xử lý lưu câu trả lời nhiều đáp án
  Future<void> _saveMultipleChoiceAnswer(int questionId, String selectedAnswerIds) async {
    final question = state.questions.firstWhere((q) => q.questionId == questionId);
    final selectedIds = selectedAnswerIds.split(',').where((id) => id.isNotEmpty).map(int.parse).toSet();

    // Lưu từng đáp án (set dapansv = 1 cho đã chọn, 0 cho chưa chọn)
    for (final answer in question.answers) {
      final isSelected = selectedIds.contains(answer.answerId);
      await _apiService.updateExamAnswer(
        ketQuaId: state.ketQuaId!,
        macauhoi: questionId,
        macautl: answer.answerId,
        dapansv: isSelected ? 1 : 0,
      );
    }
  }

  /// Lưu tất cả câu trả lời pending
  Future<void> _saveAllPendingAnswers() async {
    if (state.ketQuaId == null || _pendingAnswers.isEmpty) return;

    debugPrint('💾 Saving ${_pendingAnswers.length} pending answers...');

    final List<Future<void>> saveTasks = [];

    for (final entry in _pendingAnswers.entries) {
      final questionId = entry.key;
      final pendingAnswer = entry.value;

      saveTasks.add(_savePendingAnswer(questionId, pendingAnswer));
    }

    // Lưu tất cả đồng thời
    await Future.wait(saveTasks);

    // Xóa tất cả pending sau khi lưu
    _pendingAnswers.clear();
    debugPrint('✅ All pending answers saved');
  }

  /// Lưu một câu trả lời pending cụ thể
  Future<void> _savePendingAnswer(int questionId, Map<String, dynamic> pendingAnswer) async {
    try {
      final questionType = pendingAnswer['questionType'] as String;
      final answerId = pendingAnswer['answerId'] as String;

      if (questionType == 'essay') {
        await _apiService.updateExamAnswer(
          ketQuaId: state.ketQuaId!,
          macauhoi: questionId,
          dapantuluansv: answerId,
        );
      } else if (questionType == 'multiple_choice') {
        await _saveMultipleChoiceAnswer(questionId, answerId);
      } else {
        await _apiService.updateExamAnswer(
          ketQuaId: state.ketQuaId!,
          macauhoi: questionId,
          macautl: int.parse(answerId),
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving pending answer for question $questionId: $e');
      rethrow; // Re-throw để Future.wait có thể catch
    }
  }

  /// chuyển đến câu hỏi tiếp theo
  Future<void> nextQuestion() async {
    // Lưu câu trả lời hiện tại trước khi chuyển
    await saveCurrentAnswer();

    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  /// quay lại câu hỏi trước
  Future<void> previousQuestion() async {
    // Lưu câu trả lời hiện tại trước khi chuyển
    await saveCurrentAnswer();

    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  /// chuyển đến câu hỏi cụ thể
  Future<void> goToQuestion(int index) async {
    // Lưu câu trả lời hiện tại trước khi chuyển
    await saveCurrentAnswer();

    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentQuestionIndex: index);
    }
  }

  /// submit bài thi
  Future<void> submitExam({bool isAutoSubmit = false, String? autoSubmitReason}) async {
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

      // Lưu tất cả câu trả lời pending trước khi submit
      await _saveAllPendingAnswers();

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
        autoSubmitReason: isAutoSubmit ? autoSubmitReason : null, // lưu lý do auto submit
      );

      debugPrint('✅ Exam submitted successfully!');
      debugPrint('   Result: $result');
      debugPrint('   ExamResult: ${examResult.toString()}');

      // Clear saved exam state after successful submission
      if (state.exam?.examId != null) {
        await _clearExamState(state.exam!.examId);
      }
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

  /// Increment unfocus count và check auto submit
  Future<bool> incrementUnfocusCount() async {
    const maxUnfocusCount = 2; // Cho phép 2 lần, lần 3 sẽ auto submit

    // Increment count (sẽ được lưu vào local storage)
    final currentCount = await _getUnfocusCount() + 1;
    await _saveUnfocusCount(currentCount);

    debugPrint('⚠️ Unfocus count: $currentCount/$maxUnfocusCount');

    if (currentCount > maxUnfocusCount) {
      // Auto submit
      await submitExam(
        isAutoSubmit: true,
        autoSubmitReason: 'Vi phạm quy định thi (rời khỏi ứng dụng quá nhiều lần)'
      );
      return true; // Đã auto submit
    }

    return false; // Chưa auto submit
  }

  /// Lấy unfocus count từ local storage
  Future<int> _getUnfocusCount() async {
    if (state.exam?.examId == null) return 0;

    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('unfocus_count_${state.exam!.examId}') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Lưu unfocus count vào local storage
  Future<void> _saveUnfocusCount(int count) async {
    if (state.exam?.examId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unfocus_count_${state.exam!.examId}', count);
    } catch (e) {
      debugPrint('❌ Error saving unfocus count: $e');
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
