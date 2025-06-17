/// Service for Class (Lop Hoc) operations
/// 
/// This service handles all class-related API operations including
/// CRUD operations, student management, and invite code management.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/services/api_service.dart';

/// Service class for class operations
class LopHocService {
  final ApiService _apiService;

  LopHocService(this._apiService);

  /// Get all classes
  Future<List<LopHoc>> getAllClasses({bool? hienthi}) async {
    return await _apiService.getClasses(hienthi: hienthi);
  }

  /// Get class by ID
  Future<LopHoc> getClassById(int id) async {
    return await _apiService.getClassById(id);
  }

  /// Create new class
  Future<LopHoc> createClass(CreateLopRequestDTO request) async {
    return await _apiService.createClass(request);
  }

  /// Update class
  Future<LopHoc> updateClass(int id, UpdateLopRequestDTO request) async {
    return await _apiService.updateClass(id, request);
  }

  /// Delete class
  Future<void> deleteClass(int id) async {
    return await _apiService.deleteClass(id);
  }

  /// Toggle class status (show/hide)
  Future<void> toggleClassStatus(int id, bool hienthi) async {
    return await _apiService.toggleClassStatus(id, hienthi);
  }

  /// Refresh invite code for class
  Future<String> refreshInviteCode(int id) async {
    return await _apiService.refreshInviteCode(id);
  }
}

/// Provider for LopHocService
final lopHocServiceProvider = Provider<LopHocService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return LopHocService(apiService);
});
