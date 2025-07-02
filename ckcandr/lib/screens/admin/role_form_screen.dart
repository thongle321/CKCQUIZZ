import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/role_management_model.dart';
import 'package:ckcandr/providers/role_management_provider.dart';
import 'package:ckcandr/widgets/common/loading_widget.dart';
import 'package:ckcandr/widgets/common/error_widget.dart';

class RoleFormScreen extends ConsumerStatefulWidget {
  final String? roleGroupId;

  const RoleFormScreen({super.key, this.roleGroupId});

  @override
  ConsumerState<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends ConsumerState<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isInitialized = false;

  bool get isEditMode => widget.roleGroupId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    final formNotifier = ref.read(roleGroupFormProvider.notifier);
    formNotifier.reset();

    if (isEditMode) {
      // Load existing role group data
      ref.read(roleGroupDetailProvider(widget.roleGroupId!));
    } else {
      // Initialize for create mode
      final functionsAsync = ref.read(functionsProvider);
      functionsAsync.whenData((functions) {
        formNotifier.initializeForCreate(functions);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(roleGroupFormProvider);
    final functionsAsync = ref.watch(functionsProvider);

    // Watch role group detail if in edit mode
    final roleGroupDetailAsync = isEditMode 
        ? ref.watch(roleGroupDetailProvider(widget.roleGroupId!))
        : const AsyncValue.data(null);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Chỉnh sửa nhóm quyền' : 'Thêm nhóm quyền mới'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (formState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveRoleGroup,
              child: const Text('Lưu'),
            ),
        ],
      ),
      body: _buildBody(formState, functionsAsync, roleGroupDetailAsync),
    );
  }

  Widget _buildBody(
    RoleGroupFormState formState,
    AsyncValue<List<FunctionModel>> functionsAsync,
    AsyncValue<RoleGroupDetail?> roleGroupDetailAsync,
  ) {
    // Initialize form data when role group detail is loaded
    if (isEditMode && !_isInitialized) {
      roleGroupDetailAsync.whenData((detail) {
        if (detail != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final formNotifier = ref.read(roleGroupFormProvider.notifier);
            formNotifier.initializeWithData(detail);
            _nameController.text = detail.tenNhomQuyen;
            _isInitialized = true;
          });
        }
      });
    }

    return functionsAsync.when(
      data: (functions) {
        final filteredFunctions = PermissionHelper.getFilteredFunctions(functions);
        
        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Form fields
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên nhóm quyền
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên nhóm quyền *',
                        hintText: 'VD: Giảng viên',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên nhóm quyền';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        ref.read(roleGroupFormProvider.notifier).updateTenNhomQuyen(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Special permissions
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Tham gia thi'),
                            value: formState.thamGiaThi,
                            onChanged: (value) {
                              ref.read(roleGroupFormProvider.notifier).toggleThamGiaThi(value ?? false);
                            },
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Tham gia học phần'),
                            value: formState.thamGiaHocPhan,
                            onChanged: (value) {
                              ref.read(roleGroupFormProvider.notifier).toggleThamGiaHocPhan(value ?? false);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Error message
              if (formState.error != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    formState.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              
              // Permissions table
              Expanded(
                child: _buildPermissionsTable(filteredFunctions, formState),
              ),
            ],
          ),
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, stack) => ErrorWidgetCustom(
        message: 'Không thể tải danh sách chức năng',
        onRetry: () => ref.read(functionsProvider.notifier).loadFunctions(),
      ),
    );
  }

  Widget _buildPermissionsTable(List<FunctionModel> functions, RoleGroupFormState formState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân quyền chi tiết',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Chức năng')),
                  DataColumn(label: Text('Xem')),
                  DataColumn(label: Text('Thêm')),
                  DataColumn(label: Text('Sửa')),
                  DataColumn(label: Text('Xóa')),
                ],
                rows: functions.map((function) {
                  return DataRow(
                    cells: [
                      DataCell(Text(function.tenChucNang)),
                      ...PermissionAction.values.map((action) {
                        return DataCell(
                          Consumer(
                            builder: (context, ref, child) {
                              final formState = ref.watch(roleGroupFormProvider);
                              final isGranted = formState.permissions.any((p) =>
                                p.chucNang == function.chucNang &&
                                p.hanhDong == action.value &&
                                p.isGranted
                              );

                              return Checkbox(
                                value: isGranted,
                                onChanged: (value) {
                                  ref.read(roleGroupFormProvider.notifier)
                                      .togglePermission(function.chucNang, action.value, value ?? false);
                                },
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRoleGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(roleGroupFormProvider.notifier).save();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditMode ? 'Cập nhật nhóm quyền thành công' : 'Thêm nhóm quyền thành công'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      final error = ref.read(roleGroupFormProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
