import 'package:flutter/material.dart';
import '../config/network_config.dart';
import '../services/ip_discovery_service.dart';

class NetworkTestScreen extends StatefulWidget {
  const NetworkTestScreen({super.key});

  @override
  State<NetworkTestScreen> createState() => _NetworkTestScreenState();
}

class _NetworkTestScreenState extends State<NetworkTestScreen> {
  String _status = 'Ready to test';
  String _discoveredUrl = '';
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _testNetworkDiscovery() async {
    setState(() {
      _status = 'Testing...';
      _logs.clear();
    });

    _addLog('Starting network discovery test');
    
    try {
      // Test IP discovery service
      _addLog('Testing IP Discovery Service...');
      final discoveredIP = await IpDiscoveryService.discoverBackendIP();
      if (discoveredIP != null) {
        _addLog('✅ IP Discovery found: $discoveredIP');
      } else {
        _addLog('❌ IP Discovery failed');
      }

      // Test NetworkConfig
      _addLog('Testing NetworkConfig...');
      final backendUrl = await NetworkConfig.discoverBackend();
      _addLog('✅ NetworkConfig result: $backendUrl');
      
      setState(() {
        _discoveredUrl = backendUrl;
        _status = 'Test completed';
      });
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _status = 'Test failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Test'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: $_status', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_discoveredUrl.isNotEmpty)
                      Text('Discovered URL: $_discoveredUrl', style: const TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testNetworkDiscovery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Test Network Discovery'),
            ),
            const SizedBox(height: 16),
            const Text('Logs:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _logs[index],
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}