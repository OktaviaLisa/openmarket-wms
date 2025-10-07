import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import '../config/network_config.dart';

class NetworkDetector {
  static final NetworkInfo _networkInfo = NetworkInfo();
  
  // Auto-detect backend URL berdasarkan jaringan saat ini
  static Future<String?> detectBackendURL() async {
    try {
      // 1. Coba dapatkan gateway IP
      final gatewayIP = await _networkInfo.getWifiGatewayIP();
      if (gatewayIP != null) {
        final gatewayHost = await _testBackendAtIP(gatewayIP);
        if (gatewayHost != null) return gatewayHost;
      }
      
      // 2. Coba dapatkan IP perangkat dan scan subnet
      final deviceIP = await _networkInfo.getWifiIP();
      if (deviceIP != null) {
        final subnetHost = await _scanSubnet(deviceIP);
        if (subnetHost != null) return subnetHost;
      }
      
      // 3. Quick test IP umum
      final quickHost = await quickTest();
      if (quickHost != null) return quickHost;
      
      // 4. Fallback ke localhost
      final localhostTest = await _testBackendAtIP('localhost');
      if (localhostTest != null) {
        return 'localhost';
      }
      
    } catch (e) {
      // Network detection error - silent fail
    }
    
    return null;
  }
  
  // Test backend di IP tertentu
  static Future<String?> _testBackendAtIP(String ip) async {
    try {
      final url = 'http://$ip:${NetworkConfig.port}${NetworkConfig.apiPath}/health';
      final response = await http.get(Uri.parse(url))
          .timeout(Duration(seconds: 2));
      
      if (response.statusCode == 200 || response.statusCode == 404) {
        return ip;
      }
    } catch (e) {
      // Ignore connection errors
    }
    return null;
  }
  
  // Scan subnet untuk mencari backend
  static Future<String?> _scanSubnet(String deviceIP) async {
    final parts = deviceIP.split('.');
    if (parts.length != 4) return null;
    
    final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
    
    // Test IP umum di subnet ini
    final commonIPs = [1, 100, 101, 102, 177, 200, 254];
    
    for (int lastOctet in commonIPs) {
      final testIP = '$subnet.$lastOctet';
      final result = await _testBackendAtIP(testIP);
      if (result != null) return result;
    }
    
    return null;
  }
  
  // Quick test untuk IP yang paling umum
  static Future<String?> quickTest() async {
    final commonIPs = [
      '192.168.1.100', '192.168.1.101',
      '192.168.0.100', '192.168.0.101', 
      '192.168.43.1', '192.168.137.1',
      '10.0.2.2'
    ];
    
    for (String ip in commonIPs) {
      final result = await _testBackendAtIP(ip);
      if (result != null) return result;
    }
    
    return null;
  }
  
  // Dapatkan info jaringan saat ini
  static Future<Map<String, String?>> getCurrentNetworkInfo() async {
    try {
      return {
        'wifiName': await _networkInfo.getWifiName(),
        'wifiIP': await _networkInfo.getWifiIP(),
        'wifiGateway': await _networkInfo.getWifiGatewayIP(),
        'wifiBSSID': await _networkInfo.getWifiBSSID(),
      };
    } catch (e) {
      return {};
    }
  }
  
  // Deteksi backend di jaringan dengan info lengkap
  static Future<String?> detectBackendInNetwork() async {
    return await detectBackendURL();
  }
}