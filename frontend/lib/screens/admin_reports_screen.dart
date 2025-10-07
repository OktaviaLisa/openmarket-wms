import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> stockMovements = [];
  List<Map<String, dynamic>> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final movements = await _apiService.getStockMovements();
      
      // Get latest 10 movements for table
      final recentMovements = movements.take(10).toList();
      
      // Prepare chart data - group by date
      final movementsByDate = <String, Map<String, int>>{};
      for (var movement in movements) {
        final date = DateTime.parse(movement['created_at']).toLocal();
        final dateStr = '${date.day}/${date.month}';
        
        if (!movementsByDate.containsKey(dateStr)) {
          movementsByDate[dateStr] = {'in': 0, 'out': 0};
        }
        
        if (movement['movement_type'] == 'IN') {
          movementsByDate[dateStr]!['in'] = (movementsByDate[dateStr]!['in'] ?? 0) + (movement['quantity'] as int);
        } else if (movement['movement_type'] == 'OUT') {
          movementsByDate[dateStr]!['out'] = (movementsByDate[dateStr]!['out'] ?? 0) + (movement['quantity'] as int);
        }
      }
      
      // Get last 7 days
      final chartDataList = movementsByDate.values.toList();
      chartDataList.sort((a, b) => (a['date'] as String? ?? '').compareTo(b['date'] as String? ?? ''));
      
      setState(() {
        stockMovements = List<Map<String, dynamic>>.from(recentMovements);
        chartData = chartDataList.take(7).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReports,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChart(),
                    const SizedBox(height: 24),
                    _buildMovementsTable(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildChart() {
    if (chartData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No chart data available')),
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
              'Stock Movement Trends (Last 7 Days)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData:  FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles:  AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < chartData.length) {
                            return Text(chartData[index]['date'] ?? '');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), (entry.value['in'] ?? 0).toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData:  FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), (entry.value['out'] ?? 0).toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData:  FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Stock In', Colors.blue),
                const SizedBox(width: 20),
                _buildLegendItem('Stock Out', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildMovementsTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Stock Movements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            stockMovements.isEmpty
                ? const Center(child: Text('No movements found'))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Product')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Reference')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('User')),
                      ],
                      rows: stockMovements.map((movement) {
                        final date = DateTime.parse(movement['created_at']).toLocal();
                        return DataRow(
                          cells: [
                            DataCell(Text(movement['product_name'] ?? '')),
                            DataCell(
                              Chip(
                                label: Text(
                                  movement['movement_type'] ?? '',
                                  style: const TextStyle(fontSize: 10, color: Colors.white),
                                ),
                                backgroundColor: movement['movement_type'] == 'IN' 
                                    ? Colors.green 
                                    : Colors.red,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            DataCell(Text('${movement['quantity'] ?? 0}')),
                            DataCell(Text(movement['reference'] ?? '')),
                            DataCell(Text('${date.day}/${date.month}/${date.year}')),
                            DataCell(Text(movement['created_by_username'] ?? '')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}