import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/models/exam_permissions_model.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/exam_refresh_provider.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/services/auto_refresh_service.dart';
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

class _StudentClassExamsScreenState extends ConsumerState<StudentClassExamsScreen>
    with AutomaticKeepAliveClientMixin, AutoRefreshMixin {
  List<ExamForClassModel> _exams = [];
  bool _isLoading = false;
  String? _error;
  Timer? _minuteTimer;

  // AutoRefreshMixin implementation
  @override
  String get autoRefreshKey => AutoRefreshKeys.studentExams;

  @override
  void onAutoRefresh() {
    debugPrint('🔄 Auto-refreshing student exams');
    // Luôn refresh để cập nhật trạng thái exam mới hoặc thay đổi status
    _loadExams();
  }

  @override
  bool get shouldAutoRefresh => true;

  @override
  int get refreshIntervalSeconds => 60; // Refresh mỗi phút để cập nhật exam status



  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadExams();
    _startMinuteTimer();
  }

  @override
  void dispose() {
    _minuteTimer?.cancel();
    super.dispose();
  }

  /// Bắt đầu timer để refresh đúng phút (ví dụ: 10:01:00, 10:02:00)
  void _startMinuteTimer() {
    final now = DateTime.now();
    final nextMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1, 0);
    final timeToNextMinute = nextMinute.difference(now);

    debugPrint('🕐 Setting up minute timer - next refresh at: ${DateFormat('HH:mm:ss').format(nextMinute)}');

    // Timer đến phút tiếp theo
    Timer(timeToNextMinute, () {
      _loadExams();
      debugPrint('🔄 Minute timer refresh at: ${DateFormat('HH:mm:ss').format(DateTime.now())}');

      // Sau đó refresh mỗi phút
      _minuteTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        _loadExams();
        debugPrint('🔄 Periodic minute refresh at: ${DateFormat('HH:mm:ss').format(DateTime.now())}');
      });
    });
  }

  /// Check resume state cho exam cụ thể (optimized - chỉ gọi khi cần)
  Future<bool> _checkCanResumeExam(int examId) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser == null) return false;

      debugPrint('🔍 Checking resume state for exam $examId');

      // Check ketQuaId từ server
      final ketQuaResponse = await apiService.findKetQuaId(examId, currentUser.id);

      if (ketQuaResponse != null && ketQuaResponse.success && ketQuaResponse.ketQuaId != null) {
        debugPrint('✅ Found ketQuaId ${ketQuaResponse.ketQuaId} for exam $examId');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error checking resume state for exam $examId: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;
    final isSmallScreen = ResponsiveHelper.isMobile(context);

    // Listen for refresh events
    ref.listen<int>(examRefreshProvider, (previous, next) {
      if (previous != null && next > previous) {
        debugPrint('🔄 Exam refresh triggered, reloading exams...');
        _loadExams();
      }
    });

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
              exam.displayStartTime != null ? _formatDateTime(exam.displayStartTime!) : 'N/A',
              isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            _buildExamDetailRow(
              Icons.calendar_today_outlined,
              'Kết thúc',
              exam.displayEndTime != null ? _formatDateTime(exam.displayEndTime!) : 'N/A',
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
          // Already started - check if submitted or can continue
          return FutureBuilder<bool>(
            future: _isExamSubmitted(exam.ketQuaId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Đang kiểm tra...', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              }

              final isSubmitted = snapshot.data ?? false;

              if (isSubmitted) {
                // Already submitted - wait for exam to end
                return ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Chờ kết thúc kỳ thi', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              } else {
                // Can continue exam
                return ElevatedButton(
                  onPressed: () => _startExam(exam.made),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle, size: 20),
                      SizedBox(width: 8),
                      Text('Tiếp tục thi'),
                    ],
                  ),
                );
              }
            },
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
        if (exam.ketQuaId != null) {
          // Has result - check permissions asynchronously
          return FutureBuilder<bool>(
            future: _canViewResult(exam.made),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Text('Đang kiểm tra...', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              }

              final canView = snapshot.data ?? false;
              return ElevatedButton(
                onPressed: canView ? () => _reviewExam(exam.made, exam.ketQuaId!) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canView ? Colors.blue : Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      canView ? Icons.visibility : Icons.lock,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      canView ? 'Xem kết quả' : 'Chưa được phép xem',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text('Đã kết thúc', style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        }

      case ExamStatus.disabled:
        return ElevatedButton(
          onPressed: null, // Disabled
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[400],
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text('Đề thi đã đóng', style: TextStyle(color: Colors.white)),
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
    // For now, we don't have exam enable/disable status from backend
    // All exams returned from API are considered enabled
    // TODO: Add exam enable/disable status to backend API if needed

    final now = TimezoneHelper.nowInVietnam();
    if (exam.displayStartTime != null && now.isBefore(exam.displayStartTime!)) {
      return ExamStatus.upcoming;
    } else if (exam.displayEndTime != null && now.isAfter(exam.displayEndTime!)) {
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
      case ExamStatus.disabled:
        return Colors.grey;
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
      case ExamStatus.disabled:
        return 'Đã đóng';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    // dateTime is already in GMT+7 when using displayStartTime/displayEndTime
    return '${DateFormat('dd/MM/yyyy HH:mm').format(dateTime)} (GMT+7)';
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

      // TEMPORARY: Disable resume state check để tránh quá nhiều API calls
      // TODO: Optimize resume state check
      final examsWithResumeState = exams;

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

  void _startExam(int examId) async {
    // Check exam status before allowing access
    try {
      final apiService = ref.read(apiServiceProvider);
      final examDetail = await apiService.getDeThiById(examId);

      // Check if exam is disabled
      if (examDetail.trangthai == false) {
        _showErrorDialog(
          'Đề thi đã đóng',
          'Giảng viên đã đóng đề thi này. Sinh viên không thể vào thi.'
        );
        return;
      }

      // Check if can resume exam (optimized - chỉ gọi khi cần)
      final canResume = await _checkCanResumeExam(examId);

      if (canResume) {
        debugPrint('🔄 Can resume exam $examId');
        // TODO: Show resume dialog or navigate directly
      } else {
        debugPrint('🆕 Starting new exam $examId');
      }

      // Navigate to exam taking screen if exam is enabled
      if (mounted) {
        context.push('/sinhvien/exam/$examId');
      }
    } catch (e) {
      debugPrint('❌ Error checking exam status: $e');
      // Continue to exam screen if status check fails (backward compatibility)
      if (mounted) {
        context.push('/sinhvien/exam/$examId');
      }
    }
  }

  /// Check if exam is already submitted
  Future<bool> _isExamSubmitted(int ketQuaId) async {
    try {
      final apiService = ref.read(apiServiceProvider);

      // Try to get exam result - if successful, exam is submitted
      // ExamReviewDto is only returned for submitted exams
      final examDetail = await apiService.getStudentExamResult(ketQuaId);
      return examDetail != null;
    } catch (e) {
      debugPrint('Error checking exam submission status: $e');
      // If error (like 404), assume exam not submitted yet (can continue)
      return false;
    }
  }

  /// Kiểm tra có thể xem kết quả hay không (permissions + timing)
  Future<bool> _canViewResult(int examId) async {
    try {
      final apiService = ref.read(apiServiceProvider);

      // Check exam timing first
      final examDetail = await apiService.getDeThiById(examId);
      final now = TimezoneHelper.nowInVietnam();
      final examStartTime = examDetail.thoigiantbatdau;
      final examEndTime = examDetail.thoigianketthuc;

      if (examStartTime != null && examEndTime != null) {
        final isExamActive = now.isAfter(examStartTime) && now.isBefore(examEndTime);

        if (isExamActive) {
          // Exam is still active - cannot view results
          return false;
        }
      }

      // Check permissions
      final permissionsData = await apiService.getExamPermissions(examId);

      if (permissionsData != null) {
        final permissions = ExamPermissions.fromJson(permissionsData);
        return permissions.canViewAnyResults;
      }

      // Default to false if no permissions data
      return false;
    } catch (e) {
      debugPrint('❌ Error checking result view permissions: $e');
      // Default to false on error for security
      return false;
    }
  }

  void _reviewExam(int examId, int resultId) async {
    debugPrint('🎯 Navigating to exam result: examId=$examId, resultId=$resultId');

    // Kiểm tra nếu resultId hợp lệ
    if (resultId <= 0) {
      _showErrorDialog('Kết quả bài thi chưa sẵn sàng', 'Bài thi của bạn đang được xử lý. Vui lòng thử lại sau.');
      return;
    }

    // Kiểm tra exam timing và permissions trước khi navigate
    try {
      final apiService = ref.read(apiServiceProvider);

      // Check exam timing first
      final examDetail = await apiService.getDeThiById(examId);
      final now = TimezoneHelper.nowInVietnam();
      final examStartTime = examDetail.thoigiantbatdau;
      final examEndTime = examDetail.thoigianketthuc;

      if (examStartTime != null && examEndTime != null) {
        final isExamActive = now.isAfter(examStartTime) && now.isBefore(examEndTime);

        if (isExamActive) {
          _showErrorDialog(
            'Không thể xem kết quả',
            'Không thể xem kết quả trong khi kỳ thi đang diễn ra.\nVui lòng chờ đến khi kỳ thi kết thúc.'
          );
          return;
        }
      }

      // Check permissions
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
  disabled,
}
