/// Test script để kiểm tra API authentication
/// Chạy script này để test trực tiếp API call

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

void main() async {
  print('🧪 Testing API Authentication...');
  
  // Test credentials từ hình ảnh
  const String email = '0306221378@caothang.edu.vn';
  const String password = 'Thongle789321@';
  
  // API endpoints
  const String httpsUrl = 'https://34.145.23.90:7254/api/Auth/signin';
  const String httpUrl = 'http://34.145.23.90:5100/api/Auth/signin';
  
  // Test data
  final Map<String, dynamic> requestData = {
    'email': email,
    'password': password,
  };
  
  final String requestBody = jsonEncode(requestData);
  
  print('📤 Request Data:');
  print('   Email: $email');
  print('   Password: ${password.replaceAll(RegExp(r'.'), '*')}');
  print('   Body: $requestBody');
  print('');
  
  // Test HTTP endpoint first (simpler)
  print('🔓 Testing HTTP endpoint: $httpUrl');
  await testEndpoint(httpUrl, requestBody);

  print('');

  // Test HTTPS endpoint with certificate bypass
  print('🔐 Testing HTTPS endpoint: $httpsUrl');
  await testEndpointWithCertBypass(httpsUrl, requestBody);
}

Future<void> testEndpoint(String url, String requestBody) async {
  try {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    print('   Headers: $headers');
    
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: requestBody,
    ).timeout(Duration(seconds: 30));
    
    print('📥 Response:');
    print('   Status Code: ${response.statusCode}');
    print('   Headers: ${response.headers}');
    print('   Body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ SUCCESS: API call successful!');
      
      try {
        final jsonResponse = jsonDecode(response.body);
        print('   Parsed JSON: $jsonResponse');
      } catch (e) {
        print('   ⚠️  Could not parse JSON: $e');
      }
    } else {
      print('❌ FAILED: API call failed');
      
      try {
        final errorJson = jsonDecode(response.body);
        print('   Error details: $errorJson');
      } catch (e) {
        print('   Raw error: ${response.body}');
      }
    }
    
  } on SocketException catch (e) {
    print('❌ Socket Exception: $e');
  } on HttpException catch (e) {
    print('❌ HTTP Exception: $e');
  } on FormatException catch (e) {
    print('❌ Format Exception: $e');
  } catch (e) {
    print('❌ General Exception: $e');
  }
}

Future<void> testEndpointWithCertBypass(String url, String requestBody) async {
  try {
    // Create HTTP client with certificate bypass
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        print('⚠️  Bypassing certificate validation for: $host:$port');
        return true; // Accept all certificates
      };

    final client = IOClient(httpClient);

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    print('   Headers: $headers');
    print('   Certificate bypass: ENABLED');

    final response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: requestBody,
    ).timeout(Duration(seconds: 60));

    print('📥 Response:');
    print('   Status Code: ${response.statusCode}');
    print('   Headers: ${response.headers}');
    print('   Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ SUCCESS: HTTPS API call successful with certificate bypass!');

      try {
        final jsonResponse = jsonDecode(response.body);
        print('   Parsed JSON: $jsonResponse');
      } catch (e) {
        print('   ⚠️  Could not parse JSON: $e');
      }
    } else {
      print('❌ FAILED: HTTPS API call failed');

      try {
        final errorJson = jsonDecode(response.body);
        print('   Error details: $errorJson');
      } catch (e) {
        print('   Raw error: ${response.body}');
      }
    }

    client.close();

  } on SocketException catch (e) {
    print('❌ Socket Exception: $e');
  } on HttpException catch (e) {
    print('❌ HTTP Exception: $e');
  } on FormatException catch (e) {
    print('❌ Format Exception: $e');
  } catch (e) {
    print('❌ General Exception: $e');
  }
}
