import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/core/widgets/role_themed_screen.dart';

class AddStudentDialog extends ConsumerStatefulWidget {
  final int classId;
  final String className;

  const AddStudentDialog({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  ConsumerState<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends ConsumerState<AddStudentDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isAdding = false;
  PagedResult<GetNguoiDungDTO>? _studentsResult;
  Set<GetNguoiDungDTO> _selectedStudents = {};

  @override
  void initState() {
    super.initState();
    _loadAvailableStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.getAvailableStudents(
        classId: widget.classId,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        page: 1,
        pageSize: 50, // Load more students for selection
      );

      setState(() {
        _studentsResult = result;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách sinh viên: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Thêm sinh viên vào lớp "${widget.className}"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm sinh viên...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _loadAvailableStudents();
              },
            ),
            const SizedBox(height: 16),
            
            // Selected students info
            if (_selectedStudents.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Đã chọn ${_selectedStudents.length} sinh viên',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedStudents.clear();
                            });
                          },
                          child: const Text('Bỏ chọn tất cả'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _selectedStudents.map((student) {
                        return Chip(
                          label: Text(
                            student.hoten,
                            style: const TextStyle(fontSize: 12),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedStudents.remove(student);
                            });
                          },
                          backgroundColor: Colors.blue[100],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Select all button
            if (_studentsResult != null && _studentsResult!.items.isNotEmpty) ...[
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        if (_selectedStudents.length == _studentsResult!.items.length) {
                          // Deselect all
                          _selectedStudents.clear();
                        } else {
                          // Select all
                          _selectedStudents.addAll(_studentsResult!.items);
                        }
                      });
                    },
                    icon: Icon(
                      _selectedStudents.length == _studentsResult!.items.length
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.blue,
                    ),
                    label: Text(
                      _selectedStudents.length == _studentsResult!.items.length
                          ? 'Bỏ chọn tất cả'
                          : 'Chọn tất cả',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                  const Spacer(),
                  if (_studentsResult!.items.isNotEmpty)
                    Text(
                      '${_studentsResult!.items.length} sinh viên có thể thêm',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Students list
            Expanded(
              child: _buildStudentsList(),
            ),
            
            // Action buttons
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedStudents.isNotEmpty && !_isAdding
                      ? _addStudentsToClass
                      : null,
                  child: _isAdding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_selectedStudents.length > 1
                          ? 'Thêm ${_selectedStudents.length} sinh viên'
                          : 'Thêm vào lớp'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_studentsResult == null || _studentsResult!.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty 
                  ? 'Tất cả sinh viên đã có trong lớp'
                  : 'Không tìm thấy sinh viên nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _studentsResult!.items.length,
      itemBuilder: (context, index) {
        final student = _studentsResult!.items[index];
        final isSelected = _selectedStudents.any((s) => s.mssv == student.mssv);

        return UnifiedCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? Colors.blue : Colors.grey,
              child: Text(
                student.hoten.isNotEmpty ? student.hoten[0].toUpperCase() : 'S',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            title: Text(
              student.hoten,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MSSV: ${student.mssv}'),
                Text(
                  student.email,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedStudents.removeWhere((s) => s.mssv == student.mssv);
                } else {
                  _selectedStudents.add(student);
                }
              });
            },
          ),
        );
      },
    );
  }

  Future<void> _addStudentsToClass() async {
    if (_selectedStudents.isEmpty) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);

      // Thêm từng sinh viên một cách tuần tự
      int successCount = 0;
      List<String> failedStudents = [];

      for (final student in _selectedStudents) {
        try {
          await apiService.addStudentToClass(widget.classId, student.mssv);
          successCount++;
        } catch (e) {
          failedStudents.add(student.hoten);
        }
      }

      if (mounted) {
        Navigator.pop(context, _selectedStudents.toList()); // Return selected students

        // Hiển thị kết quả
        if (successCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm $successCount sinh viên vào lớp'),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (failedStudents.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể thêm: ${failedStudents.join(", ")}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi thêm sinh viên: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }
}
