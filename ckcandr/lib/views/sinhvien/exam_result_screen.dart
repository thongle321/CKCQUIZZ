import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/models/exam_taking_model.dart';
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
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExamResult();
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
          onPressed: () => context.go('/sinhvien'),
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
          // Exam info card
          _buildExamInfoCard(),
          const SizedBox(height: 16),
          
          // Result summary card
          _buildResultSummaryCard(),
          const SizedBox(height: 16),
          
          // Performance stats
          _buildPerformanceStatsCard(),
          const SizedBox(height: 16),
          
          // Detailed answers (if available)
          if (_result!.answerDetails.isNotEmpty)
            _buildDetailedAnswersCard(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceStatsCard() {
    final correctPercentage = (_result!.correctAnswers / _result!.totalQuestions) * 100;
    
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
                    const Text('Tỷ lệ đúng'),
                    Text('${correctPercentage.toStringAsFixed(1)}%'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: correctPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(_result!.score),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Câu đúng',
                    _result!.correctAnswers.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCorrect
            ? Colors.green.withValues(alpha: 0.3)
            : isAnswered
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        color: isCorrect
          ? Colors.green.withValues(alpha: 0.05)
          : isAnswered
            ? Colors.red.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCorrect
                    ? Colors.green
                    : isAnswered
                      ? Colors.red
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Câu $questionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isCorrect
                  ? Icons.check_circle
                  : isAnswered
                    ? Icons.cancel
                    : Icons.help_outline,
                color: isCorrect
                  ? Colors.green
                  : isAnswered
                    ? Colors.red
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                answer.status,
                style: TextStyle(
                  color: isCorrect
                    ? Colors.green
                    : isAnswered
                      ? Colors.red
                      : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Question content
          Text(
            answer.questionContent,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          // Student's answer
          if (isAnswered) ...[
            Text(
              'Câu trả lời của bạn:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              answer.selectedAnswerContent ?? 'Không có nội dung',
              style: TextStyle(
                color: isCorrect ? Colors.green[700] : Colors.red[700],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Correct answer
          Text(
            'Đáp án đúng:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer.correctAnswerContent,
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
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
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
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
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
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

  Future<void> _loadExamResult() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);

      // 1. Lấy chi tiết kết quả thi từ API
      final resultDetail = await apiService.getExamResultDetail(widget.resultId);

      // 2. Lấy thông tin đề thi từ API (nếu cần)
      // Tạm thời sử dụng dữ liệu từ resultDetail

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
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}


