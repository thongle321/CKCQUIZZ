import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';

/// Admin screen for managing subjects (môn học)
class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> {
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
    final allSubjects = ref.watch(monHocListProvider);
    final filteredSubjects = _searchQuery.isEmpty
        ? allSubjects
        : allSubjects.where((subject) {
            final query = _searchQuery.toLowerCase();
            return subject.tenMonHoc.toLowerCase().contains(query) ||
                   subject.maMonHoc.toLowerCase().contains(query);
          }).toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý môn học'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(monHocProvider.notifier).loadSubjects();
            },
            tooltip: 'Làm mới',
          ),
        ],
      ),
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
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(MonHocState state, List<MonHoc> subjects, ThemeData theme) {
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
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
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
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Nhấn nút + để thêm môn học mới',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: subject.trangThai 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              child: Text(
                subject.maMonHoc.toString(),
                style: TextStyle(
                  color: subject.trangThai 
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              subject.tenMonHoc,
              style: theme.textTheme.titleMedium?.copyWith(
                color: subject.trangThai 
                    ? null 
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mã: ${subject.maMonHoc}'),
                Text('Tín chỉ: ${subject.soTinChi}'),
                Text('LT: ${subject.soGioLT} - TH: ${subject.soGioTH}'),
                if (!subject.trangThai)
                  Text(
                    'Không hoạt động',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
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
                  case 'toggle_status':
                    _toggleSubjectStatus(subject);
                    break;
                  case 'delete':
                    _showDeleteConfirmDialog(context, subject);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Chỉnh sửa'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle_status',
                  child: ListTile(
                    leading: Icon(subject.trangThai ? Icons.visibility_off : Icons.visibility),
                    title: Text(subject.trangThai ? 'Vô hiệu hóa' : 'Kích hoạt'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Xóa', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    // TODO: Implement add subject dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thêm môn học sẽ được triển khai sau')),
    );
  }

  void _showEditSubjectDialog(BuildContext context, MonHoc subject) {
    // TODO: Implement edit subject dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng chỉnh sửa môn học sẽ được triển khai sau')),
    );
  }

  void _toggleSubjectStatus(MonHoc subject) {
    // TODO: Implement toggle status
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thay đổi trạng thái sẽ được triển khai sau')),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, MonHoc subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa môn học "${subject.tenMonHoc}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // TODO: Implement delete subject
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chức năng xóa môn học sẽ được triển khai sau'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
