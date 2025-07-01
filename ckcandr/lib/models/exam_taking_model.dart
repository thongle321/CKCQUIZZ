import 'package:json_annotation/json_annotation.dart';

part 'exam_taking_model.g.dart';

/// Model cho việc làm bài thi của sinh viên
/// Bao gồm thông tin đề thi, câu hỏi và đáp án

/// Thông tin đề thi cho sinh viên (mapping với ExamForClassDto từ backend)
@JsonSerializable()
class ExamForStudent {
  @JsonKey(name: 'made')
  final int examId;

  @JsonKey(name: 'tende')
  final String? examName;

  @JsonKey(name: 'tenMonHoc')
  final String? subjectName;

  @JsonKey(name: 'thoigianthi')
  final int? duration; // thời gian thi (phút)

  @JsonKey(name: 'thoigiantbatdau')
  final DateTime? startTime;

  @JsonKey(name: 'thoigianketthuc')
  final DateTime? endTime;

  @JsonKey(name: 'tongSoCau')
  final int totalQuestions;

  @JsonKey(name: 'trangthaiThi')
  final String status; // SapDienRa, DangDienRa, DaKetThuc

  @JsonKey(name: 'ketQuaId')
  final int? resultId; // null nếu chưa thi

  // Các field này không có trong backend DTO, set default
  final bool? showExamPaper;
  final bool? showScore;
  final bool? showAnswers;

  const ExamForStudent({
    required this.examId,
    this.examName,
    this.subjectName,
    this.duration,
    this.startTime,
    this.endTime,
    required this.totalQuestions,
    required this.status,
    this.resultId,
    this.showExamPaper,
    this.showScore,
    this.showAnswers,
  });

  factory ExamForStudent.fromJson(Map<String, dynamic> json) => _$ExamForStudentFromJson(json);
  Map<String, dynamic> toJson() => _$ExamForStudentToJson(this);

  /// kiểm tra có thể vào thi không
  bool get canTakeExam {
    if (startTime == null || endTime == null) return false;
    final now = DateTime.now();

    // Cho phép vào thi trước 5 phút và sau khi kết thúc 5 phút (giống backend)
    final allowedStartTime = startTime!.subtract(const Duration(minutes: 5));
    final allowedEndTime = endTime!.add(const Duration(minutes: 5));

    print('🕐 Flutter Time check - Now: $now');
    print('🕐 Allowed time: $allowedStartTime - $allowedEndTime');
    print('🕐 Status: $status, ResultId: $resultId');

    // Cho phép vào thi nếu trong thời gian hợp lệ và chưa thi (bỏ qua status)
    final timeIsValid = now.isAfter(allowedStartTime) && now.isBefore(allowedEndTime);
    final notTakenYet = resultId == null;

    print('🕐 Time valid: $timeIsValid, Not taken: $notTakenYet');

    return timeIsValid && notTakenYet;
  }

  /// kiểm tra đã hết hạn chưa
  bool get isExpired {
    if (endTime == null) return false;
    return status == 'DaKetThuc' || DateTime.now().isAfter(endTime!);
  }

  /// thời gian còn lại để thi
  Duration? get timeRemaining {
    if (status != 'DangDienRa' || endTime == null) return null;
    final now = DateTime.now();
    if (now.isBefore(endTime!)) {
      return endTime!.difference(now);
    }
    return null;
  }
}

/// Câu hỏi trong bài thi
@JsonSerializable()
class ExamQuestion {
  @JsonKey(name: 'macauhoi')
  final int questionId;

  @JsonKey(name: 'noidung')  // SỬA: match với server response
  final String content;

  @JsonKey(name: 'dokho')  // SỬA: match với server response (có thể là lowercase)
  final String? difficulty; // De, TrungBinh, Kho - nullable để tránh lỗi

  @JsonKey(name: 'hinhanhurl')  // SỬA: match với server response
  final String? imageUrl;

  @JsonKey(name: 'loaicauhoi')  // SỬA: match với server response
  final String questionType; // single_choice, multiple_choice, essay, etc.

  @JsonKey(name: 'answers')  // SỬA: match với server response
  final List<ExamAnswer> answers;

  // local state cho việc làm bài
  final String? selectedAnswerId;
  final List<String>? selectedAnswerIds; // For multiple choice
  final String? essayAnswer; // For essay questions
  final bool isAnswered;

