/// API User Management Screen for Admin
/// 
/// This screen provides user management functionality using real API calls
/// to the ASP.NET Core backend server.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/api_user_provider.dart';
import 'package:ckcandr/core/widgets/role_themed_screen.dart';
import 'package:ckcandr/views/admin/api_user_form_dialog.dart';

class ApiUserScreen extends ConsumerStatefulWidget {
  const ApiUserScreen({super.key});

  @override
  ConsumerState<ApiUserScreen> createState() => _ApiUserScreenState();
}

class _ApiUserScreenState extends ConsumerState<ApiUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load users when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(apiUserProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiUserState = ref.watch(apiUserProvider);
    final rolesAsync = ref.watch(rolesProvider);

    return RoleThemedScreen(
      title: 'Quản lý người dùng (API)',
      body: Column(
        children: [
          _buildSearchAndActions(),
          if (apiUserState.error != null) _buildErrorBanner(),
          Expanded(
            child: apiUserState.isLoading && apiUserState.users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _buildUserList(apiUserState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(rolesAsync),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndActions() {
    return UnifiedCard(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm theo tên, email, MSSV...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              // Debounce search
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchQuery == value) {
                  ref.read(apiUserProvider.notifier).searchUsers(value);
                }
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              UnifiedButton(
                text: 'Làm mới',
                icon: Icons.refresh,
                isOutlined: true,
                onPressed: () {
                  ref.read(apiUserProvider.notifier).refresh();
                },
              ),
              const Spacer(),
              const Text('Tổng số: '),
              Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(apiUserProvider);
                  return Text(
                    '${state.totalCount}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    final error = ref.watch(apiUserProvider).error!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(apiUserProvider.notifier).clearError();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(ApiUserState state) {
    if (state.users.isEmpty && !state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có người dùng nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.users.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.users.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = state.users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(GetNguoiDungDTO user) {
    return UnifiedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(
                  user.hoten.isNotEmpty ? user.hoten[0].toUpperCase() : 'U',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.hoten,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'MSSV: ${user.mssv}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(user.trangthai ?? true),
            ],
          ),
          const SizedBox(height: 12),
          _buildUserInfo(user),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              UnifiedButton(
                text: 'Sửa',
                icon: Icons.edit,
                isText: true,
                onPressed: () => _showEditUserDialog(user),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Xóa'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => _confirmDeleteUser(user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return UnifiedStatusChip(
      label: isActive ? 'Hoạt động' : 'Khóa',
      backgroundColor: isActive ? Colors.green : Colors.red,
    );
  }

  Widget _buildUserInfo(GetNguoiDungDTO user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.email, 'Email', user.email),
        if (user.phoneNumber.isNotEmpty)
          _buildInfoRow(Icons.phone, 'Điện thoại', user.phoneNumber),
        if (user.ngaysinh != null)
          _buildInfoRow(
            Icons.cake,
            'Ngày sinh',
            DateFormat('dd/MM/yyyy').format(user.ngaysinh!),
          ),
        if (user.currentRole != null)
          _buildInfoRow(Icons.security, 'Vai trò', user.currentRole!),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(AsyncValue<List<String>> rolesAsync) {
    rolesAsync.when(
      data: (roles) {
        _showUserFormDialog(null, roles);
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang tải danh sách vai trò...')),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải vai trò: $error')),
        );
      },
    );
  }

  void _showEditUserDialog(GetNguoiDungDTO user) {
    final rolesAsync = ref.read(rolesProvider);
    rolesAsync.when(
      data: (roles) {
        _showUserFormDialog(user, roles);
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang tải danh sách vai trò...')),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải vai trò: $error')),
        );
      },
    );
  }

  void _showUserFormDialog(GetNguoiDungDTO? user, List<String> roles) {
    showDialog(
      context: context,
      builder: (context) => ApiUserFormDialog(
        user: user,
        availableRoles: roles,
      ),
    );
  }

  void _confirmDeleteUser(GetNguoiDungDTO user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa người dùng "${user.hoten}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(apiUserProvider.notifier)
                  .deleteUser(user.mssv);
              
              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa người dùng thành công')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
