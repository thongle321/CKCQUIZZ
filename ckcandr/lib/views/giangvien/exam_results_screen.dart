import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/exam_results_provider.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/models/exam_taking_model.dart';
import 'package:ckcandr/models/de_thi_model.dart'; // Import for TimezoneHelper
import 'package:ckcandr/core/utils/responsive_helper.dart';
import 'package:ckcandr/services/ket_qua_service.dart';

/// Exam Results Screen - Màn hình xem kết quả thi cho giáo viên
/// Hiển thị danh sách sinh viên đã thi, điểm số và chi tiết đáp án
class ExamResultsScreen extends ConsumerStatefulWidget {
  final int examId;
  final String? examName;

  const ExamResultsScreen({
    super.key,
    required this.examId,
    this.examName,
  });

  @override
  ConsumerState<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends ConsumerState<ExamResultsScreen> {
  String _sortBy = 'score';
  bool _sortAscending = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final KetQuaService _ketQuaService = KetQuaService();

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// load kết quả thi
  void _loadResults() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(examResultsProvider.notifier).loadExamResults(widget.examId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.giangVien;
    final resultsState = ref.watch(examResultsProvider);
    final stats = ref.watch(examResultsStatsProvider);
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(role, theme),
      body: Column(
        children: [
          // thống kê tổng quan
          _buildStatsCard(theme, stats, isSmallScreen),
          
          // thanh tìm kiếm và lọc
          _buildSearchAndFilter(theme, resultsState, isSmallScreen),
          
          // danh sách kết quả
          Expanded(
            child: _buildResultsList(theme, resultsState, isSmallScreen),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(role),
    );
  }

  /// xây dựng app bar
  PreferredSizeWidget _buildAppBar(UserRole role, ThemeData theme) {
    return AppBar(
      backgroundColor: RoleTheme.getPrimaryColor(role),
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kết quả thi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.examName != null)
            Text(
              widget.examName!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showExportDialog(),
          icon: const Icon(Icons.download),
          tooltip: 'Xuất file',
        ),
        IconButton(
          onPressed: () => _loadResults(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Làm mới',
        ),
      ],
    );
  }

  /// xây dựng card thống kê
  Widget _buildStatsCard(ThemeData theme, Map<String, dynamic> stats, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê tổng quan',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (isSmallScreen) ...[
            // layout dọc cho mobile
            _buildStatItem('Tổng số sinh viên', '${stats['totalStudents'] ?? 0}', Icons.people),
            const SizedBox(height: 8),
            _buildStatItem('Điểm trung bình', stats['totalStudents'] == 0 ? 'N/A' : '${(stats['averageScore'] ?? 0).toStringAsFixed(1)}/10', Icons.grade),
            const SizedBox(height: 8),
            _buildStatItem('Tỷ lệ đậu', stats['totalStudents'] == 0 ? 'N/A' : '${(stats['passRate'] ?? 0).toStringAsFixed(1)}%', Icons.check_circle),
          ] else ...[
            // layout ngang cho desktop/tablet
            Row(
              children: [
                Expanded(child: _buildStatItem('Tổng số sinh viên', '${stats['totalStudents'] ?? 0}', Icons.people)),
                Expanded(child: _buildStatItem('Điểm trung bình', stats['totalStudents'] == 0 ? 'N/A' : '${(stats['averageScore'] ?? 0).toStringAsFixed(1)}/10', Icons.grade)),
                Expanded(child: _buildStatItem('Tỷ lệ đậu', stats['totalStudents'] == 0 ? 'N/A' : '${(stats['passRate'] ?? 0).toStringAsFixed(1)}%', Icons.check_circle)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatItem('Điểm cao nhất', stats['totalStudents'] == 0 ? 'N/A' : '${stats['highestScore'] ?? 0}/10', Icons.trending_up, Colors.green)),
                Expanded(child: _buildStatItem('Điểm thấp nhất', stats['totalStudents'] == 0 ? 'N/A' : '${stats['lowestScore'] ?? 0}/10', Icons.trending_down, Colors.red)),
                Expanded(child: _buildStatItem('Số người đậu', '${stats['passedCount'] ?? 0}', Icons.check, Colors.green)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// xây dựng item thống kê
  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? Colors.blue,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// xây dựng thanh tìm kiếm và lọc
  Widget _buildSearchAndFilter(ThemeData theme, ExamResultsState resultsState, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // filter theo lớp học
          if (resultsState.classes.isNotEmpty) ...[
            Row(
              children: [
                const Text('Lớp học:'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<int?>(
                    value: resultsState.selectedClassId,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tất cả lớp')),
                      ...resultsState.classes.map((lop) => DropdownMenuItem(
                        value: lop.classId,
                        child: Text(lop.className),
                      )),
                    ],
                    onChanged: (value) {
                      ref.read(examResultsProvider.notifier).selectClass(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // thanh tìm kiếm
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên sinh viên hoặc MSSV...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 12),

          // sắp xếp
          Row(
            children: [
              const Text('Sắp xếp theo:'),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _sortBy,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'score', child: Text('Điểm số')),
                    DropdownMenuItem(value: 'name', child: Text('Tên sinh viên')),
                    DropdownMenuItem(value: 'studentId', child: Text('MSSV')),
                    DropdownMenuItem(value: 'status', child: Text('Trạng thái')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                      _applySorting();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                  _applySorting();
                },
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                tooltip: _sortAscending ? 'Tăng dần' : 'Giảm dần',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// áp dụng sắp xếp
  void _applySorting() {
    ref.read(examResultsProvider.notifier).sortStudents(_sortBy, _sortAscending);
  }

  /// xây dựng danh sách kết quả
  Widget _buildResultsList(ThemeData theme, ExamResultsState state, bool isSmallScreen) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải kết quả...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      // Kiểm tra nếu lỗi là do không có dữ liệu
      final isNoDataError = state.error!.toLowerCase().contains('not found') ||
                           state.error!.toLowerCase().contains('404') ||
                           state.error!.toLowerCase().contains('không tìm thấy');

      if (isNoDataError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: Colors.orange[400],
              ),
              const SizedBox(height: 20),
              Text(
                'Không tìm thấy dữ liệu',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.orange[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đề thi này có thể chưa được gán cho lớp nào\nhoặc chưa có sinh viên làm bài',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _loadResults(),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      // Lỗi thực sự từ API
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Có lỗi xảy ra',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.red[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Text(
                state.error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadResults(),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (state.students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Lớp rỗng',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Không có sinh viên nào trong lớp này\nhoặc chưa có ai làm bài thi',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Có thể do:',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Lớp chưa được gán sinh viên\n'
                    '• Đề thi chưa được gán cho lớp\n'
                    '• Sinh viên chưa làm bài thi',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // lọc sinh viên theo tìm kiếm
    final filteredStudents = state.students.where((student) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return student.fullName.toLowerCase().contains(query) ||
             student.studentId.toLowerCase().contains(query);
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return _buildStudentCard(theme, student, index + 1, isSmallScreen);
      },
    );
  }

  /// xây dựng card kết quả của từng sinh viên
  Widget _buildStudentCard(ThemeData theme, StudentResult student, int rank, bool isSmallScreen) {
    final scoreColor = _getScoreColor(student.displayScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Click vào phần thông tin sinh viên để xem bài làm (chỉ nếu đã thi)
          Expanded(
            child: InkWell(
              onTap: student.hasSubmitted ? () => _showStudentSubmission(student) : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // header với rank và thông tin sinh viên
                    Row(
                      children: [
                        // rank badge
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getRankColor(rank),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // thông tin sinh viên
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.fullName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'MSSV: ${student.studentId}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (student.startTime != null)
                                Text(
                                  'Thời gian: ${_formatDateTime(student.startTime!)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // trạng thái và thống kê
                    Row(
                      children: [
                        // trạng thái
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(student.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getStatusColor(student.status).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            student.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(student.status),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // thời gian làm bài (nếu có)
                        if (student.durationInMinutes != null)
                          _buildDetailItem(
                            Icons.access_time,
                            '${student.durationInMinutes} phút',
                            Colors.blue,
                          ),

                        const Spacer(),

                        // số lần chuyển tab (nếu có)
                        if (student.tabSwitchCount > 0)
                          _buildDetailItem(
                            Icons.warning,
                            '${student.tabSwitchCount} lần thoát',
                            Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Click vào điểm để chỉnh sửa
          InkWell(
            onTap: () => _showScoreEditDialog(student),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      '${student.displayScore.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      '/10',
                      style: TextStyle(
                        fontSize: 12,
                        color: scoreColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// xây dựng item chi tiết
  Widget _buildDetailItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// xây dựng floating action button
  Widget? _buildFloatingActionButton(UserRole role) {
    return FloatingActionButton(
      onPressed: () => _showExportDialog(),
      backgroundColor: RoleTheme.getPrimaryColor(role),
      child: const Icon(Icons.download, color: Colors.white),
    );
  }

  /// hiển thị chi tiết kết quả
  void _showResultDetail(ExamResult result) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: ResponsiveHelper.isMobile(context) ? null : 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: RoleTheme.getPrimaryColor(UserRole.giangVien),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chi tiết kết quả - ${result.studentId}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // thông tin tổng quan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Điểm số:', '${result.score}/10'),
                    _buildInfoRow('Số câu đúng:', '${result.correctAnswers}/${result.totalQuestions}'),
                    _buildInfoRow('Thời gian làm bài:', _formatDuration(result.duration)),
                    _buildInfoRow('Thời gian bắt đầu:', _formatDateTime(result.startTime)),
                    _buildInfoRow('Thời gian nộp bài:', _formatDateTime(result.completedTime)),
                    _buildInfoRow('Đánh giá:', result.grade),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // nút xem chi tiết đáp án
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showDetailedAnswers(result);
                  },
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Xem chi tiết đáp án'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RoleTheme.getPrimaryColor(UserRole.giangVien),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// lấy màu theo điểm số
  Color _getScoreColor(double score) {
    if (score >= 9) return Colors.green;
    if (score >= 8) return Colors.lightGreen;
    if (score >= 7) return Colors.orange;
    if (score >= 5) return Colors.amber;
    return Colors.red;
  }

  /// lấy màu theo rank
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // vàng
      case 2:
        return Colors.grey; // bạc
      case 3:
        return Colors.brown; // đồng
      default:
        return Colors.blue;
    }
  }

  /// format thời gian (hiển thị theo GMT+7)
  String _formatDateTime(DateTime dateTime) {
    // Convert to GMT+7 for display if the dateTime is in UTC
    final localTime = TimezoneHelper.toLocal(dateTime);
    return '${DateFormat('dd/MM/yyyy HH:mm').format(localTime)} (GMT+7)';
  }

  /// format duration
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// xây dựng row thông tin
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// hiển thị chi tiết đáp án
  void _showDetailedAnswers(ExamResult result) {
    // load chi tiết từ API
    ref.read(examResultsProvider.notifier).loadResultDetail(result.resultId);

    // navigate to detailed answers screen
    context.push('/giangvien/exam-result-detail/${result.resultId}');
  }

  /// lấy màu sắc theo trạng thái
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã nộp':
        return Colors.green;
      case 'Chưa nộp':
        return Colors.orange;
      case 'Vắng thi':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// hiển thị dialog chỉnh sửa điểm
  void _showScoreEditDialog(StudentResult student) {
    final TextEditingController scoreController = TextEditingController(
      text: student.displayScore.toStringAsFixed(1),
    );
    final formKey = GlobalKey<FormState>(debugLabel: 'score_edit_${student.studentId}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa điểm'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin sinh viên
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text('MSSV: ${student.studentId}'),
                    Text('Trạng thái: ${student.status}'),
                    if (student.hasSubmitted && student.startTime != null)
                      Text('Thời gian thi: ${_formatDateTime(student.startTime!)}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Input điểm số
              TextFormField(
                controller: scoreController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Điểm số',
                  hintText: 'Nhập điểm từ 0 đến 10',
                  border: OutlineInputBorder(),
                  suffixText: '/10',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập điểm';
                  }
                  final score = double.tryParse(value);
                  if (score == null) {
                    return 'Điểm phải là số';
                  }
                  if (score < 0 || score > 10) {
                    return 'Điểm phải từ 0 đến 10';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Validate real-time
                  formKey.currentState?.validate();
                },
              ),

              const SizedBox(height: 12),

              // Ghi chú
              if (!student.hasSubmitted)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sinh viên chưa thi. Điểm sẽ được ghi nhận thủ công.',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final newScore = double.parse(scoreController.text);
                Navigator.pop(context);
                await _updateStudentScore(student, newScore);
              }
            },
            child: const Text('Lưu điểm'),
          ),
        ],
      ),
    );
  }

  /// cập nhật điểm số sinh viên
  Future<void> _updateStudentScore(StudentResult student, double newScore) async {
    try {
      // Gọi API cập nhật điểm
      final result = await _ketQuaService.updateScore(
        examId: widget.examId,
        studentId: student.studentId,
        newScore: newScore,
      );

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${result['message']}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Refresh data after successful update
          await ref.read(examResultsProvider.notifier).refresh(widget.examId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['message']}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật điểm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// hiển thị bài làm của sinh viên
  void _showStudentSubmission(StudentResult student) {
    debugPrint('👆 _showStudentSubmission called for: ${student.fullName}');
    debugPrint('👆 Student hasSubmitted: ${student.hasSubmitted}');

    if (!student.hasSubmitted) {
      debugPrint('❌ Student has not submitted yet');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${student.fullName} chưa nộp bài thi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    debugPrint('✅ Student has submitted, calling _findAndNavigateToStudentResult');
    // Tìm ketQuaId từ student data
    // Vì StudentResult không có ketQuaId, ta cần tìm cách khác
    // Có thể sử dụng API để tìm ketQuaId dựa trên examId và studentId
    _findAndNavigateToStudentResult(student);
  }

  /// tìm ketQuaId và điều hướng đến màn hình xem bài làm
  Future<void> _findAndNavigateToStudentResult(StudentResult student) async {
    debugPrint('🔍 _findAndNavigateToStudentResult called for student: ${student.fullName} (${student.studentId})');
    debugPrint('🔍 ExamId: ${widget.examId}');

    try {
      debugPrint('🌐 Calling findKetQuaId API...');
      // Gọi API tìm ketQuaId
      final result = await _ketQuaService.findKetQuaId(
        examId: widget.examId,
        studentId: student.studentId,
      );

      debugPrint('📥 findKetQuaId API result: $result');

      if (mounted) {
        if (result['success']) {
          final ketQuaId = result['ketQuaId'];
          debugPrint('✅ API success! ketQuaId: $ketQuaId');
          if (ketQuaId != null) {
            final route = '/giangvien/student-result-detail/${widget.examId}/${Uri.encodeComponent(student.studentId)}?studentName=${Uri.encodeComponent(student.fullName)}&examName=${Uri.encodeComponent(widget.examName ?? 'Đề thi')}';
            debugPrint('🚀 NEW CODE: Navigating to teacher detail screen: $route');
            // Navigate to teacher student result detail screen
            context.push(route);
          } else {
            debugPrint('❌ ketQuaId is null');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Không tìm thấy ketQuaId cho ${student.fullName}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          debugPrint('❌ API failed: ${result['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['message']}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }

    } catch (e) {
      debugPrint('💥 Exception in _findAndNavigateToStudentResult: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải bài làm của ${student.fullName}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  /// hiển thị dialog export
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xuất kết quả thi'),
        content: const Text('Chọn định dạng file để xuất:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportResults('excel');
            },
            child: const Text('Excel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportResults('pdf');
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  /// export kết quả
  Future<void> _exportResults(String format) async {
    try {
      final downloadUrl = await ref.read(examResultsProvider.notifier).exportResults(widget.examId, format);

      if (downloadUrl != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xuất file thành công! Đang tải xuống...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xuất file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


}
