/// Utility để test kết nối HTTP và HTTPS với server
/// 
/// File này giúp kiểm tra xem server có thể kết nối qua HTTP hay HTTPS

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ckcandr/core/config/api_config.dart';

class ConnectionTest {
  /// Test kết nối với server qua HTTP
  static Future<bool> testHttpConnection() async {
    try {
      final url = Uri.parse('${ApiConfig.httpUrl}/api/Auth/test');
      print('🔍 Testing HTTP connection: $url');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );
      
      print('✅ HTTP Response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 404; // 404 is OK if endpoint doesn't exist
    } catch (e) {
      print('❌ HTTP Connection failed: $e');
      return false;
    }
  }

  /// Test kết nối với server qua HTTPS
  static Future<bool> testHttpsConnection() async {
    try {
      // Create HTTP client with certificate bypass
      final httpClient = HttpClient()
        ..badCertificateCallback = (cert, host, port) {
          return host == 'ckcquizz.ddnsking.com' || host.contains('ddnsking.com');
        }
        ..connectionTimeout = const Duration(seconds: 10);

      final request = await httpClient.getUrl(
        Uri.parse('${ApiConfig.httpsUrl}/api/Auth/test')
      );
      
      print('🔍 Testing HTTPS connection: ${ApiConfig.httpsUrl}/api/Auth/test');
      
      final response = await request.close();
      
      print('✅ HTTPS Response: ${response.statusCode}');
      httpClient.close();
      
      return response.statusCode == 200 || response.statusCode == 404; // 404 is OK if endpoint doesn't exist
    } catch (e) {
      print('❌ HTTPS Connection failed: $e');
      return false;
    }
  }

  /// Test cả HTTP và HTTPS để xác định protocol tốt nhất
  static Future<String> findBestProtocol() async {
    // Removed debug log

    // Test HTTPS trước (ưu tiên)
    final httpsWorks = await testHttpsConnection();
    if (httpsWorks) {
      // Removed debug log
      return 'https';
    }

    // Nếu HTTPS không work, test HTTP
    final httpWorks = await testHttpConnection();
    if (httpWorks) {
      // Removed debug log
      return 'http';
    }

    // Removed debug log
    return 'none';
  }

  /// Test kết nối với endpoint cụ thể
  static Future<bool> testEndpoint(String endpoint, {bool useHttps = true}) async {
    try {
      final baseUrl = useHttps ? ApiConfig.httpsUrl : ApiConfig.httpUrl;
      final url = Uri.parse('$baseUrl$endpoint');
      
      print('🔍 Testing endpoint: $url');
      
      if (useHttps) {
        final httpClient = HttpClient()
          ..badCertificateCallback = (cert, host, port) {
            return host == 'ckcquizz.ddnsking.com' || host.contains('ddnsking.com');
          }
          ..connectionTimeout = const Duration(seconds: 10);

        final request = await httpClient.getUrl(url);
        final response = await request.close();
        httpClient.close();
        
        print('📡 Response: ${response.statusCode}');
        return response.statusCode < 500; // Accept any non-server error
      } else {
        final response = await http.get(url).timeout(
          const Duration(seconds: 10),
        );
        
        print('📡 Response: ${response.statusCode}');
        return response.statusCode < 500; // Accept any non-server error
      }
    } catch (e) {
      print('❌ Endpoint test failed: $e');
      return false;
    }
  }
}
