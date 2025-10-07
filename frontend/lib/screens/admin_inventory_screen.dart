import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> inventory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    try {
      final inventoryData = await _apiService.getInventory();
      setState(() {
        inventory = List<Map<String, dynamic>>.from(inventoryData);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading inventory: $e')),
        );
      }
    }
  }

  Map<String, dynamic> _getStockStatus(int quantity, int minStock) {
    if (quantity <= minStock) {
      return {'label': 'Low Stock', 'color': Colors.red};
    } else if (quantity <= minStock * 2) {
      return {'label': 'Medium Stock', 'color': Colors.orange};
    } else {
      return {'label': 'Good Stock', 'color': Colors.green};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInventory,
              child: inventory.isEmpty
                  ? const Center(child: Text('No inventory found'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Product')),
                            DataColumn(label: Text('SKU')),
                            DataColumn(label: Text('Location')),
                            DataColumn(label: Text('Quantity')),
                            DataColumn(label: Text('Min Stock')),
                            DataColumn(label: Text('Max Stock')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: inventory.map((item) {
                            final status = _getStockStatus(
                              item['quantity'] ?? 0,
                              item['min_stock'] ?? 0,
                            );
                            
                            return DataRow(
                              cells: [
                                DataCell(Text(item['product_name'] ?? '')),
                                DataCell(Text(item['product_sku'] ?? '')),
                                DataCell(Text(item['location'] ?? '')),
                                DataCell(Text('${item['quantity'] ?? 0}')),
                                DataCell(Text('${item['min_stock'] ?? 0}')),
                                DataCell(Text('${item['max_stock'] ?? 0}')),
                                DataCell(
                                  Chip(
                                    label: Text(
                                      status['label'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: status['color'],
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
    );
  }
}