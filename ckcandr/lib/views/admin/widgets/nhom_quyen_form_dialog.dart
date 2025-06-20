import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/nhom_quyen_model.dart';
import 'package:ckcandr/services/nhom_quyen_service.dart';

class NhomQuyenFormDialog extends ConsumerStatefulWidget {
  final NhomQuyen? permissionGroup;

  const NhomQuyenFormDialog({Key? key, this.permissionGroup}) : super(key: key);

  @override
  ConsumerState<NhomQuyenFormDialog> createState() => _NhomQuyenFormDialogState();
}

class _NhomQuyenFormDialogState extends ConsumerState<NhomQuyenFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tenNhomQuyenController = TextEditingController();
  bool _thamGiaThi = false;
  bool _thamGiaHocPhan = false;
  final Map<String, bool> _permissions = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.permissionGroup != null) {
      _tenNhomQuyenController.text = widget.permissionGroup!.tenNhomQuyen;
      // Load existing permissions if editing
      _loadExistingPermissions();
    }
  }

  Future<void> _loadExistingPermissions() async {
    if (widget.permissionGroup?.id != null) {
      try {
        final detail = await ref.read(nhomQuyenServiceProvider)
            .getPermissionGroupDetail(widget.permissionGroup!.id!);
        
        setState(() {
          _thamGiaThi = detail.thamGiaThi;
          _thamGiaHocPhan = detail.thamGiaHocPhan;
          
          // Load permissions
          for (final permission in detail.filteredPermissions) {
            final key = '${permission.chucNang}_${permission.hanhDong}';
            _permissions[key] = permission.isGranted;
          }
        });
      } catch (e) {
        // Handle error silently or show message
      }
    }
  }

  @override
  void dispose() {
    _tenNhomQuyenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final functionsAsync = ref.watch(functionsListProvider);
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isEditing = widget.permissionGroup != null;

    return Container(
      width: isSmallScreen ? MediaQuery.of(context).size.width * 0.95 : 900,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Sửa nhóm quyền' : 'Thêm nhóm quyền mới',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    // Tên nhóm quyền
                    Text(
                      'Tên nhóm quyền',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tenNhomQuyenController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nhập tên nhóm quyền',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Tên nhóm quyền không được để trống';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quyền đặc biệt
                    Text(
                      'Quyền đặc biệt',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CheckboxListTile(
                                title: const Text('Tham gia thi'),
                                subtitle: const Text('Cho phép tham gia các bài thi'),
                                value: _thamGiaThi,
                                onChanged: (value) {
                                  setState(() {
                                    _thamGiaThi = value ?? false;
                                  });
                                },
                                dense: true,
                              ),
                              CheckboxListTile(
                                title: const Text('Tham gia học phần'),
                                subtitle: const Text('Cho phép tham gia các học phần'),
                                value: _thamGiaHocPhan,
                                onChanged: (value) {
                                  setState(() {
                                    _thamGiaHocPhan = value ?? false;
                                  });
                                },
                                dense: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quyền chức năng
                    Text(
                      'Quyền chức năng',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      height: 400, // Fixed height thay vì Expanded
                      child: functionsAsync.when(
                        data: (functions) => _buildPermissionsGrid(functions, theme),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Text(
                            'Lỗi tải danh sách chức năng: $error',
                            style: TextStyle(color: Colors.red[600]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Footer với buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Cập nhật' : 'Thêm mới'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsGrid(List<ChucNang> functions, ThemeData theme) {
    if (functions.isEmpty) {
      return const Center(
        child: Text('Không có chức năng nào để phân quyền'),
      );
    }

    // Filter out special functions
    final regularFunctions = functions.where((f) =>
        !PermissionHelper.isSpecialFunction(f.chucNang)
    ).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Chức năng',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...PermissionAction.values.map((action) => Expanded(
                    child: Text(
                      action.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  )),
                ],
              ),
            ),
            const Divider(),
            
            // Permissions list
            Expanded(
              child: ListView.builder(
                itemCount: regularFunctions.length,
                itemBuilder: (context, index) {
                  final function = regularFunctions[index];
                  return _buildPermissionRow(function, theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRow(ChucNang function, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              function.tenChucNang,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          ...PermissionAction.values.map((action) {
            final key = '${function.chucNang}_${action.value}';
            final isGranted = _permissions[key] ?? false;
            
            return Expanded(
              child: Checkbox(
                value: isGranted,
                onChanged: (value) {
                  setState(() {
                    _permissions[key] = value ?? false;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(nhomQuyenNotifierProvider.notifier);

      // Create permissions list
      final permissions = <Permission>[];

      // Add regular permissions
      _permissions.forEach((key, isGranted) {
        if (isGranted) {
          final parts = key.split('_');
          if (parts.length == 2) {
            permissions.add(Permission(
              chucNang: parts[0],
              hanhDong: parts[1],
              isGranted: true,
            ));
          }
        }
      });

      // Add special permissions
      if (_thamGiaThi) {
        permissions.add(const Permission(
          chucNang: 'thamgiathi',
          hanhDong: 'join',
          isGranted: true,
        ));
      }

      if (_thamGiaHocPhan) {
        permissions.add(const Permission(
          chucNang: 'thamgiahocphan',
          hanhDong: 'join',
          isGranted: true,
        ));
      }

      // Debug logging
      print('🔧 Nhóm quyền form submit:');
      print('   Tên: ${_tenNhomQuyenController.text.trim()}');
      print('   Tham gia thi: $_thamGiaThi');
      print('   Tham gia học phần: $_thamGiaHocPhan');
      print('   Số permissions: ${permissions.length}');
      for (final p in permissions) {
        print('   - ${p.chucNang}.${p.hanhDong}: ${p.isGranted}');
      }

      if (widget.permissionGroup != null) {
        // Update existing permission group
        final request = UpdateNhomQuyenRequest(
          tenNhomQuyen: _tenNhomQuyenController.text.trim(),
          thamGiaThi: _thamGiaThi,
          thamGiaHocPhan: _thamGiaHocPhan,
          permissions: permissions,
        );
        await notifier.updatePermissionGroup(widget.permissionGroup!.id!, request);
      } else {
        // Create new permission group
        final request = CreateNhomQuyenRequest(
          tenNhomQuyen: _tenNhomQuyenController.text.trim(),
          thamGiaThi: _thamGiaThi,
          thamGiaHocPhan: _thamGiaHocPhan,
          permissions: permissions,
        );
        await notifier.createPermissionGroup(request);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.permissionGroup != null
                ? '✅ Cập nhật nhóm quyền "${_tenNhomQuyenController.text.trim()}" thành công!'
                : '✅ Thêm nhóm quyền "${_tenNhomQuyenController.text.trim()}" thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        print('✅ Nhóm quyền ${widget.permissionGroup != null ? "cập nhật" : "tạo"} thành công');
      }
    } catch (e) {
      print('❌ Lỗi ${widget.permissionGroup != null ? "cập nhật" : "tạo"} nhóm quyền: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.permissionGroup != null
                ? '❌ Lỗi cập nhật nhóm quyền: ${e.toString()}'
                : '❌ Lỗi thêm nhóm quyền: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
