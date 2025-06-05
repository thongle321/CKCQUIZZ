import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'dart:math'; // For generating random IDs, replace with proper ID generation

// Provider để lưu danh sách môn học tạm thời
final tempMonHocListProvider = StateProvider<List<MonHoc>>((ref) {
  return [];
});

class MonHocScreen extends ConsumerWidget {
  const MonHocScreen({super.key});

  void _showMonHocDialog(BuildContext context, WidgetRef ref, {MonHoc? monHocToEdit}) {
    final formKey = GlobalKey<FormState>();
    String tenMonHoc = monHocToEdit?.tenMonHoc ?? '';
    String maMonHoc = monHocToEdit?.maMonHoc ?? '';
    // int soTinChi = monHocToEdit?.soTinChi ?? 0; // Assuming soTinChi is part of your model

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(monHocToEdit == null ? 'Thêm môn học mới' : 'Chỉnh sửa môn học'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: maMonHoc,
                    decoration: const InputDecoration(labelText: 'Mã môn học'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập mã môn học';
                      }
                      return null;
                    },
                    onChanged: (value) => maMonHoc = value.trim(),
                  ),
                  TextFormField(
                    initialValue: tenMonHoc,
                    decoration: const InputDecoration(labelText: 'Tên môn học'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên môn học';
                      }
                      return null;
                    },
                    onChanged: (value) => tenMonHoc = value.trim(),
                  ),
                  // TextFormField(
                  //   initialValue: soTinChi.toString(),
                  //   decoration: const InputDecoration(labelText: 'Số tín chỉ'),
                  //   keyboardType: TextInputType.number,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) return 'Vui lòng nhập số tín chỉ';
                  //     if (int.tryParse(value) == null || int.parse(value) < 0) return 'Số tín chỉ không hợp lệ';
                  //     return null;
                  //   },
                  //   onChanged: (value) => soTinChi = int.tryParse(value) ?? 0,
                  // ),
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
                  final currentMonHocs = ref.read(monHocListProvider);
                  if (monHocToEdit == null) {
                    // Check for duplicate maMonHoc before adding
                    if (currentMonHocs.any((mh) => mh.maMonHoc.toLowerCase() == maMonHoc.toLowerCase())){
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: Mã môn học "$maMonHoc" đã tồn tại.')),
                      );
                      return;
                    }
                    final newMonHoc = MonHoc(
                      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID
                      maMonHoc: maMonHoc,
                      tenMonHoc: tenMonHoc,
                      soTinChi: 0, // Default, update if using soTinChi field
                      isDeleted: false,
                    );
                    ref.read(monHocListProvider.notifier).update((state) => [...state, newMonHoc]);
                  } else {
                     // Check for duplicate maMonHoc when editing (excluding self)
                    if (currentMonHocs.any((mh) => mh.id != monHocToEdit.id && mh.maMonHoc.toLowerCase() == maMonHoc.toLowerCase())){
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: Mã môn học "$maMonHoc" đã tồn tại cho môn khác.')),
                      );
                      return;
                    }
                    final updatedMonHoc = monHocToEdit.copyWith(
                      maMonHoc: maMonHoc,
                      tenMonHoc: tenMonHoc,
                      // soTinChi: soTinChi, 
                    );
                    ref.read(monHocListProvider.notifier).update((state) => 
                        state.map((mh) => mh.id == updatedMonHoc.id ? updatedMonHoc : mh).toList());
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(monHocToEdit == null ? 'Thêm' : 'Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteMonHoc(BuildContext context, WidgetRef ref, MonHoc monHoc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa môn học "${monHoc.tenMonHoc}"? Điều này có thể ảnh hưởng đến các nhóm học phần liên quan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              ref.read(monHocListProvider.notifier).update((state) => 
                  state.where((mh) => mh.id != monHoc.id).toList());
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa môn học: ${monHoc.tenMonHoc}')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monHocList = ref.watch(monHocListProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý môn học',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 30,
                tooltip: 'Thêm môn học mới',
                onPressed: () => _showMonHocDialog(context, ref),
                color: theme.primaryColor,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: monHocList.isEmpty
                ? Center(
                    child: Text(
                      'Chưa có môn học nào. Hãy thêm môn học mới.',
                      style: theme.textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: monHocList.length,
                    itemBuilder: (context, index) {
                      final monHoc = monHocList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(monHoc.tenMonHoc, style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text('Mã: ${monHoc.maMonHoc}'), // Thêm các thông tin khác nếu cần
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showMonHocDialog(context, ref, monHocToEdit: monHoc);
                              } else if (value == 'delete') {
                                _confirmDeleteMonHoc(context, ref, monHoc);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Chỉnh sửa'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Xóa'),
                              ),
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
