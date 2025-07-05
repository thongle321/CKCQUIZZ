import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/services/ket_qua_service.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/core/widgets/back_button_handler.dart';

class TeacherStudentResultDetailScreen extends ConsumerStatefulWidget {
  final int examId;
  final String studentId;
  final String studentName;
  final String examName;

  const TeacherStudentResultDetailScreen({
    super.key,
    required this.examId,
    required this.studentId,
    required this.studentName,
    required this.examName,
  });

  @override
  ConsumerState<TeacherStudentResultDetailScreen> createState() =>
      _TeacherStudentResultDetailScreenState();
}

class _TeacherStudentResultDetailScreenState
    extends ConsumerState<TeacherStudentResultDetailScreen> {
  final KetQuaService _ketQuaService = KetQuaService();
  Map<String, dynamic>? _resultData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudentResult();
  }

  Future<void> _loadStudentResult() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _ketQuaService.getStudentExamResultForTeacher(
        examId: widget.examId,
        studentId: widget.studentId,
      );

      if (result['success']) {
        setState(() {
          _resultData = result['data'];
          _isLoading = false;
        });
        debugPrint('✅ Teacher API result data structure:');
        debugPrint('   - diem: ${_resultData!['diem']}');
        debugPrint('   - soCauDung: ${_resultData!['soCauDung']}');
        debugPrint('   - tongSoCau: ${_resultData!['tongSoCau']}');
        debugPrint('   - cauHois length: ${_resultData!['cauHois']?.length}');
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Không thể tải kết quả bài thi';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi kết nối: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.giangVien;
    final primaryColor = RoleTheme.getPrimaryColor(role);

    return BackButtonHandler(
      fallbackRoute: '/giangvien/exam-results/${widget.examId}?examName=${Uri.encodeComponent(widget.examName)}',
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBarBackButton.withBackButton(
          title: 'Chi tiết kết quả - ${widget.studentName}',
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          fallbackRoute: '/giangvien/exam-results/${widget.examId}?examName=${Uri.encodeComponent(widget.examName)}',
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải chi tiết kết quả...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStudentResult,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_resultData == null) {
      return const Center(
        child: Text('Không có dữ liệu'),
      );
    }

    return _buildResultContent();
  }

  Widget _buildResultContent() {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.giangVien;
    final primaryColor = RoleTheme.getPrimaryColor(role);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card with exam and student info
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.examName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sinh viên: ${widget.studentName}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.badge, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'MSSV: ${widget.studentId}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Score summary card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng quan kết quả',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Score and statistics
                  _buildScoreRow('Điểm số:', '${_resultData!['diem'] ?? 'N/A'} / 10', primaryColor),
                  const SizedBox(height: 8),
                  _buildScoreRow('Số câu đúng:', '${_resultData!['soCauDung'] ?? 'N/A'}', Colors.green),
                  const SizedBox(height: 8),
                  _buildScoreRow('Tổng số câu:', '${_resultData!['tongSoCau'] ?? 'N/A'}', Colors.blue),
                  const SizedBox(height: 8),
                  _buildScoreRow('Thời gian làm bài:', '${_resultData!['thoiGianLamBai'] ?? 'N/A'} phút', Colors.orange),
                  const SizedBox(height: 8),
                  _buildScoreRow('Thời gian vào thi:', _formatDateTime(_resultData!['thoiGianVaoThi']), Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Detailed answers section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chi tiết câu trả lời',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Detailed answers
                  if (_resultData!['cauHois'] != null && _resultData!['cauHois'].isNotEmpty)
                    ..._buildDetailedAnswers(_resultData!['cauHois'])
                  else
                    const Text(
                      'Không có chi tiết câu trả lời.',
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a score row with label and value
  Widget _buildScoreRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Format datetime string
  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      if (dateTime is String) {
        final dt = DateTime.parse(dateTime);
        return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return dateTime.toString();
    } catch (e) {
      return 'N/A';
    }
  }

  /// Build detailed answers list
  List<Widget> _buildDetailedAnswers(List<dynamic> questions) {

    return questions.asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;
      final isCorrect = question['isCorrect'] ?? false;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isCorrect ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isCorrect ? Colors.green.withValues(alpha: 0.05) : Colors.red.withValues(alpha: 0.05),
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Câu ${index + 1}: ${question['noiDung'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question image if available
                  if (question['hinhAnhUrl'] != null && question['hinhAnhUrl'].toString().isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          question['hinhAnhUrl'].toString(),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Student's answer
                  _buildAnswerSection(
                    'Câu trả lời của sinh viên:',
                    question['studentAnswer'] ?? 'Chưa trả lời',
                    isCorrect ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 12),

                  // Correct answer
                  _buildAnswerSection(
                    'Đáp án đúng:',
                    question['correctAnswer'] ?? 'N/A',
                    Colors.green,
                  ),

                  // Question type and difficulty
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip('Loại: ${question['loaiCauHoi'] ?? 'N/A'}', Colors.blue),
                      const SizedBox(width: 8),
                      _buildInfoChip('Độ khó: ${question['doKho'] ?? 'N/A'}', Colors.orange),
                      const SizedBox(width: 8),
                      _buildInfoChip('Điểm: ${question['diem'] ?? 0}', Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  /// Build answer section
  Widget _buildAnswerSection(String label, String answer, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            answer,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// Build info chip
  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
