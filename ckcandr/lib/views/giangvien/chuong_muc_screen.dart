import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/providers/chuong_provider.dart';
import 'package:ckcandr/core/widgets/loading_overlay.dart';

class ChuongMucScreen extends ConsumerStatefulWidget {
  const ChuongMucScreen({super.key});

  @override
  ConsumerState<ChuongMucScreen> createState() => _ChuongMucScreenState();
}

class _ChuongMucScreenState extends ConsumerState<ChuongMucScreen> {
  int? _selectedSubjectId;
  bool _hasAutoSelected = false;

  @override
  Widget build(BuildContext context) {
    final assignedSubjects = ref.watch(assignedSubjectsProvider);

    // Force rebuild when selectedSubjectId changes
    final chapters = _selectedSubjectId != null
        ? ref.watch(chaptersProvider(_selectedSubjectId))
        : const AsyncValue<List<ChuongDTO>>.data([]);

    // 🔥 RESET AUTO-SELECT: Reset khi user thay đổi (logout/login)
    ref.listen(assignedSubjectsProvider, (previous, next) {
      if (previous != next) {
        _hasAutoSelected = false;
        _selectedSubjectId = null;
      }
    });

    // Debug logging for UI state
    if (_selectedSubjectId != null) {
      chapters.whenData((data) {
        print('🎯 UI rebuild: Subject $_selectedSubjectId has ${data.length} chapters');
      });
    }

    return PageTransitionWrapper(
      child: Scaffold(
      body: Column(
        children: [
          // Subject selection
          Container(
            padding: const EdgeInsets.all(16.0),
            child: assignedSubjects.when(
              data: (subjects) {
                // 🔥 AUTO-SELECT: Tự động chọn môn học đầu tiên nếu chưa chọn
                if (!_hasAutoSelected && subjects.isNotEmpty && _selectedSubjectId == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedSubjectId = subjects.first.mamonhoc;
                      _hasAutoSelected = true;
                    });
                    // Force load chapters for auto-selected subject
                    ref.invalidate(chaptersProvider(subjects.first.mamonhoc));
                  });
                }

                return DropdownButtonFormField<int>(
                  value: _selectedSubjectId,
                  decoration: const InputDecoration(
                    labelText: 'Chọn môn học',
                    border: OutlineInputBorder(),
                    helperText: 'Chỉ hiển thị môn học bạn được phân công',
                  ),
                  items: subjects.map((subject) {
                    return DropdownMenuItem<int>(
                      value: subject.mamonhoc,
                      child: Text('${subject.mamonhoc} - ${subject.tenmonhoc}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubjectId = value;
                    });

                    // 🔥 FORCE REFRESH: Luôn invalidate provider khi thay đổi môn học
                    if (value != null) {
                      print('🔄 Subject changed to $value, invalidating provider');
                      ref.invalidate(chaptersProvider(value));
                    }
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Lỗi tải môn học: $error'),
            ),
          ),

          // Chapters list
          Expanded(
            child: _selectedSubjectId == null
                ? const Center(
                    child: Text(
                      'Vui lòng chọn môn học để xem danh sách chương',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : chapters.when(
                    data: (chaptersList) => chaptersList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.book_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chưa có chương nào',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Môn học này chưa có chương nào.\nHãy thêm chương đầu tiên!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => _addChapter(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Thêm chương đầu tiên'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(chaptersProvider(_selectedSubjectId));
                            },
                            child: ListView.builder(
                              itemCount: chaptersList.length,
                              itemBuilder: (context, index) {
                                final chapter = chaptersList[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 4.0,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                      chapter.tenchuong,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Trạng thái: ${chapter.trangthai == true ? "Hoạt động" : "Không hoạt động"}',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Luôn hiển thị nút sửa
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _editChapter(chapter),
                                          tooltip: 'Chỉnh sửa',
                                        ),
                                        // Chỉ hiển thị nút xóa khi status = false (0)
                                        if (chapter.trangthai == false)
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteChapter(chapter),
                                            tooltip: 'Xóa',
                                          )
                                        else
                                          // Hiển thị nút ẩn/hiện thay vì xóa
                                          IconButton(
                                            icon: Icon(
                                              chapter.trangthai == true ? Icons.visibility_off : Icons.visibility,
                                              color: chapter.trangthai == true ? Colors.orange : Colors.green,
                                            ),
                                            onPressed: () => _toggleChapterStatus(chapter),
                                            tooltip: chapter.trangthai == true ? 'Ẩn chương' : 'Hiện chương',
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Lỗi tải danh sách chương: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref.invalidate(chaptersProvider(_selectedSubjectId));
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _selectedSubjectId != null
          ? FloatingActionButton(
              onPressed: () => _addChapter(),
              tooltip: 'Thêm chương mới',
              child: const Icon(Icons.add),
            )
          : null,
      ),
    );
  }

  void _addChapter() {
    if (_selectedSubjectId == null) return;

    showDialog(
      context: context,
      builder: (context) => ChuongFormDialog(
        subjectId: _selectedSubjectId!,
      ),
    );
  }

  void _editChapter(ChuongDTO chapter) {
    showDialog(
      context: context,
      builder: (context) => ChuongFormDialog(
        subjectId: chapter.mamonhoc,
        chapter: chapter,
      ),
    );
  }

  void _toggleChapterStatus(ChuongDTO chapter) {
    final newStatus = !(chapter.trangthai ?? true);
    final action = newStatus ? 'hiện' : 'ẩn';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận ${action} chương'),
        content: Text('Bạn có chắc chắn muốn ${action} chương "${chapter.tenchuong}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Update chapter status
                final request = UpdateChuongRequestDTO(
                  tenchuong: chapter.tenchuong,
                  mamonhoc: chapter.mamonhoc,
                  trangthai: newStatus,
                );

                await ref
                    .read(chaptersProvider(_selectedSubjectId).notifier)
                    .updateChapter(chapter.machuong, request);

                if (mounted) {
                  _showSuccessDialog('${newStatus ? "Hiện" : "Ẩn"} chương thành công!');
                }
              } catch (e) {
                if (mounted) {
                  _showErrorDialog('Lỗi ${action} chương: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.green : Colors.orange,
            ),
            child: Text(
              newStatus ? 'Hiện' : 'Ẩn',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteChapter(ChuongDTO chapter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa vĩnh viễn chương "${chapter.tenchuong}"?\n\nHành động này không thể hoàn tác!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(chaptersProvider(_selectedSubjectId).notifier)
                    .deleteChapter(chapter.machuong);
                if (mounted) {
                  _showSuccessDialog('Xóa chương thành công!');
                }
              } catch (e) {
                if (mounted) {
                  _showErrorDialog('Lỗi xóa chương: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa vĩnh viễn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Thành công'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Lỗi'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Dialog widget for creating/editing chapters
class ChuongFormDialog extends ConsumerStatefulWidget {
  final int subjectId;
  final ChuongDTO? chapter;

  const ChuongFormDialog({
    super.key,
    required this.subjectId,
    this.chapter,
  });

  @override
  ConsumerState<ChuongFormDialog> createState() => _ChuongFormDialogState();
}

class _ChuongFormDialogState extends ConsumerState<ChuongFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tenChuongController = TextEditingController();
  bool _trangThai = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.chapter != null) {
      _tenChuongController.text = widget.chapter!.tenchuong;
      _trangThai = widget.chapter!.trangthai ?? true;
    }
  }

  @override
  void dispose() {
    _tenChuongController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.chapter == null ? 'Thêm chương mới' : 'Chỉnh sửa chương'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _tenChuongController,
              decoration: const InputDecoration(
                labelText: 'Tên chương *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên chương';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Chỉ hiển thị trạng thái, không cho phép thay đổi trực tiếp
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    _trangThai ? Icons.visibility : Icons.visibility_off,
                    color: _trangThai ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Trạng thái: ${_trangThai ? "Hiển thị" : "Ẩn"}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lưu ý: Trạng thái chương chỉ có thể thay đổi bằng nút Ẩn/Hiện sau khi tạo',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.chapter == null ? 'Thêm' : 'Cập nhật'),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.chapter == null) {
        // Create new chapter - mặc định status = true
        final request = CreateChuongRequestDTO(
          tenchuong: _tenChuongController.text.trim(),
          mamonhoc: widget.subjectId,
          trangthai: true, // Luôn tạo với status = true
        );

        await ref
            .read(chaptersProvider(widget.subjectId).notifier)
            .addChapter(request);

        if (mounted) {
          Navigator.pop(context);
          _showSuccessDialog('Thêm chương thành công!');
        }
      } else {
        // Update existing chapter - chỉ cập nhật tên, giữ nguyên status
        final request = UpdateChuongRequestDTO(
          tenchuong: _tenChuongController.text.trim(),
          mamonhoc: widget.subjectId,
          trangthai: widget.chapter!.trangthai ?? true, // Giữ nguyên status cũ
        );

        await ref
            .read(chaptersProvider(widget.subjectId).notifier)
            .updateChapter(widget.chapter!.machuong, request);

        if (mounted) {
          Navigator.pop(context);
          _showSuccessDialog('Cập nhật chương thành công!');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Lỗi: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Thành công'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Lỗi'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}