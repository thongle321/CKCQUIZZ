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
  int? _resumedKetQuaId; // Lưu ketQuaId khi resume session

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

  /// Khôi phục trạng thái exam từ local storage (như Vue.js sessionStorage)
  Future<bool> _resumeExamState(int examId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ketQuaIdKey = 'exam-$examId-ketQuaId';
      final startTimeKey = 'exam-$examId-startTime';

      final storedKetQuaId = prefs.getString(ketQuaIdKey);
      final storedStartTime = prefs.getString(startTimeKey);

      if (storedKetQuaId == null || storedStartTime == null) {
        debugPrint('🔍 No saved exam session found for exam $examId');
        return false;
      }

      final ketQuaId = int.tryParse(storedKetQuaId);
      final startTime = DateTime.tryParse(storedStartTime);

      if (ketQuaId == null || startTime == null) {
        debugPrint('❌ Invalid saved exam session data');
        return false;
      }

      debugPrint('🔄 Found saved exam session for exam $examId');
      debugPrint('   KetQuaId: $ketQuaId');
      debugPrint('   StartTime: $startTime');

      // Kiểm tra exam có còn trong thời gian làm bài không (như Vue.js)
      try {
        final examDetail = await _getExamById(examId);
        if (examDetail != null) {
          final now = DateTime.now();
          final endTime = examDetail.endTime;

          if (endTime != null && now.isAfter(endTime)) {
            debugPrint('⏰ Exam time expired, clearing session...');
            await prefs.remove(ketQuaIdKey);
            await prefs.remove(startTimeKey);
            return false;
          }
        }
      } catch (e) {
        debugPrint('⚠️ Could not check exam time: $e');
        // Continue anyway for backward compatibility
      }

      // Kiểm tra số lần vi phạm từ API trước khi cho phép tiếp tục
      try {
        final response = await _apiService.tangSoLanChuyenTab(ketQuaId);
        debugPrint('📊 Current violation count: ${response.soLanHienTai}/${response.gioiHan}');

        if (response.nopBai) {
          debugPrint('🚨 Too many violations - exam should be auto-submitted');
          // Clear saved session
          await prefs.remove(ketQuaIdKey);
          await prefs.remove(startTimeKey);
          return false;
        }
      } catch (e) {
        debugPrint('⚠️ Could not check violation count: $e');
        // Continue anyway for backward compatibility
      }

      // Store for later use
      _examStartTime = startTime;
      _resumedKetQuaId = ketQuaId;

      return true; // Có state để resume
    } catch (e) {
      debugPrint('❌ Error resuming exam state: $e');
      return false;
    }
  }

  /// Load existing answers từ server (như Vue.js load saved answers)
  Future<Map<int, String>> _loadExistingAnswersFromServer(int ketQuaId) async {
    try {
      debugPrint('📥 Loading existing answers from server for ketQuaId: $ketQuaId');

      // Gọi API để lấy existing answers từ ChiTietTraLoiSinhVien
      final response = await _apiService.getExamDetails(state.exam?.examId ?? 0);

      // Parse existing answers từ response
      final Map<int, String> existingAnswers = {};

      if (response['questions'] != null) {
        final questions = response['questions'] as List;
        for (final question in questions) {
          final questionId = question['macauhoi'] as int?;
          final selectedAnswerId = question['selectedAnswerId'] as int?;

          if (questionId != null && selectedAnswerId != null) {
            existingAnswers[questionId] = selectedAnswerId.toString();
            debugPrint('📝 Found existing answer: Q$questionId -> A$selectedAnswerId');
          }
        }
      }

      debugPrint('✅ Loaded ${existingAnswers.length} existing answers from server');
      return existingAnswers;
    } catch (e) {
      debugPrint('❌ Error loading existing answers: $e');
      return {};
    }
  }

  /// Lưu session info (như Vue.js sessionStorage)
  Future<void> _saveSessionInfo(int examId, int ketQuaId, DateTime startTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('exam-$examId-ketQuaId', ketQuaId.toString());
      await prefs.setString('exam-$examId-startTime', startTime.toIso8601String());
      debugPrint('💾 Session info saved for exam $examId');
    } catch (e) {
      debugPrint('❌ Error saving session info: $e');
    }
  }

  /// Xóa session info (như Vue.js sessionStorage.removeItem)
  Future<void> _clearSessionInfo(int examId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('exam-$examId-ketQuaId');
      await prefs.remove('exam-$examId-startTime');
      debugPrint('🗑️ Session info cleared for exam $examId');
    } catch (e) {
      debugPrint('❌ Error clearing session info: $e');
    }
  }

  /// Load existing answers khi resume session (như Vue.js)
  Future<void> _loadExistingAnswers(int ketQuaId) async {
    try {
      debugPrint('🔄 Loading existing answers for ketQuaId: $ketQuaId');

      // Gọi API để lấy answers đã save (sử dụng API trả về raw data)
      final resultData = await _apiService.getExamResultDetails(ketQuaId);

      if (resultData.isNotEmpty) {
        final questions = resultData['questions'] as List<dynamic>? ?? [];
        final Map<int, String> loadedAnswers = {};

        for (final questionData in questions) {
          final questionId = questionData['macauhoi'] as int;
          final questionType = questionData['loaicauhoi'] as String? ?? 'single_choice';

          if (questionType == 'multiple_choice') {
            // Multiple choice - get selected answer IDs
            final selectedIds = (questionData['studentSelectedAnswerIds'] as List<dynamic>?)
                ?.map((id) => id.toString()).toList() ?? [];
            if (selectedIds.isNotEmpty) {
              loadedAnswers[questionId] = selectedIds.join(',');
            }
          } else if (questionType == 'essay') {
            // Essay - get text answer
            final essayAnswer = questionData['studentAnswerText'] as String? ?? '';
            if (essayAnswer.isNotEmpty) {
              loadedAnswers[questionId] = essayAnswer;
            }
          } else {
            // Single choice - get selected answer ID
            final selectedId = questionData['studentSelectedAnswerId'] as int?;
            if (selectedId != null) {
              loadedAnswers[questionId] = selectedId.toString();
            }
          }
        }

        // Update state with loaded answers
        state = state.copyWith(studentAnswers: loadedAnswers);
        debugPrint('✅ Loaded ${loadedAnswers.length} existing answers');

        // Debug log loaded answers
        loadedAnswers.forEach((questionId, answer) {
          debugPrint('   Question $questionId: $answer');
        });
      } else {
        debugPrint('📝 No existing answers found');
      }
    } catch (e) {
      debugPrint('❌ Error loading existing answers: $e');
      // Continue without existing answers
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
    state = state.copyWith(
      isLoading: true,
      error: null,
      unfocusCount: 0, // Reset unfocus count khi bắt đầu thi
      unfocusMessage: null,
    );

    try {
      debugPrint('🚀 Starting exam with ID: $examId');

      // Check if there's a saved exam state to resume
      final canResume = await _resumeExamState(examId);
      if (canResume) {
        debugPrint('🔄 Found saved exam state, attempting to resume...');

        // Check if exam was already submitted
        if (_resumedKetQuaId != null) {
          final examDetail = await _apiService.getStudentExamResult(_resumedKetQuaId!);
          if (examDetail != null && examDetail['isSubmitted'] == true) {
            debugPrint('✅ Exam already submitted, loading review mode');
            await _loadSubmittedExamForReview(examId, _resumedKetQuaId!);
            return;
          }
        }
      }

      // Step 1: Start exam hoặc resume session (như Vue.js)
      int ketQuaId;

      if (canResume && _resumedKetQuaId != null) {
        // Resume existing session
        ketQuaId = _resumedKetQuaId!;
        debugPrint('🔄 Resuming with existing KetQuaId: $ketQuaId');
        // _examStartTime đã được set trong _resumeExamState
      } else {
        // Start new exam session
        final startResponse = await _apiService.startExam(examId);
        if (startResponse.isEmpty) {
          throw Exception('Không nhận được phản hồi từ server khi bắt đầu bài thi');
        }

        final newKetQuaId = startResponse['ketQuaId'] as int?;
        final thoigianbatdauStr = startResponse['thoigianbatdau'] as String?;

        if (newKetQuaId == null) {
          throw Exception('Không nhận được mã kết quả từ server');
        }

        ketQuaId = newKetQuaId;

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

        // Save session info (như Vue.js sessionStorage)
        await _saveSessionInfo(examId, ketQuaId, _examStartTime!);
      }

      debugPrint('✅ Exam session ready. KetQuaId: $ketQuaId, StartTime: $_examStartTime');

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

      // Step 3: Load existing answers nếu resume (như Vue.js load saved answers)
      Map<int, String> existingAnswers = {};
      if (canResume && _resumedKetQuaId != null) {
        debugPrint('🔄 Loading existing answers for resumed exam...');
        existingAnswers = await _loadExistingAnswersFromServer(ketQuaId);
        debugPrint('✅ Loaded ${existingAnswers.length} existing answers');
      }

      // khởi tạo state với dữ liệu cơ bản từ server
      state = state.copyWith(
        exam: examData,
        questions: questions,
        currentQuestionIndex: 0,
        studentAnswers: existingAnswers, // Load existing answers nếu resume
        startTime: _examStartTime,
        timeRemaining: null, // Sẽ được tính toán trong _calculateExamEndTime
        isLoading: false,
        ketQuaId: ketQuaId, // lưu ketQuaId để dùng cho update answer và submit
      );

      // Load existing answers nếu resume session (như Vue.js)
      if (canResume) {
        await _loadExistingAnswers(ketQuaId);
      }

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

  /// bắt đầu timer đếm ngược - Cập nhật theo phút thực tế như Vue.js
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

    // Timer chính chạy mỗi giây để kiểm tra exam end time (critical)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Force check exam end time every tick - CRITICAL
      if (!_checkExamEndTime()) {
        return; // Exam ended, timer cancelled
      }

      // Kiểm tra hết thời gian làm bài (duration countdown) - PRIORITY 2
      if (state.timeRemaining != null && state.timeRemaining!.inSeconds > 0) {
        final newTimeRemaining = Duration(seconds: state.timeRemaining!.inSeconds - 1);
        state = state.copyWith(timeRemaining: newTimeRemaining);

        // cảnh báo khi còn 5 phút
        if (newTimeRemaining.inMinutes == 5 && newTimeRemaining.inSeconds == 0) {
          _showTimeWarning();
        }

        // cảnh báo khi còn 1 phút
        if (newTimeRemaining.inMinutes == 1 && newTimeRemaining.inSeconds == 0) {
          _showTimeWarning();
        }
      } else if (state.timeRemaining != null) {
        // hết thời gian làm bài, auto submit
        debugPrint('⏰ Exam duration ended, force submitting...');
        _autoSubmitExam(reason: 'Hết thời gian làm bài');
      }
    });

    // Timer phụ để cập nhật UI theo phút thực tế (như Vue.js)
    _startMinuteTimer();
  }

  /// Timer phụ để cập nhật UI theo phút thực tế (như Vue.js)
  Timer? _minuteTimer;

  void _startMinuteTimer() {
    _minuteTimer?.cancel();

    // Tính toán thời gian đến phút tiếp theo
    final now = DateTime.now();
    final secondsToNextMinute = 60 - now.second;

    // Đợi đến phút tiếp theo, sau đó chạy timer mỗi phút
    Timer(Duration(seconds: secondsToNextMinute), () {
      _updateTimeDisplay(); // Cập nhật lần đầu

      // Sau đó cập nhật mỗi phút
      _minuteTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        _updateTimeDisplay();
      });
    });
  }

  /// Cập nhật hiển thị thời gian theo phút thực tế
  void _updateTimeDisplay() {
    if (state.timeRemaining != null) {
      // Force rebuild UI để cập nhật hiển thị thời gian
      state = state.copyWith(timeRemaining: state.timeRemaining);
      debugPrint('⏰ Minute timer update: ${state.timeRemaining?.inMinutes} minutes remaining');
    }
  }

  /// cảnh báo thời gian
  void _showTimeWarning() {
    final minutes = state.timeRemaining?.inMinutes ?? 0;
    debugPrint('⚠️ Time warning: $minutes minutes remaining');
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

  /// Chọn đáp án cho câu hỏi và lưu realtime (như Vue.js)
  void selectAnswer(int questionId, String answerId) {
    // Kiểm tra exam end time trước khi cho phép select answer
    if (!_checkExamEndTime()) {
      return; // Exam đã hết thời gian, không cho phép select
    }

    final newAnswers = Map<int, String>.from(state.studentAnswers);
    newAnswers[questionId] = answerId;

    // Cập nhật local state ngay lập tức
    state = state.copyWith(studentAnswers: newAnswers);

    debugPrint('📝 Selected answer $answerId for question $questionId - saving realtime...');

    // Lưu state sau khi update answer
    _saveExamState();

    // Realtime save ngay lập tức (như Vue.js)
    _saveAnswerRealtime(questionId, answerId);
  }

  /// Lưu câu trả lời realtime ngay lập tức (như Vue.js)
  Future<void> _saveAnswerRealtime(int questionId, String answerId) async {
    if (state.ketQuaId == null) {
      debugPrint('❌ Cannot save answer: ketQuaId is null');
      return;
    }

    // Set saving state
    state = state.copyWith(isSaving: true);

    try {
      final question = state.questions.firstWhere((q) => q.questionId == questionId);

      if (question.questionType == 'essay') {
        // Câu tự luận - gửi text
        await _apiService.updateExamAnswer(
          ketQuaId: state.ketQuaId!,
          macauhoi: questionId,
          dapantuluansv: answerId,
        );
        debugPrint('✅ Essay answer saved for question $questionId');
      } else if (question.questionType == 'multiple_choice') {
        // Câu nhiều đáp án - xử lý từng đáp án
        await _saveMultipleChoiceAnswerRealtime(questionId, answerId);
        debugPrint('✅ Multiple choice answer saved for question $questionId');
      } else {
        // Câu đơn - gửi đáp án đã chọn
        await _apiService.updateExamAnswer(
          ketQuaId: state.ketQuaId!,
          macauhoi: questionId,
          macautl: int.parse(answerId),
          dapansv: 1,
        );
        debugPrint('✅ Single choice answer saved for question $questionId');
      }
    } catch (e) {
      debugPrint('❌ Error saving answer realtime: $e');
      // Không hiển thị error cho user để không làm gián đoạn trải nghiệm
    } finally {
      // Clear saving state
      state = state.copyWith(isSaving: false);
    }
  }

  /// Lưu câu trả lời multiple choice realtime
  Future<void> _saveMultipleChoiceAnswerRealtime(int questionId, String selectedAnswers) async {
    final question = state.questions.firstWhere((q) => q.questionId == questionId);
    final selectedIds = selectedAnswers.split(',').where((id) => id.isNotEmpty).toList();

    // Gửi từng đáp án
    for (final answer in question.answers) {
      final isSelected = selectedIds.contains(answer.answerId.toString());
      await _apiService.updateExamAnswer(
        ketQuaId: state.ketQuaId!,
        macauhoi: questionId,
        macautl: answer.answerId,
        dapansv: isSelected ? 1 : 0,
      );
    }
  }

  /// Lưu câu trả lời hiện tại lên server (legacy method)
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

      // Clear saved exam state and session info after successful submission (như Vue.js)
      if (state.exam?.examId != null) {
        await _clearExamState(state.exam!.examId);
        await _clearSessionInfo(state.exam!.examId);
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

  /// Increment unfocus count - CLIENT-SIDE AUTO SUBMIT
  Future<bool> incrementUnfocusCount() async {
    if (state.ketQuaId == null) {
      debugPrint('❌ Không có ketQuaId để gửi unfocus');
      return false;
    }

    // CLIENT-SIDE: Increment ngay lập tức
    final newCount = state.unfocusCount + 1;
    debugPrint('📱 CLIENT UNFOCUS: ${state.unfocusCount} → $newCount');

    // Update state ngay lập tức
    state = state.copyWith(
      unfocusCount: newCount,
      unfocusMessage: 'Bạn đã thoát ứng dụng $newCount/5 lần. Vui lòng không thoát ứng dụng để tránh vi phạm.',
    );

    debugPrint('✅ State updated - unfocusCount: ${state.unfocusCount}');

    // CLIENT-SIDE AUTO SUBMIT sau 5 lần
    if (newCount >= 5) {
      debugPrint('🚨 CLIENT AUTO SUBMIT - Đã thoát $newCount lần!');

      // Nộp bài ngay lập tức
      await submitExam(
        isAutoSubmit: true,
        autoSubmitReason: 'Tự động nộp bài do thoát ứng dụng quá 5 lần ($newCount/5)'
      );

      return true; // Đã auto submit
    }

    // Background sync với server (không chờ)
    _syncWithServerInBackground();

    debugPrint('✅ Client unfocus count: $newCount/5');
    return false; // Chưa auto submit
  }

  /// Background sync với server (không ảnh hưởng client logic)
  void _syncWithServerInBackground() async {
    if (state.ketQuaId == null) return;

    try {
      debugPrint('🔄 Background sync với server...');
      await _apiService.tangSoLanChuyenTab(state.ketQuaId!);
      debugPrint('✅ Background sync thành công');
    } catch (e) {
      debugPrint('⚠️ Background sync failed: $e');
      // Không ảnh hưởng client logic
    }
  }



  /// Load submitted exam for review mode (khi user đã nộp bài)
  Future<void> _loadSubmittedExamForReview(int examId, int ketQuaId) async {
    try {
      debugPrint('📖 Loading submitted exam for review...');

      // Get exam details
      final examDetailsResponse = await _apiService.getExamDetails(examId);
      final examData = _parseExamData(examDetailsResponse, examId);
      final questions = _parseQuestions(examDetailsResponse);

      // Get submitted answers from server
      final examResult = await _apiService.getStudentExamResult(ketQuaId);
      Map<int, String> submittedAnswers = {};

      if (examResult != null && examResult['answers'] != null) {
        final answers = examResult['answers'] as List;
        for (final answer in answers) {
          final questionId = answer['questionId'] as int?;
          final selectedAnswer = answer['selectedAnswer'] as String?;
          if (questionId != null && selectedAnswer != null) {
            submittedAnswers[questionId] = selectedAnswer;
          }
        }
      }

      // Set state for review mode
      state = state.copyWith(
        exam: examData,
        questions: questions,
        studentAnswers: submittedAnswers,
        ketQuaId: ketQuaId,
        isLoading: false,
        isSubmitted: true, // Review mode
        currentQuestionIndex: 0,
        timeRemaining: Duration.zero, // No time remaining
      );

      debugPrint('✅ Submitted exam loaded for review: ${submittedAnswers.length} answers');
    } catch (e) {
      debugPrint('❌ Error loading submitted exam: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải bài làm đã nộp: $e',
      );
    }
  }

  /// Lấy unfocus count hiện tại (public method) - SỬA: Trả về từ state thay vì local storage
  Future<int> getCurrentUnfocusCount() async {
    return state.unfocusCount;
  }

  /// Force refresh unfocus count từ server (debug purpose)
  Future<void> refreshUnfocusCountFromServer() async {
    if (state.ketQuaId == null) {
      debugPrint('❌ Không có ketQuaId để refresh unfocus count');
      return;
    }

    try {
      debugPrint('🔄 Refreshing unfocus count from server...');

      // Gọi API để lấy current count (không increment)
      // TODO: Implement API to get current count without incrementing
      // For now, we rely on the state from previous API calls

      debugPrint('✅ Current unfocus count: ${state.unfocusCount}');
    } catch (e) {
      debugPrint('❌ Error refreshing unfocus count: $e');
    }
  }

  /// reset state
  void reset() {
    _timer?.cancel();
    _minuteTimer?.cancel();
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
