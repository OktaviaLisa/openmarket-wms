import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class NetworkDebug {
  /// Test semua koneksi: primary + fallback URLs
  static Future<Map<String, dynamic>> testAllConnections() async {
    Map<String, dynamic> results = {};

    // Ambil primary URL secara async
    String baseUrl = await ApiConfig.getAutoDetectedBaseUrl();
    results['primary'] = await _testUrl(baseUrl);

    // Test fallback URLs
    final fallbackUrls = [
      'http://localhost:8000/api',
      'http://192.168.1.100:8000/api',
      'http://192.168.0.100:8000/api',
      'http://192.168.1.133:8000/api'
    ];
    
    for (int i = 0; i < fallbackUrls.length; i++) {
      String url = fallbackUrls[i];
      results['fallback_$i'] = await _testUrl(url);
    }

    return results;
  }

  /// Helper untuk mengetes satu URL
  static Future<Map<String, dynamic>> _testUrl(String baseUrl) async {
    try {
      final stopwatch = Stopwatch()..start();

      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      stopwatch.stop();

      return {
        'url': baseUrl,
        'success': response.statusCode == 200,
        'status_code': response.statusCode,
        'response_time_ms': stopwatch.elapsedMilliseconds,
        'response_body': response.body.length > 100
            ? '${response.body.substring(0, 100)}...'
            : response.body,
      };
    } catch (e) {
      return {
        'url': baseUrl,
        'success': false,
        'error': e.toString(),
        'error_type': e.runtimeType.toString(),
      };
    }
  }

  /// Dapatkan info jaringan dalam bentuk string
  static Future<String> getNetworkInfo() async {
    String baseUrl = await ApiConfig.getAutoDetectedBaseUrl();
    final networkInfo = await ApiConfig.getCurrentNetworkInfo();

    return '''
Platform: ${Platform.operatingSystem}
Primary URL: $baseUrl
WiFi Name: ${networkInfo['wifiName'] ?? 'Unknown'}
Device IP: ${networkInfo['wifiIP'] ?? 'Unknown'}
Gateway IP: ${networkInfo['wifiGateway'] ?? 'Unknown'}
''';
  }
}
