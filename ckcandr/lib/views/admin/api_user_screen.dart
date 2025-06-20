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
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/services/http_client_service.dart';
import 'package:ckcandr/services/auth_service.dart';
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
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    // Load users when screen initializes, but wait for authentication to be ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWithAuth();
    });
  }

  /// Initialize API calls after ensuring authentication is ready
  Future<void> _initializeWithAuth() async {
    try {
      // Check if user is authenticated
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        debugPrint('⚠️ No authenticated user found, skipping API initialization');
        return;
      }

      // Wait a bit for authentication cookies to be fully established
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if authentication is ready by testing a simple API call
      final httpClient = ref.read(httpClientServiceProvider);
      final isReady = await httpClient.isLoggedIn();

      if (isReady) {
        debugPrint('✅ Authentication ready, loading users...');

        // Try to load users - if it fails with 401, we need to refresh authentication
        try {
          await ref.read(apiUserProvider.notifier).loadUsers();
        } catch (e) {
          debugPrint('❌ Initial API call failed, attempting to refresh authentication...');
          await _refreshAuthenticationAndRetry();
        }
      } else {
        debugPrint('⚠️ Authentication not ready, will retry when user interacts');
      }
    } catch (e) {
      debugPrint('❌ Error during API initialization: $e');
      // Don't throw error, let user manually refresh if needed
    }
  }

  /// Refresh authentication and retry API calls
  Future<void> _refreshAuthenticationAndRetry() async {
    try {
      // Force a fresh login to get new cookies
      final authService = ref.read(authServiceProvider);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser != null) {
        // Try to refresh the session
        final refreshedUser = await authService.validateSession();
        if (refreshedUser != null) {
          // Wait a bit for cookies to be set
          await Future.delayed(const Duration(milliseconds: 1000));

          // Try loading users again
          ref.read(apiUserProvider.notifier).loadUsers();
        } else {
          debugPrint('⚠️ Session refresh failed, user may need to login again');
        }
      }
    } catch (e) {
      debugPrint('❌ Error refreshing authentication: $e');
    }
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

    // Listen to user changes and reload data when user logs in
    ref.listen<User?>(currentUserProvider, (previous, next) {
      if (previous == null && next != null) {
        // User just logged in, wait a bit then load data
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            ref.read(apiUserProvider.notifier).loadUsers();
            ref.invalidate(rolesProvider);
          }
        });
      }
    });

    return Scaffold(
      
      body: Column(
        children: [
          _buildSearchBar(),
          _buildRefreshAndStats(),
          const SizedBox(height: 16),
          if (apiUserState.error != null) _buildErrorBanner(),
          Expanded(
            child: apiUserState.isLoading && apiUserState.users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(apiUserProvider.notifier).refresh();
                      // Also refresh roles
                      ref.invalidate(rolesProvider);
                    },
                    child: _buildUserList(apiUserState),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(rolesAsync),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                  ref.read(apiUserProvider.notifier).searchUsers(value, role: _selectedRole);
                }
              });
            },
          ),
          const SizedBox(height: 12),
          // Role filter dropdown
          Consumer(
            builder: (context, ref, child) {
              final rolesAsync = ref.watch(rolesProvider);
              return rolesAsync.when(
                data: (roles) => DropdownButtonFormField<String?>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Lọc theo vai trò',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tất cả vai trò'),
                    ),
                    ...roles.map((role) => DropdownMenuItem<String?>(
                      value: role,
                      child: Text(_getRoleDisplayName(role)),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                    // Apply filter immediately
                    ref.read(apiUserProvider.notifier).searchUsers(_searchQuery, role: value);
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Container(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Quản trị viên';
      case 'teacher':
        return 'Giảng viên';
      case 'student':
        return 'Sinh viên';
      default:
        return role;
    }
  }

  Widget _buildRefreshAndStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              ref.read(apiUserProvider.notifier).searchUsers(_searchQuery, role: _selectedRole);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Làm mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
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
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 100),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Không có người dùng nào',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Kéo xuống để làm mới',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
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
                      'User_ID: ${user.mssv}',
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
          // Chỉ hiển thị nút sửa/xóa nếu không phải Admin
          if (user.currentRole != 'Admin')
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
            )
          else
            // Hiển thị thông báo cho Admin accounts
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tài khoản Admin không thể sửa/xóa',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
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
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              navigator.pop();
              final success = await ref
                  .read(apiUserProvider.notifier)
                  .deleteUser(user.mssv);

              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Đã xóa người dùng thành công')),
                );
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
