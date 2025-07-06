import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/models/exam_taking_model.dart';
import 'package:ckcandr/models/exam_permissions_model.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/services/api_service.dart';

import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';

/// Student Exam Result Screen - Xem kết quả bài thi chi tiết
/// Hiển thị điểm số, thời gian làm bài, và chi tiết câu trả lời (nếu giảng viên cho phép)
class StudentExamResultScreen extends ConsumerStatefulWidget {
  final int examId;
  final int resultId;

  const StudentExamResultScreen({
    super.key,
    required this.examId,
    required this.resultId,
  });

  @override
  ConsumerState<StudentExamResultScreen> createState() => _StudentExamResultScreenState();
}

class _StudentExamResultScreenState extends ConsumerState<StudentExamResultScreen> {
  ExamForClassModel? _exam;
  ExamResultDetail? _result;
  ExamPermissions? _permissions;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    debugPrint('🎯 StudentExamResultScreen initState: examId=${widget.examId}, resultId=${widget.resultId}');
    debugPrint('🎯 StudentExamResultScreen: About to call _loadExamResult()');
    _loadExamResult();
    debugPrint('🎯 StudentExamResultScreen: _loadExamResult() called');
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả bài thi'),
        backgroundColor: RoleTheme.getPrimaryColor(role),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Quay lại trang trước đó thay vì về trang chủ
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/sinhvien');
            }
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_exam == null || _result == null) {
      return _buildNotFoundWidget();
    }

    return _buildResultContent();
  }

  Widget _buildResultContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exam info card (always show)
          _buildExamInfoCard(),
          const SizedBox(height: 16),

          // Result summary card (show based on permissions)
          if (_permissions?.showScore ?? true)
            _buildResultSummaryCard(),
          if (_permissions?.showScore ?? true)
            const SizedBox(height: 16),

          // Performance stats (show based on permissions)
          if (_permissions?.showScore ?? true)
            _buildPerformanceStatsCard(),
          if (_permissions?.showScore ?? true)
            const SizedBox(height: 16),

          // Detailed answers (show based on permissions)
          if ((_permissions?.showExamPaper ?? true) && _result!.answerDetails.isNotEmpty)
            _buildDetailedAnswersCard(),

          // Show permission info if some features are disabled
          if (_permissions != null && !_permissions!.canViewCompleteResults)
            _buildPermissionInfoCard(),
        ],
      ),
    );
  }

  Widget _buildExamInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _exam!.tende ?? 'Đề thi không có tên',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Môn: ${_exam!.tenMonHoc ?? 'N/A'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Thời gian thi: ${_exam!.thoigianthi ?? 0} phút',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSummaryCard() {
    final scoreColor = _getScoreColor(_result!.score);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kết quả thi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Score display
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scoreColor, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_result!.score.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      'điểm',
                      style: TextStyle(
                        fontSize: 16,
                        color: scoreColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Additional info
            _buildInfoRow('Số câu đúng', '${_result!.correctAnswers}/${_result!.totalQuestions}'),
            _buildInfoRow('Thời gian làm bài', _formatDuration(_result!.duration.inMinutes)),
            _buildInfoRow('Thời gian nộp bài', _formatDateTime(_result!.completedTime)),

            const SizedBox(height: 16),

            // Thông báo về việc xem lại bài thi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bạn có thể xem lại từng câu hỏi, đáp án đã chọn và đáp án đúng bên dưới.',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceStatsCard() {
    final correctPercentage = _calculateSafePercentage(_result!.correctAnswers, _result!.totalQuestions);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Tỷ lệ đúng',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${correctPercentage.isFinite ? correctPercentage.toStringAsFixed(1) : '0.0'}%',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: correctPercentage.isFinite ? (correctPercentage / 100).clamp(0.0, 1.0) : 0.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(_result!.score),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Stats grid
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Câu đúng',
                      _result!.correctAnswers.toString(),
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatItem(
                      'Câu sai',
                      (_result!.totalQuestions - _result!.correctAnswers).toString(),
                      Colors.red,
                      Icons.cancel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedAnswersCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết câu trả lời',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Display answer details
            ...(_result!.answerDetails.asMap().entries.map((entry) {
              final index = entry.key;
              final answer = entry.value;
              return _buildAnswerDetailItem(index + 1, answer);
            }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerDetailItem(int questionNumber, StudentAnswerDetail answer) {
    final isCorrect = answer.isCorrect;
    final isAnswered = answer.isAnswered;

    // Màu sắc rõ ràng hơn
    final Color borderColor;
    final Color backgroundColor;
    final Color statusColor;

    if (isCorrect) {
      borderColor = Colors.green.shade400;
      backgroundColor = Colors.green.shade50;
      statusColor = Colors.green.shade700;
    } else if (isAnswered) {
      borderColor = Colors.red.shade400;
      backgroundColor = Colors.red.shade50;
      statusColor = Colors.red.shade700;
    } else {
      borderColor = Colors.grey.shade400;
      backgroundColor = Colors.grey.shade50;
      statusColor = Colors.grey.shade700;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Câu $questionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isCorrect
                  ? Icons.check_circle
                  : isAnswered
                    ? Icons.cancel
                    : Icons.help_outline,
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  answer.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Thêm badge điểm số nếu có
              if (isAnswered)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCorrect ? Colors.green.shade300 : Colors.red.shade300,
                    ),
                  ),
                  child: Text(
                    isCorrect ? '✓ Đúng' : '✗ Sai',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Question content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              answer.questionContent,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(height: 16),

          // Student's answer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAnswered
                ? (isCorrect ? Colors.green.shade50 : Colors.red.shade50)
                : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isAnswered
                  ? (isCorrect ? Colors.green.shade200 : Colors.red.shade200)
                  : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isAnswered
                        ? (isCorrect ? Icons.check_circle : Icons.cancel)
                        : Icons.help_outline,
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Câu trả lời của bạn:',
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  answer.studentAnswerDisplay.isEmpty
                    ? 'Chưa trả lời'
                    : answer.studentAnswerDisplay,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: answer.studentAnswerDisplay.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Correct answer - Luôn hiển thị để sinh viên học hỏi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: answer.questionType == 'essay'
                ? Colors.blue.shade50
                : Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: answer.questionType == 'essay'
                  ? Colors.blue.shade200
                  : Colors.green.shade200
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      answer.questionType == 'essay'
                        ? Icons.edit_note
                        : Icons.lightbulb,
                      color: answer.questionType == 'essay'
                        ? Colors.blue.shade700
                        : Colors.green.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        answer.questionType == 'essay'
                          ? 'Đáp án mẫu (GV):'
                          : 'Đáp án đúng:',
                        style: TextStyle(
                          fontSize: 13,
                          color: answer.questionType == 'essay'
                            ? Colors.blue.shade700
                            : Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  answer.correctAnswerDisplay.isEmpty
                    ? 'Đang tải đáp án...'
                    : answer.correctAnswerDisplay,
                  style: TextStyle(
                    color: answer.questionType == 'essay'
                      ? Colors.blue.shade700
                      : Colors.green.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),


                // Thêm so sánh trực quan cho câu trắc nghiệm
                if (answer.questionType != 'essay' && answer.isAnswered) ...[
                  const SizedBox(height: 12),
                  _buildAnswerComparison(answer, isCorrect),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Hiển thị so sánh đáp án cho các loại câu hỏi khác nhau
  Widget _buildAnswerComparison(StudentAnswerDetail answer, bool isCorrect) {
    if (answer.questionType == 'multiple_choice') {
      return _buildMultipleChoiceComparison(answer, isCorrect);
    } else {
      return _buildSingleChoiceComparison(answer, isCorrect);
    }
  }

  /// Hiển thị so sánh cho câu hỏi một đáp án
  Widget _buildSingleChoiceComparison(StudentAnswerDetail answer, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isCorrect ? Colors.green.shade200 : Colors.orange.shade200
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.compare_arrows,
            color: isCorrect ? Colors.green.shade600 : Colors.orange.shade600,
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isCorrect
                ? 'Đúng'
                : 'Sai',
              style: TextStyle(
                fontSize: 12,
                color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Hiển thị so sánh cho câu hỏi nhiều đáp án
  Widget _buildMultipleChoiceComparison(StudentAnswerDetail answer, bool isCorrect) {
    final selectedIds = answer.selectedAnswerIds ?? [];
    final correctIds = answer.correctAnswerIds ?? [];

    // Đếm số đáp án đúng mà sinh viên đã chọn
    final correctlySelected = selectedIds.where((id) => correctIds.contains(id)).length;
    final totalCorrect = correctIds.length;
    final incorrectlySelected = selectedIds.where((id) => !correctIds.contains(id)).length;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isCorrect ? Colors.green.shade200 : Colors.orange.shade200
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.rule,
                color: isCorrect ? Colors.green.shade600 : Colors.orange.shade600,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isCorrect
                    ? 'Bạn đã chọn đúng tất cả đáp án!'
                    : 'Câu nhiều đáp án: Bạn chọn đúng $correctlySelected/$totalCorrect đáp án',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCorrect ? Colors.green.shade700 : Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (!isCorrect && (correctlySelected < totalCorrect || incorrectlySelected > 0)) ...[
            const SizedBox(height: 6),
            if (incorrectlySelected > 0)
              Text(
                '❌ Chọn sai: $incorrectlySelected đáp án',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red.shade600,
                ),
              ),
            if (correctlySelected < totalCorrect)
              Text(
                '⚠️ Bỏ sót: ${totalCorrect - correctlySelected} đáp án đúng',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange.shade600,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Không thể tải kết quả bài thi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Lỗi không xác định',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadExamResult,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả bài thi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getScoreColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 6.5) return Colors.orange;
    if (score >= 5.0) return Colors.amber;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  /// Parse result from ExamController API
  void _parseExamApiResult(Map<String, dynamic> data) {
    try {
      debugPrint('🔍 Parsing ExamController API result: $data');

      // Kiểm tra xem có dữ liệu chi tiết không
      final diemRaw = data['diem'];
      double diem = 0.0;

      // Safe type conversion
      if (diemRaw is int) {
        diem = diemRaw.toDouble();
      } else if (diemRaw is double) {
        diem = diemRaw;
      } else if (diemRaw is String) {
        diem = double.tryParse(diemRaw) ?? 0.0;
      }

      // API mới trả về format khác - sử dụng 'questions' thay vì 'baiLam'
      final questions = data['questions'] as List<dynamic>? ?? [];
      final soCauDung = data['soCauDung'] as int? ?? 0;
      final tongSoCau = data['tongSoCau'] as int? ?? 0;

      debugPrint('📊 Raw data keys: ${data.keys.toList()}');
      debugPrint('📊 Questions type: ${data['questions'].runtimeType}');
      debugPrint('📊 Questions length: ${questions.length}');
      debugPrint('📊 Found ${questions.length} questions, score: $diem, correct: $soCauDung/$tongSoCau');

      if (questions.isNotEmpty) {
        debugPrint('📊 First question sample: ${questions.first}');
      }

      // Parse chi tiết câu trả lời từ format mới
      final answerDetails = <StudentAnswerDetail>[];

      for (final questionData in questions) {
        try {
          final questionId = questionData['macauhoi'] as int;
          final questionContent = questionData['noidung'] as String? ?? 'Câu hỏi $questionId';
          final questionType = questionData['loaicauhoi'] as String? ?? 'single_choice';
          final answers = questionData['answers'] as List<dynamic>? ?? [];

          // Lấy đáp án sinh viên đã chọn
          final studentSelectedAnswerId = questionData['studentSelectedAnswerId'] as int?;
          final studentSelectedAnswerIds = (questionData['studentSelectedAnswerIds'] as List<dynamic>?)
              ?.map((id) => id as int).toList() ?? [];
          final studentAnswerText = questionData['studentAnswerText'] as String?;

          // Tìm tất cả đáp án đúng
          final correctAnswers = answers.where((answer) => answer['dapan'] == true).toList();
          final correctAnswerIds = correctAnswers.map((answer) => answer['macautl'] as int).toList();

          // Debug log để kiểm tra dữ liệu
          debugPrint('🔍 Question $questionId: studentSelectedAnswerId=$studentSelectedAnswerId, correctAnswerIds=$correctAnswerIds');
          debugPrint('🔍 Question $questionId answers: $answers');
          debugPrint('🔍 Question $questionId: studentAnswerText="$studentAnswerText"');
          debugPrint('🔍 Question $questionId: studentSelectedAnswerIds=$studentSelectedAnswerIds');

          // Debug điều kiện xử lý
          debugPrint('🔍 Q$questionId conditions: selectedAnswerId=$studentSelectedAnswerId, answerText="$studentAnswerText", selectedAnswerIds=$studentSelectedAnswerIds');

          // Xử lý theo loại câu hỏi
          String studentAnswerDisplay = 'Chưa trả lời';
          String correctAnswerDisplay = 'Đáp án đúng';
          bool isCorrect = false;
          int correctCount = 0;
          int totalCorrect = correctAnswerIds.length;

          if (studentAnswerText != null && studentAnswerText.isNotEmpty && studentAnswerText != "null") {
            debugPrint('🔍 Processing text answer for Q$questionId: "$studentAnswerText"');
            // Câu tự luận: sử dụng studentAnswerText
            studentAnswerDisplay = studentAnswerText;
            correctAnswerDisplay = correctAnswers.isNotEmpty
                ? correctAnswers.first['noidungtl'] as String? ?? 'Đáp án đúng'
                : 'Đáp án đúng';

            // Kiểm tra xem text có khớp với đáp án đúng không (so sánh không phân biệt hoa thường và khoảng trắng)
            final correctAnswerText = correctAnswers.isNotEmpty
                ? correctAnswers.first['noidungtl'] as String? ?? ''
                : '';

            // So sánh chính xác: loại bỏ khoảng trắng thừa và không phân biệt hoa thường
            final studentTextNormalized = studentAnswerText.trim().toLowerCase();
            final correctTextNormalized = correctAnswerText.trim().toLowerCase();
            isCorrect = studentTextNormalized == correctTextNormalized;

            debugPrint('🔍 Text answer Q$questionId: student="$studentAnswerText" -> "$studentTextNormalized"');
            debugPrint('🔍 Text answer Q$questionId: correct="$correctAnswerText" -> "$correctTextNormalized"');
            debugPrint('🔍 Text answer Q$questionId: isCorrect=$isCorrect');
          } else if (questionType == 'multiple_choice' && studentSelectedAnswerIds.isNotEmpty) {
            // Câu hỏi nhiều đáp án
            final selectedAnswerTexts = <String>[];
            final correctAnswerTexts = <String>[];

            // Đếm số đáp án đúng mà sinh viên đã chọn
            correctCount = studentSelectedAnswerIds.where((id) => correctAnswerIds.contains(id)).length;

            // Lấy text của các đáp án đã chọn
            for (final id in studentSelectedAnswerIds) {
              final answer = answers.firstWhere(
                (a) => a['macautl'] == id,
                orElse: () => null,
              );
              if (answer != null) {
                selectedAnswerTexts.add(answer['noidungtl'] as String? ?? 'Đáp án $id');
              }
            }

            // Lấy text của các đáp án đúng
            for (final answer in correctAnswers) {
              correctAnswerTexts.add(answer['noidungtl'] as String? ?? 'Đáp án đúng');
            }

            studentAnswerDisplay = selectedAnswerTexts.isNotEmpty
                ? selectedAnswerTexts.join(', ')
                : 'Chưa trả lời';
            correctAnswerDisplay = correctAnswerTexts.join(', ');

            // Câu nhiều đáp án được coi là đúng nếu chọn đúng TẤT CẢ và không chọn sai
            isCorrect = correctCount == totalCorrect &&
                       studentSelectedAnswerIds.length == totalCorrect &&
                       studentSelectedAnswerIds.every((id) => correctAnswerIds.contains(id));
          } else if (studentSelectedAnswerId != null) {
            // Câu hỏi một đáp án
            final selectedAnswer = answers.firstWhere(
              (answer) => answer['macautl'] == studentSelectedAnswerId,
              orElse: () => null,
            );
            studentAnswerDisplay = selectedAnswer?['noidungtl'] as String? ?? 'Đáp án không xác định';
            correctAnswerDisplay = correctAnswers.isNotEmpty
                ? correctAnswers.first['noidungtl'] as String? ?? 'Đáp án đúng'
                : 'Đáp án đúng';
            isCorrect = correctAnswerIds.contains(studentSelectedAnswerId);
            debugPrint('🔍 Single choice Q$questionId: selected=$studentSelectedAnswerId, correct=$correctAnswerIds, isCorrect=$isCorrect');
          } else if (studentSelectedAnswerIds.isNotEmpty) {
            // Câu nhiều đáp án: sử dụng studentSelectedAnswerIds
            final selectedAnswers = answers.where((answer) =>
              studentSelectedAnswerIds.contains(answer['macautl'])
            ).toList();

            studentAnswerDisplay = selectedAnswers.map((answer) =>
              answer['noidungtl'] as String? ?? 'Đáp án không xác định'
            ).join(', ');

            correctAnswerDisplay = correctAnswers.map((answer) =>
              answer['noidungtl'] as String? ?? 'Đáp án đúng'
            ).join(', ');

            // Kiểm tra xem có chọn đúng tất cả đáp án không
            final selectedCorrectIds = studentSelectedAnswerIds.where((id) => correctAnswerIds.contains(id)).toList();
            final selectedWrongIds = studentSelectedAnswerIds.where((id) => !correctAnswerIds.contains(id)).toList();

            isCorrect = selectedCorrectIds.length == correctAnswerIds.length && selectedWrongIds.isEmpty;
            debugPrint('🔍 Multiple choice Q$questionId: selected=$studentSelectedAnswerIds, correct=$correctAnswerIds, isCorrect=$isCorrect');
          } else {
            // Trường hợp đặc biệt: API thiếu studentSelectedAnswerId
            // Nhưng có thể student đã trả lời đúng (dựa vào điểm số)
            // Tạm thời hiển thị thông tin đáp án đúng
            if (correctAnswers.isNotEmpty) {
              studentAnswerDisplay = 'Dữ liệu không đầy đủ';
              correctAnswerDisplay = correctAnswers.first['noidungtl'] as String? ?? 'Đáp án đúng';

              // Tạm thời đánh dấu là sai vì không có dữ liệu student
              isCorrect = false;
              debugPrint('🔍 Missing data Q$questionId: no student answer, correct="$correctAnswerDisplay"');
            }
          }

          answerDetails.add(StudentAnswerDetail(
            questionId: questionId,
            questionContent: questionContent,
            questionType: questionType,
            selectedAnswerId: studentSelectedAnswerId,
            selectedAnswerContent: studentAnswerDisplay,
            selectedAnswerIds: studentSelectedAnswerIds,
            selectedAnswerContents: questionType == 'multiple_choice' && studentSelectedAnswerIds.isNotEmpty
                ? studentSelectedAnswerIds.map((id) {
                    final answer = answers.firstWhere(
                      (a) => a['macautl'] == id,
                      orElse: () => null,
                    );
                    return answer?['noidungtl'] as String? ?? 'Đáp án $id';
                  }).toList()
                : null,
            essayAnswer: studentAnswerText,
            correctAnswerId: correctAnswerIds.isNotEmpty ? correctAnswerIds.first : null,
            correctAnswerContent: correctAnswerDisplay,
            correctAnswerIds: correctAnswerIds,
            correctAnswerContents: correctAnswers.map((answer) => answer['noidungtl'] as String? ?? 'Đáp án đúng').toList(),
            isCorrect: isCorrect,
          ));
        } catch (e) {
          debugPrint('❌ Error creating answer detail for question: $e');
          continue;
        }
      }

      // Tạo ExamResultDetail từ data
      final currentUser = ref.read(currentUserProvider);
      final now = DateTime.now();
      final examName = data['tenDeThi'] as String? ?? 'Bài thi đã hoàn thành';

      setState(() {
        // Set cả _exam và _result để UI hiển thị được
        _exam = ExamForClassModel(
          made: widget.examId,
          tende: examName,
          tenMonHoc: 'Lập trình C/C++', // Có thể lấy từ API khác nếu cần
          tongSoCau: tongSoCau, // Sử dụng data từ API
          thoigianthi: 60, // Thời gian thi mặc định
          thoigiantbatdau: now.subtract(const Duration(hours: 1)),
          thoigianketthuc: now,
          trangthaiThi: 'DaKetThuc',
          ketQuaId: widget.resultId,
        );

        _result = ExamResultDetail(
          resultId: widget.resultId,
          examId: widget.examId,
          examName: examName,
          studentId: currentUser?.id ?? '',
          studentName: currentUser?.hoVaTen ?? 'Sinh viên',
          score: diem,
          correctAnswers: soCauDung, // Sử dụng data từ API
          totalQuestions: tongSoCau, // Sử dụng data từ API
          startTime: now.subtract(const Duration(hours: 1)),
          endTime: now,
          completedTime: now,
          answerDetails: answerDetails,
        );
        _isLoading = false;
        _error = null;
      });

      debugPrint('✅ Successfully parsed ExamController API result: ${answerDetails.length} questions');
      debugPrint('✅ Correct answers already loaded from API, no need to fetch separately');

    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing ExamController API result: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      _createFallbackResult();
    }
  }





  void _createFallbackResult() {
    // Tạo kết quả tạm thời khi server trả về 404 nhưng bài thi đã hoàn thành
    final currentUser = ref.read(currentUserProvider);
    final now = DateTime.now();

    setState(() {
      _result = ExamResultDetail(
        resultId: widget.resultId,
        examId: widget.examId,
        examName: 'Bài thi đã hoàn thành',
        studentId: currentUser?.id ?? '',
        studentName: currentUser?.hoVaTen ?? 'Sinh viên',
        score: 0.0, // Điểm tạm thời - đang được xử lý
        correctAnswers: 0,
        totalQuestions: 0,
        startTime: now.subtract(const Duration(hours: 1)), // Thời gian tạm
        endTime: now,
        completedTime: now,
        answerDetails: [], // Danh sách câu trả lời trống
      );
      _isLoading = false;
      _error = null;
    });

    // Hiển thị thông báo cho sinh viên
    _showFallbackMessage();
  }

  void _showFallbackMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bài thi của bạn đã được nộp thành công!\n'
              'Kết quả chi tiết đang được xử lý, vui lòng kiểm tra lại sau.',
              style: TextStyle(fontSize: 14),
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  Future<void> _loadExamResult() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('📊 Loading exam result for resultId: ${widget.resultId}');
      final apiService = ref.read(apiServiceProvider);

      // 🔐 Load exam permissions first
      try {
        debugPrint('🔐 Loading exam permissions for examId: ${widget.examId}');
        final permissionsData = await apiService.getExamPermissions(widget.examId);
        if (permissionsData != null) {
          _permissions = ExamPermissions.fromJson(permissionsData);
          debugPrint('✅ Loaded permissions: $_permissions');
        } else {
          _permissions = ExamPermissions.defaultPermissions();
          debugPrint('⚠️ No permissions data, using defaults');
        }
      } catch (permissionsError) {
        debugPrint('❌ Failed to load permissions: $permissionsError');
        _permissions = ExamPermissions.defaultPermissions();
      }

      // Check if student can view any results
      if (_permissions != null && !_permissions!.canViewAnyResults) {
        setState(() {
          _error = 'Giảng viên không cho phép xem kết quả bài thi này.';
          _isLoading = false;
        });
        return;
      }

      // 🔍 Thử API từ ExamController trước (có thể có data chi tiết hơn)
      try {
        debugPrint('🔍 Trying ExamController API: /api/Exam/exam-result/${widget.resultId}');
        final examApiResult = await apiService.getStudentExamResult(widget.resultId);

        if (examApiResult != null) {
          debugPrint('✅ ExamController API returned data: $examApiResult');
          _parseExamApiResult(examApiResult);
          return;
        }
      } catch (examApiError) {
        debugPrint('❌ ExamController API failed: $examApiError');
      }

      // 🔄 Fallback to KetQuaController API
      debugPrint('🔄 Fallback to KetQuaController API: /api/KetQua/${widget.resultId}/detail');
      final resultDetail = await apiService.getExamResultDetail(widget.resultId);

      setState(() {
        _exam = ExamForClassModel(
          made: widget.examId,
          tende: resultDetail.examName,
          tenMonHoc: 'Lập trình C/C++', // Có thể lấy từ API khác nếu cần
          tongSoCau: resultDetail.totalQuestions,
          thoigianthi: 60, // Có thể tính từ thời gian bắt đầu và kết thúc
          thoigiantbatdau: resultDetail.startTime,
          thoigianketthuc: resultDetail.endTime,
          trangthaiThi: 'DaKetThuc',
          ketQuaId: widget.resultId,
        );

        // Sử dụng trực tiếp resultDetail thay vì tạo object mới
        _result = resultDetail;

        _isLoading = false;
      });

      debugPrint('✅ Loaded exam result detail for resultId: ${widget.resultId}');
    } catch (e) {
      debugPrint('❌ Error loading exam result: $e');

      // Nếu lỗi 404, có thể bài thi đã làm nhưng chưa được xử lý đúng
      // Tạo kết quả tạm thời để hiển thị thông tin cơ bản
      if (e.toString().contains('404') || e.toString().contains('Request failed')) {
        debugPrint('🔄 Creating fallback result for completed exam');
        _createFallbackResult();
      } else {
        setState(() {
          // Hiển thị thông báo lỗi thân thiện hơn cho các lỗi khác
          if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
            _error = 'Bạn không có quyền xem kết quả bài thi này.';
          } else if (e.toString().contains('No internet connection')) {
            _error = 'Không có kết nối internet.\nVui lòng kiểm tra kết nối và thử lại.';
          } else {
            _error = 'Có lỗi xảy ra khi tải kết quả bài thi.\nVui lòng thử lại sau.';
          }
          _isLoading = false;
        });
      }
    }
  }

  /// Build permission info card to show what student can/cannot view
  Widget _buildPermissionInfoCard() {
    if (_permissions == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'Thông tin quyền xem',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _permissions!.permissionDescription,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (!_permissions!.showScore)
              _buildPermissionItem('Điểm số', false),
            if (!_permissions!.showExamPaper)
              _buildPermissionItem('Bài làm chi tiết', false),
            if (!_permissions!.showAnswers)
              _buildPermissionItem('Đáp án đúng', false),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(String item, bool allowed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            allowed ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: allowed ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            item,
            style: TextStyle(
              fontSize: 12,
              color: allowed ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  /// Tính toán phần trăm an toàn, tránh NaN và Infinity
  double _calculateSafePercentage(int correct, int total) {
    if (total <= 0) return 0.0;
    final percentage = (correct / total) * 100;
    if (percentage.isNaN || percentage.isInfinite) return 0.0;
    return percentage.clamp(0.0, 100.0);
  }
}


