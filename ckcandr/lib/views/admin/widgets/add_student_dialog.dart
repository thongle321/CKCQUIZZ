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
  GetNguoiDungDTO? _selectedStudent;

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
            
            // Selected student info
            if (_selectedStudent != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đã chọn: ${_selectedStudent!.hoten}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('MSSV: ${_selectedStudent!.mssv}'),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedStudent = null;
                        });
                      },
                      child: const Text('Bỏ chọn'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                  onPressed: _selectedStudent != null && !_isAdding
                      ? _addStudentToClass
                      : null,
                  child: _isAdding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Thêm vào lớp'),
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
        final isSelected = _selectedStudent?.mssv == student.mssv;
        
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
                Text(student.email),
              ],
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : null,
            onTap: () {
              setState(() {
                _selectedStudent = isSelected ? null : student;
              });
            },
          ),
        );
      },
    );
  }

  Future<void> _addStudentToClass() async {
    if (_selectedStudent == null) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.addStudentToClass(widget.classId, _selectedStudent!.mssv);
      
      if (mounted) {
        Navigator.pop(context, _selectedStudent); // Return selected student
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${_selectedStudent!.hoten}" vào lớp'),
            backgroundColor: Colors.green,
          ),
        );
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
