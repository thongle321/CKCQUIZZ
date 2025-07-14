/// Exam Management Screen for Teachers (Màn hình quản lý đề kiểm tra cho giảng viên)
///
/// This screen provides a complete interface for teachers to manage their exams,
/// including creating, editing, deleting exams and composing questions.
/// Based on the Vue.js implementation in admin/test/index.vue

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/providers/de_thi_provider.dart';
import 'package:ckcandr/providers/chuong_provider.dart'; // SỬA: Thêm import cho assigned subjects
import 'package:ckcandr/views/giangvien/widgets/de_thi_form_dialog.dart';
import 'package:ckcandr/views/giangvien/widgets/question_composer_dialog.dart';
import 'package:ckcandr/services/auto_refresh_service.dart';
import 'package:ckcandr/services/api_service.dart'; // SỬA: Thêm import cho apiServiceProvider
import 'package:intl/intl.dart';
import 'package:ckcandr/core/widgets/error_dialog.dart';

class DeKiemTraScreen extends ConsumerStatefulWidget {
  const DeKiemTraScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DeKiemTraScreen> createState() => _DeKiemTraScreenState();
}

class _DeKiemTraScreenState extends ConsumerState<DeKiemTraScreen> with AutoRefreshMixin {
  final TextEditingController _searchController = TextEditingController();

  // AutoRefreshMixin implementation
  @override
  String get autoRefreshKey => AutoRefreshKeys.teacherExams;

  @override
  void onAutoRefresh() {
    debugPrint('🔄 Auto-refreshing teacher exams');
    // Refresh danh sách đề thi
    ref.read(deThiListProvider.notifier).refresh();
    // Refresh assigned subjects nếu cần
    ref.invalidate(assignedSubjectsProvider);
  }

  @override
  void initState() {
    super.initState();
    // Dữ liệu môn học được phân công sẽ tự động load thông qua assignedSubjectsProvider
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deThiListAsync = ref.watch(deThiListProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: deThiListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(context, error.toString()),
        data: (deThiListState) => _buildContent(context, deThiListState),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(deThiListProvider.notifier).refresh(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, DeThiListState state) {
    final theme = Theme.of(context);
    final filteredDeThis = state.filteredDeThis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and add button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý đề kiểm tra',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateEditExamDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Tạo đề thi mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm đề thi...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: theme.cardColor,
            ),
            onChanged: (value) {
              ref.read(deThiListProvider.notifier).updateSearchQuery(value);
            },
          ),
        ),

        const SizedBox(height: 16),

