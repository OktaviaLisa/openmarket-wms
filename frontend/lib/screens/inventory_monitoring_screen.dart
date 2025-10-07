import 'package:flutter/material.dart';

class InventoryMonitoringScreen extends StatefulWidget {
  const InventoryMonitoringScreen({super.key});

  @override
  State<InventoryMonitoringScreen> createState() => _InventoryMonitoringScreenState();
}

class _InventoryMonitoringScreenState extends State<InventoryMonitoringScreen> {
  final List<Map<String, dynamic>> _inventory = [
    {
      'product_name': 'Laptop Dell XPS 13',
      'current_stock': 48,
      'min_stock': 10,
      'status': 'NORMAL',
      'location': 'Gudang A',
      'last_updated': '2024-01-15 10:30',
    },
    {
      'product_name': 'Mouse Wireless',
      'current_stock': 8,
      'min_stock': 10,
      'status': 'LOW_STOCK',
      'location': 'Gudang B',
      'last_updated': '2024-01-16 14:20',
    },
    {
      'product_name': 'Keyboard Mechanical',
      'current_stock': 3,
      'min_stock': 10,
      'status': 'CRITICAL',
      'location': 'Gudang A',
      'last_updated': '2024-01-16 16:45',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Inventory'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _inventory.length,
              itemBuilder: (context, index) {
                final item = _inventory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(item['status']).withAlpha(50),
                      child: Icon(
                        _getStatusIcon(item['status']),
                        color: _getStatusColor(item['status']),
                      ),
                    ),
                    title: Text(item['product_name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stok: ${item['current_stock']} unit'),
                        Text('Lokasi: ${item['location']}'),
                        Text('Update: ${item['last_updated']}'),
                      ],
                    ),
                    trailing: _buildStatusChip(item['status']),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    int normalCount = _inventory.where((item) => item['status'] == 'NORMAL').length;
    int lowStockCount = _inventory.where((item) => item['status'] == 'LOW_STOCK').length;
    int criticalCount = _inventory.where((item) => item['status'] == 'CRITICAL').length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard('Normal', normalCount, Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard('Low Stock', lowStockCount, Colors.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard('Critical', criticalCount, Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'NORMAL': return Colors.green;
      case 'LOW_STOCK': return Colors.orange;
      case 'CRITICAL': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'NORMAL': return Icons.check_circle;
      case 'LOW_STOCK': return Icons.warning;
      case 'CRITICAL': return Icons.error;
      default: return Icons.help;
    }
  }

  Widget _buildStatusChip(String status) {
    Color color = _getStatusColor(status);
    return Chip(
      label: Text(status.replaceAll('_', ' '), 
                  style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withAlpha(25),
    );
  }
}