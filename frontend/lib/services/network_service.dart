import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/network_config.dart';
import 'network_detector.dart';

class NetworkService {
  static const String _lastWorkingHostKey = 'last_working_host';
  static const String _customHostsKey = 'custom_hosts';
  
  static Future<void> saveLastWorkingHost(String host) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastWorkingHostKey, host);
  }
  
  static Future<String?> getLastWorkingHost() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastWorkingHostKey);
  }
  
  static Future<void> saveCustomHosts(List<String> hosts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_customHostsKey, hosts);
  }
  
  static Future<List<String>> getCustomHosts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_customHostsKey) ?? [];
  }
  
  static Future<bool> testConnection(String host) async {
    try {
      final testUrl = 'http://$host:${NetworkConfig.port}${NetworkConfig.apiPath}/health';
      final response = await http.get(
        Uri.parse(testUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(NetworkConfig.connectionTimeout);
      
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      return false;
    }
  }
  
  // Generate IP addresses for common network ranges
  static List<String> generateNetworkIPs() {
    List<String> ips = [];
    
    // Common network ranges
    List<String> networkPrefixes = [
      '192.168.1.',   // Most common home network
      '192.168.0.',   // Alternative home network
      '192.168.43.',  // Mobile hotspot
      '192.168.137.', // Windows hotspot
      '10.0.0.',      // Some routers
    ];
    
    for (String prefix in networkPrefixes) {
      // Try common IP ranges (1-254)
      for (int i = 1; i <= 254; i++) {
        ips.add('$prefix$i');
      }
    }
    
    return ips;
  }
  
  static Future<String?> findWorkingHost() async {
    // Try last working host first
    final lastHost = await getLastWorkingHost();
    if (lastHost != null && await testConnection(lastHost)) {
      return lastHost;
    }
    
    // Quick test for most common IPs
    final quickResult = await NetworkDetector.quickTest();
    if (quickResult != null) {
      await saveLastWorkingHost(quickResult);
      return quickResult;
    }
    
    // Try custom hosts
    final customHosts = await getCustomHosts();
    for (String host in customHosts) {
      if (await testConnection(host)) {
        await saveLastWorkingHost(host);
        return host;
      }
    }
    
    // Try predefined hosts
    final predefinedHosts = [
      '192.168.1.100', '192.168.1.101',
      '192.168.0.100', '192.168.0.101',
      '192.168.43.1', '192.168.137.1',
      '192.168.1.133',
      'localhost'
    ];
    for (String host in predefinedHosts) {
      if (await testConnection(host)) {
        await saveLastWorkingHost(host);
        return host;
      }
    }
    
    // Network detection as last resort
    final detectedHost = await NetworkDetector.detectBackendInNetwork();
    if (detectedHost != null) {
      await saveLastWorkingHost(detectedHost);
      return detectedHost;
    }
    
    return null;
  }
  
  static Future<void> addCustomHost(String host) async {
    final customHosts = await getCustomHosts();
    if (!customHosts.contains(host)) {
      customHosts.insert(0, host);
      await saveCustomHosts(customHosts);
    }
  }
  
  static Future<void> removeCustomHost(String host) async {
    final customHosts = await getCustomHosts();
    customHosts.remove(host);
    await saveCustomHosts(customHosts);
  }
  
  // Quick scan for backend in current network
  static Future<String?> quickScan() async {
    // Try most common IPs first
    List<String> quickIPs = [
      '192.168.1.100', '192.168.1.101', '192.168.1.102',
      '192.168.0.100', '192.168.0.101', '192.168.0.102',
      '192.168.43.1', '192.168.137.1', '192.168.1.133',
    ];
    
    for (String ip in quickIPs) {
      if (await testConnection(ip)) {
        await saveLastWorkingHost(ip);
        return ip;
      }
    }
    
    return null;
  }
  
  // Reset all cached data
  static Future<void> resetCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastWorkingHostKey);
  }
}