  const ExamQuestion({
    required this.questionId,
    required this.content,
    this.difficulty,  // SỬA: nullable để tránh lỗi khi server không trả về
    this.imageUrl,
    required this.questionType,
    required this.answers,
    this.selectedAnswerId,
    this.selectedAnswerIds,
    this.essayAnswer,
    this.isAnswered = false,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) => _$ExamQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$ExamQuestionToJson(this);

  ExamQuestion copyWith({
    String? selectedAnswerId,
    List<String>? selectedAnswerIds,
    String? essayAnswer,
    bool? isAnswered,
  }) {
    return ExamQuestion(
      questionId: questionId,
      content: content,
      difficulty: difficulty,
      imageUrl: imageUrl,
      questionType: questionType,
      answers: answers,
      selectedAnswerId: selectedAnswerId ?? this.selectedAnswerId,
      selectedAnswerIds: selectedAnswerIds ?? this.selectedAnswerIds,
      essayAnswer: essayAnswer ?? this.essayAnswer,
      isAnswered: isAnswered ?? this.isAnswered,
    );
  }
}

/// Đáp án của câu hỏi
@JsonSerializable()
class ExamAnswer {
  @JsonKey(name: 'macautl')  // SỬA: match với server response
  final int answerId;

  @JsonKey(name: 'noidungtl')  // SỬA: match với server response
  final String content;

  // Không nhận isCorrect từ backend để tránh lộ đáp án
  final bool isCorrect;

  const ExamAnswer({
    required this.answerId,
    required this.content,
    this.isCorrect = false, // Default false vì backend không trả về
  });

  factory ExamAnswer.fromJson(Map<String, dynamic> json) => _$ExamAnswerFromJson(json);
  Map<String, dynamic> toJson() => _$ExamAnswerToJson(this);
}

/// Request để submit bài thi
@JsonSerializable()
class SubmitExamRequest {
  @JsonKey(name: 'made')
  final int examId;

  @JsonKey(name: 'manguoidung')
  final String studentId;

  @JsonKey(name: 'thoigianbatdau')
  final DateTime startTime;

  @JsonKey(name: 'thoigianketthuc')
  final DateTime endTime;

  @JsonKey(name: 'chiTietTraLoi')
  final List<StudentAnswer> answers;

  const SubmitExamRequest({
    required this.examId,
    required this.studentId,
    required this.startTime,
    required this.endTime,
    required this.answers,
  });

  factory SubmitExamRequest.fromJson(Map<String, dynamic> json) => _$SubmitExamRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SubmitExamRequestToJson(this);
}

/// Đáp án của sinh viên
@JsonSerializable()
class StudentAnswer {
  @JsonKey(name: 'macauhoi')
  final int questionId;

  @JsonKey(name: 'macautraloi')
  final int? selectedAnswerId; // Single choice

  @JsonKey(name: 'danhSachMacautraloi')
  final List<int>? selectedAnswerIds; // Multiple choice

  @JsonKey(name: 'cauTraLoiTuLuan')
  final String? essayAnswer; // Essay

  @JsonKey(name: 'thoigiantraloi')
  final DateTime? answerTime;

  const StudentAnswer({
    required this.questionId,
    this.selectedAnswerId,
    this.selectedAnswerIds,
    this.essayAnswer,
    this.answerTime,
  });

  factory StudentAnswer.fromJson(Map<String, dynamic> json) => _$StudentAnswerFromJson(json);
  Map<String, dynamic> toJson() => _$StudentAnswerToJson(this);
}

/// Kết quả sau khi submit bài thi
@JsonSerializable()
class ExamResult {
  @JsonKey(name: 'makq')
  final int resultId;

  @JsonKey(name: 'made')
  final int examId;

  @JsonKey(name: 'manguoidung')
  final String studentId;

  @JsonKey(name: 'diem')
  final double score;

  @JsonKey(name: 'socaudung')
  final int correctAnswers;

  @JsonKey(name: 'tongcauhoi')
  final int totalQuestions;

  @JsonKey(name: 'thoigianbatdau')
  final DateTime startTime;

  @JsonKey(name: 'thoigianketthuc')
  final DateTime endTime;

  @JsonKey(name: 'thoigianhoanthanh')
  final DateTime completedTime;

  const ExamResult({
    required this.resultId,
    required this.examId,
    required this.studentId,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.startTime,
    required this.endTime,
    required this.completedTime,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) => _$ExamResultFromJson(json);
  Map<String, dynamic> toJson() => _$ExamResultToJson(this);

  /// tính phần trăm điểm
  double get percentage => (score / 10) * 100;

  /// thời gian làm bài
  Duration get duration => completedTime.difference(startTime);

  /// đánh giá kết quả
  String get grade {
    if (score >= 9) return 'Xuất sắc';
    if (score >= 8) return 'Giỏi';
    if (score >= 7) return 'Khá';
    if (score >= 5) return 'Trung bình';
    return 'Yếu';
  }
}

/// State cho việc làm bài thi - Enhanced for Vue.js compatibility
class ExamTakingState {
  final ExamForStudent? exam;
  final List<ExamQuestion> questions;
  final int currentQuestionIndex;
  final Map<int, String> studentAnswers; // questionId -> answerId
  final DateTime? startTime;
  final Duration? timeRemaining;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final ExamResult? result;
  final int? ketQuaId; // ID kết quả từ server khi start exam

