import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ckcandr/services/http_client_service.dart';
import 'package:ckcandr/models/ket_qua_model.dart';

class KetQuaService {
  final HttpClientService _httpClient = HttpClientService();

  /// Cập nhật điểm số cho sinh viên
  Future<Map<String, dynamic>> updateScore({
    required int examId,
    required String studentId,
    required double newScore,
  }) async {
    try {
      final response = await _httpClient.put<UpdateScoreResponse>(
        '/api/KetQua/update-score',
        {
          'examId': examId,
          'studentId': studentId,
          'newScore': newScore,
        },
        (json) => UpdateScoreResponse.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        return {
          'success': response.data!.success,
          'data': response.data,
          'message': response.data!.message,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Lỗi khi cập nhật điểm',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }

  /// Tìm ketQuaId theo examId và studentId
  Future<Map<String, dynamic>> findKetQuaId({
    required int examId,
    required String studentId,
  }) async {
    try {
      final response = await _httpClient.get<FindKetQuaResponse>(
        '/api/KetQua/find-by-exam-student/$examId/$studentId',
        (json) => FindKetQuaResponse.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        return {
          'success': response.data!.success,
          'data': response.data,
          'ketQuaId': response.data!.ketQuaId,
          'message': response.data!.message,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': response.message ?? 'Không tìm thấy kết quả thi cho sinh viên này',
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Lỗi khi tìm kiếm kết quả thi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }

  /// Lấy chi tiết kết quả bài thi của sinh viên cho giáo viên
  /// Sử dụng API mới: /api/KetQua/teacher/student-result/{examId}/{studentId}
  Future<Map<String, dynamic>> getStudentExamResultForTeacher({
    required int examId,
    required String studentId,
  }) async {
    try {
      debugPrint('📊 API: Getting student exam result for teacher - examId: $examId, studentId: $studentId');

      // Sử dụng API mới cho giáo viên
      final response = await _httpClient.get<dynamic>(
        '/api/KetQua/teacher/student-result/$examId/$studentId',
        (json) => json, // Return raw JSON
      );

      if (response.isSuccess && response.data != null) {
        debugPrint('✅ API: Get student exam result for teacher successful');
        debugPrint('📊 API response data: ${response.data}');
        return {
          'success': true,
          'data': response.data,
          'examId': examId,
          'studentId': studentId,
          'message': 'Lấy chi tiết kết quả thành công',
        };
      } else if (response.statusCode == 404) {
        debugPrint('❌ API: Student exam result not found');
        return {
          'success': false,
          'message': response.message ?? 'Không tìm thấy kết quả thi cho sinh viên này',
        };
      } else if (response.statusCode == 403) {
        debugPrint('❌ API: Access forbidden - not your exam');
        return {
          'success': false,
          'message': response.message ?? 'Bạn chỉ có thể xem kết quả của đề thi do chính mình tạo',
        };
      } else {
        debugPrint('❌ API: Get student exam result failed: ${response.message}');
        return {
          'success': false,
          'message': response.message ?? 'Lỗi khi lấy chi tiết kết quả thi',
        };
      }
    } catch (e) {
      debugPrint('❌ API: Get student exam result error: $e');
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }
}
