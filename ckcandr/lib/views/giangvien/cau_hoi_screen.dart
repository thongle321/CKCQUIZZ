import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/models/chuong_muc_model.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/providers/chuong_muc_provider.dart';
import 'package:ckcandr/providers/cau_hoi_provider.dart';
import 'dart:math'; // For temporary ID generation

// Forward declaration for CauHoiDialogScreen
class CauHoiDialogScreen extends ConsumerStatefulWidget {
  final String monHocId;
  final CauHoi? cauHoiToEdit;

  const CauHoiDialogScreen({super.key, required this.monHocId, this.cauHoiToEdit});

  @override
  ConsumerState<CauHoiDialogScreen> createState() => _CauHoiDialogScreenState();
}

class CauHoiScreen extends ConsumerStatefulWidget {
  const CauHoiScreen({super.key});

  @override
  ConsumerState<CauHoiScreen> createState() => _CauHoiScreenState();
}

class _CauHoiScreenState extends ConsumerState<CauHoiScreen> {
  String? _selectedMonHocIdFilter;
  String? _selectedChuongMucIdFilter;
  DoKho? _selectedDoKhoFilter;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final monHocList = ref.read(monHocListProvider);
        if (_selectedMonHocIdFilter == null && monHocList.isNotEmpty) {
          setState(() {
            _selectedMonHocIdFilter = monHocList.first.id;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monHocList = ref.watch(monHocListProvider);

    if (_selectedMonHocIdFilter != null && !monHocList.any((mh) => mh.id == _selectedMonHocIdFilter)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedMonHocIdFilter = monHocList.isNotEmpty ? monHocList.first.id : null;
            _selectedChuongMucIdFilter = null;
          });
        }
      });
    }

    final chuongMucListForSelectedMonHoc = _selectedMonHocIdFilter == null
        ? <ChuongMuc>[]
        : ref.watch(filteredChuongMucListProvider(_selectedMonHocIdFilter!));

    final allCauHoi = ref.watch(cauHoiListProvider);
    List<CauHoi> filteredCauHoi = allCauHoi.where((ch) {
      bool matchMonHoc = _selectedMonHocIdFilter == null || ch.monHocId == _selectedMonHocIdFilter;
      bool matchChuongMuc = _selectedChuongMucIdFilter == null || (_selectedMonHocIdFilter != null && ch.chuongMucId == _selectedChuongMucIdFilter);
      bool matchDoKho = _selectedDoKhoFilter == null || ch.doKho == _selectedDoKhoFilter;
      bool matchSearch = _searchTerm.isEmpty || ch.noiDung.toLowerCase().contains(_searchTerm.toLowerCase());
      return matchMonHoc && matchChuongMuc && matchDoKho && matchSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tất cả câu hỏi',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Thêm câu hỏi mới'),
                    onPressed: () {
                      if (monHocList.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng thêm Môn học trước khi tạo câu hỏi.')),
                        );
                        return;
                      }
                      String? monHocIdForDialog = _selectedMonHocIdFilter ?? (monHocList.isNotEmpty ? monHocList.first.id : null);
                      if (monHocIdForDialog == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không có môn học nào. Vui lòng thêm Môn học trước.')),
                        );
                        return;
                      }
                      _showCauHoiDialog(context, monHocIdForDialog: monHocIdForDialog);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMonHocIdFilter,
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
                          _selectedMonHocIdFilter = newValue;
                          _selectedChuongMucIdFilter = null; 
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedChuongMucIdFilter,
                      decoration: const InputDecoration(labelText: 'Chọn chương', border: OutlineInputBorder()),
                      isExpanded: true,
                      hint: const Text('Tất cả chương'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null, 
                          child: Text('Tất cả chương'),
                        ),
                        ...chuongMucListForSelectedMonHoc.map((ChuongMuc cm) {
                          return DropdownMenuItem<String>(
                            value: cm.id,
                            child: Text(cm.tenChuongMuc, overflow: TextOverflow.ellipsis),
                          );
                        })
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedChuongMucIdFilter = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<DoKho?>(
                      value: _selectedDoKhoFilter,
                      decoration: const InputDecoration(labelText: 'Độ khó', border: OutlineInputBorder()),
                      isExpanded: true,
                      hint: const Text('Tất cả độ khó'),
                      items: [
                        const DropdownMenuItem<DoKho?>(
                          value: null,
                          child: Text('Tất cả độ khó'),
                        ),
                        ...DoKho.values.map((DoKho dk) {
                          return DropdownMenuItem<DoKho?>(
                            value: dk,
                            child: Text(CauHoi(id:'',monHocId:'',noiDung:'',loaiCauHoi:LoaiCauHoi.tracNghiemChonMot,doKho:dk,ngayTao:DateTime.now(), ngayCapNhat: DateTime.now()).tenDoKho, overflow: TextOverflow.ellipsis),
                          );
                        })
                      ],
                      onChanged: (DoKho? newValue) {
                        setState(() {
                          _selectedDoKhoFilter = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm nội dung câu hỏi...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      ),
                      onChanged: (value) => setState(() => _searchTerm = value),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: filteredCauHoi.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      monHocList.isEmpty ? 'Vui lòng thêm Môn học để bắt đầu.' : 'Không tìm thấy câu hỏi nào phù hợp với bộ lọc của bạn.',
                      style: theme.textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.builder(
                    itemCount: filteredCauHoi.length,
                    itemBuilder: (context, index) {
                      final cauHoi = filteredCauHoi[index];
                      final monHoc = monHocList.firstWhere((mh) => mh.id == cauHoi.monHocId, orElse: () => MonHoc(id:'', tenMonHoc: 'N/A', maMonHoc: '', soTinChi: 0));
                      final chuongMuc = cauHoi.chuongMucId != null && _selectedMonHocIdFilter != null && chuongMucListForSelectedMonHoc.any((cm) => cm.id == cauHoi.chuongMucId) ? 
                                          chuongMucListForSelectedMonHoc.firstWhere((cm) => cm.id == cauHoi.chuongMucId) 
                                          : null;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 30, 
                                child: Text('${index + 1}.', style: theme.textTheme.titleSmall)
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cauHoi.noiDung, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500), maxLines: 3, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text('Môn: ${monHoc.tenMonHoc}${chuongMuc != null ? ' - C: ${chuongMuc.tenChuongMuc.substring(0, min(chuongMuc.tenChuongMuc.length,15))}${chuongMuc.tenChuongMuc.length > 15 ? "..." : ""}' : ''}', style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis, maxLines:1),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(cauHoi.tenDoKho, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                              ),
                              SizedBox(
                                width: 70,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined, size: 20, color: theme.primaryColor),
                                      tooltip: 'Chỉnh sửa',
                                      onPressed: () => _showCauHoiDialog(context, cauHoiToEdit: cauHoi, monHocIdForDialog: cauHoi.monHocId ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                                      tooltip: 'Xóa',
                                      onPressed: () => _confirmDeleteCauHoi(context, ref, cauHoi),
                                    ),
                                  ],
                                ),
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

  void _showCauHoiDialog(BuildContext context, {CauHoi? cauHoiToEdit, required String monHocIdForDialog}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CauHoiDialogScreen(monHocId: monHocIdForDialog, cauHoiToEdit: cauHoiToEdit),
        fullscreenDialog: true,
      ),
    );
  }

  void _confirmDeleteCauHoi(BuildContext context, WidgetRef ref, CauHoi cauHoi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa câu hỏi: "${cauHoi.noiDung.substring(0, min(cauHoi.noiDung.length, 50))}..."?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cauHoiListProvider.notifier).update((state) => 
                  state.where((ch) => ch.id != cauHoi.id).toList());
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa câu hỏi.')),
              );
            },
            child: Text('Xóa', style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

class _CauHoiDialogScreenState extends ConsumerState<CauHoiDialogScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _noiDung;
  late LoaiCauHoi _loaiCauHoi;
  late DoKho _doKho;
  String? _selectedChuongMucId;
  List<LuaChonDapAn> _cacLuaChon = [];
  List<String> _dapAnDungIds = []; 
  String _giaiThich = '';
  List<TextEditingController> _luaChonControllers = [];

  @override
  void initState() {
    super.initState();
    final chuongMucList = ref.read(filteredChuongMucListProvider(widget.monHocId));

    if (widget.cauHoiToEdit != null) {
      final ch = widget.cauHoiToEdit!;
      _noiDung = ch.noiDung;
      _loaiCauHoi = ch.loaiCauHoi;
      _doKho = ch.doKho;
      _selectedChuongMucId = ch.chuongMucId;
      _cacLuaChon = List.from(ch.cacLuaChon.map((lc) => lc.copyWith()));
      _dapAnDungIds = List.from(ch.dapAnDungIds);
      _giaiThich = ch.giaiThich ?? '';
    } else {
      _noiDung = '';
      _loaiCauHoi = LoaiCauHoi.tracNghiemChonMot;
      _doKho = DoKho.trungBinh;
      _selectedChuongMucId = chuongMucList.isNotEmpty ? chuongMucList.first.id : null;
      _updateDefaultLuaChon(triggerRebuildControllers: false);
    }
    _rebuildLuaChonControllers();
  }

  void _rebuildLuaChonControllers() {
    for (var controller in _luaChonControllers) {
      controller.dispose();
    }
    _luaChonControllers = _cacLuaChon.map((lc) => TextEditingController(text: lc.noiDung)).toList();
  }

  @override
  void dispose() {
    for (var controller in _luaChonControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateDefaultLuaChon({bool triggerRebuildControllers = true}) {
    _cacLuaChon.clear();
    _dapAnDungIds.clear();
    if (_loaiCauHoi == LoaiCauHoi.tracNghiemChonMot || _loaiCauHoi == LoaiCauHoi.tracNghiemChonNhieu) {
      _cacLuaChon = [LuaChonDapAn(id: 'option_${DateTime.now().millisecondsSinceEpoch}', noiDung: '')];
    } else if (_loaiCauHoi == LoaiCauHoi.dungSai) {
      _cacLuaChon = [
        LuaChonDapAn(id: 'true', noiDung: 'Đúng'),
        LuaChonDapAn(id: 'false', noiDung: 'Sai'),
      ];
       if (_cacLuaChon.isNotEmpty) _dapAnDungIds.add(_cacLuaChon.first.id);
    }
    if (triggerRebuildControllers) {
      _rebuildLuaChonControllers();
    }
  }

  void _addLuaChon() {
    setState(() {
      if (_cacLuaChon.length < 6) {
        _cacLuaChon.add(LuaChonDapAn(id: 'option_${DateTime.now().millisecondsSinceEpoch}', noiDung: ''));
        _luaChonControllers.add(TextEditingController());
      }
    });
  }

  void _removeLuaChon(int index) {
    setState(() {
      if (_cacLuaChon.length > 1) {
        final removedId = _cacLuaChon[index].id;
        _cacLuaChon.removeAt(index);
        _luaChonControllers[index].dispose(); 
        _luaChonControllers.removeAt(index); 
        _dapAnDungIds.remove(removedId);
      }
    });
  }

  void _toggleDapAn(String luaChonId) {
    setState(() {
      if (_loaiCauHoi == LoaiCauHoi.tracNghiemChonMot || _loaiCauHoi == LoaiCauHoi.dungSai) {
        _dapAnDungIds.clear();
        _dapAnDungIds.add(luaChonId);
      } else if (_loaiCauHoi == LoaiCauHoi.tracNghiemChonNhieu) {
        if (_dapAnDungIds.contains(luaChonId)) {
          _dapAnDungIds.remove(luaChonId);
        } else {
          _dapAnDungIds.add(luaChonId);
        }
      }
    });
  }

  void _saveCauHoi() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); 
      
      List<LuaChonDapAn> finalLuaChon = [];
      for(int i=0; i < _cacLuaChon.length; i++){
        String noiDungLuaChon = _luaChonControllers[i].text.trim();
        if (_loaiCauHoi != LoaiCauHoi.dienKhuyet && noiDungLuaChon.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nội dung lựa chọn ${i+1} không được để trống.')));
            return;
        }
        finalLuaChon.add(_cacLuaChon[i].copyWith(noiDung: noiDungLuaChon));
      }
      _cacLuaChon = finalLuaChon;

      if ((_loaiCauHoi == LoaiCauHoi.tracNghiemChonMot || 
           _loaiCauHoi == LoaiCauHoi.tracNghiemChonNhieu || 
           _loaiCauHoi == LoaiCauHoi.dungSai) && 
          _dapAnDungIds.isEmpty && _loaiCauHoi != LoaiCauHoi.dienKhuyet) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ít nhất một đáp án đúng.')));
        return;
      }
      if(_loaiCauHoi == LoaiCauHoi.dienKhuyet && _dapAnDungIds.first.trim().isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đáp án cho câu hỏi điền khuyết.')));
        return;
      }

      final cauHoi = CauHoi(
        id: widget.cauHoiToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        monHocId: widget.monHocId,
        chuongMucId: _selectedChuongMucId,
        noiDung: _noiDung,
        loaiCauHoi: _loaiCauHoi,
        doKho: _doKho,
        cacLuaChon: _cacLuaChon,
        dapAnDungIds: _dapAnDungIds,
        giaiThich: _giaiThich.isNotEmpty ? _giaiThich : null,
        ngayTao: widget.cauHoiToEdit?.ngayTao ?? DateTime.now(),
        ngayCapNhat: DateTime.now(),
      );

      final notifier = ref.read(cauHoiListProvider.notifier);
      if (widget.cauHoiToEdit == null) {
        notifier.update((state) => [cauHoi, ...state]);
      } else {
        notifier.update((state) => state.map((ch) => ch.id == cauHoi.id ? cauHoi : ch).toList());
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monHocDaChon = ref.watch(monHocListProvider).firstWhere((mh) => mh.id == widget.monHocId);
    final List<ChuongMuc> chuongMucList = ref.watch(filteredChuongMucListProvider(widget.monHocId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cauHoiToEdit == null ? 'Thêm Câu Hỏi' : 'Sửa Câu Hỏi'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_outlined, size: 18),
              label: Text(widget.cauHoiToEdit == null ? 'Lưu câu hỏi' : 'Lưu thay đổi'),
              onPressed: _saveCauHoi,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AbsorbPointer(
                      absorbing: true,
                      child: DropdownButtonFormField<String>(
                        value: widget.monHocId,
                        decoration: const InputDecoration(labelText: 'Môn học', border: OutlineInputBorder(), filled: true),
                        items: [DropdownMenuItem(value: widget.monHocId, child: Text(monHocDaChon.tenMonHoc, overflow: TextOverflow.ellipsis))],
                        onChanged: null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedChuongMucId,
                      decoration: const InputDecoration(labelText: 'Chương', border: OutlineInputBorder()),
                      isExpanded: true,
                      hint: const Text('Không chọn'),
                      items: [
                        const DropdownMenuItem<String>(value: null, child: Text('-- Không chọn chương --')),
                        ...chuongMucList.map((cm) => DropdownMenuItem(value: cm.id, child: Text(cm.tenChuongMuc, overflow: TextOverflow.ellipsis)))
                      ],
                      onChanged: (value) => setState(() => _selectedChuongMucId = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<DoKho>(
                      value: _doKho,
                      decoration: const InputDecoration(labelText: 'Độ khó', border: OutlineInputBorder()),
                      isExpanded: true,
                      items: DoKho.values.map((dk) => 
                        DropdownMenuItem(value: dk, child: Text(CauHoi(id:'',monHocId:'',noiDung:'',loaiCauHoi:_loaiCauHoi,doKho:dk,ngayTao:DateTime.now(), ngayCapNhat: DateTime.now()).tenDoKho)))
                      .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _doKho = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Nội dung câu hỏi', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _noiDung,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Nhập nội dung chi tiết cho câu hỏi...'),
                minLines: 4,
                maxLines: 8,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Nhập nội dung câu hỏi' : null,
                onSaved: (value) => _noiDung = value!,
              ),
              const SizedBox(height: 24),
              Text('Danh sách đáp án', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              if (_loaiCauHoi == LoaiCauHoi.tracNghiemChonMot || _loaiCauHoi == LoaiCauHoi.tracNghiemChonNhieu || _loaiCauHoi == LoaiCauHoi.dungSai)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _cacLuaChon.length,
                  itemBuilder: (context, index) {
                     while (_luaChonControllers.length <= index) {
                      _luaChonControllers.add(TextEditingController());
                    }
                    final luaChon = _cacLuaChon[index];
                    _luaChonControllers[index].text = luaChon.noiDung;

                    bool isSelectedAsCorrect = _dapAnDungIds.contains(luaChon.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          SizedBox(width: 20, child: Text('${index + 1}.')),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _luaChonControllers[index],
                              decoration: InputDecoration(hintText: 'Đáp án ${index + 1}', border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập nội dung đáp án' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_loaiCauHoi == LoaiCauHoi.tracNghiemChonMot || _loaiCauHoi == LoaiCauHoi.dungSai)
                            Radio<String>(
                              value: luaChon.id,
                              groupValue: _dapAnDungIds.isNotEmpty ? _dapAnDungIds.first : null,
                              onChanged: (value) => _toggleDapAn(luaChon.id),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )
                          else if (_loaiCauHoi == LoaiCauHoi.tracNghiemChonNhieu)
                            Checkbox(
                              value: isSelectedAsCorrect,
                              onChanged: (bool? value) => _toggleDapAn(luaChon.id),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          if (!(_loaiCauHoi == LoaiCauHoi.dungSai))
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 22),
                              tooltip: 'Xóa đáp án',
                              onPressed: () => _removeLuaChon(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              if ((_loaiCauHoi == LoaiCauHoi.tracNghiemChonMot || _loaiCauHoi == LoaiCauHoi.tracNghiemChonNhieu) && _cacLuaChon.length < 6) 
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('Thêm Câu Trả Lời'),
                    onPressed: _addLuaChon, 
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 0)),
                  ),
                ),
              
              if (_loaiCauHoi == LoaiCauHoi.dienKhuyet) 
                 Padding(
                   padding: const EdgeInsets.symmetric(vertical: 8.0),
                   child: TextFormField(
                    initialValue: _dapAnDungIds.isNotEmpty ? _dapAnDungIds.first : '',
                    decoration: const InputDecoration(labelText: 'Đáp án điền khuyết', border: OutlineInputBorder()),
                    validator: (v)=>(v==null || v.trim().isEmpty) ? 'Nhập đáp án' : null,
                    onSaved: (v) {
                        if (v != null && v.trim().isNotEmpty) _dapAnDungIds = [v.trim()];
                        else _dapAnDungIds = [];
                    },
                   ),
                 ),
              const SizedBox(height: 20),
              Text('Giải thích đáp án (tùy chọn)', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _giaiThich,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Nhập giải thích chi tiết (nếu có)...'),
                minLines: 2,
                maxLines: 4,
                onSaved: (value) => _giaiThich = value ?? '',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
} 