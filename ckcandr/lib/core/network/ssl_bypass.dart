/// SSL Certificate Bypass Configuration
/// 
/// This file provides utilities to bypass SSL certificate validation
/// for development environments where self-signed certificates are used.
library;

import 'dart:io';
import 'package:flutter/foundation.dart';

class SSLBypass {
  /// Force bypass all SSL certificate validation
  /// This is ONLY for development - NEVER use in production
  static void configureHttpOverrides() {
    // SỬA: Bỏ điều kiện kDebugMode để hoạt động cả trong release mode
    // Override global HTTP client behavior
    HttpOverrides.global = _DevHttpOverrides();
    debugPrint('🔒 SSL Certificate bypass enabled for development');
  }
  
  /// Create HttpClient with all SSL verification disabled
  static HttpClient createBypassClient() {
    final client = HttpClient()
      // Bypass ALL certificate validation
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        debugPrint('🔒 BYPASSING SSL for $host:$port');
        debugPrint('   Certificate Subject: ${cert.subject}');
        debugPrint('   Certificate Issuer: ${cert.issuer}');
        debugPrint('   Valid From: ${cert.startValidity}');
        debugPrint('   Valid To: ${cert.endValidity}');
        return true; // Always accept any certificate
      }
      // Connection timeout - phù hợp với server
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 30)
      // Additional settings to avoid SSL issues
      ..autoUncompress = true
      ..userAgent = 'Flutter-CKC-Quiz-Development/1.0';
    
    return client;
  }
}

/// Custom HttpOverrides to bypass SSL globally
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      // FORCE bypass all certificate validation
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // SỬA: Bỏ điều kiện kDebugMode để hoạt động cả trong release mode
        debugPrint('🔒 Global SSL bypass for $host:$port');
        debugPrint('   Certificate: ${cert.subject}');
        return true; // Always accept in development
      }
      // Connection settings - phù hợp với server
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 30)
      ..autoUncompress = true;
  }
}
