import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/role_management_model.dart';
import 'package:ckcandr/providers/role_management_provider.dart';
import 'package:ckcandr/providers/permission_provider.dart';
import 'package:ckcandr/widgets/common/loading_widget.dart';
import 'package:ckcandr/widgets/common/error_widget.dart';
import 'package:ckcandr/services/auto_refresh_service.dart';
import 'package:ckcandr/screens/admin/role_form_screen.dart';

class RoleManagementScreen extends ConsumerStatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  ConsumerState<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends ConsumerState<RoleManagementScreen> with AutoRefreshMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  // AutoRefreshMixin implementation
  @override
  String get autoRefreshKey => AutoRefreshKeys.adminPermissions;

  @override
  void onAutoRefresh() {
    debugPrint('🔄 Auto-refreshing admin permissions');
    // Refresh role groups
    ref.invalidate(roleGroupsProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleGroupsAsync = ref.watch(roleGroupsProvider);
    final permissionService = ref.watch(permissionServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nhóm quyền'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Header với search và button thêm mới
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm nhóm quyền...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Add button
                FutureBuilder<bool>(
                  future: permissionService.canCreate('nhomquyen'),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return ElevatedButton.icon(
                        onPressed: () => _navigateToForm(context, null),
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm mới'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: roleGroupsAsync.when(
              data: (roleGroups) {
                final filteredGroups = _filterRoleGroups(roleGroups);
                
                if (filteredGroups.isEmpty) {
                  return const Center(
                    child: Text('Không có nhóm quyền nào'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(roleGroupsProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) {
                      final roleGroup = filteredGroups[index];
                      return _buildRoleGroupCard(context, roleGroup);
                    },
                  ),
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) => ErrorWidgetCustom(
                message: 'Không thể tải danh sách nhóm quyền',
                onRetry: () => ref.read(roleGroupsProvider.notifier).refresh(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<RoleGroup> _filterRoleGroups(List<RoleGroup> roleGroups) {
    if (_searchText.isEmpty) return roleGroups;
    
    return roleGroups.where((group) {
      return group.tenNhomQuyen.toLowerCase().contains(_searchText);
    }).toList();
  }

  Widget _buildRoleGroupCard(BuildContext context, RoleGroup roleGroup) {
    final permissionService = ref.watch(permissionServiceProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          roleGroup.tenNhomQuyen,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Số người dùng: ${roleGroup.soNguoiDung}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            FutureBuilder<bool>(
              future: permissionService.canUpdate('nhomquyen'),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToForm(context, roleGroup.id),
                    tooltip: 'Sửa nhóm quyền',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Delete button
            FutureBuilder<bool>(
              future: permissionService.canDelete('nhomquyen'),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(context, roleGroup),
                    tooltip: 'Xóa nhóm quyền',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, String? roleGroupId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoleFormScreen(roleGroupId: roleGroupId),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, RoleGroup roleGroup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa nhóm quyền "${roleGroup.tenNhomQuyen}"?\n\n'
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteRoleGroup(roleGroup.id);
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

  Future<void> _deleteRoleGroup(String id) async {
    try {
      await ref.read(roleGroupsProvider.notifier).deleteRoleGroup(id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa nhóm quyền thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa nhóm quyền: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
