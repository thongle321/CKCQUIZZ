import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/core/widgets/role_themed_screen.dart';

class ClassDetailScreen extends ConsumerStatefulWidget {
  final LopHoc lopHoc;

  const ClassDetailScreen({super.key, required this.lopHoc});

  @override
  ConsumerState<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends ConsumerState<ClassDetailScreen> {
  String _searchQuery = '';
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isLoading = false;
  PagedResult<GetNguoiDungDTO>? _studentsResult;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.getStudentsInClass(
        widget.lopHoc.malop,
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lopHoc.tenlop),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildClassInfo(),
          _buildSearchBar(),
          Expanded(
            child: _buildStudentsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(),
        child: const Icon(Icons.person_add),
        tooltip: 'Thêm sinh viên',
      ),
    );
  }

  Widget _buildClassInfo() {
    return UnifiedCard(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.lopHoc.tenlop,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusChip(widget.lopHoc.trangthai),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Mã mời', widget.lopHoc.mamoi ?? 'Chưa có'),
          _buildInfoRow('Môn học', widget.lopHoc.monhocs.isNotEmpty ? widget.lopHoc.monhocs.first : 'Chưa có'),
          _buildInfoRow('Năm học', widget.lopHoc.namhoc?.toString() ?? 'Chưa có'),
          _buildInfoRow('Học kỳ', widget.lopHoc.hocky?.toString() ?? 'Chưa có'),
          _buildInfoRow('Sĩ số', '${_studentsResult?.totalCount ?? widget.lopHoc.siso ?? 0} sinh viên'),
          if (widget.lopHoc.ghichu != null && widget.lopHoc.ghichu!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Ghi chú: ${widget.lopHoc.ghichu}',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool? trangThai) {
    Color color;
    String text;

    if (trangThai == true) {
      color = Colors.green;
      text = 'Hoạt động';
    } else {
      color = Colors.orange;
      text = 'Tạm dừng';
    }

    return UnifiedStatusChip(
      label: text,
      backgroundColor: color,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm sinh viên...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _currentPage = 1; // Reset to first page when searching
          });
          _loadStudents();
        },
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
                  ? 'Chưa có sinh viên nào trong lớp'
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

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _studentsResult!.items.length,
            itemBuilder: (context, index) {
              final student = _studentsResult!.items[index];
              return _buildStudentCard(student);
            },
          ),
        ),
        _buildPagination(),
      ],
    );
  }

  Widget _buildStudentCard(GetNguoiDungDTO student) {
    return UnifiedCard(
      child: Row(
        children: [
          CircleAvatar(
            child: Text(
              student.hoten.isNotEmpty ? student.hoten[0].toUpperCase() : 'S',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.hoten,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'MSSV: ${student.mssv}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  student.email,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildStudentStatusChip(student.trangthai),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) => _handleStudentAction(value, student),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.remove_circle, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xóa khỏi lớp'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentStatusChip(bool? isActive) {
    return UnifiedStatusChip(
      label: isActive == true ? 'Hoạt động' : 'Khóa',
      backgroundColor: isActive == true ? Colors.green : Colors.red,
    );
  }

  Widget _buildPagination() {
    if (_studentsResult == null || _studentsResult!.totalCount <= _pageSize) {
      return const SizedBox.shrink();
    }

    final totalPages = (_studentsResult!.totalCount / _pageSize).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('$_currentPage / $totalPages'),
          IconButton(
            onPressed: _currentPage < totalPages ? () => _changePage(_currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  void _changePage(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
    _loadStudents();
  }

  void _handleStudentAction(String action, GetNguoiDungDTO student) {
    switch (action) {
      case 'remove':
        _confirmRemoveStudent(student);
        break;
    }
  }

  void _confirmRemoveStudent(GetNguoiDungDTO student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${student.hoten}" khỏi lớp?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _removeStudent(student);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeStudent(GetNguoiDungDTO student) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.removeStudentFromClass(widget.lopHoc.malop, student.mssv);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa "${student.hoten}" khỏi lớp')),
      );
      
      _loadStudents(); // Reload the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xóa sinh viên: $e')),
      );
    }
  }

  void _showAddStudentDialog() {
    // TODO: Implement add student dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thêm sinh viên sẽ được triển khai sau')),
    );
  }
}
