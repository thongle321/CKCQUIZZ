import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';

class AdminLopHocDetailScreen extends ConsumerStatefulWidget {
  final LopHoc lopHoc;

  const AdminLopHocDetailScreen({super.key, required this.lopHoc});

  @override
  ConsumerState<AdminLopHocDetailScreen> createState() => _AdminLopHocDetailScreenState();
}

class _AdminLopHocDetailScreenState extends ConsumerState<AdminLopHocDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lopHoc = ref.watch(lopHocListProvider)
        .firstWhere((lop) => lop.id == widget.lopHoc.id, orElse: () => widget.lopHoc);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lopHoc.tenLop),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(lopHoc),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _confirmDelete(lopHoc);
                  break;
                case 'change_teacher':
                  _showChangeTeacherDialog(lopHoc);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'change_teacher',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 8),
                    Text('Đổi giảng viên'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xóa lớp học', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thông tin'),
            Tab(text: 'Sinh viên'),
            Tab(text: 'Yêu cầu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildThongTinTab(lopHoc),
          _buildSinhVienTab(lopHoc),
          _buildYeuCauTab(lopHoc),
        ],
      ),
    );
  }

  Widget _buildThongTinTab(LopHoc lopHoc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(lopHoc),
          const SizedBox(height: 16),
          _buildStatsCard(lopHoc),
          const SizedBox(height: 16),
          _buildProgressCard(lopHoc),
        ],
      ),
    );
  }

  Widget _buildInfoCard(LopHoc lopHoc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin lớp học',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Tên lớp', lopHoc.tenLop),
            _buildInfoRow('Mã lớp', lopHoc.maLop),
            _buildInfoRow('Môn học', lopHoc.monHocTen),
            _buildInfoRow('Giảng viên', lopHoc.giangVienTen),
            _buildInfoRow('Năm học', '${lopHoc.namHoc}'),
            _buildInfoRow('Học kỳ', '${lopHoc.hocKy}'),
            _buildInfoRow('Sĩ số', '${lopHoc.siSoHienTai}/${lopHoc.siSo}'),
            _buildInfoRow('Trạng thái', lopHoc.tenTrangThai),
            if (lopHoc.moTa.isNotEmpty)
              _buildInfoRow('Mô tả', lopHoc.moTa),
            _buildInfoRow('Ngày tạo', _formatDate(lopHoc.ngayTao)),
            _buildInfoRow('Cập nhật', _formatDate(lopHoc.ngayCapNhat)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(LopHoc lopHoc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Sinh viên',
                    '${lopHoc.siSoHienTai}',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Còn trống',
                    '${lopHoc.siSo - lopHoc.siSoHienTai}',
                    Icons.person_add,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Tỷ lệ đầy',
                    '${lopHoc.phanTramDayLop.toStringAsFixed(1)}%',
                    Icons.analytics,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(LopHoc lopHoc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiến độ lớp học',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Sĩ số: ${lopHoc.siSoHienTai}/${lopHoc.siSo}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: lopHoc.phanTramDayLop / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                lopHoc.phanTramDayLop > 80 ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${lopHoc.phanTramDayLop.toStringAsFixed(1)}% đã đầy',
              style: TextStyle(
                color: lopHoc.phanTramDayLop > 80 ? Colors.red : Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSinhVienTab(LopHoc lopHoc) {
    final danhSachUser = ref.watch(userListProvider);
    final sinhVienTrongLop = danhSachUser
        .where((user) => lopHoc.danhSachSinhVienIds.contains(user.id))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Danh sách sinh viên (${sinhVienTrongLop.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Thêm SV'),
                onPressed: () => _showAddStudentDialog(lopHoc),
              ),
            ],
          ),
        ),
        Expanded(
          child: sinhVienTrongLop.isEmpty
              ? const Center(
                  child: Text('Chưa có sinh viên nào trong lớp'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sinhVienTrongLop.length,
                  itemBuilder: (context, index) {
                    final sinhVien = sinhVienTrongLop[index];
                    return _buildSinhVienCard(sinhVien, lopHoc);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildYeuCauTab(LopHoc lopHoc) {
    final danhSachYeuCau = ref.watch(yeuCauThamGiaLopProvider)
        .where((yeuCau) => yeuCau.lopHocId == lopHoc.id)
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Yêu cầu tham gia (${danhSachYeuCau.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: danhSachYeuCau.isEmpty
              ? const Center(
                  child: Text('Không có yêu cầu nào'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: danhSachYeuCau.length,
                  itemBuilder: (context, index) {
                    final yeuCau = danhSachYeuCau[index];
                    return _buildYeuCauCard(yeuCau, lopHoc);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSinhVienCard(User sinhVien, LopHoc lopHoc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(sinhVien.hoVaTen[0].toUpperCase()),
        ),
        title: Text(sinhVien.hoVaTen),
        subtitle: Text('MSSV: ${sinhVien.mssv}\nEmail: ${sinhVien.email}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'remove') {
              _confirmRemoveStudent(sinhVien, lopHoc);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.remove_circle, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa khỏi lớp', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYeuCauCard(YeuCauThamGiaLop yeuCau, LopHoc lopHoc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    yeuCau.sinhVienTen,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _buildTrangThaiYeuCauChip(yeuCau.trangThai),
              ],
            ),
            const SizedBox(height: 8),
            Text('MSSV: ${yeuCau.sinhVienMSSV}'),
            if (yeuCau.lyDo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Lý do: ${yeuCau.lyDo}'),
            ],
            Text('Ngày yêu cầu: ${_formatDate(yeuCau.ngayYeuCau)}'),
            if (yeuCau.trangThai == TrangThaiYeuCau.choXuLy) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Từ chối', style: TextStyle(color: Colors.red)),
                    onPressed: () => _handleYeuCau(yeuCau, TrangThaiYeuCau.tuChoi),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Chấp nhận'),
                    onPressed: () => _handleYeuCau(yeuCau, TrangThaiYeuCau.chapNhan),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrangThaiYeuCauChip(TrangThaiYeuCau trangThai) {
    Color color;
    String text;
    switch (trangThai) {
      case TrangThaiYeuCau.choXuLy:
        color = Colors.orange;
        text = 'Chờ xử lý';
        break;
      case TrangThaiYeuCau.chapNhan:
        color = Colors.green;
        text = 'Chấp nhận';
        break;
      case TrangThaiYeuCau.tuChoi:
        color = Colors.red;
        text = 'Từ chối';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showEditDialog(LopHoc lopHoc) {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng sửa lớp học sẽ được implement')),
    );
  }

  void _showChangeTeacherDialog(LopHoc lopHoc) {
    // TODO: Implement change teacher dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng đổi giảng viên sẽ được implement')),
    );
  }

  void _showAddStudentDialog(LopHoc lopHoc) {
    // TODO: Implement add student dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thêm sinh viên sẽ được implement')),
    );
  }

  void _confirmDelete(LopHoc lopHoc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa lớp "${lopHoc.tenLop}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              ref.read(lopHocListProvider.notifier).deleteLopHoc(lopHoc.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa lớp "${lopHoc.tenLop}"')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveStudent(User sinhVien, LopHoc lopHoc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${sinhVien.hoVaTen}" khỏi lớp?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              ref.read(lopHocListProvider.notifier)
                  .removeSinhVienFromLop(lopHoc.id, sinhVien.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa "${sinhVien.hoVaTen}" khỏi lớp')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _handleYeuCau(YeuCauThamGiaLop yeuCau, TrangThaiYeuCau trangThai) {
    ref.read(yeuCauThamGiaLopProvider.notifier)
        .updateTrangThaiYeuCau(yeuCau.id, trangThai);

    if (trangThai == TrangThaiYeuCau.chapNhan) {
      // Thêm sinh viên vào lớp
      ref.read(lopHocListProvider.notifier)
          .addSinhVienToLop(yeuCau.lopHocId, yeuCau.sinhVienId);
    }

    final message = trangThai == TrangThaiYeuCau.chapNhan
        ? 'Đã chấp nhận yêu cầu của ${yeuCau.sinhVienTen}'
        : 'Đã từ chối yêu cầu của ${yeuCau.sinhVienTen}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
