import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/phan_cong_model.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/services/phan_cong_service.dart';
import 'package:ckcandr/views/admin/widgets/phan_cong_form_dialog.dart';
import 'package:ckcandr/core/utils/message_utils.dart';

class PhanCongScreen extends ConsumerStatefulWidget {
  const PhanCongScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PhanCongScreen> createState() => _PhanCongScreenState();
}

class _PhanCongScreenState extends ConsumerState<PhanCongScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedLecturer;
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(phanCongNotifierProvider);
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Phân công',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAssignmentDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm phân công'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Thanh tìm kiếm
              isSmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Tìm kiếm phân công',
                          hintText: 'Nhập tên giảng viên hoặc môn học',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _currentPage = 1;
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _currentPage = 1;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _refreshAssignments(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Làm mới'),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Tìm kiếm phân công',
                            hintText: 'Nhập tên giảng viên hoặc môn học',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _currentPage = 1;
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _currentPage = 1;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _refreshAssignments(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Làm mới'),
                      ),
                    ],
                  ),
            ],
          ),
        ),
        
        // Danh sách phân công
        Expanded(
          child: assignmentsAsync.when(
            data: (assignments) {
              // Lọc theo từ khóa tìm kiếm
              final filteredAssignments = assignments.where((assignment) {
                final searchQuery = _searchController.text.toLowerCase().trim();
                return searchQuery.isEmpty ||
                    assignment.hoTen.toLowerCase().contains(searchQuery) ||
                    assignment.tenMonHoc.toLowerCase().contains(searchQuery) ||
                    assignment.maMonHoc.toString().toLowerCase().contains(searchQuery);
              }).toList();

              if (filteredAssignments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không có phân công nào',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Phân trang
              final totalPages = (filteredAssignments.length / _itemsPerPage).ceil();
              final startIndex = (_currentPage - 1) * _itemsPerPage;
              final endIndex = startIndex + _itemsPerPage > filteredAssignments.length
                  ? filteredAssignments.length
                  : startIndex + _itemsPerPage;
              
              final displayedAssignments = filteredAssignments.sublist(
                startIndex < filteredAssignments.length ? startIndex : 0,
                endIndex < filteredAssignments.length ? endIndex : filteredAssignments.length,
              );

              return Column(
                children: [
                  Expanded(
                    child: isSmallScreen
                        ? _buildMobileList(displayedAssignments, theme)
                        : _buildDesktopTable(displayedAssignments, theme),
                  ),
                  
                  // Phân trang
                  if (filteredAssignments.isNotEmpty)
                    _buildPagination(totalPages, theme),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi tải dữ liệu: $error',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.red[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _refreshAssignments(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList(List<PhanCong> assignments, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        assignment.hoTen,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _confirmDeleteAssignment(context, assignment),
                      tooltip: 'Xóa phân công',
                      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildAssignmentInfoRow('Mã môn:', assignment.maMonHoc.toString()),
                _buildAssignmentInfoRow('Môn học:', assignment.tenMonHoc),
                if (assignment.soTinChi != null)
                  _buildAssignmentInfoRow('Số tín chỉ:', assignment.soTinChi.toString()),
                if (assignment.soTietLyThuyet != null)
                  _buildAssignmentInfoRow('Tiết LT:', assignment.soTietLyThuyet.toString()),
                if (assignment.soTietThucHanh != null)
                  _buildAssignmentInfoRow('Tiết TH:', assignment.soTietThucHanh.toString()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(List<PhanCong> assignments, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(
            theme.colorScheme.primary.withOpacity(0.1),
          ),
          columns: const [
            DataColumn(label: Text('STT')),
            DataColumn(label: Text('Giảng viên')),
            DataColumn(label: Text('Mã môn')),
            DataColumn(label: Text('Tên môn học')),
            DataColumn(label: Text('Tín chỉ')),
            DataColumn(label: Text('Tiết LT')),
            DataColumn(label: Text('Tiết TH')),
            DataColumn(label: Text('Hành động')),
          ],
          rows: assignments.asMap().entries.map((entry) {
            final index = entry.key;
            final assignment = entry.value;
            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(assignment.hoTen)),
                DataCell(Text(assignment.maMonHoc.toString())),
                DataCell(Text(assignment.tenMonHoc)),
                DataCell(Text(assignment.soTinChi?.toString() ?? 'N/A')),
                DataCell(Text(assignment.soTietLyThuyet?.toString() ?? 'N/A')),
                DataCell(Text(assignment.soTietThucHanh?.toString() ?? 'N/A')),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteAssignment(context, assignment),
                    tooltip: 'Xóa phân công',
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAssignmentInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int totalPages, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Trang $_currentPage / ${totalPages == 0 ? 1 : totalPages}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _showAddAssignmentDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => const Dialog(
        child: PhanCongFormDialog(),
      ),
    );
  }

  void _confirmDeleteAssignment(BuildContext context, PhanCong assignment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa phân công môn "${assignment.tenMonHoc}" '
          'của giảng viên "${assignment.hoTen}" không?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(phanCongNotifierProvider.notifier)
                    .deleteAssignment(assignment.maMonHoc, assignment.maNguoiDung);
                if (mounted) {
                  await MessageUtils.showSuccess(
                    context,
                    title: 'Xóa thành công',
                    message: 'Phân công đã được xóa khỏi hệ thống.',
                  );
                }
              } catch (e) {
                if (mounted) {
                  await MessageUtils.showError(
                    context,
                    title: 'Lỗi xóa phân công',
                    message: 'Không thể xóa phân công này. Vui lòng thử lại sau.',
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _refreshAssignments() {
    ref.read(phanCongNotifierProvider.notifier).loadAssignments();
  }
}