  const ExamTakingState({
    this.exam,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.studentAnswers = const {},
    this.startTime,
    this.timeRemaining,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.result,
    this.ketQuaId,
  });

  ExamTakingState copyWith({
    ExamForStudent? exam,
    List<ExamQuestion>? questions,
    int? currentQuestionIndex,
    Map<int, String>? studentAnswers,
    DateTime? startTime,
    Duration? timeRemaining,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    ExamResult? result,
    int? ketQuaId,
  }) {
    return ExamTakingState(
      exam: exam ?? this.exam,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      studentAnswers: studentAnswers ?? this.studentAnswers,
      startTime: startTime ?? this.startTime,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      result: result ?? this.result,
      ketQuaId: ketQuaId ?? this.ketQuaId,
    );
  }

  /// số câu đã trả lời
  int get answeredCount => studentAnswers.length;

  /// tiến độ làm bài (%)
  double get progress {
    if (questions.isEmpty) return 0;
    return answeredCount / questions.length;
  }

  /// có thể submit không
  bool get canSubmit => answeredCount > 0 && !isSubmitting;
}

/// Chi tiết kết quả thi với đáp án của sinh viên
@JsonSerializable()
class ExamResultDetail {
  @JsonKey(name: 'makq')
  final int resultId;

  @JsonKey(name: 'made')
  final int examId;

  @JsonKey(name: 'tende')
  final String examName;

  @JsonKey(name: 'manguoidung')
  final String studentId;

  @JsonKey(name: 'hoten')
  final String studentName;

  @JsonKey(name: 'diem')
  final double score;

  @JsonKey(name: 'socaudung')
  final int correctAnswers;

  @JsonKey(name: 'tongcauhoi')
  final int totalQuestions;

  @JsonKey(name: 'thoigianbatdau')
  final DateTime startTime;

  @JsonKey(name: 'thoigianketthuc')
  final DateTime endTime;

  @JsonKey(name: 'thoigianhoanthanh')
  final DateTime completedTime;

  @JsonKey(name: 'chiTietTraLoi')
  final List<StudentAnswerDetail> answerDetails;

  const ExamResultDetail({
    required this.resultId,
    required this.examId,
    required this.examName,
    required this.studentId,
    required this.studentName,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.startTime,
    required this.endTime,
    required this.completedTime,
    required this.answerDetails,
  });

  factory ExamResultDetail.fromJson(Map<String, dynamic> json) => _$ExamResultDetailFromJson(json);
  Map<String, dynamic> toJson() => _$ExamResultDetailToJson(this);

  /// tính phần trăm điểm
  double get percentage => (score / 10) * 100;

  /// thời gian làm bài
  Duration get duration => completedTime.difference(startTime);

  /// đánh giá kết quả
  String get grade {
    if (score >= 9) return 'Xuất sắc';
    if (score >= 8) return 'Giỏi';
    if (score >= 7) return 'Khá';
    if (score >= 5) return 'Trung bình';
    return 'Yếu';
  }
}

/// Chi tiết đáp án của sinh viên cho từng câu hỏi
@JsonSerializable()
class StudentAnswerDetail {
  @JsonKey(name: 'macauhoi')
  final int questionId;

  @JsonKey(name: 'noiDungCauHoi')
  final String questionContent;

  @JsonKey(name: 'loaiCauHoi')
  final String? questionType; // single_choice, multiple_choice, essay

  // Single choice
  @JsonKey(name: 'macautraloichon')
  final int? selectedAnswerId;

  @JsonKey(name: 'noiDungTraLoiChon')
  final String? selectedAnswerContent;

  // Multiple choice
  @JsonKey(name: 'danhSachMacautraloiChon')
  final List<int>? selectedAnswerIds;

  @JsonKey(name: 'danhSachNoiDungTraLoiChon')
  final List<String>? selectedAnswerContents;

  // Essay
  @JsonKey(name: 'cauTraLoiTuLuan')
  final String? essayAnswer;

  // Correct answers
  @JsonKey(name: 'macautraloiDung')
  final int? correctAnswerId;

