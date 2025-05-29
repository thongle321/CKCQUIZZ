import 'package:flutter/material.dart';

class ChiTietLopHocPhanPage extends StatefulWidget {
  final String? lopHocPhanId; // Nhận ID lớp học phần (nếu có)

  const ChiTietLopHocPhanPage({super.key, this.lopHocPhanId });

  @override
  State<ChiTietLopHocPhanPage> createState() => _ChiTietLopHocPhanPageState();
}

class _ChiTietLopHocPhanPageState extends State<ChiTietLopHocPhanPage> {
  // Sample data - replace with actual data fetching based on lopHocPhanId
  final List<Map<String, String>> _danhSachSinhVien = [
    {
      'stt': '1',
      'hoTen': 'Nguyễn Văn A',
      'mssv': '0306221378',
      'gioiTinh': 'Nam',
      'ngaySinh': '2002-02-15',
    },
    // Add more students here
  ];

  int _currentPage = 1;
  final int _rowsPerPage = 8; // Adjust as needed

  List<Map<String, String>> get _paginatedSinhVien {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;
    return _danhSachSinhVien.sublist(
        startIndex,
        endIndex > _danhSachSinhVien.length ? _danhSachSinhVien.length : endIndex);
  }

  int get _totalPages => (_danhSachSinhVien.length / _rowsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết lớp Vật lý đại cương - HK1 (ID: ${widget.lopHocPhanId ?? "N/A"})'),
         leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm sinh viên...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('XUẤT BẢNG ĐIỂM'),
                  onPressed: () { /* TODO: Implement export */ },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                     side: BorderSide(color: theme.colorScheme.outline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('XUẤT DANH SÁCH'),
                  onPressed: () { /* TODO: Implement export */ },
                   style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                     side: BorderSide(color: theme.colorScheme.outline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('THÊM SINH VIÊN', style: TextStyle(color: Colors.white)),
                  onPressed: () { /* TODO: Implement add student */ },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith((states) => theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                  columns: const [
                    DataColumn(label: Text('STT')),
                    DataColumn(label: Text('Họ tên')),
                    DataColumn(label: Text('MSSV')),
                    DataColumn(label: Text('Giới tính')),
                    DataColumn(label: Text('Ngày sinh')),
                    DataColumn(label: Text('Hành động')),
                  ],
                  rows: _paginatedSinhVien.map((sinhVien) {
                    return DataRow(
                      cells: [
                        DataCell(Text(sinhVien['stt']!)),
                        DataCell(Text(sinhVien['hoTen']!)),
                        DataCell(Text(sinhVien['mssv']!)),
                        DataCell(Text(sinhVien['gioiTinh']!)),
                        DataCell(Text(sinhVien['ngaySinh']!)),
                        DataCell(Row(
                          children: [
                            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () { /* TODO: Edit */ }),
                            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () { /* TODO: Delete */ }),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Pagination Controls
            if (_totalPages > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                ),
                Text('$_currentPage / $_totalPages'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < _totalPages ? () => setState(() => _currentPage++) : null,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
} 