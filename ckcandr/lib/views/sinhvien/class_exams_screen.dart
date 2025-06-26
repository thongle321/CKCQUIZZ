import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/services/api_service.dart';

import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';

/// Student Class Exams Screen - Danh sách đề thi cho sinh viên
/// Tương đương với Vue.js classexams.vue
class StudentClassExamsScreen extends ConsumerStatefulWidget {
  const StudentClassExamsScreen({super.key});

  @override
  ConsumerState<StudentClassExamsScreen> createState() => _StudentClassExamsScreenState();
}

class _StudentClassExamsScreenState extends ConsumerState<StudentClassExamsScreen> {
  List<ExamForClassModel> _exams = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;

    return RoleThemedWidget(
      role: role,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_exams.isEmpty) {
      return _buildEmptyState();
    }

    return _buildExamsList();
  }

  Widget _buildExamsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _exams.length,
      itemBuilder: (context, index) {
        final exam = _exams[index];
        return _buildExamCard(exam);
      },
    );
  }

  Widget _buildExamCard(ExamForClassModel exam) {
    final status = _getExamStatus(exam);
    final statusColor = _getStatusColor(status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    exam.tende ?? 'Đề thi không có tên',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Exam details
            _buildExamDetailRow(
              Icons.quiz,
              'Số câu hỏi',
              '${exam.tongSoCau} câu',
            ),
            const SizedBox(height: 8),
            _buildExamDetailRow(
              Icons.timer,
              'Thời gian',
              '${exam.thoigianthi} phút',
            ),
            const SizedBox(height: 8),
            _buildExamDetailRow(
              Icons.calendar_today,
              'Bắt đầu',
              exam.thoigiantbatdau != null ? _formatDateTime(exam.thoigiantbatdau!) : 'N/A',
            ),
            const SizedBox(height: 8),
            _buildExamDetailRow(
              Icons.calendar_today_outlined,
              'Kết thúc',
              exam.thoigianketthuc != null ? _formatDateTime(exam.thoigianketthuc!) : 'N/A',
            ),
            const SizedBox(height: 16),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(exam, status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(value),
      ],
    );
  }

  Widget _buildActionButton(ExamForClassModel exam, ExamStatus status) {
    switch (status) {
      case ExamStatus.upcoming:
        return ElevatedButton(
          onPressed: null, // Disabled
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Chưa đến giờ thi'),
        );
        
      case ExamStatus.ongoing:
        if (exam.ketQuaId != null) {
          // Already taken
          return ElevatedButton(
            onPressed: () => _reviewExam(exam.made, exam.ketQuaId!),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.visibility, size: 20),
                SizedBox(width: 8),
                Text('Xem kết quả'),
              ],
            ),
          );
        } else {
          // Can take exam
          return ElevatedButton(
            onPressed: () => _startExam(exam.made),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle, size: 20),
                SizedBox(width: 8),
                Text('Vào thi'),
              ],
            ),
          );
        }
        
      case ExamStatus.ended:
        return ElevatedButton(
          onPressed: exam.ketQuaId != null 
            ? () => _reviewExam(exam.made, exam.ketQuaId!)
            : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history, size: 20),
              const SizedBox(width: 8),
              Text(exam.ketQuaId != null ? 'Xem kết quả' : 'Đã kết thúc'),
            ],
          ),
        );
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Chưa có đề thi nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Các đề thi sẽ hiển thị ở đây khi giảng viên tạo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
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
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Không thể tải danh sách đề thi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Lỗi không xác định',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadExams,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  ExamStatus _getExamStatus(ExamForClassModel exam) {
    final now = DateTime.now();
    if (exam.thoigiantbatdau != null && now.isBefore(exam.thoigiantbatdau!)) {
      return ExamStatus.upcoming;
    } else if (exam.thoigianketthuc != null && now.isAfter(exam.thoigianketthuc!)) {
      return ExamStatus.ended;
    } else {
      return ExamStatus.ongoing;
    }
  }

  Color _getStatusColor(ExamStatus status) {
    switch (status) {
      case ExamStatus.upcoming:
        return Colors.blue;
      case ExamStatus.ongoing:
        return Colors.green;
      case ExamStatus.ended:
        return Colors.red;
    }
  }

  String _getStatusText(ExamStatus status) {
    switch (status) {
      case ExamStatus.upcoming:
        return 'Sắp diễn ra';
      case ExamStatus.ongoing:
        return 'Đang diễn ra';
      case ExamStatus.ended:
        return 'Đã kết thúc';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  Future<void> _loadExams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final apiService = ref.read(apiServiceProvider);
      final exams = await apiService.getAllExamsForStudent();
      
      setState(() {
        _exams = exams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startExam(int examId) {
    // Navigate to exam taking screen
    context.push('/sinhvien/exam/$examId');
  }

  void _reviewExam(int examId, int resultId) {
    context.go('/sinhvien/exam-result/$examId/$resultId');
  }
}

enum ExamStatus {
  upcoming,
  ongoing,
  ended,
}
