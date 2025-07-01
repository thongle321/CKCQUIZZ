import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/models/exam_taking_model.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/services/cau_hoi_service.dart';
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
    debugPrint('🎯 StudentExamResultScreen: examId=${widget.examId}, resultId=${widget.resultId}');
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
              Text(
                answer.status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
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
            ),
          ),
          const SizedBox(height: 16),

          // Student's answer
          Container(
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
                    Text(
                      'Câu trả lời của bạn:',
                      style: TextStyle(
                        fontSize: 13,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  answer.studentAnswerDisplay,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Correct answer - Hiển thị cho cả trắc nghiệm và tự luận
          Container(
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
                    Text(
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
                ),
                // Thêm ghi chú cho câu tự luận
                if (answer.questionType == 'essay') ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                          color: Colors.orange.shade600, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Lưu ý: Câu tự luận cần so sánh thủ công với đáp án mẫu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
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

      final baiLam = data['baiLam'] as List<dynamic>? ?? [];

      debugPrint('📊 Found ${baiLam.length} answer details, score: $diem');

      // Parse chi tiết câu trả lời
      final answerDetails = <StudentAnswerDetail>[];
      final Map<int, List<Map<String, dynamic>>> questionGroups = {};

      // Nhóm theo câu hỏi
      for (final item in baiLam) {
        try {
          final macauhoi = item['macauhoi'] as int;
          if (!questionGroups.containsKey(macauhoi)) {
            questionGroups[macauhoi] = [];
          }
          questionGroups[macauhoi]!.add(item as Map<String, dynamic>);
        } catch (e) {
          debugPrint('❌ Error parsing answer item: $item, error: $e');
          continue;
        }
      }

      // Tạo StudentAnswerDetail cho mỗi câu hỏi
      for (final entry in questionGroups.entries) {
        try {
          final questionId = entry.key;
          final answers = entry.value;

          // Tìm đáp án sinh viên đã chọn (dapansv = 1)
          final selectedAnswer = answers.firstWhere(
            (a) => a['dapansv'] == 1,
            orElse: () => answers.first, // Nếu không có đáp án nào được chọn
          );

          final studentAnswer = selectedAnswer['dapansv'] == 1 ? selectedAnswer['macautl'] as int? : null;
          final essayAnswer = selectedAnswer['dapantuluansv'] as String?;

          // Xác định loại câu hỏi
          final questionType = essayAnswer != null ? 'essay' : 'single_choice';

          answerDetails.add(StudentAnswerDetail(
            questionId: questionId,
            questionContent: 'Câu hỏi $questionId', // Sẽ load từ API khác nếu cần
            questionType: questionType,
            selectedAnswerId: studentAnswer,
            essayAnswer: essayAnswer,
            correctAnswerId: null, // Sẽ load từ API
            correctAnswerContent: 'Đang tải...', // Sẽ load đáp án mẫu từ GV
            isCorrect: false, // Sẽ update sau khi load đáp án đúng
          ));
        } catch (e) {
          debugPrint('❌ Error creating answer detail for question ${entry.key}: $e');
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
          tongSoCau: answerDetails.length,
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
          correctAnswers: answerDetails.where((a) => a.isCorrect).length,
          totalQuestions: answerDetails.length,
          startTime: now.subtract(const Duration(hours: 1)),
          endTime: now,
          completedTime: now,
          answerDetails: answerDetails,
        );
        _isLoading = false;
        _error = null;
      });

      debugPrint('✅ Successfully parsed ExamController API result: ${answerDetails.length} questions');

      // Load đáp án đúng cho tất cả câu hỏi
      _loadCorrectAnswersForQuestions(answerDetails);

    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing ExamController API result: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      _createFallbackResult();
    }
  }

  /// Load đáp án đúng cho tất cả câu hỏi
  Future<void> _loadCorrectAnswersForQuestions(List<StudentAnswerDetail> answerDetails) async {
    try {
      debugPrint('🔍 Loading correct answers for ${answerDetails.length} questions');

      for (int i = 0; i < answerDetails.length; i++) {
        final detail = answerDetails[i];
        final correctAnswer = await _loadCorrectAnswerForQuestion(detail.questionId);

        if (correctAnswer != null) {
          bool isCorrect = false;
          String correctAnswerText = correctAnswer['noidungtl'] as String? ?? 'Đáp án đúng';

          // Xử lý theo loại câu hỏi
          if (detail.questionType == 'essay') {
            // Câu tự luận: So sánh text (có thể cần logic phức tạp hơn)
            final studentEssay = detail.essayAnswer?.trim().toLowerCase() ?? '';
            final correctEssay = correctAnswerText.trim().toLowerCase();

            // Tạm thời: so sánh đơn giản, có thể cần AI/fuzzy matching sau này
            isCorrect = studentEssay.isNotEmpty && studentEssay.contains(correctEssay);

            debugPrint('📝 Essay comparison - Student: "$studentEssay", Correct: "$correctEssay", Match: $isCorrect');
            debugPrint('📝 Essay correct answer text: "$correctAnswerText"');
          } else {
            // Câu trắc nghiệm: So sánh ID
            isCorrect = detail.selectedAnswerId == correctAnswer['macautl'];
          }

          // Update answer detail với đáp án đúng
          final updatedDetail = StudentAnswerDetail(
            questionId: detail.questionId,
            questionContent: detail.questionContent,
            questionType: detail.questionType,
            selectedAnswerId: detail.selectedAnswerId,
            essayAnswer: detail.essayAnswer,
            correctAnswerId: correctAnswer['macautl'] as int?,
            correctAnswerContent: correctAnswerText, // Sử dụng text đã load
            isCorrect: isCorrect,
          );

          debugPrint('🔄 Before update - Question ${detail.questionId}: correctAnswerDisplay = "${detail.correctAnswerDisplay}"');
          answerDetails[i] = updatedDetail;
          debugPrint('✅ After update - Question ${detail.questionId}: correctAnswerDisplay = "${updatedDetail.correctAnswerDisplay}"');
        }
      }

      // Update UI với đáp án đúng
      setState(() {
        if (_result != null) {
          final correctCount = answerDetails.where((a) => a.isCorrect).length;
          _result = ExamResultDetail(
            resultId: _result!.resultId,
            examId: _result!.examId,
            examName: _result!.examName,
            studentId: _result!.studentId,
            studentName: _result!.studentName,
            score: _result!.score,
            correctAnswers: correctCount,
            totalQuestions: _result!.totalQuestions,
            startTime: _result!.startTime,
            endTime: _result!.endTime,
            completedTime: _result!.completedTime,
            answerDetails: answerDetails,
          );
        }
      });

      debugPrint('✅ Updated ${answerDetails.length} questions with correct answers');
    } catch (e) {
      debugPrint('❌ Error loading correct answers: $e');
    }
  }

  /// Load đáp án đúng cho một câu hỏi
  Future<Map<String, dynamic>?> _loadCorrectAnswerForQuestion(int questionId) async {
    try {
      final cauHoiService = ref.read(cauHoiServiceProvider);

      // Gọi API để lấy thông tin câu hỏi và đáp án
      final response = await cauHoiService.getQuestionById(questionId);

      if (response.isSuccess && response.data != null) {
        final question = response.data!;

        // Tìm đáp án đúng từ cacLuaChon
        final correctAnswer = question.cacLuaChon.firstWhere(
          (answer) => answer.laDapAnDung == true,
          orElse: () => throw Exception('No correct answer found'),
        );

        return {
          'macautl': correctAnswer.macautl,
          'noidungtl': correctAnswer.noiDung,
        };
      } else {
        debugPrint('❌ Failed to load question $questionId: ${response.error}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error loading correct answer for question $questionId: $e');
      return null;
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
}


