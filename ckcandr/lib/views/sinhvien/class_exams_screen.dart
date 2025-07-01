import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/models/exam_permissions_model.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/core/utils/responsive_helper.dart';

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
    final isSmallScreen = ResponsiveHelper.isMobile(context);

    return RoleThemedWidget(
      role: role,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(context, role, isSmallScreen),
        body: _buildBody(isSmallScreen),
        floatingActionButton: _buildFloatingActionButton(context, role),
      ),
    );
  }

  /// Xây dựng app bar chuyên nghiệp
  PreferredSizeWidget _buildAppBar(BuildContext context, UserRole role, bool isSmallScreen) {
    return AppBar(
      backgroundColor: RoleTheme.getPrimaryColor(role),
      foregroundColor: Colors.white,
      elevation: 2,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bài kiểm tra',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_exams.isNotEmpty)
            Text(
              '${_exams.length} đề thi',
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                color: Colors.white70,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _loadExams,
          icon: const Icon(Icons.refresh),
          tooltip: 'Làm mới',
        ),
      ],
    );
  }

  /// Xây dựng floating action button
  Widget? _buildFloatingActionButton(BuildContext context, UserRole role) {
    if (_error != null) {
      return FloatingActionButton(
        onPressed: _loadExams,
        backgroundColor: RoleTheme.getPrimaryColor(role),
        child: const Icon(Icons.refresh, color: Colors.white),
        tooltip: 'Thử lại',
      );
    }
    return null;
  }

  Widget _buildBody(bool isSmallScreen) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Đang tải danh sách đề thi...',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorWidget(isSmallScreen);
    }

    if (_exams.isEmpty) {
      return _buildEmptyState(isSmallScreen);
    }

    return _buildExamsList(isSmallScreen);
  }

  Widget _buildExamsList(bool isSmallScreen) {
    return RefreshIndicator(
      onRefresh: _loadExams,
      child: ListView.builder(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        itemCount: _exams.length,
        itemBuilder: (context, index) {
          final exam = _exams[index];
          return _buildExamCard(exam, isSmallScreen);
        },
      ),
    );
  }

  Widget _buildExamCard(ExamForClassModel exam, bool isSmallScreen) {
    final status = _getExamStatus(exam);
    final statusColor = _getStatusColor(status);

    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    exam.tende ?? 'Đề thi không có tên',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 12,
                    vertical: isSmallScreen ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                    border: Border.all(color: statusColor, width: 1.5),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 11 : 12,
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
              isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            _buildExamDetailRow(
              Icons.timer,
              'Thời gian',
              '${exam.thoigianthi} phút',
              isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            _buildExamDetailRow(
              Icons.calendar_today,
              'Bắt đầu',
              exam.thoigiantbatdau != null ? _formatDateTime(exam.thoigiantbatdau!) : 'N/A',
              isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            _buildExamDetailRow(
              Icons.calendar_today_outlined,
              'Kết thúc',
              exam.thoigianketthuc != null ? _formatDateTime(exam.thoigianketthuc!) : 'N/A',
              isSmallScreen,
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

  Widget _buildExamDetailRow(IconData icon, String label, String value, bool isSmallScreen) {
    return Row(
      children: [
        Icon(
          icon,
          size: isSmallScreen ? 14 : 16,
          color: Colors.grey[600],
        ),
        SizedBox(width: isSmallScreen ? 6 : 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: isSmallScreen ? 13 : 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
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

  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: isSmallScreen ? 56 : 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có đề thi nào',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Các đề thi sẽ hiển thị ở đây khi giảng viên tạo',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadExams,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: isSmallScreen ? 8 : 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(bool isSmallScreen) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isSmallScreen ? 56 : 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể tải danh sách đề thi',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Lỗi không xác định',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadExams,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[500],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: isSmallScreen ? 8 : 12,
                ),
              ),
            ),
          ],
        ),
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

  /// Load exams - Match Vue.js /DeThi/my-exams API exactly
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

      // Sử dụng API mới match với Vue.js
      final examsData = await apiService.getMyExamsForStudent();

      // Convert từ dynamic sang ExamForClassModel
      final exams = examsData.map((examData) {
        return ExamForClassModel.fromJson(examData as Map<String, dynamic>);
      }).toList();

      // Thêm logic isResumable như Vue.js (check localStorage)
      final examsWithResumeState = exams.map((exam) {
        // TODO: Implement localStorage check for resume state
        // const savedState = localStorage.getItem(`exam_state_${exam.made}`);
        // isResumable: savedState && exam.trangthaiThi === 'DangDienRa'
        return exam; // For now, không có resume state
      }).toList();

      if (mounted) {
        setState(() {
          _exams = examsWithResumeState;
          _isLoading = false;
        });
      }

      debugPrint('✅ Loaded ${_exams.length} exams for student');
    } catch (e) {
      debugPrint('❌ Error loading exams: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _startExam(int examId) {
    // Navigate to exam taking screen
    context.push('/sinhvien/exam/$examId');
  }

  void _reviewExam(int examId, int resultId) async {
    debugPrint('🎯 Navigating to exam result: examId=$examId, resultId=$resultId');

    // Kiểm tra nếu resultId hợp lệ
    if (resultId <= 0) {
      _showErrorDialog('Kết quả bài thi chưa sẵn sàng', 'Bài thi của bạn đang được xử lý. Vui lòng thử lại sau.');
      return;
    }

    // Kiểm tra permissions trước khi navigate
    try {
      final apiService = ref.read(apiServiceProvider);
      final permissionsData = await apiService.getExamPermissions(examId);

      if (permissionsData != null) {
        final permissions = ExamPermissions.fromJson(permissionsData);

        if (!permissions.canViewAnyResults) {
          _showErrorDialog(
            'Không thể xem kết quả',
            'Giảng viên không cho phép xem kết quả bài thi này.'
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking permissions: $e');
      // Continue to result screen if permission check fails (backward compatibility)
    }

    if (mounted) {
      context.go('/sinhvien/exam-result/$examId/$resultId');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

enum ExamStatus {
  upcoming,
  ongoing,
  ended,
}
