import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/views/admin/mon_hoc_form_dialog.dart';

class MonHocScreen extends ConsumerStatefulWidget {
  const MonHocScreen({super.key});

  @override
  ConsumerState<MonHocScreen> createState() => _MonHocScreenState();
}

class _MonHocScreenState extends ConsumerState<MonHocScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load subjects when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(monHocProvider.notifier).loadSubjects();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monHocState = ref.watch(monHocProvider);
    final theme = Theme.of(context);

    // Filter subjects based on search query
    final filteredSubjects = monHocState.subjects.where((subject) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return subject.tenMonHoc.toLowerCase().contains(query) ||
             subject.maMonHoc.toString().contains(query);
    }).toList();

    return Scaffold(
      
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm môn học...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Refresh button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(monHocProvider.notifier).loadSubjects();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _buildContent(monHocState, filteredSubjects, theme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSubjectDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(MonHocState state, List<ApiMonHoc> subjects, ThemeData theme) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi: ${state.error}',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(monHocProvider.notifier).loadSubjects();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Chưa có môn học nào'
                  : 'Không tìm thấy môn học phù hợp',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _buildSubjectCard(subject, theme);
      },
    );
  }

  Widget _buildSubjectCard(ApiMonHoc subject, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            subject.maMonHoc.toString(),
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          subject.tenMonHoc,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã môn: ${subject.maMonHoc}'),
            Text('Tín chỉ: ${subject.soTinChi}'),
            Text('LT: ${subject.soTietLyThuyet} - TH: ${subject.soTietThucHanh}'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: subject.trangThai ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                subject.trangThai ? 'Hoạt động' : 'Không hoạt động',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditSubjectDialog(context, subject);
                break;
              case 'delete':
                _showDeleteConfirmDialog(context, subject);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Xóa'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const MonHocFormDialog(),
    );
  }

  void _showEditSubjectDialog(BuildContext context, ApiMonHoc subject) {
    showDialog(
      context: context,
      builder: (context) => MonHocFormDialog(monHoc: subject),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, ApiMonHoc subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa môn học "${subject.tenMonHoc}"?\n\nHành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleDeleteSubject(subject);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteSubject(ApiMonHoc subject) async {
    final success = await ref.read(monHocProvider.notifier).deleteSubject(subject.maMonHoc);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Đã xóa môn học "${subject.tenMonHoc}" thành công!'
              : 'Không thể xóa môn học. ${ref.read(monHocProvider).error ?? ""}'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
