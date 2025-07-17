/// Model cho API cập nhật điểm số
class UpdateScoreRequest {
  final int examId;
  final String studentId;
  final double newScore;

  UpdateScoreRequest({
    required this.examId,
    required this.studentId,
    required this.newScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'examId': examId,
      'studentId': studentId,
      'newScore': newScore,
    };
  }
}

/// Model cho response cập nhật điểm số
class UpdateScoreResponse {
  final bool success;
  final String message;
  final int? ketQuaId;
  final double? newScore;

  UpdateScoreResponse({
    required this.success,
    required this.message,
    this.ketQuaId,
    this.newScore,
  });

  factory UpdateScoreResponse.fromJson(Map<String, dynamic> json) {
    return UpdateScoreResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      ketQuaId: json['ketQuaId'],
      newScore: json['newScore']?.toDouble(),
    );
  }
}

/// Model cho response tìm ketQuaId
class FindKetQuaResponse {
  final bool success;
  final String message;
  final int? ketQuaId;
  final int? examId;
  final String? studentId;
  final double? score;

  FindKetQuaResponse({
    required this.success,
    required this.message,
    this.ketQuaId,
    this.examId,
    this.studentId,
    this.score,
  });

  factory FindKetQuaResponse.fromJson(Map<String, dynamic> json) {
    return FindKetQuaResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      ketQuaId: json['ketQuaId'],
      examId: json['examId'],
      studentId: json['studentId'],
      score: json['score']?.toDouble(),
    );
  }
}


