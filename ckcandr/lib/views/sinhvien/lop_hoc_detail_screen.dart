import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';

class SinhVienLopHocDetailScreen extends ConsumerStatefulWidget {
  final LopHoc lopHoc;

  const SinhVienLopHocDetailScreen({super.key, required this.lopHoc});

  @override
  ConsumerState<SinhVienLopHocDetailScreen> createState() => _SinhVienLopHocDetailScreenState();
}

class _SinhVienLopHocDetailScreenState extends ConsumerState<SinhVienLopHocDetailScreen>
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thông tin'),
            Tab(text: 'Bạn học'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildThongTinTab(lopHoc),
          _buildBanHocTab(lopHoc),
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
          _buildGiangVienCard(lopHoc),
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
            _buildInfoRow('Học kỳ', _getHocKyText(lopHoc.hocKy)),
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
              'Thống kê lớp học',
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
                    'Sĩ số tối đa',
                    '${lopHoc.siSo}',
                    Icons.group,
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
            const SizedBox(height: 8),
            Text(
              'Lớp đã đầy ${lopHoc.phanTramDayLop.toStringAsFixed(1)}%',
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

  Widget _buildGiangVienCard(LopHoc lopHoc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Giảng viên',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Text(
                    lopHoc.giangVienTen[0].toUpperCase(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lopHoc.giangVienTen,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Giảng viên phụ trách',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () => _contactGiangVien(lopHoc),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanHocTab(LopHoc lopHoc) {
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
                  'Danh sách bạn học (${sinhVienTrongLop.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: sinhVienTrongLop.isEmpty
              ? const Center(
                  child: Text('Chưa có sinh viên nào khác trong lớp'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sinhVienTrongLop.length,
                  itemBuilder: (context, index) {
                    final sinhVien = sinhVienTrongLop[index];
                    return _buildSinhVienCard(sinhVien);
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
            fontSize: 18,
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

  Widget _buildSinhVienCard(User sinhVien) {
    final currentUser = ref.watch(currentUserProvider);
    final isCurrentUser = sinhVien.id == currentUser?.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrentUser ? Colors.blue[50] : null,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(sinhVien.hoVaTen[0].toUpperCase()),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                sinhVien.hoVaTen,
                style: TextStyle(
                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Bạn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text('MSSV: ${sinhVien.mssv}'),
        trailing: isCurrentUser
            ? null
            : IconButton(
                icon: const Icon(Icons.message),
                onPressed: () => _contactSinhVien(sinhVien),
              ),
      ),
    );
  }

  String _getHocKyText(int hocKy) {
    switch (hocKy) {
      case 1:
        return 'Học kỳ 1';
      case 2:
        return 'Học kỳ 2';
      case 3:
        return 'Học kỳ hè';
      default:
        return 'Học kỳ $hocKy';
    }
  }

  void _contactGiangVien(LopHoc lopHoc) {
    // TODO: Implement contact teacher functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Liên hệ với ${lopHoc.giangVienTen}')),
    );
  }

  void _contactSinhVien(User sinhVien) {
    // TODO: Implement contact student functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nhắn tin với ${sinhVien.hoVaTen}')),
    );
  }
}
