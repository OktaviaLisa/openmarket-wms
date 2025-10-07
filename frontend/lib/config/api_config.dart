import 'dart:io';
import 'package:flutter/foundation.dart';
import 'network_config.dart';

class ApiConfig {
  static String? _cachedBaseUrl;

  static Future<String> getAutoDetectedBaseUrl() async {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    
    // For Android emulator, use 10.0.2.2 to access host machine
    if (Platform.isAndroid) {
      // Try emulator host first
      if (await _testConnection('10.0.2.2', 8000)) {
        return 'http://10.0.2.2:8000/api';
      }
    }

    if (_cachedBaseUrl != null) {
      print('🔧 ApiConfig: Using cached URL: $_cachedBaseUrl');
      return _cachedBaseUrl!;
    }

    _cachedBaseUrl = await NetworkConfig.discoverBackend();
    print('🔧 ApiConfig: Discovered URL: $_cachedBaseUrl');
    return _cachedBaseUrl!;
  }
  
  static Future<bool> _testConnection(String host, int port) async {
    try {
      final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 2));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> resetCache() async {
    _cachedBaseUrl = null;
    print('🔧 ApiConfig: Cache reset');
  }
}
