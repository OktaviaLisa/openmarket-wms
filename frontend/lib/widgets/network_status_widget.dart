import 'package:flutter/material.dart';
import '../config/api_config.dart';

class NetworkStatusWidget extends StatefulWidget {
  @override
  _NetworkStatusWidgetState createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget> {
  String? _currentUrl;
  Map<String, String?> _networkInfo = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNetworkInfo();
  }

  Future<void> _loadNetworkInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = await ApiConfig.getAutoDetectedBaseUrl();
      final info = await ApiConfig.getCurrentNetworkInfo();
      
      setState(() {
        _currentUrl = url;
        _networkInfo = info;
      });
    } catch (e) {
      print('Error loading network info: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshNetwork() async {
    await ApiConfig.resetCache();
    await _loadNetworkInfo();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Network refreshed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.network_check, color: Colors.blue),
                SizedBox(width: 8),
                Text('Network Status', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _refreshNetwork,
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else ...[
              _buildInfoRow('Backend URL', _currentUrl ?? 'Not detected'),
              _buildInfoRow('WiFi Name', _networkInfo['wifiName'] ?? 'Unknown'),
              _buildInfoRow('Device IP', _networkInfo['wifiIP'] ?? 'Unknown'),
              _buildInfoRow('Gateway IP', _networkInfo['wifiGateway'] ?? 'Unknown'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}