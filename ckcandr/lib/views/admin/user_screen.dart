import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:intl/intl.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  String? _selectedRole;
  final TextEditingController _searchController = TextEditingController();
  bool _showInactiveUsers = true;
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userList = ref.watch(userListProvider);
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    // Lọc người dùng theo vai trò và từ khóa tìm kiếm
    List<User> filteredUsers = userList.where((user) {
      // Lọc theo vai trò
      final roleMatches = _selectedRole == null || 
          user.quyen.toString().split('.').last == _selectedRole;
      
      // Lọc theo từ khóa tìm kiếm
      final searchQuery = _searchController.text.toLowerCase().trim();
      final searchMatches = searchQuery.isEmpty ||
          user.hoVaTen.toLowerCase().contains(searchQuery) ||
          user.mssv.toLowerCase().contains(searchQuery) ||
          user.email.toLowerCase().contains(searchQuery);
      
      // Lọc theo trạng thái hoạt động
      final statusMatches = _showInactiveUsers || user.trangThai;
      
      return roleMatches && searchMatches && statusMatches;
    }).toList();
    
    // Phân trang
    final totalPages = (filteredUsers.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage > filteredUsers.length
        ? filteredUsers.length
        : startIndex + _itemsPerPage;
    
    final displayedUsers = filteredUsers.sublist(
      startIndex < filteredUsers.length ? startIndex : 0,
      endIndex < filteredUsers.length ? endIndex : filteredUsers.length,
    );

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
                      'Quản lý người dùng',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditUserDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm người dùng'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Thanh công cụ tìm kiếm và lọc - điều chỉnh layout dựa trên kích thước màn hình
              isSmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Dropdown lọc theo vai trò
                      Container(
                        width: double.infinity,
                        child: DropdownButtonFormField<String?>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Phân quyền',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Tất cả'),
                            ),
                            ...UserRole.values.map((role) => DropdownMenuItem<String?>(
                              value: role.toString().split('.').last,
                              child: Text(
                                role.toString().split('.').last == 'admin'
                                    ? 'Admin'
                                    : role.toString().split('.').last == 'giangVien'
                                        ? 'Giảng viên'
                                        : 'Sinh viên',
                              ),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value;
                              _currentPage = 1; // Reset về trang đầu khi lọc
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Ô tìm kiếm
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Tìm kiếm người dùng',
                          hintText: 'Nhập tên, mã số hoặc email',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _currentPage = 1; // Reset về trang đầu
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _currentPage = 1; // Reset về trang đầu khi tìm kiếm
                          });
                        },
                      ),
                    ],
                  )
                : Row(
                    children: [
                      // Dropdown lọc theo vai trò
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String?>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Phân quyền',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Tất cả'),
                            ),
                            ...UserRole.values.map((role) => DropdownMenuItem<String?>(
                              value: role.toString().split('.').last,
                              child: Text(
                                role.toString().split('.').last == 'admin'
                                    ? 'Admin'
                                    : role.toString().split('.').last == 'giangVien'
                                        ? 'Giảng viên'
                                        : 'Sinh viên',
                              ),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value;
                              _currentPage = 1; // Reset về trang đầu khi lọc
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Ô tìm kiếm
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Tìm kiếm người dùng',
                            hintText: 'Nhập tên, mã số hoặc email',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _currentPage = 1; // Reset về trang đầu
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _currentPage = 1; // Reset về trang đầu khi tìm kiếm
                            });
                          },
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: 8),
              
              // Checkbox hiển thị người dùng không hoạt động
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Checkbox(
                      value: _showInactiveUsers,
                      onChanged: (value) {
                        setState(() {
                          _showInactiveUsers = value ?? true;
                          _currentPage = 1; // Reset về trang đầu khi lọc
                        });
                      },
                    ),
                    const Text('Hiển thị cả người dùng không hoạt động'),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Bảng hiển thị người dùng
        Expanded(
          child: filteredUsers.isEmpty
              ? Center(
                  child: Text(
                    'Không tìm thấy người dùng nào',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : isSmallScreen
                  // Hiển thị dạng card cho màn hình nhỏ
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                      itemCount: displayedUsers.length,
                      itemBuilder: (context, index) {
                        final user = displayedUsers[index];
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
                                        user.hoVaTen,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                          onPressed: () => _showAddEditUserDialog(context, user: user),
                                          tooltip: 'Chỉnh sửa',
                                          constraints: BoxConstraints.tightFor(width: 32, height: 32),
                                          padding: EdgeInsets.zero,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                          onPressed: () => _confirmDeleteUser(context, user),
                                          tooltip: 'Xóa',
                                          constraints: BoxConstraints.tightFor(width: 32, height: 32),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildUserInfoRow('ID:', user.mssv),
                                _buildUserInfoRow('Email:', user.email),
                                _buildUserInfoRow('Giới tính:', user.gioiTinh ? 'Nam' : 'Nữ'),
                                _buildUserInfoRow(
                                  'Ngày sinh:',
                                  user.ngaySinh != null ? DateFormat('dd/MM/yyyy').format(user.ngaySinh!) : 'N/A'
                                ),
                                _buildUserInfoRow('Phân quyền:', user.tenQuyen),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Trạng thái: ${user.trangThai ? "Hoạt động" : "Khóa"}'),
                                    Switch(
                                      value: user.trangThai,
                                      onChanged: (value) {
                                        ref.read(userNotifierProvider.notifier).updateUserStatus(user.id, value);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  // Hiển thị dạng bảng cho màn hình lớn
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: MaterialStateProperty.all(
                            theme.colorScheme.primary.withOpacity(0.1),
                          ),
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Họ và tên')),
                            DataColumn(label: Text('Giới tính')),
                            DataColumn(label: Text('Ngày sinh')),
                            DataColumn(label: Text('Quyền')),
                            DataColumn(label: Text('Ngày tham gia')),
                            DataColumn(label: Text('Trạng thái')),
                            DataColumn(label: Text('Hành động')),
                          ],
                          rows: displayedUsers.map((user) {
                            return DataRow(
                              cells: [
                                DataCell(Text(user.mssv)),
                                DataCell(Text(user.hoVaTen)),
                                DataCell(Text(user.gioiTinh ? 'Nam' : 'Nữ')),
                                DataCell(Text(user.ngaySinh != null
                                    ? DateFormat('dd/MM/yyyy').format(user.ngaySinh!)
                                    : 'N/A')),
                                DataCell(Text(user.tenQuyen)),
                                DataCell(Text(DateFormat('dd/MM/yyyy').format(user.ngayTao))),
                                DataCell(
                                  Switch(
                                    value: user.trangThai,
                                    onChanged: (value) {
                                      ref.read(userNotifierProvider.notifier).updateUserStatus(user.id, value);
                                    },
                                  ),
                                ),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showAddEditUserDialog(context, user: user),
                                      tooltip: 'Chỉnh sửa',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDeleteUser(context, user),
                                      tooltip: 'Xóa',
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
        ),
        
        // Phân trang
        if (filteredUsers.isNotEmpty)
          Padding(
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
          ),
      ],
    );
  }
  
  // Helper widget để hiển thị thông tin người dùng trên card
  Widget _buildUserInfoRow(String label, String value) {
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
  
  // Hiển thị dialog thêm/sửa người dùng
  Future<void> _showAddEditUserDialog(BuildContext context, {User? user}) async {
    final isEditing = user != null;
    
    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: AddEditUserForm(
          isEditing: isEditing,
          initialUser: user,
        ),
      ),
    );
  }
  
  // Hiển thị dialog xác nhận xóa người dùng
  void _confirmDeleteUser(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa người dùng "${user.hoVaTen}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              ref.read(userNotifierProvider.notifier).deleteUser(user);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa người dùng: ${user.hoVaTen}')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddEditUserForm extends ConsumerStatefulWidget {
  final bool isEditing;
  final User? initialUser;
  
  const AddEditUserForm({
    Key? key,
    required this.isEditing,
    this.initialUser,
  }) : super(key: key);
  
  @override
  ConsumerState<AddEditUserForm> createState() => _AddEditUserFormState();
}

class _AddEditUserFormState extends ConsumerState<AddEditUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _mssvController = TextEditingController();
  final _hoVaTenController = TextEditingController();
  final _emailController = TextEditingController();
  final _matKhauController = TextEditingController();
  bool _gioiTinh = true; // Mặc định là Nam
  DateTime? _ngaySinh;
  UserRole _quyen = UserRole.sinhVien; // Mặc định là sinh viên
  bool _trangThai = true; // Mặc định là hoạt động
  
  @override
  void initState() {
    super.initState();
    
    if (widget.isEditing && widget.initialUser != null) {
      // Đổ dữ liệu người dùng vào form nếu đang chỉnh sửa
      final user = widget.initialUser!;
      _mssvController.text = user.mssv;
      _hoVaTenController.text = user.hoVaTen;
      _emailController.text = user.email;
      _gioiTinh = user.gioiTinh;
      _ngaySinh = user.ngaySinh;
      _quyen = user.quyen;
      _trangThai = user.trangThai;
    }
  }
  
  @override
  void dispose() {
    _mssvController.dispose();
    _hoVaTenController.dispose();
    _emailController.dispose();
    _matKhauController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;
    
    return Container(
      width: isSmallScreen ? screenWidth * 0.95 : screenWidth * 0.6,
      constraints: BoxConstraints(maxWidth: 600, maxHeight: isSmallScreen ? 650 : 600),
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing ? 'Chỉnh sửa người dùng' : 'Thêm người dùng mới',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              
              // ID
              TextFormField(
                controller: _mssvController,
                decoration: const InputDecoration(
                  labelText: 'ID người dùng',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Họ và tên
              TextFormField(
                controller: _hoVaTenController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!value.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Mật khẩu (chỉ hiển thị khi thêm mới)
              if (!widget.isEditing)
                TextFormField(
                  controller: _matKhauController,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
              if (!widget.isEditing) const SizedBox(height: 16),
              
              // Giới tính
              Row(
                children: [
                  const Text('Giới tính:'),
                  const SizedBox(width: 16),
                  Radio<bool>(
                    value: true,
                    groupValue: _gioiTinh,
                    onChanged: (value) {
                      setState(() {
                        _gioiTinh = value!;
                      });
                    },
                  ),
                  const Text('Nam'),
                  const SizedBox(width: 16),
                  Radio<bool>(
                    value: false,
                    groupValue: _gioiTinh,
                    onChanged: (value) {
                      setState(() {
                        _gioiTinh = value!;
                      });
                    },
                  ),
                  const Text('Nữ'),
                ],
              ),
              const SizedBox(height: 16),
              
              // Ngày sinh
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày sinh',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _ngaySinh != null
                        ? DateFormat('dd/MM/yyyy').format(_ngaySinh!)
                        : 'Chọn ngày sinh',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Phân quyền
              DropdownButtonFormField<UserRole>(
                value: _quyen,
                decoration: const InputDecoration(
                  labelText: 'Phân quyền',
                  border: OutlineInputBorder(),
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem<UserRole>(
                    value: role,
                    child: Text(
                      role == UserRole.admin
                          ? 'Admin'
                          : role == UserRole.giangVien
                              ? 'Giảng viên'
                              : 'Sinh viên',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _quyen = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn phân quyền';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Trạng thái
              SwitchListTile(
                title: const Text('Trạng thái hoạt động'),
                value: _trangThai,
                onChanged: (value) {
                  setState(() {
                    _trangThai = value;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Nút Hủy và Lưu
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveUser,
                    child: Text(widget.isEditing ? 'Cập nhật' : 'Tạo mới'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Chọn ngày sinh
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _ngaySinh ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _ngaySinh) {
      setState(() {
        _ngaySinh = picked;
      });
    }
  }
  
  // Lưu người dùng
  void _saveUser() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final userNotifier = ref.read(userNotifierProvider.notifier);
    final now = DateTime.now();
    
    if (widget.isEditing && widget.initialUser != null) {
      // Cập nhật người dùng hiện có
      final updatedUser = widget.initialUser!.copyWith(
        mssv: _mssvController.text,
        hoVaTen: _hoVaTenController.text,
        email: _emailController.text,
        gioiTinh: _gioiTinh,
        ngaySinh: _ngaySinh,
        quyen: _quyen,
        trangThai: _trangThai,
        ngayCapNhat: now,
      );
      
      userNotifier.updateUser(updatedUser);
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật người dùng: ${updatedUser.hoVaTen}')),
      );
    } else {
      // Tạo người dùng mới
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID tạm thời
        mssv: _mssvController.text,
        hoVaTen: _hoVaTenController.text,
        email: _emailController.text,
        gioiTinh: _gioiTinh,
        ngaySinh: _ngaySinh,
        matKhau: _matKhauController.text, // Cần hash mật khẩu trong thực tế
        quyen: _quyen,
        trangThai: _trangThai,
        ngayTao: now,
        ngayCapNhat: now,
      );
      
      userNotifier.addUser(newUser);
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm người dùng mới: ${newUser.hoVaTen}')),
      );
    }
  }
} 