import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/nhom_quyen_model.dart';
import 'package:ckcandr/services/nhom_quyen_service.dart';
import 'package:ckcandr/views/admin/widgets/nhom_quyen_form_dialog.dart';

class NhomQuyenScreen extends ConsumerStatefulWidget {
  const NhomQuyenScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NhomQuyenScreen> createState() => _NhomQuyenScreenState();
}

class _NhomQuyenScreenState extends ConsumerState<NhomQuyenScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissionGroupsAsync = ref.watch(nhomQuyenNotifierProvider);
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
                      'Nhóm quyền',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Ẩn nút thêm mới vì nhóm quyền dựa trên 3 role có sẵn
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      'Quản lý quyền cho 3 role: Admin, Teacher, Student',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                          labelText: 'Tìm kiếm nhóm quyền',
                          hintText: 'Nhập tên nhóm quyền...',
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
                        onPressed: () => _refreshPermissionGroups(),
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
                            labelText: 'Tìm kiếm nhóm quyền',
                            hintText: 'Nhập tên nhóm quyền...',
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
                        onPressed: () => _refreshPermissionGroups(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Làm mới'),
                      ),
                    ],
                  ),
            ],
          ),
        ),
        
        // Danh sách nhóm quyền
        Expanded(
          child: permissionGroupsAsync.when(
            data: (permissionGroups) {
              // Lọc theo từ khóa tìm kiếm
              final filteredGroups = permissionGroups.where((group) {
                final searchQuery = _searchController.text.toLowerCase().trim();
                return searchQuery.isEmpty ||
                    group.tenNhomQuyen.toLowerCase().contains(searchQuery);
              }).toList();

              if (filteredGroups.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.security,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không có nhóm quyền nào',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Phân trang
              final totalPages = (filteredGroups.length / _itemsPerPage).ceil();
              final startIndex = (_currentPage - 1) * _itemsPerPage;
              final endIndex = startIndex + _itemsPerPage > filteredGroups.length
                  ? filteredGroups.length
                  : startIndex + _itemsPerPage;
              
              final displayedGroups = filteredGroups.sublist(
                startIndex < filteredGroups.length ? startIndex : 0,
                endIndex < filteredGroups.length ? endIndex : filteredGroups.length,
              );

              return Column(
                children: [
                  Expanded(
                    child: isSmallScreen
                        ? _buildMobileList(displayedGroups, theme)
                        : _buildDesktopTable(displayedGroups, theme),
                  ),
                  
                  // Phân trang
                  if (filteredGroups.isNotEmpty)
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
                    onPressed: () => _refreshPermissionGroups(),
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

  Widget _buildMobileList(List<NhomQuyen> groups, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
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
                        group.tenNhomQuyen,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditPermissionGroupDialog(context, group);
                        }
                        // Ẩn chức năng xóa vì nhóm quyền dựa trên role có sẵn
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Xem/Sửa quyền'),
                            ],
                          ),
                        ),
                        // Ẩn option xóa
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildGroupInfoRow('Số người dùng:', '${group.soNguoiDung ?? 0}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(List<NhomQuyen> groups, ThemeData theme) {
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
            DataColumn(label: Text('Tên nhóm')),
            DataColumn(label: Text('Số người dùng')),
            DataColumn(label: Text('Hành động')),
          ],
          rows: groups.map((group) {
            return DataRow(
              cells: [
                DataCell(Text(group.tenNhomQuyen)),
                DataCell(Text('${group.soNguoiDung ?? 0}')),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditPermissionGroupDialog(context, group),
                      tooltip: 'Xem/Sửa quyền',
                    ),
                    // Ẩn nút xóa vì nhóm quyền dựa trên role có sẵn
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGroupInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  Future<void> _showAddPermissionGroupDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => const Dialog(
        child: NhomQuyenFormDialog(),
      ),
    );
  }

  Future<void> _showEditPermissionGroupDialog(BuildContext context, NhomQuyen group) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: NhomQuyenFormDialog(permissionGroup: group),
      ),
    );
  }

  void _confirmDeletePermissionGroup(BuildContext context, NhomQuyen group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa nhóm quyền "${group.tenNhomQuyen}" không?'
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
                await ref.read(nhomQuyenNotifierProvider.notifier)
                    .deletePermissionGroup(group.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa nhóm quyền thành công!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi xóa nhóm quyền: $e')),
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

  void _refreshPermissionGroups() {
    ref.read(nhomQuyenNotifierProvider.notifier).loadPermissionGroups();
  }
}
