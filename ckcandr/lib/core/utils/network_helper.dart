import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ckcandr/core/config/api_config.dart';

/// Helper class for network connectivity and domain testing
class NetworkHelper {
  
  /// Test if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Internet connectivity test failed: $e');
      return false;
    }
  }

  /// Test specific domain connectivity
  static Future<bool> testDomainConnectivity(String domain) async {
    try {
      // Extract domain without port for DNS lookup
      final domainOnly = domain.split(':')[0];
      debugPrint('🔍 Testing domain connectivity: $domainOnly');
      
      final result = await InternetAddress.lookup(domainOnly);
      final isReachable = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (isReachable) {
        debugPrint('✅ Domain $domainOnly is reachable');
      } else {
        debugPrint('❌ Domain $domainOnly is not reachable');
      }
      
      return isReachable;
    } catch (e) {
      debugPrint('❌ Domain connectivity test failed for $domain: $e');
      return false;
    }
  }

  /// Test HTTP endpoint connectivity
  static Future<bool> testHttpEndpoint(String url) async {
    try {
      debugPrint('🔍 Testing HTTP endpoint: $url');
      
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      client.badCertificateCallback = (cert, host, port) => true; // Accept all certificates for testing
      
      try {
        final uri = Uri.parse(url);
        final request = await client.getUrl(uri);
        final response = await request.close();
        await response.drain();
        client.close();
        
        final isSuccess = response.statusCode >= 200 && response.statusCode < 500;
        debugPrint('✅ HTTP endpoint test result: ${response.statusCode} - ${isSuccess ? 'Success' : 'Failed'}');
        return isSuccess;
      } catch (e) {
        debugPrint('❌ HTTP endpoint test failed: $e');
        client.close();
        return false;
      }
    } catch (e) {
      debugPrint('❌ HTTP endpoint test error: $e');
      return false;
    }
  }

  /// Find working API endpoint from fallback list
  static Future<String?> findWorkingApiEndpoint() async {
    debugPrint('🔍 Finding working API endpoint...');
    
    // First check internet connectivity
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      debugPrint('❌ No internet connection detected');
      return null;
    }

    // Test each fallback domain
    for (String domain in ApiConfig.fallbackDomains) {
      try {
        // Test domain connectivity first
        final domainReachable = await testDomainConnectivity(domain);
        if (!domainReachable) {
          continue;
        }

        // Test HTTP endpoint
        final testUrl = ApiConfig.useHttps 
            ? 'https://$domain/api/Auth/validate-token'
            : 'http://$domain/api/Auth/validate-token';
            
        final endpointWorks = await testHttpEndpoint(testUrl);
        if (endpointWorks) {
          final baseUrl = ApiConfig.useHttps ? 'https://$domain' : 'http://$domain';
          debugPrint('✅ Found working API endpoint: $baseUrl');
          return baseUrl;
        }
      } catch (e) {
        debugPrint('❌ Error testing domain $domain: $e');
      }
    }

    debugPrint('❌ No working API endpoint found');
    return null;
  }

  /// Get network diagnostics info
  static Future<Map<String, dynamic>> getNetworkDiagnostics() async {
    final diagnostics = <String, dynamic>{};
    
    try {
      // Internet connectivity
      diagnostics['hasInternet'] = await hasInternetConnection();
      
      // Test each fallback domain
      final domainTests = <String, bool>{};
      for (String domain in ApiConfig.fallbackDomains) {
        domainTests[domain] = await testDomainConnectivity(domain);
      }
      diagnostics['domainTests'] = domainTests;
      
      // Current API config
      diagnostics['currentConfig'] = {
        'useHttps': ApiConfig.useHttps,
        'serverDomain': ApiConfig.serverDomain,
        'baseUrl': ApiConfig.baseUrl,
      };
      
      // Working endpoint
      diagnostics['workingEndpoint'] = await findWorkingApiEndpoint();
      
    } catch (e) {
      diagnostics['error'] = e.toString();
    }
    
    return diagnostics;
  }

  /// Print network diagnostics to console
  static Future<void> printNetworkDiagnostics() async {
    debugPrint('🔍 === NETWORK DIAGNOSTICS ===');
    
    final diagnostics = await getNetworkDiagnostics();
    
    debugPrint('📶 Internet: ${diagnostics['hasInternet'] ? '✅ Connected' : '❌ No connection'}');
    debugPrint('⚙️ Config: ${diagnostics['currentConfig']}');
    
    final domainTests = diagnostics['domainTests'] as Map<String, bool>?;
    if (domainTests != null) {
      debugPrint('🌐 Domain Tests:');
      domainTests.forEach((domain, result) {
        debugPrint('   $domain: ${result ? '✅' : '❌'}');
      });
    }
    
    final workingEndpoint = diagnostics['workingEndpoint'];
    debugPrint('🎯 Working Endpoint: ${workingEndpoint ?? '❌ None found'}');
    
    if (diagnostics['error'] != null) {
      debugPrint('❌ Error: ${diagnostics['error']}');
    }
    
    debugPrint('🔍 === END DIAGNOSTICS ===');
  }
}
