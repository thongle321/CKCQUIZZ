import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/providers/thong_bao_provider.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

// TODO: Potentially get current GiangVienId from an auth provider
const String _currentGiangVienId = 'gv001'; // Placeholder

class ThongBaoScreen extends ConsumerStatefulWidget {
  const ThongBaoScreen({super.key});

  @override
  ConsumerState<ThongBaoScreen> createState() => _ThongBaoScreenState();
}

class _ThongBaoScreenState extends ConsumerState<ThongBaoScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ThongBao> _filteredThongBao = [];
  String _searchTerm = '';

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 5; // Display 5 notifications per page

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
        _applyFiltersAndPagination();
      });
    });
    // Initial load
    // Note: In a real app, you might fetch initial data here or rely on the provider's initial state.
    // For now, we assume thongBaoListProvider might have data or will be populated elsewhere.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyFiltersAndPagination(); // Apply filters when dependencies change (e.g. provider updates)
  }

  void _applyFiltersAndPagination() {
    final allThongBao = ref.watch(thongBaoListProvider);
    List<ThongBao> tempFiltered = allThongBao;

    if (_searchTerm.isNotEmpty) {
      tempFiltered = tempFiltered.where((thongBao) {
        return thongBao.tieuDe.toLowerCase().contains(_searchTerm.toLowerCase()) ||
               thongBao.noiDung.toLowerCase().contains(_searchTerm.toLowerCase()) ||
               thongBao.phamViMoTa.toLowerCase().contains(_searchTerm.toLowerCase());
      }).toList();
    }

    // Sort by newest first
    tempFiltered.sort((a, b) => b.ngayCapNhat.compareTo(a.ngayCapNhat));

    // Apply pagination
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    _filteredThongBao = tempFiltered.sublist(
        startIndex,
        endIndex > tempFiltered.length ? tempFiltered.length : endIndex
    );
    if (mounted) {
      setState(() {});
    }
  }
  
  int _getTotalPages(int totalItems) {
    return (totalItems / _itemsPerPage).ceil();
  }

  void _showCreateOrEditThongBaoDialog({ThongBao? thongBaoToEdit}) {
    final _formKey = GlobalKey<FormState>();
    final _tieuDeController = TextEditingController(text: thongBaoToEdit?.tieuDe ?? '');
    final _noiDungController = TextEditingController(text: thongBaoToEdit?.noiDung ?? '');
    final _phamViController = TextEditingController(text: thongBaoToEdit?.phamViMoTa ?? '');
    bool _isPublished = thongBaoToEdit?.isPublished ?? true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(thongBaoToEdit == null ? 'Tạo thông báo mới' : 'Chỉnh sửa thông báo'),
          content: StatefulBuilder( // To update _isPublished in dialog
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: _tieuDeController,
                        decoration: const InputDecoration(labelText: 'Tiêu đề (*)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _noiDungController,
                        decoration: const InputDecoration(labelText: 'Nội dung (*)', hintText: 'Nhập nội dung chi tiết...'),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập nội dung';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phamViController,
                        decoration: const InputDecoration(labelText: 'Phạm vi/Đối tượng (*)', hintText: 'VD: Sinh viên lớp NMLT - HK1'),
                         validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập phạm vi/đối tượng';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        title: const Text('Đăng thông báo?'),
                        value: _isPublished,
                        onChanged: (bool value) {
                          setStateDialog(() {
                            _isPublished = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(thongBaoToEdit == null ? 'Tạo' : 'Lưu thay đổi'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (thongBaoToEdit == null) {
                    ref.read(thongBaoListProvider.notifier).addThongBao(
                          tieuDe: _tieuDeController.text,
                          noiDung: _noiDungController.text,
                          nguoiTaoId: _currentGiangVienId, // Placeholder
                          phamViMoTa: _phamViController.text,
                          isPublished: _isPublished,
                        );
                  } else {
                    final updatedThongBao = thongBaoToEdit.copyWith(
                      tieuDe: _tieuDeController.text,
                      noiDung: _noiDungController.text,
                      phamViMoTa: _phamViController.text,
                      isPublished: _isPublished,
                      ngayCapNhat: DateTime.now(),
                    );
                    ref.read(thongBaoListProvider.notifier).editThongBao(updatedThongBao);
                  }
                  _applyFiltersAndPagination(); // Refresh list
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteThongBao(String thongBaoId, String tieuDe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa thông báo "$tieuDe" không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
              onPressed: () {
                ref.read(thongBaoListProvider.notifier).deleteThongBao(thongBaoId);
                _applyFiltersAndPagination(); // Refresh list
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allThongBaoOriginal = ref.watch(thongBaoListProvider);
    final totalItems = allThongBaoOriginal.where((thongBao) {
      if (_searchTerm.isEmpty) return true;
      return thongBao.tieuDe.toLowerCase().contains(_searchTerm.toLowerCase()) ||
             thongBao.noiDung.toLowerCase().contains(_searchTerm.toLowerCase()) ||
             thongBao.phamViMoTa.toLowerCase().contains(_searchTerm.toLowerCase());
    }).length;
    final totalPages = _getTotalPages(totalItems);
    
    // Re-apply filters and pagination whenever build is called and provider changes
    // This can be sometimes redundant with didChangeDependencies but ensures UI is consistent
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFiltersAndPagination());


    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm thông báo...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Tạo thông báo'),
                onPressed: () => _showCreateOrEditThongBaoDialog(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_filteredThongBao.isEmpty)
            Expanded(
              child: Center(
                child: Text(allThongBaoOriginal.isEmpty 
                    ? 'Chưa có thông báo nào.' 
                    : 'Không tìm thấy thông báo nào khớp với tìm kiếm.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filteredThongBao.length,
                itemBuilder: (context, index) {
                  final thongBao = _filteredThongBao[index];
                  return _ThongBaoCard(
                    thongBao: thongBao,
                    onEdit: () => _showCreateOrEditThongBaoDialog(thongBaoToEdit: thongBao),
                    onDelete: () => _confirmDeleteThongBao(thongBao.id, thongBao.tieuDe),
                  );
                },
              ),
            ),
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() {
                              _currentPage--;
                              _applyFiltersAndPagination();
                            });
                          }
                        : null,
                  ),
                  for (int i = 1; i <= totalPages; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(i.toString()),
                        selected: _currentPage == i,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _currentPage = i;
                              _applyFiltersAndPagination();
                            });
                          }
                        },
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < totalPages
                        ? () {
                            setState(() {
                              _currentPage++;
                              _applyFiltersAndPagination();
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ThongBaoCard extends StatelessWidget {
  final ThongBao thongBao;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ThongBaoCard({required this.thongBao, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              thongBao.tieuDe,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.campaign_outlined, size: 16, color: theme.textTheme.bodySmall?.color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    thongBao.phamViMoTa,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
             Text(
              thongBao.noiDung,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_filled_rounded, size: 14, color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm dd/MM/yyyy').format(thongBao.ngayCapNhat),
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.edit_outlined, size: 18, color: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                      label: Text('Chỉnh sửa', style: TextStyle(color: isDark ? Colors.blue.shade300 : Colors.blue.shade700)),
                      onPressed: onEdit,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30), 
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, 
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: Icon(Icons.delete_outline, size: 18, color: isDark ? Colors.red.shade300 : Colors.red.shade700),
                      label: Text('Xóa', style: TextStyle(color: isDark ? Colors.red.shade300 : Colors.red.shade700)),
                      onPressed: onDelete,
                       style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30), 
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!thongBao.isPublished)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '(Bản nháp - Chưa đăng)',
                  style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 