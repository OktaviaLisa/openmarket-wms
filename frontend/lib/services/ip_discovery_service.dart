import 'dart:io';
import 'package:http/http.dart' as http;

class IpDiscoveryService {
  static const int backendPort = 8000;
  static const Duration timeout = Duration(seconds: 2);
  
  // Generate possible IPs based on device's network
  static Future<List<String>> generatePossibleIPs() async {
    List<String> possibleIPs = [];
    
    try {
      // Get device's own IP to determine subnet
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            final deviceIP = addr.address;
            if (deviceIP.startsWith('192.168.') || deviceIP.startsWith('10.') || deviceIP.startsWith('172.')) {
              // Generate IPs in same subnet
              final subnet = _getSubnet(deviceIP);
              possibleIPs.addAll(_generateSubnetIPs(subnet));
              break;
            }
          }
        }
      }
    } catch (e) {
      print('Error getting network interfaces: $e');
    }
    
    // Add common IPs if subnet detection failed
    if (possibleIPs.isEmpty) {
      possibleIPs.addAll(_getCommonIPs());
    }
    
    return possibleIPs;
  }
  
  static String _getSubnet(String ip) {
    final parts = ip.split('.');
    if (parts.length >= 3) {
      return '${parts[0]}.${parts[1]}.${parts[2]}';
    }
    return '192.168.1';
  }
  
  static List<String> _generateSubnetIPs(String subnet) {
    List<String> ips = [];
    
    // Common host numbers for servers/laptops
    List<int> commonHosts = [
      1,    // Router/Gateway
      100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110,  // Common DHCP range
      133, 134, 135, 136, 137, 138, 139, 140,  // Around current IP
      200, 201, 202, 203, 204, 205,  // High range
      50, 51, 52, 53, 54, 55,  // Mid range
    ];
    
    for (int host in commonHosts) {
      ips.add('$subnet.$host');
    }
    
    return ips;
  }
  
  static List<String> _getCommonIPs() {
    return [
      '192.168.1.133', // Current known working IP - PRIORITY
      '192.168.1.134', '192.168.1.135', '192.168.1.136', // Nearby IPs
      '192.168.1.100', '192.168.1.101', '192.168.1.102', '192.168.1.1',
      '192.168.0.100', '192.168.0.101', '192.168.0.102', '192.168.0.1',
      '192.168.43.1', '192.168.43.100',  // Mobile hotspot
      '192.168.137.1', '192.168.137.100', // Windows hotspot
      '10.0.0.1', '10.0.0.100', '10.0.0.101',
      '172.16.0.1', '172.16.0.100',
    ];
  }
  
  static Future<String?> discoverBackendIP() async {
    final possibleIPs = await generatePossibleIPs();
    
    print('🔍 Scanning ${possibleIPs.length} possible IPs for backend...');
    print('📋 IPs to test: ${possibleIPs.take(10).join(", ")}...');
    
    // Test IPs sequentially for better debugging
    for (String ip in possibleIPs) {
      print('🧪 Testing: $ip');
      if (await _testIP(ip)) {
        print('✅ Found backend at: $ip');
        return ip;
      }
    }
    
    print('❌ No backend found in network scan');
    return null;
  }
  
  static Future<bool> _testIP(String ip) async {
    try {
      final response = await http.get(
        Uri.parse('http://$ip:$backendPort/api/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}