  @JsonKey(name: 'noiDungTraLoiDung')
  final String? correctAnswerContent;

  @JsonKey(name: 'danhSachMacautraloiDung')
  final List<int>? correctAnswerIds;

  @JsonKey(name: 'danhSachNoiDungTraLoiDung')
  final List<String>? correctAnswerContents;

  @JsonKey(name: 'laDung')
  final bool isCorrect;

  @JsonKey(name: 'thoigiantraloi')
  final DateTime? answerTime;

  const StudentAnswerDetail({
    required this.questionId,
    required this.questionContent,
    this.questionType,
    this.selectedAnswerId,
    this.selectedAnswerContent,
    this.selectedAnswerIds,
    this.selectedAnswerContents,
    this.essayAnswer,
    this.correctAnswerId,
    this.correctAnswerContent,
    this.correctAnswerIds,
    this.correctAnswerContents,
    required this.isCorrect,
    this.answerTime,
  });

  factory StudentAnswerDetail.fromJson(Map<String, dynamic> json) {
    // Tạm thời xử lý dữ liệu từ backend hiện tại
    final detail = _$StudentAnswerDetailFromJson(json);

    // Nếu không có questionType, cố gắng suy đoán từ dữ liệu
    String? inferredType = detail.questionType;
    if (inferredType == null) {
      if (detail.selectedAnswerContent != null && detail.selectedAnswerContent!.contains(',')) {
        inferredType = 'multiple_choice';
      } else if (detail.selectedAnswerContent != null && detail.selectedAnswerContent!.length > 100) {
        inferredType = 'essay';
      } else {
        inferredType = 'single_choice';
      }
    }

    return StudentAnswerDetail(
      questionId: detail.questionId,
      questionContent: detail.questionContent,
      questionType: inferredType,
      selectedAnswerId: detail.selectedAnswerId,
      selectedAnswerContent: detail.selectedAnswerContent,
      selectedAnswerIds: detail.selectedAnswerIds,
      selectedAnswerContents: detail.selectedAnswerContents,
      essayAnswer: detail.essayAnswer,
      correctAnswerId: detail.correctAnswerId,
      correctAnswerContent: detail.correctAnswerContent,
      correctAnswerIds: detail.correctAnswerIds,
      correctAnswerContents: detail.correctAnswerContents,
      isCorrect: detail.isCorrect,
      answerTime: detail.answerTime,
    );
  }

  Map<String, dynamic> toJson() => _$StudentAnswerDetailToJson(this);

  /// sinh viên có trả lời câu này không
  bool get isAnswered {
    switch (questionType?.toLowerCase()) {
      case 'single_choice':
        return selectedAnswerId != null;
      case 'multiple_choice':
        return selectedAnswerIds != null && selectedAnswerIds!.isNotEmpty;
      case 'essay':
        return essayAnswer != null && essayAnswer!.trim().isNotEmpty;
      default:
        return selectedAnswerId != null ||
               (selectedAnswerIds != null && selectedAnswerIds!.isNotEmpty) ||
               (essayAnswer != null && essayAnswer!.trim().isNotEmpty);
    }
  }

  /// trạng thái câu trả lời
  String get status {
    if (!isAnswered) return 'Không trả lời';
    return isCorrect ? 'Đúng' : 'Sai';
  }

  /// Lấy nội dung câu trả lời của sinh viên
  String get studentAnswerDisplay {
    switch (questionType?.toLowerCase()) {
      case 'single_choice':
        return selectedAnswerContent ?? 'Không trả lời';
      case 'multiple_choice':
        if (selectedAnswerContents != null && selectedAnswerContents!.isNotEmpty) {
          return selectedAnswerContents!.join(', ');
        }
        return 'Không trả lời';
      case 'essay':
        return essayAnswer?.trim().isNotEmpty == true ? essayAnswer! : 'Không trả lời';
      default:
        return selectedAnswerContent ?? essayAnswer ?? 'Không trả lời';
    }
  }

  /// Lấy nội dung đáp án đúng
  String get correctAnswerDisplay {
    switch (questionType?.toLowerCase()) {
      case 'single_choice':
        return correctAnswerContent ?? 'Không có đáp án';
      case 'multiple_choice':
        if (correctAnswerContents != null && correctAnswerContents!.isNotEmpty) {
          return correctAnswerContents!.join(', ');
        }
        return correctAnswerContent ?? 'Không có đáp án';
      case 'essay':
        // Hiển thị đáp án đúng cho câu tự luận nếu có
        return correctAnswerContent ?? 'Không có đáp án mẫu';
      default:
        return correctAnswerContent ?? 'Không có đáp án';
    }
  }
}
