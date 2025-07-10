import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/services/phan_cong_service.dart';

class PhanCongFormDialog extends ConsumerStatefulWidget {
  const PhanCongFormDialog({super.key});

  @override
  ConsumerState<PhanCongFormDialog> createState() => _PhanCongFormDialogState();
}

class _PhanCongFormDialogState extends ConsumerState<PhanCongFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLecturerId;
  final Set<String> _selectedSubjectIds = <String>{};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final lecturersAsync = ref.watch(lecturersListProvider);
    final subjectsAsync = ref.watch(subjectsForAssignmentProvider);
    final assignmentsAsync = ref.watch(phanCongListProvider);
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

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
                  'Thêm phân công mới',
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dropdown chọn giảng viên
                    Text(
                      'Chọn giảng viên',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    lecturersAsync.when(
                      data: (lecturers) {
                        return DropdownButtonFormField<String>(
                          value: _selectedLecturerId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Chọn giảng viên',
                          ),
                          items: lecturers.map((lecturer) {
                            return DropdownMenuItem<String>(
                              value: lecturer.id,
                              child: Text('${lecturer.hoTen} (${lecturer.id})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLecturerId = value;
                              _selectedSubjectIds.clear();
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn giảng viên';
                            }
                            return null;
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text(
                          'Lỗi tải danh sách giảng viên: $error',
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Danh sách môn học
                    Text(
                      'Chọn môn học',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: assignmentsAsync.when(
                          data: (assignments) {
                            return subjectsAsync.when(
                              data: (allSubjects) {
                                // Filter ra những môn học chưa được phân công cho giảng viên đã chọn
                                final subjects = _selectedLecturerId == null
                                  ? allSubjects
                                  : allSubjects.where((subject) {
                                      return !assignments.any((assignment) =>
                                        assignment.maNguoiDung == _selectedLecturerId &&
                                        assignment.maMonHoc == subject.maMonHoc
                                      );
                                    }).toList();
                            return Column(
                              children: [
                                // Header với checkbox "Chọn tất cả"
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _selectedSubjectIds.length == subjects.length && subjects.isNotEmpty,
                                        tristate: true,
                                        onChanged: (value) {
                                          setState(() {
                                            if (value == true) {
                                              _selectedSubjectIds.addAll(
                                                subjects.map((s) => s.maMonHoc.toString()),
                                              );
                                            } else {
                                              _selectedSubjectIds.clear();
                                            }
                                          });
                                        },
                                      ),
                                      const Text(
                                        'Chọn tất cả',
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Danh sách môn học
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: subjects.length,
                                    itemBuilder: (context, index) {
                                      final subject = subjects[index];
                                      final isSelected = _selectedSubjectIds.contains(subject.maMonHoc.toString());
                                      
                                      return CheckboxListTile(
                                        value: isSelected,
                                        onChanged: (value) {
                                          setState(() {
                                            if (value == true) {
                                              _selectedSubjectIds.add(subject.maMonHoc.toString());
                                            } else {
                                              _selectedSubjectIds.remove(subject.maMonHoc.toString());
                                            }
                                          });
                                        },
                                        title: Text(
                                          '${subject.maMonHoc} - ${subject.tenMonHoc}',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        subtitle: Text(
                                          'Tín chỉ: ${subject.soTinChi} | '
                                          'LT: ${subject.soTietLyThuyet} | '
                                          'TH: ${subject.soTietThucHanh}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        dense: true,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (error, stack) => Center(
                                child: Text(
                                  'Lỗi tải danh sách môn học: $error',
                                  style: TextStyle(color: Colors.red[600]),
                                ),
                              ),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Center(
                            child: Text(
                              'Lỗi tải danh sách phân công: $error',
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Validation message cho môn học
                    if (_selectedSubjectIds.isEmpty && _selectedLecturerId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Vui lòng chọn ít nhất một môn học',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading || _selectedLecturerId == null || _selectedSubjectIds.isEmpty
                      ? null
                      : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Thêm phân công'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLecturerId == null || _selectedSubjectIds.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(phanCongNotifierProvider.notifier).addAssignment(
        _selectedLecturerId!,
        _selectedSubjectIds.toList(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm phân công thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi thêm phân công: $e')),
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
