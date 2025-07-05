import 'dart:convert';
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
}