        // Exam list
        Expanded(
          child: filteredDeThis.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () => ref.read(deThiListProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredDeThis.length,
                    itemBuilder: (context, index) {
                      final deThi = filteredDeThis[index];
                      return _DeThiCard(
                        deThi: deThi,
                        onEdit: () => _showCreateEditExamDialog(context, editingDeThi: deThi),
                        onDelete: () => _confirmDeleteExam(context, deThi),
                        onCompose: () => _showQuestionComposer(context, deThi),
                        onViewResults: () => _viewExamResults(context, deThi),
                        onToggleStatus: () => _toggleExamStatus(context, deThi),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: theme.disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có đề thi nào',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo đề thi đầu tiên của bạn',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showCreateEditExamDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Tạo đề thi mới'),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  Future<void> _showCreateEditExamDialog(BuildContext context, {DeThiModel? editingDeThi}) async {
    await showDialog(
      context: context,
      builder: (context) => DeThiFormDialog(deThi: editingDeThi),
    );

    // Auto refresh sau khi tạo mới hoặc sửa đề thi
    ref.read(deThiListProvider.notifier).refresh();
  }

  void _confirmDeleteExam(BuildContext context, DeThiModel deThi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc chắn muốn xóa đề thi "${deThi.tende}"?'),
            const SizedBox(height: 8),
            const Text(
              'Hành động này không thể hoàn tác.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();

              // Show loading indicator
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text('Đang xóa đề thi...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              }

              try {
                final success = await ref.read(deThiFormProvider.notifier).deleteDeThi(deThi.made);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  if (success) {
                    // Refresh the exam list to hide the soft-deleted exam
                    await ref.read(deThiListProvider.notifier).loadDeThis();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã xóa đề thi "${deThi.tende}" thành công'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'OK',
                            textColor: Colors.white,
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            },
                          ),
                        ),
                      );
                    }
                  } else {
                    await ErrorDialog.show(
                      context,
                      message: 'Không thể xóa đề thi. Vui lòng thử lại.',
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  await ErrorDialog.show(
                    context,
                    message: 'Lỗi khi xóa đề thi: ${e.toString()}',
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showQuestionComposer(BuildContext context, DeThiModel deThi) {
    showDialog(
      context: context,
      builder: (context) => QuestionComposerDialog(deThi: deThi),
    );
  }

  /// Xem kết quả thi của học sinh
  void _viewExamResults(BuildContext context, DeThiModel deThi) {
    // Navigate to exam results screen - tham khảo Vue.js TestResults.vue
    context.push(
      '/giangvien/exam-results/${deThi.made}?examName=${Uri.encodeComponent(deThi.tende ?? '')}',
    );
  }

  /// Đóng/Mở đề thi
  Future<void> _toggleExamStatus(BuildContext context, DeThiModel deThi) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final newStatus = !deThi.trangthai;

      // Call API to toggle exam status
      await apiService.toggleExamStatus(deThi.made, newStatus);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus ? 'Đã mở đề thi "${deThi.tende}"' : 'Đã đóng đề thi "${deThi.tende}"',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: newStatus ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Auto refresh danh sách đề thi
      ref.read(deThiListProvider.notifier).refresh();

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi thay đổi trạng thái đề thi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }


}

// Widget for displaying exam card
class _DeThiCard extends ConsumerWidget {
  final DeThiModel deThi;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCompose;
  final VoidCallback? onViewResults; // Thêm callback xem kết quả
  final VoidCallback? onToggleStatus; // Thêm callback đóng/mở đề thi

  const _DeThiCard({
    required this.deThi,
    required this.onEdit,
    required this.onDelete,
    required this.onCompose,
    this.onViewResults,
    this.onToggleStatus,
  });

  /// Chuyển đổi text "Giao cho: lớp X, Y, Z" thành chỉ số lượng "3"
  String _getClassCountText(String? giaoCho) {
    if (giaoCho == null || giaoCho.isEmpty) {
      return '0';
    }

    // Đếm số lượng lớp bằng cách đếm dấu phẩy + 1
    // Ví dụ: "lớp A, lớp B, lớp C" -> 3 lớp
    final classCount = giaoCho.split(',').length;
    return classCount.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final trangThai = deThi.getTrangThaiDeThi();

    // SỬA: Lấy tên môn học từ danh sách môn học được phân công
    final assignedSubjectsAsync = ref.watch(assignedSubjectsProvider);
    String tenMonHoc = 'Đang tải...';

    assignedSubjectsAsync.when(
      loading: () => tenMonHoc = 'Đang tải...',
      error: (error, stack) => tenMonHoc = 'Lỗi tải dữ liệu',
      data: (subjects) {
        try {
          final subject = subjects.firstWhere(
            (s) => s.mamonhoc == deThi.monthi,
          );
          tenMonHoc = subject.tenmonhoc;
        } catch (e) {
          // Debug: In ra thông tin để kiểm tra
          debugPrint('🔍 Không tìm thấy môn học với ID: ${deThi.monthi}');
          debugPrint('📚 Danh sách môn học được phân công: ${subjects.map((s) => '${s.mamonhoc}-${s.tenmonhoc}').join(', ')}');
          tenMonHoc = 'Môn học ID: ${deThi.monthi}';
        }
      },
    );

    Color statusColor;
    IconData statusIcon;

    switch (trangThai) {
      case TrangThaiDeThi.sapDienRa:
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
      case TrangThaiDeThi.dangDienRa:
        statusColor = Colors.green;
        statusIcon = Icons.play_circle_outline;
        break;
      case TrangThaiDeThi.daKetThuc:
        statusColor = Colors.grey;
        statusIcon = Icons.check_circle_outline;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    deThi.tende ?? 'Không có tên',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge trạng thái đóng/mở
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: deThi.trangthai ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: deThi.trangthai ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            deThi.trangthai ? Icons.visibility : Icons.visibility_off,
                            color: deThi.trangthai ? Colors.green : Colors.red,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            deThi.trangthai ? 'MỞ' : 'ĐÓNG',
                            style: TextStyle(
                              color: deThi.trangthai ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge trạng thái thời gian
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            trangThai.displayName,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Exam details
            Row(
              children: [
                const Icon(Icons.assignment_outlined, size: 20),
                const SizedBox(width: 8),
                Text('Môn: $tenMonHoc'), // SỬA: Hiển thị tên môn học thay vì ID
                const SizedBox(width: 16),
                const Icon(Icons.class_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(_getClassCountText(deThi.giaoCho))),
              ],
            ),
            const SizedBox(height: 8),

            // Time information (hiển thị theo GMT+7)
            if (deThi.displayStartTime != null && deThi.displayEndTime != null) ...[
              Row(
                children: [
                  const Icon(Icons.schedule, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Từ ${DateFormat('dd/MM/yyyy HH:mm').format(deThi.displayStartTime!)} '
                      'đến ${DateFormat('dd/MM/yyyy HH:mm').format(deThi.displayEndTime!)} (GMT+7)',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Action buttons - phân quyền theo trạng thái đề thi
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                // Soạn câu hỏi - chỉ cho phép khi chưa bắt đầu
                if (trangThai == TrangThaiDeThi.sapDienRa) ...[
                  _buildActionButton(
                    icon: Icons.edit_note,
                    label: 'Soạn câu hỏi',
                    onPressed: onCompose,
                    color: Colors.green,
                  ),
                ],

                // Sửa đề thi - chỉ cho phép khi chưa bắt đầu hoặc đang diễn ra
                if (trangThai == TrangThaiDeThi.sapDienRa || trangThai == TrangThaiDeThi.dangDienRa) ...[
                  _buildActionButton(
                    icon: Icons.edit,
                    label: 'Sửa',
                    onPressed: onEdit,
                    color: Colors.orange,
                  ),
                ],

                // Xóa - chỉ cho phép khi chưa bắt đầu
                if (trangThai == TrangThaiDeThi.sapDienRa) ...[
                  _buildActionButton(
                    icon: Icons.delete,
                    label: 'Xóa',
                    onPressed: onDelete,
                    color: Colors.red,
                  ),
                ],

                // Xem kết quả - hiển thị khi đang diễn ra hoặc đã kết thúc
                if (onViewResults != null && (trangThai == TrangThaiDeThi.dangDienRa || trangThai == TrangThaiDeThi.daKetThuc)) ...[
                  _buildActionButton(
                    icon: Icons.assessment,
                    label: 'Xem kết quả',
                    onPressed: onViewResults!,
                    // Màu thay đổi theo trạng thái thời gian
                    color: trangThai == TrangThaiDeThi.dangDienRa
                        ? Colors.orange  // Màu cam khi đang thi
                        : Colors.blue,   // Màu xanh dương khi đã kết thúc
                  ),
                ],

                // Đóng/Mở đề thi - hiển thị khi đang diễn ra hoặc đã kết thúc
                if (onToggleStatus != null && (trangThai == TrangThaiDeThi.dangDienRa || trangThai == TrangThaiDeThi.daKetThuc)) ...[
                  _buildActionButton(
                    icon: deThi.trangthai ? Icons.visibility_off : Icons.visibility,
                    label: deThi.trangthai ? 'Đóng đề' : 'Mở đề',
                    onPressed: onToggleStatus!,
                    color: deThi.trangthai ? Colors.red : Colors.green,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method để tạo action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null ? color : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}