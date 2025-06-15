import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';

class GiangVienLopHocDetailScreen extends ConsumerStatefulWidget {
  final LopHoc lopHoc;

  const GiangVienLopHocDetailScreen({super.key, required this.lopHoc});

  @override
  ConsumerState<GiangVienLopHocDetailScreen> createState() => _GiangVienLopHocDetailScreenState();
}

class _GiangVienLopHocDetailScreenState extends ConsumerState<GiangVienLopHocDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            icon: const Icon(Icons.share),
            onPressed: () => _shareMaLop(lopHoc),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thông tin'),
            Tab(text: 'Sinh viên'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildThongTinTab(lopHoc),
          _buildSinhVienTab(lopHoc),
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
          _buildMaLopCard(lopHoc),
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
            _buildInfoRow('Năm học', '${lopHoc.namHoc}'),
            _buildInfoRow('Học kỳ', '${lopHoc.hocKy}'),
            _buildInfoRow('Sĩ số', '${lopHoc.siSoHienTai}/${lopHoc.siSo}'),
            _buildInfoRow('Trạng thái', lopHoc.tenTrangThai),
            if (lopHoc.moTa.isNotEmpty)
              _buildInfoRow('Mô tả', lopHoc.moTa),
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
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: lopHoc.phanTramDayLop / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                lopHoc.phanTramDayLop > 80 ? Colors.red : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaLopCard(LopHoc lopHoc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mã lớp cho sinh viên',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    lopHoc.maLop,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chia sẻ mã này với sinh viên để họ tham gia lớp',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Sao chép mã'),
                    onPressed: () => _copyMaLop(lopHoc.maLop),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Chia sẻ'),
                    onPressed: () => _shareMaLop(lopHoc),
                  ),
                ),
              ],
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
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditStudentDialog(sinhVien),
        ),
      ),
    );
  }

  void _copyMaLop(String maLop) {
    // TODO: Implement copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã sao chép mã lớp: $maLop')),
    );
  }

  void _shareMaLop(LopHoc lopHoc) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chia sẻ mã lớp: ${lopHoc.maLop}')),
    );
  }

  void _showAddStudentDialog(LopHoc lopHoc) {
    // TODO: Implement add student dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thêm sinh viên sẽ được implement')),
    );
  }

  void _showEditStudentDialog(User sinhVien) {
    // TODO: Implement edit student dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chỉnh sửa thông tin ${sinhVien.hoVaTen}')),
    );
  }
}
