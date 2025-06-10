import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/de_kiem_tra_model.dart';
import 'package:ckcandr/providers/de_kiem_tra_provider.dart';
import 'package:ckcandr/models/nhom_hocphan_model.dart';
import 'package:ckcandr/providers/nhom_hocphan_provider.dart' as nhom_provider;
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/models/chuong_muc_model.dart';
import 'package:ckcandr/providers/chuong_muc_provider.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';
import 'package:ckcandr/providers/cau_hoi_provider.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:ckcandr/core/utils/responsive_helper.dart';
import 'package:intl/intl.dart';

// Tạm thời sử dụng provider cho người dùng hiện tại
final currentUserProvider = Provider<User?>((ref) => null);

class DeKiemTraScreen extends ConsumerStatefulWidget {
  const DeKiemTraScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DeKiemTraScreen> createState() => _DeKiemTraScreenState();
}

class _DeKiemTraScreenState extends ConsumerState<DeKiemTraScreen> {
  String? _selectedMonHocId;
  final TextEditingController _searchController = TextEditingController();
  bool _showCompletedExams = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monHocList = ref.watch(monHocListProvider);
    final deKiemTraList = ref.watch(deKiemTraListProvider);

    // Lọc đề kiểm tra theo môn học và search query
    List<DeKiemTra> filteredDeKiemTra = deKiemTraList.where((deThi) {
      // Lọc theo môn học
      final matchesMonHoc = _selectedMonHocId == null || deThi.monHocId == _selectedMonHocId;
      
      // Lọc theo tên đề thi
      final matchesSearchQuery = _searchController.text.isEmpty || 
          deThi.tenDeThi.toLowerCase().contains(_searchController.text.toLowerCase());
      
      // Lọc theo trạng thái hoàn thành
      final trangThaiHienTai = deThi.tinhTrangThai();
      final matchesCompletionStatus = _showCompletedExams || 
          (trangThaiHienTai != TrangThaiDeThi.daKetThuc);
      
      return matchesMonHoc && matchesSearchQuery && matchesCompletionStatus;
    }).toList();

