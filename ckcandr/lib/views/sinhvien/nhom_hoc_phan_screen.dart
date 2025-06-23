import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/sinh_vien_lop_provider.dart';

import 'package:ckcandr/providers/user_provider.dart';

import 'package:ckcandr/core/theme/role_theme.dart';

// Provider để lọc lớp học mà sinh viên đã đăng ký (sử dụng API thực tế)
final sinhVienLopHocFilteredProvider = Provider.family<List<LopHoc>, Map<String, String>>((ref, filters) {
  return ref.watch(filteredSinhVienLopHocProvider(filters));
});

class SinhVienNhomHocPhanScreen extends ConsumerStatefulWidget {
  const SinhVienNhomHocPhanScreen({super.key});

  @override
  ConsumerState<SinhVienNhomHocPhanScreen> createState() => _SinhVienNhomHocPhanScreenState();
}

class _SinhVienNhomHocPhanScreenState extends ConsumerState<SinhVienNhomHocPhanScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedHocKyFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Lọc lớp học mà sinh viên đã đăng ký
  List<LopHoc> get _filteredLopHoc {
    final query = _searchController.text.toLowerCase();
    final filters = {
      'search': query,
      'hocKy': _selectedHocKyFilter,
    };

    return ref.watch(sinhVienLopHocFilteredProvider(filters));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;

    return RoleThemedWidget(
      role: role,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lớp học đã tham gia'),
          backgroundColor: RoleTheme.getPrimaryColor(role),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Refresh dữ liệu từ API
                ref.invalidate(sinhVienLopHocListProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã làm mới dữ liệu từ server')),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tìm kiếm và bộ lọc
              _buildSearchAndFilters(),
              const SizedBox(height: 16),

              // Tiêu đề và thống kê
              _buildHeader(),
              const SizedBox(height: 16),

              // Danh sách nhóm học phần
              Expanded(
                child: _buildNhomHocPhanList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget thanh tìm kiếm và bộ lọc
  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Thanh tìm kiếm
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm nhóm học phần...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 12),

        // Bộ lọc
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedHocKyFilter,
                decoration: InputDecoration(
                  labelText: 'Học kỳ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ['all', 'HK1', 'HK2', 'HK3'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'all' ? 'Tất cả học kỳ' : value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedHocKyFilter = newValue ?? 'all';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget tiêu đề và thống kê
  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Lớp học đã tham gia',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Text(
            'Tổng: ${_filteredLopHoc.length} lớp',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Widget danh sách lớp học
  Widget _buildNhomHocPhanList() {
    final lopHocAsyncValue = ref.watch(sinhVienLopHocListProvider);

    return lopHocAsyncValue.when(
      data: (lopHocList) {
        final filteredList = _filteredLopHoc;

        if (filteredList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa tham gia lớp học nào',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Liên hệ giảng viên để tham gia lớp học',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(sinhVienLopHocListProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final lopHoc = filteredList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildLopHocCard(lopHoc),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi khi tải dữ liệu',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(sinhVienLopHocListProvider),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget card lớp học
  Widget _buildLopHocCard(LopHoc lopHoc) {
    // Lấy thông tin môn học từ danh sách môn học của lớp
    String tenMonHoc = 'Đang tải môn học...';
    if (lopHoc.monhocs.isNotEmpty) {
      tenMonHoc = lopHoc.monhocs.join(', ');
    } else {
      tenMonHoc = 'Chưa có môn học';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLopHocDetail(lopHoc),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với tên lớp và trạng thái
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lopHoc.tenlop,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (lopHoc.trangthai ?? false) ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (lopHoc.trangthai ?? false) ? Colors.green.shade200 : Colors.red.shade200,
                      ),
                    ),
                    child: Text(
                      (lopHoc.trangthai ?? false) ? 'Hoạt động' : 'Tạm dừng',
                      style: TextStyle(
                        fontSize: 12,
                        color: (lopHoc.trangthai ?? false) ? Colors.green.shade700 : Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Thông tin môn học
              Row(
                children: [
                  Icon(Icons.book, size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tenMonHoc,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Thông tin học kỳ và năm học
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'HK${lopHoc.hocky ?? 'N/A'} - Năm học ${lopHoc.namhoc ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Sĩ số và mã mời
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.purple.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Sĩ số: ${lopHoc.siso ?? 0} sinh viên',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (lopHoc.mamoi != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lopHoc.mamoi!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Thêm thông tin ghi chú nếu có
              if (lopHoc.ghichu != null && lopHoc.ghichu!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.amber.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ghi chú: ${lopHoc.ghichu}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }



  // Hiển thị chi tiết lớp học
  void _showLopHocDetail(LopHoc lopHoc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chi tiết: ${lopHoc.tenlop}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Tên lớp:', lopHoc.tenlop),
                _buildDetailRow('Mã lớp:', lopHoc.malop.toString()),
                if (lopHoc.monhocs.isNotEmpty)
                  _buildDetailRow('Môn học:', lopHoc.monhocs.join(', ')),
                _buildDetailRow('Học kỳ:', 'HK${lopHoc.hocky ?? 'N/A'}'),
                _buildDetailRow('Năm học:', lopHoc.namhoc?.toString() ?? 'N/A'),
                _buildDetailRow('Sĩ số:', '${lopHoc.siso ?? 0} sinh viên'),
                if (lopHoc.mamoi != null)
                  _buildDetailRow('Mã mời:', lopHoc.mamoi!),
                if (lopHoc.ghichu != null && lopHoc.ghichu!.isNotEmpty)
                  _buildDetailRow('Ghi chú:', lopHoc.ghichu!),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trạng thái tham gia',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Đã tham gia lớp học',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (lopHoc.trangthai ?? false) ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (lopHoc.trangthai ?? false) ? Colors.green.shade200 : Colors.red.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trạng thái lớp học',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: (lopHoc.trangthai ?? false) ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            (lopHoc.trangthai ?? false) ? Icons.check_circle : Icons.pause_circle,
                            size: 16,
                            color: (lopHoc.trangthai ?? false) ? Colors.green.shade600 : Colors.red.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (lopHoc.trangthai ?? false) ? 'Đang hoạt động' : 'Tạm dừng',
                            style: TextStyle(
                              color: (lopHoc.trangthai ?? false) ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 