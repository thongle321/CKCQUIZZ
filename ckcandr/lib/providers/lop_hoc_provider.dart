import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/services/lop_hoc_service.dart';
import 'dart:math';

/// Provider cho danh sách lớp học
final lopHocListProvider = StateNotifierProvider<LopHocNotifier, AsyncValue<List<LopHoc>>>((ref) {
  return LopHocNotifier(ref.watch(lopHocServiceProvider));
});

/// Notifier quản lý danh sách lớp học
class LopHocNotifier extends StateNotifier<AsyncValue<List<LopHoc>>> {
  final LopHocService _lopHocService;

  LopHocNotifier(this._lopHocService) : super(const AsyncValue.loading()) {
    loadClasses();
  }

  /// Load danh sách lớp học từ API
  Future<void> loadClasses({bool? hienthi}) async {
    try {
      state = const AsyncValue.loading();
      final classes = await _lopHocService.getAllClasses(hienthi: hienthi);
      state = AsyncValue.data(classes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Thêm lớp học mới
  Future<void> addLopHoc(CreateLopRequestDTO request) async {
    try {
      final newClass = await _lopHocService.createClass(request);
      state = state.whenData((classes) => [...classes, newClass]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Cập nhật lớp học
  Future<void> updateLopHoc(int id, UpdateLopRequestDTO request) async {
    try {
      final updatedClass = await _lopHocService.updateClass(id, request);
      state = state.whenData((classes) => [
        for (final item in classes)
          if (item.malop == id) updatedClass else item,
      ]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Xóa lớp học
  Future<void> deleteLopHoc(int id) async {
    try {
      await _lopHocService.deleteClass(id);
      state = state.whenData((classes) =>
        classes.where((item) => item.malop != id).toList());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Toggle trạng thái hiển thị lớp học
  Future<void> toggleClassStatus(int id, bool hienthi) async {
    try {
      await _lopHocService.toggleClassStatus(id, hienthi);
      // Reload data after toggle
      await loadClasses();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh mã mời lớp học
  Future<String?> refreshInviteCode(int id) async {
    try {
      final newCode = await _lopHocService.refreshInviteCode(id);
      // Reload data to get updated invite code
      await loadClasses();
      return newCode;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Tạo mã lớp ngẫu nhiên
  String generateMaLop() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}


