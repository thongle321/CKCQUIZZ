import 'package:json_annotation/json_annotation.dart';

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
