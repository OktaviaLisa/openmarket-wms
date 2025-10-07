import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'widgets/network_status_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WMS Auto Network',
      home: AutoNetworkDemo(),
    );
  }
}

class AutoNetworkDemo extends StatefulWidget {
  @override
  _AutoNetworkDemoState createState() => _AutoNetworkDemoState();
}

class _AutoNetworkDemoState extends State<AutoNetworkDemo> {
  final ApiService _apiService = ApiService();
  String _status = 'Ready';
  List<dynamic> _data = [];

  Future<void> _testConnection() async {
    setState(() {
      _status = 'Testing connection...';
    });

    try {
      final inventory = await _apiService.getInventory();
      setState(() {
        _status = 'Connected! Found ${inventory.length} items';
        _data = inventory;
      });
    } catch (e) {
      setState(() {
        _status = 'Connection failed: $e';
        _data = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto Network Detection'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            NetworkStatusWidget(),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('API Test', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text(_status),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _testConnection,
                      child: Text('Test API Connection'),
                    ),
                  ],
                ),
              ),
            ),
            if (_data.isNotEmpty) ...[
              SizedBox(height: 20),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Data Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _data.length,
                            itemBuilder: (context, index) {
                              final item = _data[index];
                              return ListTile(
                                title: Text(item['product_name'] ?? 'Unknown'),
                                subtitle: Text('Quantity: ${item['quantity'] ?? 0}'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}