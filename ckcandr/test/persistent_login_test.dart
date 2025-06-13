import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:ckcandr/services/http_client_service.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/core/config/api_config.dart';

void main() {
  group('Persistent Login Tests', () {
    late HttpClientService httpClientService;
    late AuthService authService;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      
      httpClientService = HttpClientService();
      authService = AuthService(httpClientService);
    });

    tearDown(() async {
      // Clear all stored data after each test
      await httpClientService.clearAuthData();
    });

    test('should store authentication tokens after successful login', () async {
      // Mock successful login response
      const accessToken = 'mock_access_token';
      const refreshToken = 'mock_refresh_token';
      
      // Store tokens
      await httpClientService.storeAuthTokens(
        accessToken,
        refreshToken,
        expiryTime: DateTime.now().add(const Duration(hours: 24)),
      );

      // Verify tokens are stored
      final isLoggedIn = await httpClientService.isLoggedIn();
      expect(isLoggedIn, true);

      // Note: _getStoredToken is private, so we test through public methods
      expect(isLoggedIn, true);

      final storedRefreshToken = await httpClientService.getStoredRefreshToken();
      expect(storedRefreshToken, refreshToken);
    });

    test('should detect expired tokens', () async {
      // Store expired token
      await httpClientService.storeAuthTokens(
        'expired_token',
        'expired_refresh_token',
        expiryTime: DateTime.now().subtract(const Duration(hours: 1)),
      );

      // Check if token is expired
      final isExpired = await httpClientService.isTokenExpired();
      expect(isExpired, true);
    });

    test('should clear all authentication data on logout', () async {
      // Store some authentication data
      await httpClientService.storeAuthTokens(
        'test_token',
        'test_refresh_token',
      );

      // Create and store user data
      final testUser = User(
        id: 'test_id',
        mssv: 'test_mssv',
        hoVaTen: 'Test User',
        gioiTinh: true,
        email: 'test@example.com',
        quyen: UserRole.sinhVien,
        ngayTao: DateTime.now(),
        ngayCapNhat: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConfig.userDataKey, testUser.toJson().toString());

      // Verify data is stored
      expect(await httpClientService.isLoggedIn(), true);

      // Perform logout
      await authService.logout();

      // Verify all data is cleared
      expect(await httpClientService.isLoggedIn(), false);
      expect(prefs.getString(ApiConfig.userDataKey), null);
      expect(prefs.getString(ApiConfig.tokenKey), null);
      expect(prefs.getString(ApiConfig.refreshTokenKey), null);
    });

    test('should preserve theme settings after logout', () async {
      // Set theme preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', true);

      // Store authentication data
      await httpClientService.storeAuthTokens('token', 'refresh_token');

      // Perform logout
      await authService.logout();

      // Verify theme setting is preserved
      expect(prefs.getBool('isDarkMode'), true);
    });

    test('should validate session correctly', () async {
      // Test with no stored data
      final user1 = await authService.validateSession();
      expect(user1, null);

      // Test with valid session
      await httpClientService.storeAuthTokens(
        'valid_token',
        'valid_refresh_token',
        expiryTime: DateTime.now().add(const Duration(hours: 1)),
      );

      // Store user data
      final testUser = User(
        id: 'test_id',
        mssv: 'test_mssv',
        hoVaTen: 'Test User',
        gioiTinh: true,
        email: 'test@example.com',
        quyen: UserRole.sinhVien,
        ngayTao: DateTime.now(),
        ngayCapNhat: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', testUser.toJson().toString());

      // Note: This test would require mocking the API call for full validation
      // For now, we test the basic logic
    });

    test('should handle basic authentication flow', () async {
      // This test verifies the basic authentication components work together
      // In a real scenario, this would test the full login flow with API mocking

      expect(await httpClientService.isLoggedIn(), false);

      // Store tokens to simulate successful login
      await httpClientService.storeAuthTokens(
        'test_token',
        'test_refresh_token',
      );

      expect(await httpClientService.isLoggedIn(), true);
    });
  });
}
