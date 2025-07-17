/// Question Management Screen for Teachers with API Integration
/// 
/// This screen provides full CRUD operations for questions including:
/// - List questions with pagination and filters
/// - Create new questions with image support
/// - Edit existing questions
/// - Delete questions (soft delete)
/// - Image upload and base64 conversion similar to Vue frontend

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/models/chuong_muc_model.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/providers/chuong_muc_provider.dart';
import 'package:ckcandr/providers/chuong_provider.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/providers/cau_hoi_api_provider.dart';
import 'package:ckcandr/providers/hoat_dong_provider.dart';
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart';
import 'package:ckcandr/widgets/cau_hoi_form_dialog.dart';
import 'package:ckcandr/services/cau_hoi_service.dart';
import 'package:ckcandr/services/auto_refresh_service.dart';
// BỎ IMPORT AUTO REFRESH INDICATOR THEO YÊU CẦU USER
// import 'package:ckcandr/widgets/auto_refresh_indicator.dart';
import 'package:ckcandr/views/giangvien/dashboard_screen.dart';

class CauHoiScreen extends ConsumerStatefulWidget {
  const CauHoiScreen({super.key});

  @override
  ConsumerState<CauHoiScreen> createState() => _CauHoiScreenState();
}

class _CauHoiScreenState extends ConsumerState<CauHoiScreen> with AutoRefreshMixin {
  int? _selectedMonHocIdFilter;
  int? _selectedChuongMucIdFilter;
  int? _selectedDoKhoFilter;
  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();
  bool _hasAutoSelected = false;
  bool _showMyQuestionsOnly = true; // Mặc định hiển thị câu hỏi của mình

  // AutoRefreshMixin implementation
  @override
  String get autoRefreshKey => AutoRefreshKeys.teacherQuestions;

  @override
  void onAutoRefresh() {
    debugPrint('🔄 Auto-refreshing teacher questions');
    // Refresh danh sách câu hỏi
    ref.invalidate(cauHoiListProvider);
    // Refresh assigned subjects nếu cần
    ref.invalidate(assignedSubjectsProvider);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load assigned subjects for current teacher
      ref.invalidate(assignedSubjectsProvider);
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    // Set default filter and load questions
    final monHocList = ref.read(monHocListProvider);
    if (monHocList.isNotEmpty && _selectedMonHocIdFilter == null) {
      setState(() {
        _selectedMonHocIdFilter = int.tryParse(monHocList.first.id);
      });
      _loadQuestions();
    } else if (monHocList.isEmpty) {
      // Don't load questions if no subjects available
      setState(() {
        _selectedMonHocIdFilter = null;
      });
    } else if (_selectedMonHocIdFilter != null) {
      _loadQuestions();
    }
  }

  void _loadQuestions() {
    // Only load questions if a subject is selected
    if (_selectedMonHocIdFilter == null) {
      return;
    }

    final filter = CauHoiFilter(
      maMonHoc: _selectedMonHocIdFilter,
      maChuong: _selectedChuongMucIdFilter,
      doKho: _selectedDoKhoFilter,
      keyword: _searchTerm.isNotEmpty ? _searchTerm : null,
    );

    ref.read(cauHoiFilterProvider.notifier).state = filter;

    // Sử dụng provider phù hợp dựa trên toggle
    if (_showMyQuestionsOnly) {
      ref.read(myCreatedQuestionsProvider.notifier).refresh(filter);
    } else {
      ref.read(cauHoiListProvider.notifier).refresh(filter);
    }
  }

