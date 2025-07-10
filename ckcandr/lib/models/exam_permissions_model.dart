import 'package:json_annotation/json_annotation.dart';
import 'package:ckcandr/core/utils/timezone_helper.dart';

part 'exam_permissions_model.g.dart';

/// Model for exam permissions set by instructor
@JsonSerializable()
class ExamPermissions {
  @JsonKey(name: 'hienthibailam')
  final bool showExamPaper;

  @JsonKey(name: 'xemdiemthi')
  final bool showScore;

  @JsonKey(name: 'xemdapan')
  final bool showAnswers;

  const ExamPermissions({
    required this.showExamPaper,
    required this.showScore,
    required this.showAnswers,
  });

  factory ExamPermissions.fromJson(Map<String, dynamic> json) => _$ExamPermissionsFromJson(json);
  Map<String, dynamic> toJson() => _$ExamPermissionsToJson(this);

  /// Default permissions (all disabled)
  factory ExamPermissions.defaultPermissions() {
    return const ExamPermissions(
      showExamPaper: false,
      showScore: false,
      showAnswers: false,
    );
  }

  /// Check if student can view any results
  bool get canViewAnyResults => showExamPaper || showScore || showAnswers;

  /// Check if student can view results with exam timing consideration
  bool canViewResultsWithTiming({
    DateTime? examStartTime,
    DateTime? examEndTime,
  }) {
    // If no timing info, use basic permission check
    if (examStartTime == null || examEndTime == null) {
      return canViewAnyResults;
    }

    final now = TimezoneHelper.nowLocal();
    final isExamEnded = now.isAfter(examEndTime);

    // Students can only view results after exam has ended
    return isExamEnded && canViewAnyResults;
  }

  /// Check if student can view score with timing consideration
  bool canViewScoreWithTiming({
    DateTime? examStartTime,
    DateTime? examEndTime,
  }) {
    if (!showScore) return false;

    // If no timing info, use basic permission check
    if (examStartTime == null || examEndTime == null) {
      return showScore;
    }

    final now = TimezoneHelper.nowLocal();
    final isExamEnded = now.isAfter(examEndTime);

    // Students can only view score after exam has ended
    return isExamEnded && showScore;
  }

  /// Check if student can view exam paper/details with timing consideration
  bool canViewExamPaperWithTiming({
    DateTime? examStartTime,
    DateTime? examEndTime,
  }) {
    if (!showExamPaper) return false;

    // If no timing info, use basic permission check
    if (examStartTime == null || examEndTime == null) {
      return showExamPaper;
    }

    final now = TimezoneHelper.nowLocal();
    final isExamEnded = now.isAfter(examEndTime);

    // Students can only view exam paper after exam has ended
    return isExamEnded && showExamPaper;
  }

  /// Check if student can view answers with timing consideration
  bool canViewAnswersWithTiming({
    DateTime? examStartTime,
    DateTime? examEndTime,
  }) {
    if (!showAnswers) return false;

    // If no timing info, use basic permission check
    if (examStartTime == null || examEndTime == null) {
      return showAnswers;
    }

    final now = TimezoneHelper.nowLocal();
    final isExamEnded = now.isAfter(examEndTime);

    // Students can only view answers after exam has ended
    return isExamEnded && showAnswers;
  }

  /// Check if student can view complete results (all permissions enabled)
  bool get canViewCompleteResults => showExamPaper && showScore && showAnswers;

  /// Check if student can view only score
  bool get canViewOnlyScore => showScore && !showExamPaper && !showAnswers;

  /// Check if student can view only answers
  bool get canViewOnlyAnswers => showAnswers && !showExamPaper && !showScore;

  /// Check if student can view only exam paper
  bool get canViewOnlyExamPaper => showExamPaper && !showScore && !showAnswers;

  /// Get user-friendly description of what student can view
  String get permissionDescription {
    if (!canViewAnyResults) {
      return 'Không được xem kết quả';
    }
    
    if (canViewCompleteResults) {
      return 'Xem đầy đủ kết quả';
    }

    List<String> allowed = [];
    if (showScore) allowed.add('điểm số');
    if (showExamPaper) allowed.add('bài làm');
    if (showAnswers) allowed.add('đáp án');

    return 'Chỉ được xem: ${allowed.join(', ')}';
  }

  @override
  String toString() {
    return 'ExamPermissions(showExamPaper: $showExamPaper, showScore: $showScore, showAnswers: $showAnswers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExamPermissions &&
        other.showExamPaper == showExamPaper &&
        other.showScore == showScore &&
        other.showAnswers == showAnswers;
  }

  @override
  int get hashCode {
    return showExamPaper.hashCode ^ showScore.hashCode ^ showAnswers.hashCode;
  }

  ExamPermissions copyWith({
    bool? showExamPaper,
    bool? showScore,
    bool? showAnswers,
  }) {
    return ExamPermissions(
      showExamPaper: showExamPaper ?? this.showExamPaper,
      showScore: showScore ?? this.showScore,
      showAnswers: showAnswers ?? this.showAnswers,
    );
  }
}
