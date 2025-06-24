/// Service for managing questions (Câu hỏi) API calls
/// 
/// This service handles all HTTP communication with the ASP.NET Core backend API
/// for question management operations including CRUD operations and image handling.

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ckcandr/core/config/api_config.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';
import 'package:ckcandr/models/api_response_model.dart';
import 'package:ckcandr/services/http_client_service.dart';

// Provider for CauHoiService
final cauHoiServiceProvider = Provider<CauHoiService>((ref) {
  final httpClient = ref.watch(httpClientServiceProvider);
  return CauHoiService(httpClient);
});

class CauHoiService {
  final HttpClientService _httpClient;

  CauHoiService(this._httpClient);

  /// Get paginated list of questions with filters
  Future<ApiResponse<CauHoiListResponse>> getQuestions({
    int? maMonHoc,
    int? maChuong,
    int? doKho,
    String? keyword,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (maMonHoc != null) queryParams['MaMonHoc'] = maMonHoc.toString();
      if (maChuong != null) queryParams['MaChuong'] = maChuong.toString();
      if (doKho != null) queryParams['DoKho'] = doKho.toString();
      if (keyword != null && keyword.isNotEmpty) queryParams['Keyword'] = keyword;

      final uri = Uri.parse(ApiConfig.getFullUrl('/api/CauHoi')).replace(queryParameters: queryParams);
      final headers = await _httpClient.getHeaders(includeAuth: true);

      print('🌐 GET Questions Request:');
      print('   URL: $uri');
      print('   Headers: $headers');

      final response = await http.get(uri, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      print('📥 Questions Response: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse.success(CauHoiListResponse.fromJson(jsonData));
      } else {
        return ApiResponse.error('Lỗi khi tải danh sách câu hỏi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting questions: $e');
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }

  /// Get question by ID
  Future<ApiResponse<CauHoi>> getQuestionById(int id) async {
    try {
      final url = '/api/CauHoi/$id';
      final uri = Uri.parse(ApiConfig.getFullUrl(url));
      final headers = await _httpClient.getHeaders(includeAuth: true);

      print('🌐 GET Question by ID Request:');
      print('   URL: $uri');

      final response = await http.get(uri, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      print('📥 Question Detail Response: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse.success(CauHoi.fromDetailJson(jsonData));
      } else if (response.statusCode == 404) {
        return ApiResponse.error('Không tìm thấy câu hỏi');
      } else {
        return ApiResponse.error('Lỗi khi tải chi tiết câu hỏi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting question by ID: $e');
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }

  /// Create new question
  Future<ApiResponse<int>> createQuestion(CauHoi cauHoi) async {
    try {
      final url = '/api/CauHoi';
      final uri = Uri.parse(ApiConfig.getFullUrl(url));
      final headers = await _httpClient.getHeaders(includeAuth: true);
      headers['Content-Type'] = 'application/json';

      final body = json.encode(cauHoi.toCreateDto());

      print('🌐 POST Create Question Request:');
      print('   URL: $uri');
      print('   Body: $body');

      final response = await http.post(uri, headers: headers, body: body)
          .timeout(ApiConfig.connectionTimeout);

      print('📥 Create Question Response: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return ApiResponse.success(jsonData['id'] as int);
      } else {
        final errorMsg = _parseErrorMessage(response);
        return ApiResponse.error('Lỗi khi tạo câu hỏi: $errorMsg');
      }
    } catch (e) {
      print('❌ Error creating question: $e');
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }

  /// Update existing question
  Future<ApiResponse<bool>> updateQuestion(int id, CauHoi cauHoi) async {
    try {
      final url = '/api/CauHoi/$id';
      final uri = Uri.parse(ApiConfig.getFullUrl(url));
      final headers = await _httpClient.getHeaders(includeAuth: true);
      headers['Content-Type'] = 'application/json';

      final body = json.encode(cauHoi.toUpdateDto());

      print('🌐 PUT Update Question Request:');
      print('   URL: $uri');
      print('   Body: $body');

      final response = await http.put(uri, headers: headers, body: body)
          .timeout(ApiConfig.connectionTimeout);

      print('📥 Update Question Response: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 204) {
        return ApiResponse.success(true);
      } else if (response.statusCode == 404) {
        return ApiResponse.error('Không tìm thấy câu hỏi để cập nhật');
      } else {
        final errorMsg = _parseErrorMessage(response);
        return ApiResponse.error('Lỗi khi cập nhật câu hỏi: $errorMsg');
      }
    } catch (e) {
      print('❌ Error updating question: $e');
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }

  /// Delete question (soft delete)
  Future<ApiResponse<bool>> deleteQuestion(int id) async {
    try {
      final url = '/api/CauHoi/$id';
      final uri = Uri.parse(ApiConfig.getFullUrl(url));
      final headers = await _httpClient.getHeaders(includeAuth: true);

      print('🌐 DELETE Question Request:');
      print('   URL: $uri');

      final response = await http.delete(uri, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      print('📥 Delete Question Response: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(true);
      } else if (response.statusCode == 404) {
        return ApiResponse.error('Không tìm thấy câu hỏi để xóa');
      } else {
        return ApiResponse.error('Lỗi khi xóa câu hỏi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting question: $e');
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }

  /// Upload image for question
  Future<ApiResponse<String>> uploadImage(XFile imageFile) async {
    try {
      final url = '/api/Files/upload';
      final uri = Uri.parse(ApiConfig.getFullUrl(url));
      final headers = await _httpClient.getHeaders(includeAuth: true);

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      // Add file to request
      final bytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      );
      request.files.add(multipartFile);

      print('🌐 POST Upload Image Request:');
      print('   URL: $uri');
      print('   File: ${imageFile.name}');

      final streamedResponse = await request.send()
          .timeout(ApiConfig.connectionTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Upload Image Response: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse.success(jsonData['url'] as String);
      } else {
        final errorMsg = _parseErrorMessage(response);
        return ApiResponse.error('Lỗi khi tải ảnh: $errorMsg');
      }
    } catch (e) {
      print('❌ Error uploading image: $e');
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }

  /// Convert image to base64 (for local processing if needed)
  Future<String> imageToBase64(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('❌ Error converting image to base64: $e');
      throw Exception('Lỗi chuyển đổi ảnh: $e');
    }
  }

  /// Parse error message from response
  String _parseErrorMessage(http.Response response) {
    try {
      final jsonData = json.decode(response.body);
      if (jsonData is Map<String, dynamic>) {
        if (jsonData.containsKey('message')) {
          return jsonData['message'];
        } else if (jsonData.containsKey('errors')) {
          final errors = jsonData['errors'];
          if (errors is Map<String, dynamic>) {
            return errors.values.expand((e) => e is List ? e : [e]).join('\n');
          }
        }
      }
      return response.body;
    } catch (e) {
      return 'Lỗi không xác định';
    }
  }
}

/// Response model for paginated question list
class CauHoiListResponse {
  final List<CauHoi> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  CauHoiListResponse({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  factory CauHoiListResponse.fromJson(Map<String, dynamic> json) {
    return CauHoiListResponse(
      items: (json['items'] as List? ?? [])
          .map((e) => CauHoi.fromJson(e))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }
}
