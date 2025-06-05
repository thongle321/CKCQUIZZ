import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/providers/thong_bao_provider.dart';

// TODO: Potentially get current GiangVienId from an auth provider
const String _currentGiangVienId = 'gv001'; // Placeholder

class ThongBaoScreen extends ConsumerStatefulWidget {
  const ThongBaoScreen({super.key});

  @override
  ConsumerState<ThongBaoScreen> createState() => _ThongBaoScreenState();
}

class _ThongBaoScreenState extends ConsumerState<ThongBaoScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 5; // Display 5 notifications per page

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      // No need to check mounted here, listener should be removed in dispose
      setState(() {
        _searchTerm = _searchController.text;
        _currentPage = 1; // Reset to first page on new search
      });
    });
  }

  int _getTotalPages(int totalItems) {
    if (totalItems == 0) return 1; // Ensure at least one page even if no items
    return (totalItems / _itemsPerPage).ceil();
  }

  void _showCreateOrEditThongBaoDialog({ThongBao? thongBaoToEdit}) {
    final formKey = GlobalKey<FormState>();
    final tieuDeController = TextEditingController(text: thongBaoToEdit?.tieuDe ?? '');
    final noiDungController = TextEditingController(text: thongBaoToEdit?.noiDung ?? '');
    final phamViController = TextEditingController(text: thongBaoToEdit?.phamViMoTa ?? '');
    bool isPublished = thongBaoToEdit?.isPublished ?? true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(thongBaoToEdit == null ? 'Tạo thông báo mới' : 'Chỉnh sửa thông báo'),
          content: StatefulBuilder( // To update isPublished in dialog
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: tieuDeController,
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
                        controller: noiDungController,
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
                        controller: phamViController,
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
                        value: isPublished,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (bool value) {
                          setStateDialog(() {
                            isPublished = value;
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
                if (formKey.currentState!.validate()) {
                  if (thongBaoToEdit == null) {
                    ref.read(thongBaoListProvider.notifier).addThongBao(
                          tieuDe: tieuDeController.text,
                          noiDung: noiDungController.text,
                          nguoiTaoId: _currentGiangVienId, // Placeholder
                          phamViMoTa: phamViController.text,
                          isPublished: isPublished,
                        );
                  } else {
                    final updatedThongBao = thongBaoToEdit.copyWith(
                      tieuDe: tieuDeController.text,
                      noiDung: noiDungController.text,
                      phamViMoTa: phamViController.text,
                      isPublished: isPublished,
                      ngayCapNhat: DateTime.now(),
                    );
                    ref.read(thongBaoListProvider.notifier).editThongBao(updatedThongBao);
                  }
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
                // Reset to page 1 if the current page becomes empty after deletion
                // This logic needs to be smarter by checking the number of items on the current page
                setState(() {
                  _currentPage = 1; 
                });
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
    final allThongBaoFromProvider = ref.watch(thongBaoListProvider);
    
    List<ThongBao> thongBaoAfterSearch = allThongBaoFromProvider;
    if (_searchTerm.isNotEmpty) {
      thongBaoAfterSearch = allThongBaoFromProvider.where((thongBao) {
        final searchTermLower = _searchTerm.toLowerCase();
        return thongBao.tieuDe.toLowerCase().contains(searchTermLower) ||
               thongBao.noiDung.toLowerCase().contains(searchTermLower) ||
               thongBao.phamViMoTa.toLowerCase().contains(searchTermLower);
      }).toList();
    }
    thongBaoAfterSearch.sort((a, b) => b.ngayCapNhat.compareTo(a.ngayCapNhat));

    final totalItemsAfterSearch = thongBaoAfterSearch.length;
    final totalPages = _getTotalPages(totalItemsAfterSearch);

    // Adjust current page if it's out of bounds
    if (_currentPage > totalPages) {
        _currentPage = totalPages;
    }
    if (_currentPage < 1 && totalPages > 0) {
        _currentPage = 1;
    }
    // If current page is 0 because totalPages is 0, make it 1
    if (_currentPage < 1 ) _currentPage = 1;


    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage > totalItemsAfterSearch) 
                        ? totalItemsAfterSearch 
                        : startIndex + _itemsPerPage;
    
    final thongBaoForCurrentPage = (totalItemsAfterSearch > 0 && startIndex < endIndex) 
                                    ? thongBaoAfterSearch.sublist(startIndex, endIndex)
                                    : <ThongBao>[];

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
                    suffixIcon: _searchTerm.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              // setState is called by the listener
                            },
                          )
                        : null,
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
          if (thongBaoForCurrentPage.isEmpty)
            Expanded(
              child: Center(
                child: Text(allThongBaoFromProvider.isEmpty 
                    ? 'Chưa có thông báo nào.' 
                    : 'Không tìm thấy thông báo nào khớp với tìm kiếm.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: thongBaoForCurrentPage.length,
                itemBuilder: (context, index) {
                  final thongBao = thongBaoForCurrentPage[index];
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
                            });
                          }
                        : null,
                  ),
                  // Display a limited number of page buttons
                  ..._buildPageButtons(totalPages, context),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < totalPages
                        ? () {
                            setState(() {
                              _currentPage++;
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

  List<Widget> _buildPageButtons(int totalPages, BuildContext context) {
    List<Widget> buttons = [];
    const int maxDisplayedPages = 5; // Max number of page buttons to show (e.g., 1, 2, ..., 5, 6)
    const int edgeButtonCount = 1; // Number of buttons to show at the beginning and end

    if (totalPages <= maxDisplayedPages) {
      for (int i = 1; i <= totalPages; i++) {
        buttons.add(_pageButton(i, context));
      }
    } else {
      buttons.add(_pageButton(1, context)); // First page

      int startPage = _currentPage - (maxDisplayedPages ~/ 2) + edgeButtonCount;
      int endPage = _currentPage + (maxDisplayedPages ~/ 2) - edgeButtonCount -1; // -1 because first and last are always shown

      if (startPage <= edgeButtonCount +1 ) {
        startPage = edgeButtonCount +1;
        endPage = maxDisplayedPages - edgeButtonCount;
      }

      if (endPage >= totalPages - edgeButtonCount) {
        endPage = totalPages - edgeButtonCount;
        startPage = totalPages - maxDisplayedPages + edgeButtonCount +1;
      }

      if (startPage > edgeButtonCount + 1) {
          buttons.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('...')));
      }

      for (int i = startPage; i <= endPage; i++) {
          if (i > edgeButtonCount && i < totalPages - edgeButtonCount + 1) {
             buttons.add(_pageButton(i, context));
          }
      }

      if (endPage < totalPages - edgeButtonCount) {
          buttons.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('...')));
      }

      buttons.add(_pageButton(totalPages, context)); // Last page
    }
    return buttons;
  }

  Widget _pageButton(int pageNumber, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: ChoiceChip(
        label: Text(pageNumber.toString(), style: TextStyle(fontSize: 13, color: _currentPage == pageNumber ? Theme.of(context).colorScheme.onPrimary : null)),
        selected: _currentPage == pageNumber,
        selectedColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).chipTheme.backgroundColor,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _currentPage = pageNumber;
            });
          }
        },
        materialTapTargetSize: MaterialTapTargetSize.padded,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(() { 
      // Listener logic was here, now just remove 
    });
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
              maxLines: 3, // Increased maxLines for more content visibility
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.orange.shade700),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 