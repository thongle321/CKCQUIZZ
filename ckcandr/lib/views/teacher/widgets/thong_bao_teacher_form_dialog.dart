import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/services/thong_bao_service.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';

class ThongBaoTeacherFormDialog extends ConsumerStatefulWidget {
  final ThongBao? notification;

  const ThongBaoTeacherFormDialog({
    super.key,
    this.notification,
  });

  @override
  ConsumerState<ThongBaoTeacherFormDialog> createState() => _ThongBaoTeacherFormDialogState();
}

class _ThongBaoTeacherFormDialogState extends ConsumerState<ThongBaoTeacherFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _noiDungController = TextEditingController();
  final Set<String> _selectedGroupIds = <String>{};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.notification != null) {
      _noiDungController.text = widget.notification!.noiDung;
      if (widget.notification!.nhom != null) {
        _selectedGroupIds.addAll(widget.notification!.nhom!.map((id) => id.toString()));
      }
    }
  }

  @override
  void dispose() {
    _noiDungController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.notification != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Chỉnh sửa thông báo' : 'Tạo thông báo mới',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nội dung thông báo
                    Text(
                      'Nội dung thông báo *',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noiDungController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nhập nội dung thông báo...',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập nội dung thông báo';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Chọn lớp học
                    Text(
                      'Chọn lớp học *',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final lopHocAsync = ref.watch(lopHocListProvider);
                            return lopHocAsync.when(
                              data: (lopHocList) {
                                if (lopHocList.isEmpty) {
                                  return const Center(
                                    child: Text('Không có lớp học nào'),
                                  );
                                }
                                
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: lopHocList.length,
                                  itemBuilder: (context, index) {
                                    final lop = lopHocList[index];
                                    final lopId = lop.malop.toString();
                                    final isSelected = _selectedGroupIds.contains(lopId);
                                    
                                    return CheckboxListTile(
                                      title: Text(lop.tenlop),
                                      subtitle: Text(
                                        'NH${lop.namhoc} - HK${lop.hocky}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      value: isSelected,
                                      onChanged: isEditing ? null : (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedGroupIds.add(lopId);
                                          } else {
                                            _selectedGroupIds.remove(lopId);
                                          }
                                        });
                                      },
                                      activeColor: Colors.green[600],
                                    );
                                  },
                                );
                              },
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (error, stackTrace) => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red),
                                    const SizedBox(height: 8),
                                    Text('Lỗi tải danh sách lớp: $error'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    if (isEditing) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, 
                                 size: 16, 
                                 color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Không thể thay đổi lớp học khi chỉnh sửa thông báo',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.orange[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(isEditing ? 'Cập nhật' : 'Tạo thông báo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGroupIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một lớp học')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(thongBaoNotifierProvider.notifier);
      
      if (widget.notification != null) {
        // Update existing notification
        final request = UpdateThongBaoRequest(
          noiDung: _noiDungController.text.trim(),
          nhomIds: _selectedGroupIds.map((id) => int.parse(id)).toList(),
        );
        await notifier.updateNotification(widget.notification!.maTb!, request);
      } else {
        // Create new notification
        final request = CreateThongBaoRequest(
          noiDung: _noiDungController.text.trim(),
          nhomIds: _selectedGroupIds.map((id) => int.parse(id)).toList(),
        );
        await notifier.createNotification(request);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.notification != null 
                ? 'Cập nhật thông báo thành công!' 
                : 'Tạo thông báo thành công!'),
            backgroundColor: Colors.green[600],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.notification != null 
                ? 'Lỗi cập nhật thông báo: $e' 
                : 'Lỗi tạo thông báo: $e'),
            backgroundColor: Colors.red[600],
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
