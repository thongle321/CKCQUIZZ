/// API User Form Dialog for Admin
/// 
/// This dialog provides form for creating and editing users via API calls.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/providers/api_user_provider.dart';

class ApiUserFormDialog extends ConsumerStatefulWidget {
  final GetNguoiDungDTO? user;
  final List<String> availableRoles;

  const ApiUserFormDialog({
    super.key,
    this.user,
    required this.availableRoles,
  });

  @override
  ConsumerState<ApiUserFormDialog> createState() => _ApiUserFormDialogState();
}

class _ApiUserFormDialogState extends ConsumerState<ApiUserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _mssvController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _hotenController = TextEditingController();
  final _phoneController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedRole;
  bool _status = true;
  bool _isLoading = false;

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
    
    // Set default role if available
    if (widget.availableRoles.isNotEmpty) {
      _selectedRole = widget.availableRoles.first;
    }
  }

  void _populateFields() {
    final user = widget.user!;
    _mssvController.text = user.mssv;
    _userNameController.text = user.userName;
    _emailController.text = user.email;
    _hotenController.text = user.hoten;
    _phoneController.text = user.phoneNumber;
    _selectedDate = user.ngaysinh;
    _selectedRole = user.currentRole;
    _status = user.trangthai ?? true;
  }

  @override
  void dispose() {
    _mssvController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _hotenController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Sửa người dùng' : 'Thêm người dùng'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // MSSV field
                TextFormField(
                  controller: _mssvController,
                  decoration: const InputDecoration(
                    labelText: 'MSSV *',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isEditing, // Cannot edit MSSV
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập MSSV';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Username field
                TextFormField(
                  controller: _userNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên đăng nhập *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên đăng nhập';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field (only for create)
                if (!isEditing) ...[
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu *',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Full name field
                TextFormField(
                  controller: _hotenController,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone field
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Date of birth field
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ngày sinh',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Chọn ngày sinh',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Role dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Vai trò *',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.availableRoles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(_getRoleDisplayName(role)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn vai trò';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Status switch (only for edit)
                if (isEditing) ...[
                  Row(
                    children: [
                      const Text('Trạng thái: '),
                      const Spacer(),
                      Switch(
                        value: _status,
                        onChanged: (value) {
                          setState(() {
                            _status = value;
                          });
                        },
                      ),
                      Text(_status ? 'Hoạt động' : 'Khóa'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn vai trò')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      
      if (isEditing) {
        final request = UpdateNguoiDungRequestDTO(
          userName: _userNameController.text.trim(),
          email: _emailController.text.trim(),
          fullName: _hotenController.text.trim(),
          dob: _selectedDate ?? DateTime.now(),
          phoneNumber: _phoneController.text.trim(),
          status: _status,
          role: _selectedRole!,
        );
        
        success = await ref
            .read(apiUserProvider.notifier)
            .updateUser(widget.user!.mssv, request);
      } else {
        final request = CreateNguoiDungRequestDTO(
          mssv: _mssvController.text.trim(),
          userName: _userNameController.text.trim(),
          password: _passwordController.text.trim(),
          email: _emailController.text.trim(),
          hoten: _hotenController.text.trim(),
          ngaysinh: _selectedDate ?? DateTime.now(),
          phoneNumber: _phoneController.text.trim(),
          role: _selectedRole!,
        );
        
        success = await ref
            .read(apiUserProvider.notifier)
            .createUser(request);
      }

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing 
                ? 'Đã cập nhật người dùng thành công' 
                : 'Đã thêm người dùng thành công'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
