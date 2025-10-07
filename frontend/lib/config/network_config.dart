import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/ip_discovery_service.dart';

class NetworkConfig {
  static const String primaryHostname = 'wms-backend.local';
  static const int port = 8000;
  static const String apiPath = '/api';
  static const Duration connectionTimeout = Duration(seconds: 2);
  
  static const List<String> fallbackHosts = [
    '10.0.2.2',         // Android emulator host
    '127.0.0.1',        // Localhost
    'localhost',        // Localhost hostname
    '10.201.153.231',   // Current laptop IP - PRIORITY
    '10.112.115.231',
    '172.20.141.174',
    '192.168.137.177',
    '192.168.1.134',
    '192.168.1.135',
    '192.168.1.136',
    '192.168.1.100',
    '192.168.1.101',
    '192.168.0.100', 
    '192.168.0.101',
    '10.0.0.100',
  ];
  
  static Future<String> discoverBackend() async {
    if (kIsWeb) {
      return 'http://localhost:$port/api';
    }
    
    print('🔍 NetworkConfig: Starting backend discovery...');
    
    // Try static list first (more reliable)
    for (String host in fallbackHosts) {
      print('🧪 NetworkConfig: Testing host: $host');
      if (await _testConnection(host, port)) {
        final url = 'http://$host:$port/api';
        print('✅ NetworkConfig: Found backend at: $url');
        return url;
      }
    }
    
    // Try smart IP discovery as backup
    print('🔄 NetworkConfig: Trying IP discovery...');
    final discoveredIP = await IpDiscoveryService.discoverBackendIP();
    if (discoveredIP != null) {
      final url = 'http://$discoveredIP:$port/api';
      print('✅ NetworkConfig: Using discovered IP: $url');
      return url;
    }
    
    // Force use first host as final fallback
    final finalFallback = 'http://${fallbackHosts.first}:$port/api';
    print('⚠️ NetworkConfig: Force using: $finalFallback');
    return finalFallback;
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
}