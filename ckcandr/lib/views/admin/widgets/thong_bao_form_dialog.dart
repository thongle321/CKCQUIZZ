import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/services/thong_bao_service.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/core/widgets/error_dialog.dart';

class ThongBaoFormDialog extends ConsumerStatefulWidget {
  final ThongBao? notification;

  const ThongBaoFormDialog({Key? key, this.notification}) : super(key: key);

  @override
  ConsumerState<ThongBaoFormDialog> createState() => _ThongBaoFormDialogState();
}

class _ThongBaoFormDialogState extends ConsumerState<ThongBaoFormDialog> {
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
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isEditing = widget.notification != null;

    return Container(
      width: isSmallScreen ? MediaQuery.of(context).size.width * 0.95 : 800,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                  isEditing ? 'Cập nhật thông báo' : 'Tạo và gửi thông báo',
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
                    // Nội dung thông báo
                    Text(
                      'Nội dung thông báo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noiDungController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nhập nội dung thông báo cần gửi',
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nội dung thông báo không được để trống';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Chọn lớp học
                    Text(
                      'Chọn lớp học',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref, child) {
                        final lopHocAsync = ref.watch(lopHocListProvider);
                        return lopHocAsync.when(
                          data: (lopHocList) => DropdownButtonFormField<String>(
                            value: _selectedGroupIds.isNotEmpty ? _selectedGroupIds.first : null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Chọn lớp học để gửi thông báo',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng chọn lớp học';
                              }
                              return null;
                            },
                            isExpanded: true,
                            items: lopHocList.map((lopHoc) {
                              return DropdownMenuItem<String>(
                                value: lopHoc.malop.toString(),
                                child: Text(
                                  '${lopHoc.tenlop} - ${lopHoc.tengiangvien}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                            onChanged: isEditing ? null : (value) {
                              setState(() {
                                _selectedGroupIds.clear();
                                if (value != null) {
                                  _selectedGroupIds.add(value);
                                }

                              });
                            },
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (error, stack) => Text(
                            'Lỗi tải danh sách lớp học: $error',
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),

                    // Thông tin lớp được chọn
                    if (_selectedGroupIds.isNotEmpty)
                      Consumer(
                        builder: (context, ref, child) {
                          final lopHocAsync = ref.watch(lopHocListProvider);
                          return lopHocAsync.when(
                            data: (lopHocList) {
                              try {
                                final selectedLop = lopHocList.firstWhere(
                                  (lop) => lop.malop.toString() == _selectedGroupIds.first,
                                );

                                return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.class_, color: Colors.green[600], size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Thông tin lớp được chọn:',
                                          style: TextStyle(
                                            color: Colors.green[600],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '• Tên lớp: ${selectedLop.tenlop}',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '• Giảng viên: ${selectedLop.tengiangvien}',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '• Sĩ số: ${selectedLop.siso} học viên',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (selectedLop.monhocs.isNotEmpty)
                                      Text(
                                        '• Môn học: ${selectedLop.monhocs.join(", ")}',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                              } catch (e) {
                                return Container();
                              }
                            },
                            loading: () => Container(),
                            error: (error, stack) => Container(),
                          );
                        },
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
                      : Text(isEditing ? 'Cập nhật thông báo' : 'Gửi thông báo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGroupIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn lớp học')),
      );
      return;
    }

    // Không cần validation cho nhóm - có thể gửi cho tất cả

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(thongBaoNotifierProvider.notifier);
      
      if (widget.notification != null) {
        // Update existing notification
        final currentUser = ref.read(currentUserProvider);
        final request = UpdateThongBaoRequest(
          noiDung: _noiDungController.text.trim(),
          nguoitao: currentUser?.id ?? '',
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
        await SuccessDialog.show(
          context,
          message: widget.notification != null
              ? 'Cập nhật thông báo thành công!'
              : 'Gửi thông báo thành công!',
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialog.show(
          context,
          message: widget.notification != null
              ? 'Lỗi cập nhật thông báo: ${e.toString()}'
              : 'Lỗi gửi thông báo: ${e.toString()}',
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
