import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InventoryMonitoringScreen extends StatefulWidget {
  const InventoryMonitoringScreen({super.key});

  @override
  State<InventoryMonitoringScreen> createState() => _InventoryMonitoringScreenState();
}

class _InventoryMonitoringScreenState extends State<InventoryMonitoringScreen> {
  List<Map<String, dynamic>> _inventory = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);
    try {
      final inventory = await _apiService.getInventory();
      setState(() {
        _inventory = inventory.map((item) {
          final quantity = item['quantity'] ?? 0;
          final minStock = item['min_stock'] ?? 10;
          String status;
          if (quantity <= 0) {
            status = 'CRITICAL';
          } else if (quantity <= minStock) {
            status = 'LOW_STOCK';
          } else {
            status = 'NORMAL';
          }
          return {
            'product_name': item['product_name'] ?? 'Unknown',
            'current_stock': quantity,
            'min_stock': minStock,
            'status': status,
            'location': item['location'] ?? 'Unknown',
            'last_updated': item['updated_at'] ?? 'Unknown',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading inventory: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Inventory'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadInventory,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inventory.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Tidak ada data inventory', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadInventory,
                  child: Column(
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