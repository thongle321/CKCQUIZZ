import 'dart:convert';
import 'dart:io';

/// Test script để kiểm tra API thông báo cho sinh viên
void main() async {
  print('🧪 Testing Student Notification API...\n');
  
  // Test data
  const baseUrl = 'https://ckcquizz.dnssking.com:7254';
  const testUserId = 'test-student-id'; // Thay bằng user ID thực tế
  
  // Test 1: API cũ (dành cho giảng viên) - sẽ trả về empty
  await testOldAPI(baseUrl);
  
  // Test 2: API mới (dành cho sinh viên) - sẽ trả về data
  await testNewAPI(baseUrl, testUserId);
}

/// Test API cũ /api/ThongBao/me (dành cho giảng viên)
Future<void> testOldAPI(String baseUrl) async {
  print('📋 Test 1: API cũ /api/ThongBao/me (dành cho giảng viên)');
  
  try {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true; // Ignore SSL for testing
    
    final request = await client.getUrl(Uri.parse('$baseUrl/api/ThongBao/me?page=1&pageSize=10'));
    request.headers.set('Content-Type', 'application/json');
    // Note: Trong thực tế cần thêm Authorization header với JWT token
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('   Status Code: ${response.statusCode}');
    print('   Response: $responseBody');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final totalCount = data['totalCount'] ?? 0;
      final items = data['items'] ?? [];
      print('   ✅ API hoạt động - Total: $totalCount, Items: ${items.length}');
      if (totalCount == 0) {
        print('   ⚠️  Không có data (đúng như mong đợi cho sinh viên)');
      }
    } else {
      print('   ❌ API lỗi');
    }
    
    client.close();
  } catch (e) {
    print('   ❌ Error: $e');
  }
  
  print('');
}

/// Test API mới /api/ThongBao/notifications/{userId} (dành cho sinh viên)
Future<void> testNewAPI(String baseUrl, String userId) async {
  print('📋 Test 2: API mới /api/ThongBao/notifications/$userId (dành cho sinh viên)');
  
  try {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true; // Ignore SSL for testing
    
    final request = await client.getUrl(Uri.parse('$baseUrl/api/ThongBao/notifications/$userId'));
    request.headers.set('Content-Type', 'application/json');
    // Note: Trong thực tế cần thêm Authorization header với JWT token
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('   Status Code: ${response.statusCode}');
    print('   Response: $responseBody');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      if (data is List) {
        print('   ✅ API hoạt động - Số thông báo: ${data.length}');
        if (data.isNotEmpty) {
          print('   📄 Sample notification:');
          final sample = data.first;
          print('      - ID: ${sample['matb']}');
          print('      - Nội dung: ${sample['noidung']}');
          print('      - Người tạo: ${sample['hoten']}');
          print('      - Môn học: ${sample['tenmonhoc']}');
          print('      - Thời gian: ${sample['thoigiantao']}');
        } else {
          print('   ⚠️  Không có thông báo nào cho user này');
        }
      } else {
        print('   ❌ Response format không đúng (không phải List)');
      }
    } else {
      print('   ❌ API lỗi');
    }
    
    client.close();
  } catch (e) {
    print('   ❌ Error: $e');
  }
  
  print('');
}
