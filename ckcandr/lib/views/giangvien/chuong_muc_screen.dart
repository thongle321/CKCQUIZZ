import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/providers/chuong_provider.dart';

class ChuongMucScreen extends ConsumerStatefulWidget {
  const ChuongMucScreen({super.key});

  @override
  ConsumerState<ChuongMucScreen> createState() => _ChuongMucScreenState();
}

class _ChuongMucScreenState extends ConsumerState<ChuongMucScreen> {
  int? _selectedSubjectId;

  @override
  Widget build(BuildContext context) {
    final assignedSubjects = ref.watch(assignedSubjectsProvider);
    final chapters = _selectedSubjectId != null
        ? ref.watch(chaptersProvider(_selectedSubjectId))
        : const AsyncValue<List<ChuongDTO>>.data([]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chương mục'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Subject selection
          Container(
            padding: const EdgeInsets.all(16.0),
            child: assignedSubjects.when(
              data: (subjects) => DropdownButtonFormField<int>(
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
                },
              ),
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
                        ? const Center(
                            child: Text(
                              'Chưa có chương nào.\nNhấn nút + để thêm chương mới.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey),
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
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _editChapter(chapter),
                                          tooltip: 'Chỉnh sửa',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteChapter(chapter),
                                          tooltip: 'Xóa',
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

  void _deleteChapter(ChuongDTO chapter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa chương "${chapter.tenchuong}"?'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa chương thành công!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi xóa chương: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
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
            CheckboxListTile(
              title: const Text('Hoạt động'),
              value: _trangThai,
              onChanged: (value) {
                setState(() {
                  _trangThai = value ?? true;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
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
        // Create new chapter
        final request = CreateChuongRequestDTO(
          tenchuong: _tenChuongController.text.trim(),
          mamonhoc: widget.subjectId,
          trangthai: _trangThai,
        );

        await ref
            .read(chaptersProvider(widget.subjectId).notifier)
            .addChapter(request);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm chương thành công!')),
          );
        }
      } else {
        // Update existing chapter
        final request = UpdateChuongRequestDTO(
          tenchuong: _tenChuongController.text.trim(),
          mamonhoc: widget.subjectId,
          trangthai: _trangThai,
        );

        await ref
            .read(chaptersProvider(widget.subjectId).notifier)
            .updateChapter(widget.chapter!.machuong, request);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật chương thành công!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
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