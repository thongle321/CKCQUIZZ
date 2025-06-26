import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/core/widgets/role_themed_screen.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';

/// Student Class Detail Screen - Chi tiết lớp học cho sinh viên
/// Tương đương với Vue.js classdetail.vue
class StudentClassDetailScreen extends ConsumerStatefulWidget {
  final int classId;
  
  const StudentClassDetailScreen({
    super.key,
    required this.classId,
  });

  @override
  ConsumerState<StudentClassDetailScreen> createState() => _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends ConsumerState<StudentClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // State for students list
  List<GetNguoiDungDTO> _students = [];
  List<GetNguoiDungDTO> _teachers = [];
  bool _isLoadingPeople = false;
  String _searchText = '';
  int _currentPage = 1;
  int _totalCount = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPeople();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;
    final lopHocAsyncValue = ref.watch(lopHocListProvider);

    return RoleThemedWidget(
      role: role,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết lớp học'),
          backgroundColor: RoleTheme.getPrimaryColor(role),
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Thông tin'),
              Tab(text: 'Thành viên'),
            ],
          ),
        ),
        body: lopHocAsyncValue.when(
          data: (lopHocList) {
            final lopHoc = lopHocList.firstWhere(
              (lop) => lop.malop == widget.classId,
              orElse: () => throw Exception('Không tìm thấy lớp học'),
            );
            return _buildTabContent(lopHoc, role);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorWidget(error),
        ),
      ),
    );
  }

  Widget _buildTabContent(LopHoc lopHoc, UserRole role) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildClassInfoTab(lopHoc),
        _buildMembersTab(),
      ],
    );
  }

  Widget _buildClassInfoTab(LopHoc lopHoc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class header card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lopHoc.tenlop,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mã lớp: ${lopHoc.malop}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (lopHoc.mamoi != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Mã mời: ${lopHoc.mamoi}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Class details
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin chi tiết',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Năm học', lopHoc.namhoc?.toString() ?? 'N/A'),
                  _buildInfoRow('Học kỳ', lopHoc.hocky?.toString() ?? 'N/A'),
                  _buildInfoRow('Sĩ số', lopHoc.siso?.toString() ?? 'N/A'),
                  _buildInfoRow('Trạng thái', lopHoc.tenTrangThai),
                  if (lopHoc.ghichu != null && lopHoc.ghichu!.isNotEmpty)
                    _buildInfoRow('Ghi chú', lopHoc.ghichu!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Subjects
          if (lopHoc.monhocs.isNotEmpty)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Môn học',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...lopHoc.monhocs.map((monhoc) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.book, size: 20, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(monhoc),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm thành viên...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchText = value;
                _currentPage = 1;
              });
              _loadPeople();
            },
          ),
        ),
        
        // Members list
        Expanded(
          child: _isLoadingPeople
              ? const Center(child: CircularProgressIndicator())
              : _buildMembersList(),
        ),
      ],
    );
  }

  Widget _buildMembersList() {
    final allMembers = [..._teachers, ..._students];
    
    if (allMembers.isEmpty) {
      return const Center(
        child: Text('Không có thành viên nào'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: allMembers.length,
      itemBuilder: (context, index) {
        final member = allMembers[index];
        final isTeacher = _teachers.contains(member);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isTeacher ? Colors.blue : Colors.green,
              child: Text(
                member.hoten.isNotEmpty ? member.hoten[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(member.hoten),
            subtitle: Text(member.email),
            trailing: Chip(
              label: Text(
                isTeacher ? 'Giảng viên' : 'Sinh viên',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: isTeacher ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Không thể tải thông tin lớp học',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(lopHocListProvider),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPeople() async {
    setState(() {
      _isLoadingPeople = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Load students
      final studentsResult = await apiService.getStudentsInClass(
        widget.classId,
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchText.isNotEmpty ? _searchText : null,
      );
      
      // Load teachers
      final teachersResult = await apiService.getTeachersInClass(widget.classId);
      
      setState(() {
        _students = studentsResult.items;
        _teachers = teachersResult;
        _totalCount = studentsResult.totalCount;
        _isLoadingPeople = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPeople = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách thành viên: $e')),
        );
      }
    }
  }
}
