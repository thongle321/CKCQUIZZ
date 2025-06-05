import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/models/chuong_muc_model.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/providers/chuong_muc_provider.dart';
import 'package:ckcandr/providers/hoat_dong_provider.dart';
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart';

class ChuongMucScreen extends ConsumerStatefulWidget {
  const ChuongMucScreen({super.key});

  @override
  ConsumerState<ChuongMucScreen> createState() => _ChuongMucScreenState();
}

class _ChuongMucScreenState extends ConsumerState<ChuongMucScreen> {
  String? _selectedMonHocId;

  void _showChuongMucDialog(BuildContext context, {
    ChuongMuc? chuongMucToEdit,
    required String currentMonHocId,
  }) {
    final formKey = GlobalKey<FormState>();
    String tenChuongMuc = chuongMucToEdit?.tenChuongMuc ?? '';
    int thuTu = chuongMucToEdit?.thuTu ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(chuongMucToEdit == null ? 'Thêm chương mục mới' : 'Chỉnh sửa chương mục'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: tenChuongMuc,
                    decoration: const InputDecoration(labelText: 'Tên chương mục'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên chương mục';
                      }
                      return null;
                    },
                    onChanged: (value) => tenChuongMuc = value.trim(),
                  ),
                  TextFormField(
                    initialValue: thuTu.toString(),
                    decoration: const InputDecoration(labelText: 'Thứ tự'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Nhập thứ tự';
                      if (int.tryParse(value) == null || int.parse(value) < 0) return 'Thứ tự không hợp lệ';
                      return null;
                    },
                    onChanged: (value) => thuTu = int.tryParse(value) ?? 0,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final isEditing = chuongMucToEdit != null;
                  final tenChuongMucLog = tenChuongMuc.isNotEmpty ? tenChuongMuc : (chuongMucToEdit?.tenChuongMuc ?? 'N/A');
                  final monHoc = ref.read(monHocListProvider).firstWhere((mh) => mh.id == currentMonHocId, orElse: () => MonHoc(id: '', tenMonHoc: 'Không xác định', maMonHoc: '', soTinChi: 0));
                  final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
                  
                  if (!isEditing) {
                    final newChuongMuc = ChuongMuc(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      monHocId: currentMonHocId,
                      tenChuongMuc: tenChuongMuc,
                      thuTu: thuTu,
                    );
                    ref.read(chuongMucListProvider.notifier).update((state) => [...state, newChuongMuc]);
                    final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
                    hoatDongNotifier.addHoatDong(
                      'Đã thêm chương mục: ${newChuongMuc.tenChuongMuc}',
                      LoaiHoatDong.MON_HOC,
                      Icons.add_link_outlined,
                      idDoiTuongLienQuan: newChuongMuc.id,
                    );
                  } else {
                    final updatedChuongMuc = chuongMucToEdit!.copyWith(
                      tenChuongMuc: tenChuongMuc,
                      thuTu: thuTu,
                    );
                    ref.read(chuongMucListProvider.notifier).update((state) => 
                        state.map((cm) => cm.id == updatedChuongMuc.id ? updatedChuongMuc : cm).toList());
                    hoatDongNotifier.addHoatDong(
                      'Đã cập nhật chương mục: ${updatedChuongMuc.tenChuongMuc}',
                      LoaiHoatDong.MON_HOC,
                      Icons.edit_attributes_outlined,
                      idDoiTuongLienQuan: updatedChuongMuc.id,
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(chuongMucToEdit == null ? 'Thêm' : 'Lưu'),
            ),
          ],
        );
      },
    );
  }

 void _confirmDeleteChuongMuc(BuildContext context, ChuongMuc chuongMuc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa chương mục "${chuongMuc.tenChuongMuc}"? Các câu hỏi thuộc chương này cũng có thể bị ảnh hưởng.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final tenChuongMucLog = chuongMuc.tenChuongMuc;
              final monHoc = ref.read(monHocListProvider).firstWhere((mh) => mh.id == chuongMuc.monHocId, orElse: () => MonHoc(id: '', tenMonHoc: 'Không xác định', maMonHoc: '', soTinChi: 0));
              ref.read(chuongMucListProvider.notifier).update((state) => 
                  state.where((cm) => cm.id != chuongMuc.id).toList());
              final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
              hoatDongNotifier.addHoatDong(
                'Đã xóa chương mục: ${chuongMuc.tenChuongMuc}',
                LoaiHoatDong.MON_HOC,
                Icons.link_off_outlined,
                idDoiTuongLienQuan: chuongMuc.id,
              );
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa chương mục: ${chuongMuc.tenChuongMuc}')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monHocList = ref.watch(monHocListProvider);
    final theme = Theme.of(context);
    
    // Initialize _selectedMonHocId if it's null and monHocList is not empty
    if (_selectedMonHocId == null && monHocList.isNotEmpty) {
      _selectedMonHocId = monHocList.first.id;
    }
    // If _selectedMonHocId is not null but not in monHocList (e.g. subject deleted), reset it
    else if (_selectedMonHocId != null && !monHocList.any((mh) => mh.id == _selectedMonHocId)){
        _selectedMonHocId = monHocList.isNotEmpty ? monHocList.first.id : null;
    }

    final chuongMucHienTai = _selectedMonHocId == null 
        ? <ChuongMuc>[] 
        : ref.watch(filteredChuongMucListProvider(_selectedMonHocId!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý chương mục',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (_selectedMonHocId != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 30,
                  tooltip: 'Thêm chương mục mới',
                  onPressed: () => _showChuongMucDialog(context, currentMonHocId: _selectedMonHocId!),
                  color: theme.primaryColor,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              if (monHocList.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Vui lòng thêm Môn học trước khi quản lý Chương mục.',
                     style: theme.textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
                     textAlign: TextAlign.center,
                    ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedMonHocId,
                  decoration: const InputDecoration(labelText: 'Chọn môn học', border: OutlineInputBorder()), 
                  isExpanded: true,
                  items: monHocList.map((MonHoc monHoc) {
                    return DropdownMenuItem<String>(
                      value: monHoc.id,
                      child: Text(monHoc.tenMonHoc, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMonHocId = newValue;
                    });
                  },
                ),
              const SizedBox(height: 16),
              if (_selectedMonHocId != null && monHocList.isNotEmpty)
                Text('Các chương mục cho: ${monHocList.firstWhere((mh) => mh.id == _selectedMonHocId).tenMonHoc}', style: theme.textTheme.titleMedium),
            ],
          )
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:12.0),
            child: _selectedMonHocId == null || chuongMucHienTai.isEmpty
                ? Center(
                    child: Text(
                      _selectedMonHocId == null && monHocList.isNotEmpty ? 'Vui lòng chọn một môn học.' : 'Chưa có chương mục nào cho môn học này.',
                      style: theme.textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: chuongMucHienTai.length,
                    itemBuilder: (context, index) {
                      final chuongMuc = chuongMucHienTai[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(child: Text((chuongMuc.thuTu).toString())),
                          title: Text(chuongMuc.tenChuongMuc, style: const TextStyle(fontWeight: FontWeight.w500)),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showChuongMucDialog(context, chuongMucToEdit: chuongMuc, currentMonHocId: _selectedMonHocId!);
                              } else if (value == 'delete') {
                                _confirmDeleteChuongMuc(context, chuongMuc);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                              const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
} 