import 'dart:convert';
import 'dart:io';

/// Test script to verify login API functionality
void main() async {
  print('🧪 Testing Login API...');
  
  // Test credentials from SeedData.cs (CORRECT CREDENTIALS)
  final testCredentials = [
    {'email': '0306221378@caothang.edu.vn', 'password': 'Thongle789321@', 'role': 'Admin'},
    {'email': 'teacher1@caothang.edu.vn', 'password': 'Giaovien123@', 'role': 'Teacher'},
    {'email': 'student1@caothang.edu.vn', 'password': 'Hocsinh123@', 'role': 'Student'},
  ];

  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => host == '34.145.23.90';

  for (final cred in testCredentials) {
    print('\n📧 Testing login for: ${cred['email']} (${cred['role']})');
    
    try {
      final request = await client.postUrl(
        Uri.parse('https://34.145.23.90:7254/api/Auth/signin')
      );
      
      request.headers.set('Content-Type', 'application/json');
      
      final body = jsonEncode({
        'email': cred['email'],
        'password': cred['password'],
      });
      
      request.write(body);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Headers: ${response.headers}');
      print('📥 Response Body: $responseBody');
      
      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(responseBody);
          print('✅ Login successful!');
          print('   Access Token: ${jsonResponse['accessToken']?.toString().substring(0, 20)}...');
          print('   Refresh Token: ${jsonResponse['refreshToken']?.toString().substring(0, 20)}...');
        } catch (e) {
          print('❌ Failed to parse JSON response: $e');
        }
      } else {
        print('❌ Login failed with status: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Error during login test: $e');
    }
  }
  
  client.close();
  print('\n🏁 Login API test completed!');
}