  /// Xử lý thêm câu hỏi từ FloatingActionButton
  void _handleAddQuestionFromFAB() {
    final assignedSubjectsAsync = ref.read(assignedSubjectsProvider);

    assignedSubjectsAsync.when(
      data: (assignedSubjects) {
        if (assignedSubjects.isEmpty) {
          _showErrorDialog(context, 'Chưa có môn học', 'Vui lòng thêm môn học trước khi tạo câu hỏi.');
          return;
        }

        if (_selectedMonHocIdFilter == null) {
          _showErrorDialog(context, 'Chưa chọn môn học', 'Vui lòng chọn môn học từ dropdown bên dưới trước khi thêm câu hỏi.');
          return;
        }

        _showCauHoiDialog(context, monHocIdForDialog: _selectedMonHocIdFilter!);
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang tải dữ liệu môn học...')),
        );
      },
      error: (error, stack) {
        _showErrorDialog(context, 'Lỗi', 'Không thể tải danh sách môn học: $error');
      },
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đã hiểu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assignedSubjectsAsync = ref.watch(assignedSubjectsProvider);

    // Watch provider phù hợp dựa trên toggle
    final cauHoiState = _showMyQuestionsOnly
        ? ref.watch(myCreatedQuestionsProvider)
        : ref.watch(cauHoiListProvider);

    // 🔥 RESET AUTO-SELECT: Reset khi user thay đổi (logout/login)
    ref.listen(assignedSubjectsProvider, (previous, next) {
      if (previous != next) {
        _hasAutoSelected = false;
        _selectedMonHocIdFilter = null;
        _selectedChuongMucIdFilter = null;
      }
    });

    // 🔥 LISTEN TO FAB TRIGGER: Lắng nghe trigger từ FloatingActionButton
    ref.listen(addQuestionTriggerProvider, (previous, next) {
      if (previous != next && next > 0) {
        // Trigger thêm câu hỏi
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleAddQuestionFromFAB();
        });
      }
    });

    return assignedSubjectsAsync.when(
      data: (assignedSubjects) {
        // Convert MonHocDTO to MonHoc for compatibility
        final monHocList = assignedSubjects.map((dto) => MonHoc(
          id: dto.mamonhoc.toString(),
          tenMonHoc: dto.tenmonhoc,
          maMonHoc: dto.mamonhoc.toString(),
          soTinChi: dto.sotinchi,
          soGioLT: dto.sotietlythuyet,
          soGioTH: dto.sotietthuchanh,
          trangThai: dto.trangthai,
        )).toList();

        // 🔥 AUTO-SELECT: Tự động chọn môn học đầu tiên nếu chưa chọn
        if (!_hasAutoSelected && assignedSubjects.isNotEmpty && _selectedMonHocIdFilter == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedMonHocIdFilter = assignedSubjects.first.mamonhoc;
              _hasAutoSelected = true;
            });
            // Force load questions for auto-selected subject
            _loadQuestions();
          });
        }

        // Get chapters for selected subject using new provider
        final chaptersAsync = _selectedMonHocIdFilter == null
            ? const AsyncValue<List<ChuongDTO>>.data([])
            : ref.watch(chaptersProvider(_selectedMonHocIdFilter));

        // Convert to ChuongMuc for compatibility
        final chuongMucListForSelectedMonHoc = chaptersAsync.when(
          data: (chapters) => chapters.map((ch) => ChuongMuc(
            id: ch.machuong.toString(),
            monHocId: ch.mamonhoc.toString(),
            tenChuongMuc: ch.tenchuong,
            thuTu: ch.machuong,
          )).toList(),
          loading: () => <ChuongMuc>[],
          error: (error, stack) => <ChuongMuc>[],
        );

        // BỎ AUTO REFRESH INDICATOR THEO YÊU CẦU USER
        return _buildMainContent(context, theme, monHocList, chuongMucListForSelectedMonHoc, cauHoiState);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Lỗi tải môn học: $error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(assignedSubjectsProvider),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    ThemeData theme,
    List<MonHoc> monHocList,
    List<ChuongMuc> chuongMucListForSelectedMonHoc,
    CauHoiListState cauHoiState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quản lý câu hỏi',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (_selectedMonHocIdFilter != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Môn: ${monHocList.firstWhere((m) => int.tryParse(m.id) == _selectedMonHocIdFilter, orElse: () => MonHoc(id: '', tenMonHoc: 'N/A', maMonHoc: '', soTinChi: 0)).tenMonHoc}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Đã chuyển thành FloatingActionButton ở cuối màn hình
                ],
              ),
              const SizedBox(height: 16),

              // Toggle button for question filter
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      _showMyQuestionsOnly ? Icons.person : Icons.group,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _showMyQuestionsOnly
                            ? 'Hiển thị: Câu hỏi do tôi tạo'
                            : 'Hiển thị: Tất cả câu hỏi của môn học',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch(
                      value: _showMyQuestionsOnly,
                      onChanged: (value) {
                        setState(() {
                          _showMyQuestionsOnly = value;
                        });
                        _loadQuestions(); // Reload với filter mới
                      },
                      activeColor: theme.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Filters row 1: Subject and Chapter
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Debug info
                        if (monHocList.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Chưa có môn học. Nhấn để tải lại.',
                                    style: TextStyle(color: Colors.orange[700], fontSize: 12),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref.invalidate(assignedSubjectsProvider);
                                  },
                                  child: const Text('Tải lại'),
                                ),
                              ],
                            ),
                          )
                        else
                          DropdownButtonFormField<int>(
                            value: _selectedMonHocIdFilter,
                            decoration: InputDecoration(
                              labelText: 'Chọn môn học * (${monHocList.length} môn)',
                              labelStyle: TextStyle(
                                color: _selectedMonHocIdFilter == null ? theme.colorScheme.error : null,
                                fontWeight: _selectedMonHocIdFilter == null ? FontWeight.bold : null,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: _selectedMonHocIdFilter == null ? theme.colorScheme.error : theme.dividerColor,
                                  width: _selectedMonHocIdFilter == null ? 2 : 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: _selectedMonHocIdFilter == null ? theme.colorScheme.error : theme.dividerColor,
                                  width: _selectedMonHocIdFilter == null ? 2 : 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: theme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.school,
                                color: _selectedMonHocIdFilter == null ? theme.colorScheme.error : theme.primaryColor,
                              ),
                            ),
                            isExpanded: true,
                            hint: Text(
                              'Chọn từ ${monHocList.length} môn học',
                              style: TextStyle(color: theme.hintColor),
                            ),
                            items: monHocList.map((MonHoc monHoc) {
                              return DropdownMenuItem<int>(
                                value: int.tryParse(monHoc.id),
                                child: Text(
                                  monHoc.tenMonHoc,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedMonHocIdFilter = newValue;
                                _selectedChuongMucIdFilter = null;
                              });

                              // 🔥 FORCE REFRESH: Invalidate chapters provider khi thay đổi môn học
                              if (newValue != null) {
                                ref.invalidate(chaptersProvider(newValue));
                              }

                              _loadQuestions();
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedChuongMucIdFilter,
                      decoration: const InputDecoration(
                        labelText: 'Chọn chương', 
                        border: OutlineInputBorder()
                      ),
                      isExpanded: true,
                      hint: const Text('Tất cả chương'),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null, 
                          child: Text('Tất cả chương'),
                        ),
                        ...chuongMucListForSelectedMonHoc.map((ChuongMuc cm) {
                          return DropdownMenuItem<int>(
                            value: int.tryParse(cm.id),
                            child: Text(cm.tenChuongMuc, overflow: TextOverflow.ellipsis),
                          );
                        })
                      ],
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedChuongMucIdFilter = newValue;
                        });
                        _loadQuestions();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Filters row 2: Difficulty and Search
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedDoKhoFilter,
                      decoration: const InputDecoration(
                        labelText: 'Độ khó', 
                        border: OutlineInputBorder()
                      ),
                      isExpanded: true,
                      hint: const Text('Tất cả độ khó'),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Tất cả độ khó'),
                        ),
                        const DropdownMenuItem<int>(
                          value: 1,
                          child: Text('Dễ', style: TextStyle(color: Colors.green)),
                        ),
                        const DropdownMenuItem<int>(
                          value: 2,
                          child: Text('Trung bình', style: TextStyle(color: Colors.orange)),
                        ),
                        const DropdownMenuItem<int>(
                          value: 3,
                          child: Text('Khó', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedDoKhoFilter = newValue;
                        });
                        _loadQuestions();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm nội dung câu hỏi...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchTerm = value;
                        });
                        // Debounce search
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_searchTerm == value) {
                            _loadQuestions();
                          }
                        });
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const Divider(height: 1),
        
        // Questions list
        Expanded(
          child: _buildQuestionsList(cauHoiState, monHocList, chuongMucListForSelectedMonHoc, theme),
        ),
      ],
    );
  }

  Widget _buildQuestionsList(
    CauHoiListState cauHoiState, 
    List<MonHoc> monHocList, 
    List<ChuongMuc> chuongMucList,
    ThemeData theme,
  ) {
    if (cauHoiState.isLoading && cauHoiState.questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cauHoiState.error != null && cauHoiState.questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Lỗi: ${cauHoiState.error}',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadQuestions,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (cauHoiState.questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                monHocList.isEmpty ? Icons.school_outlined :
                _selectedMonHocIdFilter == null ? Icons.arrow_upward : Icons.quiz_outlined,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                monHocList.isEmpty
                    ? 'Chưa có môn học nào'
                    : _selectedMonHocIdFilter == null
                        ? 'Vui lòng chọn môn học'
                        : 'Chưa có câu hỏi nào',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                monHocList.isEmpty
                    ? 'Vui lòng thêm môn học trước để bắt đầu tạo câu hỏi.'
                    : _selectedMonHocIdFilter == null
                        ? 'Chọn môn học từ dropdown ở trên để xem và quản lý câu hỏi.'
                        : 'Không tìm thấy câu hỏi nào phù hợp với bộ lọc của bạn.',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
                textAlign: TextAlign.center,
              ),
              if (_selectedMonHocIdFilter != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Sử dụng nút + ở góc dưới để thêm câu hỏi',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadQuestions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: cauHoiState.questions.length + (cauHoiState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= cauHoiState.questions.length) {
            // Load more indicator
            if (cauHoiState.isLoading) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      final filter = ref.read(cauHoiFilterProvider);
                      ref.read(cauHoiListProvider.notifier).loadMore(filter);
                    },
                    child: const Text('Tải thêm'),
                  ),
                ),
              );
            }
          }

          final cauHoi = cauHoiState.questions[index];
          return _buildQuestionCard(cauHoi, index, monHocList, chuongMucList, theme);
        },
      ),
    );
  }

  Widget _buildQuestionCard(
    CauHoi cauHoi,
    int index,
    List<MonHoc> monHocList,
    List<ChuongMuc> chuongMucList,
    ThemeData theme,
  ) {
    // Use data from API response if available, otherwise fallback to lookup
    final tenMonHoc = cauHoi.tenMonHoc ?? (() {
      final monHoc = monHocList.firstWhere(
        (mh) => int.tryParse(mh.id) == cauHoi.monHocId,
        orElse: () => MonHoc(id: cauHoi.monHocId.toString(), tenMonHoc: 'N/A', maMonHoc: '', soTinChi: 0)
      );
      return monHoc.tenMonHoc;
    })();

    final tenChuong = cauHoi.tenChuong ?? (() {
      if (cauHoi.chuongMucId != null) {
        try {
          final chuongMuc = chuongMucList.firstWhere(
            (cm) => int.tryParse(cm.id) == cauHoi.chuongMucId,
          );
          return chuongMuc.tenChuongMuc;
        } catch (e) {
          return null;
        }
      }
      return null;
    })();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _showQuestionDetailDialog(context, cauHoi),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 30,
                  child: Text('${index + 1}.', style: theme.textTheme.titleSmall)
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cauHoi.noiDung,
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis
                      ),
                      if (cauHoi.hinhanhUrl != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              cauHoi.hinhanhUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.subject, size: 16, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Môn: $tenMonHoc${tenChuong != null ? ' - C: $tenChuong' : ''}',
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.quiz_outlined, size: 16, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        cauHoi.tenLoaiCauHoi,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.trending_up, size: 16, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        cauHoi.tenDoKho,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cauHoi.doKho == DoKho.de
                              ? Colors.green
                              : cauHoi.doKho == DoKho.trungBinh
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Chỉ hiển thị nút sửa/xóa khi xem câu hỏi của mình
            if (_showMyQuestionsOnly)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.edit_outlined, size: 18, color: theme.primaryColor),
                    label: const Text('Sửa'),
                    onPressed: () => _showCauHoiDialog(
                      context,
                      cauHoiToEdit: cauHoi,
                      monHocIdForDialog: cauHoi.monHocId
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                    label: Text('Xóa', style: TextStyle(color: theme.colorScheme.error)),
                    onPressed: () => _deleteCauHoi(cauHoi),
                  ),
                ],
              )
            else
              // Khi xem tất cả câu hỏi, chỉ hiển thị thông tin tác giả
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Câu hỏi của giảng viên khác',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuestionDetailDialog(BuildContext context, CauHoi cauHoi) async {
    // Load detailed question data
    CauHoi? detailedCauHoi = cauHoi;
    if (cauHoi.macauhoi != null) {
      final response = await ref.read(cauHoiServiceProvider).getQuestionById(cauHoi.macauhoi!);
      if (response.isSuccess && response.data != null) {
        detailedCauHoi = response.data;
      }
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => _QuestionDetailDialog(
        cauHoi: detailedCauHoi!,
        canEdit: _showMyQuestionsOnly, // Chỉ cho phép sửa nếu đang xem câu hỏi của mình
        onEdit: _showMyQuestionsOnly ? () {
          Navigator.of(context).pop();
          _showCauHoiDialog(context, cauHoiToEdit: detailedCauHoi, monHocIdForDialog: detailedCauHoi!.monHocId);
        } : null,
      ),
    );
  }

  void _showCauHoiDialog(BuildContext context, {CauHoi? cauHoiToEdit, required int monHocIdForDialog}) async {
    // Get assigned subjects and convert to MonHoc list
    final assignedSubjectsAsync = ref.read(assignedSubjectsProvider);

    assignedSubjectsAsync.when(
      data: (assignedSubjects) async {
        final monHocList = assignedSubjects.map((dto) => MonHoc(
          id: dto.mamonhoc.toString(),
          tenMonHoc: dto.tenmonhoc,
          maMonHoc: dto.mamonhoc.toString(),
          soTinChi: dto.sotinchi,
          soGioLT: dto.sotietlythuyet,
          soGioTH: dto.sotietthuchanh,
          trangThai: dto.trangthai,
        )).toList();

        final chuongMucList = ref.read(filteredChuongMucListProvider(monHocIdForDialog.toString()));

        // If editing, load detailed question data first
        CauHoi? detailedCauHoi = cauHoiToEdit;
        if (cauHoiToEdit != null && cauHoiToEdit.macauhoi != null) {
          print('🔍 Loading detailed question data for ID: ${cauHoiToEdit.macauhoi}');
          final response = await ref.read(cauHoiServiceProvider).getQuestionById(cauHoiToEdit.macauhoi!);
          if (response.isSuccess && response.data != null) {
            detailedCauHoi = response.data;
            print('✅ Loaded detailed question: ${detailedCauHoi!.noiDung}');
            print('   MonHoc ID: ${detailedCauHoi.monHocId}');
            print('   Chuong ID: ${detailedCauHoi.chuongMucId}');
            print('   Answers: ${detailedCauHoi.cacLuaChon.length}');
          } else {
            print('❌ Failed to load detailed question: ${response.error}');
          }
        }

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CauHoiFormDialog(
                cauHoiToEdit: detailedCauHoi,
                monHocIdForDialog: monHocIdForDialog,
                monHocList: monHocList,
                chuongMucList: chuongMucList,
                onSaved: () {
                  _loadQuestions(); // Refresh list after save
                },
              );
            },
          );
        }
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang tải dữ liệu môn học...')),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải môn học: $error')),
        );
      },
    );
  }

  void _deleteCauHoi(CauHoi cauHoi) {
    if (cauHoi.macauhoi == null) return;

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
            onPressed: () async {
              Navigator.of(ctx).pop();

              try {
                // Call delete API
                await ref.read(deleteQuestionProvider(cauHoi.macauhoi!).future);

                // Log activity
                String noiDungLog = cauHoi.noiDung;
                if (noiDungLog.length > 50) noiDungLog = '${noiDungLog.substring(0, 47)}...';

                final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
                hoatDongNotifier.addHoatDong(
                  'Đã xóa câu hỏi: "$noiDungLog"',
                  LoaiHoatDong.CAU_HOI,
                  Icons.delete_outline,
                  idDoiTuongLienQuan: cauHoi.id,
                );

                if (mounted) {
                  _showSuccessDialog('Đã xóa câu hỏi thành công!');
                }

                // Refresh list
                _loadQuestions();
              } catch (e) {
                if (mounted) {
                  _showErrorDialog(context, 'Lỗi', 'Lỗi khi xóa câu hỏi: $e');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Thành công'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

}

class _QuestionDetailDialog extends StatelessWidget {
  final CauHoi cauHoi;
  final bool canEdit;
  final VoidCallback? onEdit;

  const _QuestionDetailDialog({
    required this.cauHoi,
    required this.canEdit,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.quiz, color: theme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Chi tiết câu hỏi',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question content
                    Text(
                      'Nội dung câu hỏi:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cauHoi.noiDung,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),

                    // Question image if available
                    if (cauHoi.hinhanhUrl != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Hình ảnh:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            cauHoi.hinhanhUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 100,
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Question info
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            'Môn học',
                            cauHoi.tenMonHoc ?? 'N/A',
                            Icons.subject,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            'Chương',
                            cauHoi.tenChuong ?? 'N/A',
                            Icons.book,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            'Loại câu hỏi',
                            cauHoi.tenLoaiCauHoi,
                            Icons.quiz_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            'Độ khó',
                            cauHoi.tenDoKho,
                            Icons.trending_up,
                            valueColor: cauHoi.doKho == DoKho.de
                                ? Colors.green
                                : cauHoi.doKho == DoKho.trungBinh
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),

                    // Answers section
                    if (cauHoi.cacLuaChon.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Các lựa chọn trả lời:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...cauHoi.cacLuaChon.asMap().entries.map((entry) {
                        final index = entry.key;
                        final luaChon = entry.value;
                        final isCorrect = luaChon.laDapAnDung ?? false;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? Colors.green.withValues(alpha: 0.1)
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCorrect
                                  ? Colors.green
                                  : theme.dividerColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isCorrect ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index), // A, B, C, D
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  luaChon.noiDung,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              if (isCorrect)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            // Actions
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canEdit && onEdit != null)
                  ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Chỉnh sửa'),
                  ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.hintColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
