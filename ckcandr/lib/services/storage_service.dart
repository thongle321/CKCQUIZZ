/// Storage Service for CKC Quiz Application
/// 
/// This service handles local storage operations including
/// user data, authentication tokens, and app preferences.

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/core/config/api_config.dart';

/// Storage service for managing local data
class StorageService {
  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Initialize the storage service
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  /// Ensure storage is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  /// Save user data
  Future<void> saveUser(User user) async {
    await _ensureInitialized();
    final userJson = json.encode(user.toJson());
    await _prefs.setString(ApiConfig.userDataKey, userJson);
  }

  /// Get saved user data
  Future<User?> getUser() async {
    await _ensureInitialized();
    final userJson = _prefs.getString(ApiConfig.userDataKey);
    if (userJson != null) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        // If error parsing user data, clear it
        await clearUser();
        return null;
      }
    }
    return null;
  }

  /// Clear user data
  Future<void> clearUser() async {
    await _ensureInitialized();
    await _prefs.remove(ApiConfig.userDataKey);
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _ensureInitialized();
    await _prefs.setString(ApiConfig.tokenKey, token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    await _ensureInitialized();
    return _prefs.getString(ApiConfig.tokenKey);
  }

  /// Clear authentication token
  Future<void> clearToken() async {
    await _ensureInitialized();
    await _prefs.remove(ApiConfig.tokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    await _ensureInitialized();
    await _prefs.setString(ApiConfig.refreshTokenKey, refreshToken);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    await _ensureInitialized();
    return _prefs.getString(ApiConfig.refreshTokenKey);
  }

  /// Clear refresh token
  Future<void> clearRefreshToken() async {
    await _ensureInitialized();
    await _prefs.remove(ApiConfig.refreshTokenKey);
  }

  /// Save login status
  Future<void> saveLoginStatus(bool isLoggedIn) async {
    await _ensureInitialized();
    await _prefs.setBool(ApiConfig.isLoggedInKey, isLoggedIn);
  }

  /// Get login status
  Future<bool> getLoginStatus() async {
    await _ensureInitialized();
    return _prefs.getBool(ApiConfig.isLoggedInKey) ?? false;
  }

  /// Save token expiry time
  Future<void> saveTokenExpiry(DateTime expiry) async {
    await _ensureInitialized();
    await _prefs.setString(ApiConfig.tokenExpiryKey, expiry.toIso8601String());
  }

  /// Get token expiry time
  Future<DateTime?> getTokenExpiry() async {
    await _ensureInitialized();
    final expiryString = _prefs.getString(ApiConfig.tokenExpiryKey);
    if (expiryString != null) {
      try {
        return DateTime.parse(expiryString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Check if token is expired
  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  /// Save last login time
  Future<void> saveLastLogin(DateTime lastLogin) async {
    await _ensureInitialized();
    await _prefs.setString(ApiConfig.lastLoginKey, lastLogin.toIso8601String());
  }

  /// Get last login time
  Future<DateTime?> getLastLogin() async {
    await _ensureInitialized();
    final lastLoginString = _prefs.getString(ApiConfig.lastLoginKey);
    if (lastLoginString != null) {
      try {
        return DateTime.parse(lastLoginString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Save user roles
  Future<void> saveUserRoles(List<String> roles) async {
    await _ensureInitialized();
    await _prefs.setStringList(ApiConfig.userRolesKey, roles);
  }

  /// Get user roles
  Future<List<String>> getUserRoles() async {
    await _ensureInitialized();
    return _prefs.getStringList(ApiConfig.userRolesKey) ?? [];
  }

  /// Clear all user-related data
  Future<void> clearAllUserData() async {
    await _ensureInitialized();
    await Future.wait([
      clearUser(),
      clearToken(),
      clearRefreshToken(),
      _prefs.remove(ApiConfig.isLoggedInKey),
      _prefs.remove(ApiConfig.tokenExpiryKey),
      _prefs.remove(ApiConfig.lastLoginKey),
      _prefs.remove(ApiConfig.userRolesKey),
    ]);
  }

  /// Save generic string value
  Future<void> saveString(String key, String value) async {
    await _ensureInitialized();
    await _prefs.setString(key, value);
  }

  /// Get generic string value
  Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _prefs.getString(key);
  }

  /// Save generic boolean value
  Future<void> saveBool(String key, bool value) async {
    await _ensureInitialized();
    await _prefs.setBool(key, value);
  }

  /// Get generic boolean value
  Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    return _prefs.getBool(key);
  }

  /// Save generic integer value
  Future<void> saveInt(String key, int value) async {
    await _ensureInitialized();
    await _prefs.setInt(key, value);
  }

  /// Get generic integer value
  Future<int?> getInt(String key) async {
    await _ensureInitialized();
    return _prefs.getInt(key);
  }

  /// Remove specific key
  Future<void> remove(String key) async {
    await _ensureInitialized();
    await _prefs.remove(key);
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return _prefs.containsKey(key);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _prefs.clear();
  }
}

/// Provider for storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
