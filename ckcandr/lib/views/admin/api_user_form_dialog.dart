/// API User Form Dialog for Admin
/// 
/// This dialog provides form for creating and editing users via API calls.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/providers/api_user_provider.dart';
import 'package:ckcandr/utils/phone_validation.dart';

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
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _hotenController = TextEditingController();
  final _phoneController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedRole;
  bool _status = true;
  bool _isLoading = false;
  bool? _gioitinh = true; // Default to Nam

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
    _emailController.text = user.email;
    _hotenController.text = user.hoten;
    _phoneController.text = user.phoneNumber;
    _selectedDate = user.ngaysinh;
    _selectedRole = user.currentRole;
    _status = user.trangthai ?? true;
    _gioitinh = user.gioitinh ?? true; // Default to Nam if null
  }

  @override
  void dispose() {
    _mssvController.dispose();
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
                // ID field
                TextFormField(
                  controller: _mssvController,
                  decoration: const InputDecoration(
                    labelText: 'ID *',
                    border: OutlineInputBorder(),
                    helperText: 'Từ 6-10 ký tự',
                  ),
                  enabled: !isEditing, // Cannot edit ID
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'ID là bắt buộc';
                    }
                    if (value.trim().length < 6) {
                      return 'Tối thiểu là 6 ký tự';
                    }
                    if (value.trim().length > 10) {
                      return 'Tối đa là 10 ký tự';
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
                      helperText: 'Tối thiểu 8 ký tự',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Mật khẩu là bắt buộc';
                      }
                      if (value.length < 8) {
                        return 'Mật khẩu tối thiểu là 8 ký tự';
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
                    helperText: 'Định dạng: example@domain.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email là bắt buộc';
                    }
                    // Enhanced email validation matching .NET backend pattern
                    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|caothang\.edu\.vn)$').hasMatch(value.trim())) {
                      return 'Email không đúng định dạng';
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
                    helperText: 'Tối đa 40 ký tự',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Họ tên là bắt buộc';
                    }
                    if (value.trim().length > 40) {
                      return 'Họ tên không được vượt quá 40 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone field
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại *',
                    border: OutlineInputBorder(),
                    helperText: 'Định dạng VN: 0xxxxxxxxx hoặc +84xxxxxxxxx',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Số điện thoại là bắt buộc';
                    }
                    // Vietnamese phone number validation
                    if (!isVietnamesePhoneNumberValid(value.trim())) {
                      return 'Số điện thoại không đúng định dạng Việt Nam';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date of birth field
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Ngày sinh *',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                      errorText: _selectedDate == null ? 'Ngày sinh là bắt buộc' : null,
                    ),
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Chọn ngày sinh',
                      style: TextStyle(
                        color: _selectedDate == null ? Colors.grey : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gender dropdown
                DropdownButtonFormField<bool>(
                  value: _gioitinh,
                  decoration: const InputDecoration(
                    labelText: 'Giới tính *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: true,
                      child: Text('Nam'),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text('Nữ'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null) {
                      return 'Giới tính là bắt buộc';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _gioitinh = value;
                    });
                  },
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
                      return 'Quyền là bắt buộc';
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

    // Validate required date of birth
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ngày sinh là bắt buộc')),
      );
      setState(() {}); // Trigger rebuild to show error
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quyền là bắt buộc')),
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
          email: _emailController.text.trim(),
          fullName: _hotenController.text.trim(),
          dob: _selectedDate!, // Already validated above
          phoneNumber: _phoneController.text.trim(),
          status: _status,
          role: _selectedRole!,
          gioitinh: _gioitinh!, // Already validated above
        );
        
        success = await ref
            .read(apiUserProvider.notifier)
            .updateUser(widget.user!.mssv, request);
      } else {
        final request = CreateNguoiDungRequestDTO(
          mssv: _mssvController.text.trim(),
          password: _passwordController.text.trim(),
          email: _emailController.text.trim(),
          hoten: _hotenController.text.trim(),
          ngaysinh: _selectedDate!, // Already validated above
          phoneNumber: _phoneController.text.trim(),
          role: _selectedRole!,
          gioitinh: _gioitinh!, // Already validated above
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
