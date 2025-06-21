import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/core/widgets/role_themed_screen.dart';
import 'package:ckcandr/views/admin/class_detail_screen.dart';
import 'package:ckcandr/views/sinhvien/widgets/join_class_dialog.dart';

class StudentLopHocScreen extends ConsumerStatefulWidget {
  const StudentLopHocScreen({super.key});

  @override
  ConsumerState<StudentLopHocScreen> createState() => _StudentLopHocScreenState();
}

class _StudentLopHocScreenState extends ConsumerState<StudentLopHocScreen> {
  String _searchQuery = '';
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final lopHocAsync = ref.watch(lopHocListProvider);
    final currentUser = ref.watch(currentUserControllerProvider);

    return RoleThemedScreen(
      title: 'Danh sách lớp học',
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm lớp học...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filter and Join button row
                Row(
                  children: [
                    // Status filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedStatus,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tất cả')),
                          DropdownMenuItem(value: 'active', child: Text('Đang hoạt động')),
                          DropdownMenuItem(value: 'inactive', child: Text('Không hoạt động')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Join class button
                    ElevatedButton.icon(
                      onPressed: () => _showJoinClassDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Tham gia lớp'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Class list
          Expanded(
            child: lopHocAsync.when(
              data: (lopHocList) {
                final filteredList = _filterClasses(lopHocList, currentUser);
                
                if (filteredList.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có lớp học nào',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Hãy tham gia lớp học bằng mã mời',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(lopHocListProvider.notifier).loadClasses();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final lopHoc = filteredList[index];
                      return _buildClassCard(lopHoc);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: $error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(lopHocListProvider.notifier).loadClasses();
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
    );
  }

  List<LopHoc> _filterClasses(List<LopHoc> classes, User? currentUser) {
    return classes.where((lopHoc) {
      // Filter by search query
      final matchesSearch = _searchQuery.isEmpty ||
          lopHoc.tenlop.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (lopHoc.mamoi?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          lopHoc.monhocs.any((monhoc) => monhoc.toLowerCase().contains(_searchQuery.toLowerCase()));

      // Filter by status
      final matchesStatus = _selectedStatus == null ||
          (_selectedStatus == 'active' && (lopHoc.trangthai ?? false)) ||
          (_selectedStatus == 'inactive' && !(lopHoc.trangthai ?? true));

      // Only show classes that are visible to students
      final isVisible = lopHoc.hienthi ?? false;

      return matchesSearch && matchesStatus && isVisible;
    }).toList();
  }

  Widget _buildClassCard(LopHoc lopHoc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassDetailScreen(lopHoc: lopHoc),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lopHoc.tenlop,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (lopHoc.trangthai ?? false) ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (lopHoc.trangthai ?? false) ? 'Hoạt động' : 'Không hoạt động',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Teacher info
              if (lopHoc.tengiangvien?.isNotEmpty ?? false)
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Giảng viên: ${lopHoc.tengiangvien ?? "Chưa có"}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              // Class info
              Row(
                children: [
                  const Icon(Icons.people, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Sĩ số: ${lopHoc.siso}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Năm học: ${lopHoc.namhoc} - HK${lopHoc.hocky}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              if (lopHoc.mamoi?.isNotEmpty ?? false) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.vpn_key, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Mã mời: ${lopHoc.mamoi ?? ""}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
              // Subjects
              if (lopHoc.monhocs.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: lopHoc.monhocs.map((monhoc) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Text(
                        monhoc,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const JoinClassDialog(),
    ).then((_) {
      // Refresh class list after joining
      ref.read(lopHocListProvider.notifier).loadClasses();
    });
  }
}