    // Sắp xếp theo thời gian bắt đầu
    filteredDeKiemTra.sort((a, b) => b.thoiGianBatDau.compareTo(a.thoiGianBatDau));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quản lý đề kiểm tra',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 30,
                    tooltip: 'Tạo đề kiểm tra mới',
                    onPressed: () => _showCreateEditExamDialog(context),
                    color: theme.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String?>(
                      value: _selectedMonHocId,
                      decoration: const InputDecoration(
                        labelText: 'Lọc theo môn học',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Tất cả môn học'),
                        ),
                        ...monHocList.map((monHoc) {
                          return DropdownMenuItem<String?>(
                            value: monHoc.id,
                            child: Text(monHoc.tenMonHoc),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedMonHocId = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Tìm kiếm đề thi',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _showCompletedExams,
                    onChanged: (value) {
                      setState(() {
                        _showCompletedExams = value ?? true;
                      });
                    },
                  ),
                  const Text('Hiển thị cả đề thi đã kết thúc'),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Lọc'),
                    onPressed: () {
                      // Implement additional filtering here
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredDeKiemTra.isEmpty
              ? Center(
                  child: Text(
                    'Không có đề kiểm tra nào',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemCount: filteredDeKiemTra.length,
                  itemBuilder: (context, index) {
                    final deThi = filteredDeKiemTra[index];
                    return _DeKiemTraCard(
                      deThi: deThi,
                      onEdit: () => _showCreateEditExamDialog(
                        context,
                        editingDeKiemTra: deThi,
                      ),
                      onDelete: () => _confirmDeleteExam(context, deThi),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showCreateEditExamDialog(BuildContext context, {DeKiemTra? editingDeKiemTra}) async {
    final bool isEditing = editingDeKiemTra != null;

    // Hiển thị dialog chỉnh sửa/tạo mới đề thi với responsive design
    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: ResponsiveHelper.shouldUseDrawer(context)
            ? const EdgeInsets.all(16.0) // Mobile: padding nhỏ hơn
            : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0), // Desktop: padding lớn hơn
        child: CreateEditDeKiemTraForm(
          isEditing: isEditing,
          initialDeThi: editingDeKiemTra,
        ),
      ),
    );
  }

  void _confirmDeleteExam(BuildContext context, DeKiemTra deThi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa đề kiểm tra "${deThi.tenDeThi}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              ref.read(deKiemTraListProvider.notifier).update(
                (state) => state.where((item) => item.id != deThi.id).toList(),
              );
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa đề kiểm tra: ${deThi.tenDeThi}'),
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _DeKiemTraCard extends ConsumerWidget {
  final DeKiemTra deThi;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DeKiemTraCard({
    required this.deThi,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final trangThaiHienTai = deThi.tinhTrangThai();
    
    // Lấy thông tin môn học
    MonHoc? monHoc;
    try {
      monHoc = ref.read(monHocListProvider).firstWhere(
        (mh) => mh.id == deThi.monHocId,
      );
    } catch (_) {}

    // Lấy số lượng câu hỏi
    final soCauHoi = deThi.danhSachCauHoiIds.length;

    // Lấy số lượng nhóm học phần tham gia
    final soNhomHP = deThi.danhSachNhomHPIds.length;

    Color statusColor;
    IconData statusIcon;
    
    switch (trangThaiHienTai) {
      case TrangThaiDeThi.moiTao:
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
      case TrangThaiDeThi.dangDienRa:
        statusColor = Colors.green;
        statusIcon = Icons.play_circle_outline;
        break;
      case TrangThaiDeThi.daKetThuc:
        statusColor = Colors.grey;
        statusIcon = Icons.check_circle_outline;
        break;
      case TrangThaiDeThi.tam:
        statusColor = Colors.orange;
        statusIcon = Icons.pause_circle_outline;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    deThi.tenDeThi,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Switch(
                  value: deThi.choPhepThi,
                  activeColor: theme.primaryColor,
                  onChanged: (newValue) {
                    ref.read(deKiemTraListProvider.notifier).update(
                      (state) => state.map((item) {
                        if (item.id == deThi.id) {
                          return item.copyWith(
                            choPhepThi: newValue,
                            ngayCapNhat: DateTime.now(),
                          );
                        }
                        return item;
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 4),
                Text(
                  DeKiemTra.getTenTrangThai(trangThaiHienTai),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.school_outlined, size: 20),
                const SizedBox(width: 4),
                Text(monHoc?.tenMonHoc ?? 'Không xác định'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 20),
                const SizedBox(width: 4),
                Text('${DateFormat('dd/MM/yyyy HH:mm').format(deThi.thoiGianBatDau)} - ${deThi.thoiGianLamBai} phút'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.question_answer_outlined, size: 20),
                const SizedBox(width: 4),
                Text('$soCauHoi câu hỏi'),
                const SizedBox(width: 16),
                const Icon(Icons.group_outlined, size: 20),
                const SizedBox(width: 4),
                Text('$soNhomHP nhóm tham gia'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Thống kê'),
                  onPressed: () {
                    // Hiển thị thống kê kết quả
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Sửa'),
                  onPressed: onEdit,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CreateEditDeKiemTraForm extends ConsumerStatefulWidget {
  final bool isEditing;
  final DeKiemTra? initialDeThi;

  const CreateEditDeKiemTraForm({
    Key? key,
    required this.isEditing,
    this.initialDeThi,
  }) : super(key: key);

  @override
  ConsumerState<CreateEditDeKiemTraForm> createState() => _CreateEditDeKiemTraFormState();
}

class _CreateEditDeKiemTraFormState extends ConsumerState<CreateEditDeKiemTraForm> {
  final _formKey = GlobalKey<FormState>();
  final _tenDeThiController = TextEditingController();
  DateTime _thoiGianBatDau = DateTime.now();
  final _thoiGianLamBaiController = TextEditingController();
  String? _selectedMonHocId;
  String? _selectedChuongMucId;
  bool _choPhepThi = false;
  final _moTaController = TextEditingController();

  List<String> _selectedCauHoiIds = [];
  List<String> _selectedNhomHPIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.initialDeThi != null) {
      _tenDeThiController.text = widget.initialDeThi!.tenDeThi;
      _thoiGianBatDau = widget.initialDeThi!.thoiGianBatDau;
      _thoiGianLamBaiController.text = widget.initialDeThi!.thoiGianLamBai.toString();
      _selectedMonHocId = widget.initialDeThi!.monHocId;
      _selectedChuongMucId = widget.initialDeThi!.chuongMucId;
      _choPhepThi = widget.initialDeThi!.choPhepThi;
      _moTaController.text = widget.initialDeThi!.moTa ?? '';
      _selectedCauHoiIds = List.from(widget.initialDeThi!.danhSachCauHoiIds);
      _selectedNhomHPIds = List.from(widget.initialDeThi!.danhSachNhomHPIds);
    } else {
      // Mặc định cho đề thi mới
      _thoiGianLamBaiController.text = '60'; // 60 phút
      _thoiGianBatDau = DateTime.now().add(const Duration(days: 1)); // Mặc định ngày mai
      
      // Tự động chọn môn học đầu tiên nếu có
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final monHocList = ref.read(monHocListProvider);
        if (monHocList.isNotEmpty && _selectedMonHocId == null) {
          setState(() {
            _selectedMonHocId = monHocList.first.id;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tenDeThiController.dispose();
    _thoiGianLamBaiController.dispose();
    _moTaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monHocList = ref.watch(monHocListProvider);
    final theme = Theme.of(context);

    // Danh sách chương mục dựa trên môn học đã chọn
    List<ChuongMuc> chuongMucList = [];
    if (_selectedMonHocId != null) {
      chuongMucList = ref.watch(filteredChuongMucListProvider(_selectedMonHocId!));
    }

    // Danh sách câu hỏi dựa trên môn học và chương mục đã chọn
    final allCauHoi = ref.watch(cauHoiListProvider);
    List<CauHoi> filteredCauHoi = allCauHoi.where((cauHoi) {
      if (_selectedMonHocId == null) return false;
      
      if (cauHoi.monHocId != _selectedMonHocId) return false;
      
      if (_selectedChuongMucId != null && cauHoi.chuongMucId != _selectedChuongMucId) return false;
      
      return true;
    }).toList();

    // Danh sách nhóm học phần theo môn học đã chọn
    final allNhomHP = ref.watch(nhom_provider.nhomHocPhanListProvider);
    var filteredNhomHP = allNhomHP.where((nhom) {
      if (_selectedMonHocId == null) return false;
      return nhom.monHocId == _selectedMonHocId;
    }).toList();

    return Container(
      width: ResponsiveHelper.shouldUseDrawer(context)
          ? MediaQuery.of(context).size.width - 32 // Mobile: full width minus padding
          : MediaQuery.of(context).size.width * 0.8, // Desktop: 80% width
      height: ResponsiveHelper.shouldUseDrawer(context)
          ? MediaQuery.of(context).size.height - 100 // Mobile: full height minus safe area
          : MediaQuery.of(context).size.height * 0.8, // Desktop: 80% height
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing ? 'Chỉnh sửa đề kiểm tra' : 'Tạo đề kiểm tra mới',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thông tin cơ bản
                    TextFormField(
                      controller: _tenDeThiController,
                      decoration: const InputDecoration(
                        labelText: 'Tên đề kiểm tra',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên đề kiểm tra';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveValue(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    )),

                    // Responsive layout for dropdowns
                    ResponsiveHelper.shouldUseDrawer(context)
                        ? Column( // Mobile: stack vertically
                            children: [
                              DropdownButtonFormField<String?>(
                                value: _selectedMonHocId,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                                    context,
                                    mobile: 16,
                                    tablet: 17,
                                    desktop: 18,
                                  ),
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Môn học',
                                  border: const OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: ResponsiveHelper.getResponsiveValue(
                                      context,
                                      mobile: 16,
                                      tablet: 18,
                                      desktop: 20,
                                    ),
                                  ),
                                ),
                                items: monHocList.map((monHoc) {
                                  return DropdownMenuItem<String?>(
                                    value: monHoc.id,
                                    child: Text(monHoc.tenMonHoc, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMonHocId = value;
                                    _selectedChuongMucId = null;
                                    _selectedCauHoiIds = [];
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Vui lòng chọn môn học';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: ResponsiveHelper.getResponsiveValue(
                                context,
                                mobile: 16,
                                tablet: 18,
                                desktop: 20,
                              )),
                              DropdownButtonFormField<String?>(
                                value: _selectedChuongMucId,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                                    context,
                                    mobile: 16,
                                    tablet: 17,
                                    desktop: 18,
                                  ),
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Chương mục (không bắt buộc)',
                                  border: const OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: ResponsiveHelper.getResponsiveValue(
                                      context,
                                      mobile: 16,
                                      tablet: 18,
                                      desktop: 20,
                                    ),
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('Tất cả chương'),
                                  ),
                                  ...chuongMucList.map((chuongMuc) {
                                    return DropdownMenuItem<String?>(
                                      value: chuongMuc.id,
                                      child: Text(chuongMuc.tenChuongMuc, overflow: TextOverflow.ellipsis),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedChuongMucId = value;
                                    _selectedCauHoiIds = [];
                                  });
                                },
                              ),
                            ],
                          )
                        : Row( // Desktop: side by side
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String?>(
                                  value: _selectedMonHocId,
                                  decoration: const InputDecoration(
                                    labelText: 'Môn học',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: monHocList.map((monHoc) {
                                    return DropdownMenuItem<String?>(
                                      value: monHoc.id,
                                      child: Text(monHoc.tenMonHoc, overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMonHocId = value;
                                      _selectedChuongMucId = null;
                                      _selectedCauHoiIds = [];
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Vui lòng chọn môn học';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String?>(
                                  value: _selectedChuongMucId,
                                  decoration: const InputDecoration(
                                    labelText: 'Chương mục (không bắt buộc)',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('Tất cả chương'),
                                    ),
                                    ...chuongMucList.map((chuongMuc) {
                                      return DropdownMenuItem<String?>(
                                        value: chuongMuc.id,
                                        child: Text(chuongMuc.tenChuongMuc, overflow: TextOverflow.ellipsis),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedChuongMucId = value;
                                      _selectedCauHoiIds = [];
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                    SizedBox(height: ResponsiveHelper.getResponsiveValue(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    )),

                    // Responsive layout for time fields
                    ResponsiveHelper.shouldUseDrawer(context)
                        ? Column( // Mobile: stack vertically
                            children: [
                              InkWell(
                                onTap: () => _selectDateTime(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Thời gian bắt đầu',
                                    border: const OutlineInputBorder(),
                                    suffixIcon: const Icon(Icons.calendar_today),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: ResponsiveHelper.getResponsiveValue(
                                        context,
                                        mobile: 16,
                                        tablet: 18,
                                        desktop: 20,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    DateFormat('dd/MM/yyyy HH:mm').format(_thoiGianBatDau),
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        mobile: 16,
                                        tablet: 17,
                                        desktop: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.getResponsiveValue(
                                context,
                                mobile: 16,
                                tablet: 18,
                                desktop: 20,
                              )),
                              TextFormField(
                                controller: _thoiGianLamBaiController,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                                    context,
                                    mobile: 16,
                                    tablet: 17,
                                    desktop: 18,
                                  ),
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Thời gian làm bài (phút)',
                                  border: const OutlineInputBorder(),
                                  suffixText: 'phút',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: ResponsiveHelper.getResponsiveValue(
                                      context,
                                      mobile: 16,
                                      tablet: 18,
                                      desktop: 20,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập thời gian';
                                  }
                                  final time = int.tryParse(value);
                                  if (time == null || time <= 0) {
                                    return 'Thời gian không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          )
                        : Row( // Desktop: side by side
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDateTime(context),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Thời gian bắt đầu',
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(_thoiGianBatDau),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _thoiGianLamBaiController,
                                  decoration: const InputDecoration(
                                    labelText: 'Thời gian làm bài (phút)',
                                    border: OutlineInputBorder(),
                                    suffixText: 'phút',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập thời gian';
                                    }
                                    final time = int.tryParse(value);
                                    if (time == null || time <= 0) {
                                      return 'Thời gian không hợp lệ';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                    SizedBox(height: ResponsiveHelper.getResponsiveValue(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    )),

                    // Description field
                    TextFormField(
                      controller: _moTaController,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 17,
                          desktop: 18,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Mô tả (không bắt buộc)',
                        border: const OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: ResponsiveHelper.getResponsiveValue(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                      maxLines: ResponsiveHelper.shouldUseDrawer(context) ? 3 : 2,
                    ),

                    SizedBox(height: ResponsiveHelper.getResponsiveValue(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    )),

                    // Switch with responsive styling
                    SwitchListTile(
                      title: Text(
                        'Cho phép thi',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 17,
                            desktop: 18,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Sinh viên có thể truy cập đề thi này',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                          ),
                        ),
                      ),
                      value: _choPhepThi,
                      onChanged: (value) {
                        setState(() {
                          _choPhepThi = value;
                        });
                      },
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.shouldUseDrawer(context) ? 8 : 16,
                        vertical: 4,
                      ),
                    ),
                    const Divider(),
                    
                    // Phần chọn câu hỏi
                    const Text(
                      'Chọn câu hỏi:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (filteredCauHoi.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Không có câu hỏi nào cho môn học / chương mục đã chọn',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      )
                    else
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: filteredCauHoi.length,
                          itemBuilder: (context, index) {
                            final cauHoi = filteredCauHoi[index];
                            final isSelected = _selectedCauHoiIds.contains(cauHoi.id);
                            
                            return CheckboxListTile(
                              title: Text(
                                cauHoi.noiDung,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                'Loại: ${cauHoi.loaiCauHoi.toString().split('.').last} - Độ khó: ${cauHoi.doKho.toString().split('.').last}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedCauHoiIds.add(cauHoi.id);
                                  } else {
                                    _selectedCauHoiIds.remove(cauHoi.id);
                                  }
                                });
                              },
                              dense: true,
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    // Phần chọn nhóm học phần
                    const Text(
                      'Chọn nhóm học phần tham gia:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (filteredNhomHP.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Không có nhóm học phần nào cho môn học đã chọn',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      )
                    else
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          itemCount: filteredNhomHP.length,
                          itemBuilder: (context, index) {
                            final nhomHP = filteredNhomHP[index];
                            final isSelected = _selectedNhomHPIds.contains(nhomHP.id);
                            
                            return CheckboxListTile(
                              title: Text(
                                nhomHP.tenNhomHocPhan ?? "Nhóm học phần",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${nhomHP.hocKy} - ${nhomHP.namHoc}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedNhomHPIds.add(nhomHP.id);
                                  } else {
                                    _selectedNhomHPIds.remove(nhomHP.id);
                                  }
                                });
                              },
                              dense: true,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(),

            // Responsive button layout
            ResponsiveHelper.shouldUseDrawer(context)
                ? Column( // Mobile: stack vertically
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: _saveDeKiemTra,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getResponsiveValue(
                              context,
                              mobile: 16,
                              tablet: 14,
                              desktop: 12,
                            ),
                          ),
                        ),
                        child: Text(
                          widget.isEditing ? 'Cập nhật' : 'Tạo',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 16,
                              tablet: 15,
                              desktop: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getResponsiveValue(
                              context,
                              mobile: 16,
                              tablet: 14,
                              desktop: 12,
                            ),
                          ),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 16,
                              tablet: 15,
                              desktop: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row( // Desktop: side by side
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Hủy'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saveDeKiemTra,
                        child: Text(widget.isEditing ? 'Cập nhật' : 'Tạo'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final initialDate = _thoiGianBatDau;
    
    // Chọn ngày
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate == null) return;
    
    // Chọn thời gian
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    
    if (pickedTime == null) return;
    
    setState(() {
      _thoiGianBatDau = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _saveDeKiemTra() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    if (_selectedMonHocId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn môn học')),
      );
      return;
    }
    
    if (_selectedCauHoiIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một câu hỏi')),
      );
      return;
    }
    
    if (_selectedNhomHPIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một nhóm học phần')),
      );
      return;
    }
    
    final deKiemTraList = ref.read(deKiemTraListProvider);
    
    final currentUser = ref.read(currentUserProvider);
    final nguoiTaoId = currentUser?.id ?? 'unknown';
    
    final thoiGianLamBai = int.parse(_thoiGianLamBaiController.text);
    
    if (widget.isEditing && widget.initialDeThi != null) {
      // Cập nhật đề kiểm tra hiện có
      final updatedDeThi = widget.initialDeThi!.copyWith(
        tenDeThi: _tenDeThiController.text.trim(),
        thoiGianBatDau: _thoiGianBatDau,
        thoiGianLamBai: thoiGianLamBai,
        danhSachCauHoiIds: _selectedCauHoiIds,
        danhSachNhomHPIds: _selectedNhomHPIds,
        monHocId: _selectedMonHocId,
        chuongMucId: _selectedChuongMucId,
        choPhepThi: _choPhepThi,
        moTa: _moTaController.text.trim().isNotEmpty ? _moTaController.text.trim() : null,
        ngayCapNhat: DateTime.now(),
      );
      
      ref.read(deKiemTraListProvider.notifier).update((state) => 
        state.map((deThi) => deThi.id == updatedDeThi.id ? updatedDeThi : deThi).toList()
      );
      
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật đề kiểm tra: ${updatedDeThi.tenDeThi}')),
      );
    } else {
      // Tạo đề kiểm tra mới
      final newDeThi = DeKiemTra(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tenDeThi: _tenDeThiController.text.trim(),
        thoiGianBatDau: _thoiGianBatDau,
        thoiGianLamBai: thoiGianLamBai,
        danhSachCauHoiIds: _selectedCauHoiIds,
        danhSachNhomHPIds: _selectedNhomHPIds,
        monHocId: _selectedMonHocId,
        chuongMucId: _selectedChuongMucId,
        choPhepThi: _choPhepThi,
        nguoiTaoId: nguoiTaoId,
        ngayTao: DateTime.now(),
        ngayCapNhat: DateTime.now(),
        moTa: _moTaController.text.trim().isNotEmpty ? _moTaController.text.trim() : null,
      );
      
      ref.read(deKiemTraListProvider.notifier).update((state) => [newDeThi, ...state]);
      
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã tạo đề kiểm tra: ${newDeThi.tenDeThi}')),
      );
    }
  }
} 