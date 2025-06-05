import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/models/chuong_muc_model.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/providers/chuong_muc_provider.dart';
import 'package:ckcandr/providers/cau_hoi_provider.dart';
import 'dart:math'; // For temporary ID generation
import 'package:ckcandr/providers/hoat_dong_provider.dart';
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart';

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
                                      onPressed: () => _deleteCauHoi(cauHoi),
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

  void _deleteCauHoi(CauHoi cauHoi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa câu hỏi "${cauHoi.noiDung.substring(0, min(cauHoi.noiDung.length, 50))}..."?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(cauHoiListProvider.notifier).update((state) => state.where((ch) => ch.id != cauHoi.id).toList());
              
              String noiDungLog = cauHoi.noiDung;
              if (noiDungLog.length > 50) noiDungLog = '${noiDungLog.substring(0, 47)}...';
              
              MonHoc monHocForLogDelete;
              try {
                  monHocForLogDelete = ref.read(monHocListProvider).firstWhere((m) => m.id == cauHoi.monHocId);
              } catch(e) {
                  monHocForLogDelete = MonHoc(id: cauHoi.monHocId, tenMonHoc: 'N/A', maMonHoc: 'N/A', soTinChi: 0);
              }
              
              ChuongMuc? chuongMucForLogDelete;
              if (cauHoi.chuongMucId != null) {
                final String currentCauHoiChuongMucId = cauHoi.chuongMucId!;
                try {
                  chuongMucForLogDelete = ref.read(chuongMucListProvider).firstWhere((cm) => cm.id == currentCauHoiChuongMucId);
                } catch (e) {
                  chuongMucForLogDelete = null; 
                }
              }

              // Chuyển đổi WidgetRef thành Ref
              final notifier = ref.read(hoatDongGanDayListProvider.notifier);
              notifier.addHoatDong(
                'Đã xóa câu hỏi: "$noiDungLog" (Môn: ${monHocForLogDelete.tenMonHoc}, Chương: ${chuongMucForLogDelete?.tenChuongMuc ?? 'Không có'})',
                LoaiHoatDong.XOA_CAU_HOI,
                HoatDongNotifier.getIconForLoai(LoaiHoatDong.XOA_CAU_HOI, isDeletion: true),
                idDoiTuongLienQuan: cauHoi.id,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa câu hỏi.')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CauHoiDialogScreenState extends ConsumerState<CauHoiDialogScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _selectedMonHocId;
  String? _selectedChuongMucId;

  late TextEditingController _noiDungController;
  late TextEditingController _giaiThichController;
  late TextEditingController _dienKhuyetController;

  LoaiCauHoi _selectedLoaiCauHoi = LoaiCauHoi.tracNghiemChonMot;
  DoKho _selectedDoKho = DoKho.de;
  
  List<LuaChonDapAn> _answerOptions = [];
  String? _selectedSingleCorrectOptionId;

  @override
  void initState() {
    super.initState();
    _selectedMonHocId = widget.monHocId; 

    _noiDungController = TextEditingController();
    _giaiThichController = TextEditingController();
    _dienKhuyetController = TextEditingController();

    if (widget.cauHoiToEdit != null) {
      final cauHoi = widget.cauHoiToEdit!;
      _selectedMonHocId = cauHoi.monHocId;
      _selectedChuongMucId = cauHoi.chuongMucId;
      _noiDungController.text = cauHoi.noiDung;
      _selectedLoaiCauHoi = cauHoi.loaiCauHoi;
      _selectedDoKho = cauHoi.doKho;
      _giaiThichController.text = cauHoi.giaiThich ?? '';

      _answerOptions = List<LuaChonDapAn>.from(cauHoi.cacLuaChon.map((opt) => opt.copyWith()));

      if (cauHoi.loaiCauHoi == LoaiCauHoi.tracNghiemChonMot || cauHoi.loaiCauHoi == LoaiCauHoi.dungSai) {
        if (cauHoi.dapAnDungIds.isNotEmpty) {
          _selectedSingleCorrectOptionId = cauHoi.dapAnDungIds.first;
          _answerOptions = _answerOptions.map((opt) => opt.copyWith(laDapAnDung: opt.id == _selectedSingleCorrectOptionId)).toList();
        }
      } else if (cauHoi.loaiCauHoi == LoaiCauHoi.tracNghiemChonNhieu) {
         _answerOptions = _answerOptions.map((opt) => opt.copyWith(laDapAnDung: cauHoi.dapAnDungIds.contains(opt.id))).toList();
      } else if (cauHoi.loaiCauHoi == LoaiCauHoi.dienKhuyet) {
        if (cauHoi.dapAnDungIds.isNotEmpty) {
          _dienKhuyetController.text = cauHoi.dapAnDungIds.first;
        }
      }
    } else {
          final chuongMucCuaMonHoc = ref.read(filteredChuongMucListProvider(_selectedMonHocId));
    if (chuongMucCuaMonHoc.isNotEmpty) {
      _selectedChuongMucId = chuongMucCuaMonHoc.first.id;
    }
      if (_selectedLoaiCauHoi == LoaiCauHoi.dungSai && _answerOptions.isEmpty) {
        _answerOptions = [
          LuaChonDapAn(id: 'dung_${GlobalKey().toString()}', noiDung: 'Đúng', laDapAnDung: false),
          LuaChonDapAn(id: 'sai_${GlobalKey().toString()}', noiDung: 'Sai', laDapAnDung: false),
        ];
      }
    }
  }
  
  @override
  void dispose() {
    _noiDungController.dispose();
    _giaiThichController.dispose();
    _dienKhuyetController.dispose();
    super.dispose();
  }

  void _saveQuestion() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang xử lý...')),
      );
    }
    final String currentSelectedMonHocId = _selectedMonHocId;

    final isEditing = widget.cauHoiToEdit != null;
    List<LuaChonDapAn> finalCacLuaChon = [];
    List<String> finalDapAnDungIds = [];

    if (_selectedLoaiCauHoi == LoaiCauHoi.tracNghiemChonMot || _selectedLoaiCauHoi == LoaiCauHoi.dungSai) {
      if (_answerOptions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm các lựa chọn đáp án.')));
          return;
      }
      if (_selectedSingleCorrectOptionId == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vui lòng chọn đáp án đúng cho câu hỏi ${_selectedLoaiCauHoi == LoaiCauHoi.dungSai ? "Đúng/Sai" : "chọn một"}.')));
          return;
      }
      finalCacLuaChon = _answerOptions.map((opt) => opt.copyWith(laDapAnDung: opt.id == _selectedSingleCorrectOptionId)).toList();
      finalDapAnDungIds.add(_selectedSingleCorrectOptionId!); 
    } else if (_selectedLoaiCauHoi == LoaiCauHoi.tracNghiemChonNhieu) {
      if (_answerOptions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm các lựa chọn đáp án.')));
          return;
      }
      finalCacLuaChon = _answerOptions; 
      finalDapAnDungIds = _answerOptions.where((opt) => opt.laDapAnDung == true).map((opt) => opt.id).toList();
      if (finalDapAnDungIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ít nhất một đáp án đúng cho câu hỏi chọn nhiều.')));
        return;
      }
    } else if (_selectedLoaiCauHoi == LoaiCauHoi.dienKhuyet) {
      final dienKhuyetAnswer = _dienKhuyetController.text.trim();
      if (dienKhuyetAnswer.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đáp án cho câu hỏi điền khuyết.')));
         return;
      }
      finalCacLuaChon = [];
      finalDapAnDungIds = [dienKhuyetAnswer];
    }

    String noiDungLog = _noiDungController.text.trim();
    if (noiDungLog.isEmpty && isEditing) noiDungLog = widget.cauHoiToEdit?.noiDung ?? 'N/A';
    if (noiDungLog.length > 50) noiDungLog = '${noiDungLog.substring(0, 47)}...';

    MonHoc monHocForLog;
    try {
      monHocForLog = ref.read(monHocListProvider).firstWhere((m) => m.id == currentSelectedMonHocId);
    } catch (e) {
      monHocForLog = MonHoc(id: currentSelectedMonHocId, tenMonHoc: 'N/A', maMonHoc: 'N/A', soTinChi: 0); // Fallback
    }

    ChuongMuc? chuongMucForLog;
    if (_selectedChuongMucId != null) {
        final String currentSelectedChuongMucId = _selectedChuongMucId!;
        try {
            chuongMucForLog = ref.read(chuongMucListProvider).firstWhere((cm) => cm.id == currentSelectedChuongMucId);
        } catch (e) { 
            chuongMucForLog = null; // Corrected typo: chuongMucForLog instead of chuongMucForlog
        }
    }
    
    final newOrUpdatedCauHoi = CauHoi(
      id: isEditing ? widget.cauHoiToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      monHocId: currentSelectedMonHocId, 
      chuongMucId: _selectedChuongMucId,
      noiDung: _noiDungController.text.trim(),
      loaiCauHoi: _selectedLoaiCauHoi,
      doKho: _selectedDoKho,
      cacLuaChon: finalCacLuaChon,
      dapAnDungIds: finalDapAnDungIds,
      giaiThich: _giaiThichController.text.trim().isNotEmpty ? _giaiThichController.text.trim() : null,
      ngayTao: isEditing ? widget.cauHoiToEdit!.ngayTao : DateTime.now(),
      ngayCapNhat: DateTime.now(),
    );

    final notifier = ref.read(cauHoiListProvider.notifier);
    // Chuyển đổi WidgetRef thành Ref
    final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
    
    if (isEditing) {
      notifier.update((state) => 
        state.map((ch) => ch.id == newOrUpdatedCauHoi.id ? newOrUpdatedCauHoi : ch).toList());
      hoatDongNotifier.addHoatDong(
        'Đã sửa câu hỏi: "$noiDungLog" (Môn: ${monHocForLog.tenMonHoc}, Chương: ${chuongMucForLog?.tenChuongMuc ?? 'Không có'})',
        LoaiHoatDong.SUA_CAU_HOI,
        HoatDongNotifier.getIconForLoai(LoaiHoatDong.SUA_CAU_HOI),
        idDoiTuongLienQuan: newOrUpdatedCauHoi.id,
      );
    } else {
      notifier.update((state) => [newOrUpdatedCauHoi, ...state]);
      hoatDongNotifier.addHoatDong(
        'Đã thêm câu hỏi: "$noiDungLog" (Môn: ${monHocForLog.tenMonHoc}, Chương: ${chuongMucForLog?.tenChuongMuc ?? 'Không có'})',
        LoaiHoatDong.THEM_CAU_HOI,
        HoatDongNotifier.getIconForLoai(LoaiHoatDong.THEM_CAU_HOI),
        idDoiTuongLienQuan: newOrUpdatedCauHoi.id,
      );
    }
    if (mounted) Navigator.of(context).pop(true); 
  }
  
  void _addAnswerOption() {
    setState(() {
      _answerOptions.add(LuaChonDapAn(id: 'option_${DateTime.now().millisecondsSinceEpoch}_${_answerOptions.length}', noiDung: '', laDapAnDung: false));
    });
  }

  void _removeAnswerOption(int index) {
    setState(() {
      if (index < 0 || index >= _answerOptions.length) return;
      LuaChonDapAn removedOption = _answerOptions.removeAt(index);
      if ((_selectedLoaiCauHoi == LoaiCauHoi.tracNghiemChonMot || _selectedLoaiCauHoi == LoaiCauHoi.dungSai) && 
          _selectedSingleCorrectOptionId == removedOption.id) {
        _selectedSingleCorrectOptionId = null;
      }
    });
  }

  void _updateAnswerText(int index, String text) {
    if (index < 0 || index >= _answerOptions.length) return;
    setState(() {
      _answerOptions[index] = _answerOptions[index].copyWith(noiDung: text);
    });
  }

  void _toggleMultiChoiceCorrect(int index, bool? value) {
    if (index < 0 || index >= _answerOptions.length) return;
    setState(() {
      _answerOptions[index] = _answerOptions[index].copyWith(laDapAnDung: value);
    });
  }

  void _setSingleChoiceCorrect(String? optionId) {
     setState(() {
        _selectedSingleCorrectOptionId = optionId;
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cauHoiToEdit == null ? 'Thêm câu hỏi mới' : 'Chỉnh sửa câu hỏi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveQuestion,
            tooltip: 'Lưu câu hỏi',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _noiDungController, 
                decoration: const InputDecoration(labelText: 'Nội dung câu hỏi', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nội dung không được để trống' : null, 
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Loại câu hỏi (Hiện tại: ${_selectedLoaiCauHoi.toString().split('.').last})'), 
              Text('Độ khó (Hiện tại: ${_selectedDoKho.toString().split('.').last})'),
              const SizedBox(height: 16),

              if (_selectedLoaiCauHoi == LoaiCauHoi.dienKhuyet)
                TextFormField(
                  controller: _dienKhuyetController,
                  decoration: const InputDecoration(labelText: 'Đáp án điền khuyết', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập đáp án.';
                    return null;
                  },
                )
              else ...[
                const Text('Các lựa chọn đáp án:', style: TextStyle(fontWeight: FontWeight.bold)),
                if(_answerOptions.isEmpty && (_selectedLoaiCauHoi != LoaiCauHoi.dienKhuyet))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Chưa có lựa chọn nào.', style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).hintColor)),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _answerOptions.length,
                  itemBuilder: (context, index) {
                    LuaChonDapAn option = _answerOptions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: option.noiDung, 
                                decoration: InputDecoration(labelText: 'Lựa chọn ${index + 1}', border: InputBorder.none),
                                onChanged: (text) => _updateAnswerText(index, text),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nội dung lựa chọn không được để trống' : null,
                              ),
                            ),
                            if (_selectedLoaiCauHoi == LoaiCauHoi.tracNghiemChonMot || _selectedLoaiCauHoi == LoaiCauHoi.dungSai)
                              Radio<String?>(
                                value: option.id,
                                groupValue: _selectedSingleCorrectOptionId,
                                onChanged: _setSingleChoiceCorrect,
                                visualDensity: VisualDensity.compact,
                              ),
                            if (_selectedLoaiCauHoi == LoaiCauHoi.tracNghiemChonNhieu)
                              Checkbox(
                                value: option.laDapAnDung ?? false,
                                onChanged: (bool? value) => _toggleMultiChoiceCorrect(index, value),
                                visualDensity: VisualDensity.compact,
                              ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                              tooltip: 'Xóa lựa chọn này',
                              onPressed: () => _removeAnswerOption(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (_selectedLoaiCauHoi != LoaiCauHoi.dienKhuyet && _answerOptions.length < 6)
                  TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline), 
                    label: const Text('Thêm lựa chọn'), 
                    onPressed: _addAnswerOption,
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10.0)),
                  ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _giaiThichController, 
                decoration: const InputDecoration(labelText: 'Giải thích đáp án (nếu có)', border: OutlineInputBorder()), 
                maxLines: 2
              ),
            ],
          ),
        ),
      ),
    );
  }
} 