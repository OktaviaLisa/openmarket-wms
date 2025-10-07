import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> stats = {
    'totalProducts': 0,
    'totalInventory': 0,
    'lowStock': 0,
    'recentMovements': 0
  };
  List<Map<String, dynamic>> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final products = await _apiService.getProducts();
      final inventory = await _apiService.getInventory();
      final movements = await _apiService.getStockMovements();

      final totalInventory = inventory.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
      final lowStock = inventory.where((item) => item['quantity'] <= (item['min_stock'] ?? 0)).length;

      // Category data for chart
      final categoryData = <String, int>{};
      for (var product in products) {
        final category = product['category_name'] ?? 'Uncategorized';
        categoryData[category] = (categoryData[category] ?? 0) + 1;
      }

      setState(() {
        stats = {
          'totalProducts': products.length,
          'totalInventory': totalInventory,
          'lowStock': lowStock,
          'recentMovements': movements.length
        };
        chartData = categoryData.entries.map((e) => {'name': e.key, 'value': e.value}).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCards(),
                    const SizedBox(height: 24),
                    _buildChart(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: crossAxisCount == 4 ? 1.2 : 1.5,
          children: [
            _buildStatCard('Products', stats['totalProducts'].toString(), Icons.inventory, Colors.blue),
            _buildStatCard('Inventory', stats['totalInventory'].toString(), Icons.warehouse, Colors.green),
            _buildStatCard('Low Stock', stats['lowStock'].toString(), Icons.warning, Colors.orange),
            _buildStatCard('Movements', stats['recentMovements'].toString(), Icons.trending_up, Colors.purple),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              child: Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (chartData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No data available')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Products by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final chartSize = constraints.maxWidth > 400 ? 200.0 : 150.0;
                final radius = constraints.maxWidth > 400 ? 60.0 : 45.0;
                return SizedBox(
                  height: chartSize,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 20,
                      sections: chartData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: data['value'].toDouble(),
                          title: data['value'].toString(),
                          radius: radius,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}