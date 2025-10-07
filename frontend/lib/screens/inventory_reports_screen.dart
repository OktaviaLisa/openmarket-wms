import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InventoryReportsScreen extends StatefulWidget {
  const InventoryReportsScreen({super.key});

  @override
  State<InventoryReportsScreen> createState() => _InventoryReportsScreenState();
}

class _InventoryReportsScreenState extends State<InventoryReportsScreen> {
  String _selectedReport = 'stock_opname';

  final Map<String, String> _reportTypes = {
    'stock_opname': 'Laporan Stock Opname',
    'stock_movement': 'Laporan Stock Movement',
    'reception': 'Laporan Penerimaan',
    'dispatch': 'Laporan Pengeluaran',
    'returns': 'Laporan Pengembalian',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Inventory'),
        backgroundColor: Colors.cyan[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildReportSelector(),
          Expanded(child: _buildReportContent()),
        ],
      ),
    );
  }

  Widget _buildReportSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Pilih Jenis Laporan',
          border: OutlineInputBorder(),
        ),
        items: _reportTypes.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (value) => setState(() => _selectedReport = value!),
      ),
    );
  }

  Widget _buildReportContent() {
    switch (_selectedReport) {
      case 'stock_opname':
        return _buildStockOpnameReport();
      case 'stock_movement':
        return _buildStockMovementReport();
      case 'reception':
        return _buildReceptionReport();
      case 'dispatch':
        return _buildDispatchReport();
      case 'returns':
        return _buildReturnsReport();
      default:
        return const Center(child: Text('Pilih jenis laporan'));
    }
  }

  Widget _buildStockOpnameReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard('Total Opname', '15', Colors.blue),
          const SizedBox(height: 16),
          _buildChart(),
          const SizedBox(height: 16),
          _buildDataTable([
            ['Produk', 'Sistem', 'Fisik', 'Selisih'],
            ['Laptop Dell', '50', '48', '-2'],
            ['Mouse Wireless', '100', '102', '+2'],
          ]),
        ],
      ),
    );
  }

  Widget _buildStockMovementReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSummaryCard('IN', '25', Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('OUT', '18', Colors.red)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('TRANSFER', '7', Colors.blue)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDataTable([
            ['Produk', 'Tipe', 'Qty', 'Tanggal'],
            ['Laptop Dell', 'IN', '10', '2024-01-15'],
            ['Mouse Wireless', 'OUT', '5', '2024-01-16'],
          ]),
        ],
      ),
    );
  }

  Widget _buildReceptionReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard('Total Penerimaan', '32', Colors.orange),
          const SizedBox(height: 16),
          _buildDataTable([
            ['Produk', 'Qty', 'Supplier', 'Status'],
            ['Laptop Dell', '10', 'PT. Tech', 'COMPLETED'],
            ['Mouse Wireless', '25', 'CV. Elektronik', 'QC'],
          ]),
        ],
      ),
    );
  }

  Widget _buildDispatchReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard('Total Pengeluaran', '28', Colors.red),
          const SizedBox(height: 16),
          _buildDataTable([
            ['Produk', 'Qty', 'Customer', 'Status'],
            ['Laptop Dell', '5', 'PT. ABC', 'SHIPPED'],
            ['Mouse Wireless', '10', 'CV. XYZ', 'DELIVERED'],
          ]),
        ],
      ),
    );
  }

  Widget _buildReturnsReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard('Total Return', '8', Colors.amber),
          const SizedBox(height: 16),
          _buildDataTable([
            ['Produk', 'Qty', 'Tipe', 'Status'],
            ['Laptop Dell', '2', 'CUSTOMER', 'APPROVED'],
            ['Mouse Wireless', '3', 'SUPPLIER', 'PENDING'],
          ]),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData:  FlGridData(show: false),
          titlesData:  FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 3),
                const FlSpot(1, 1),
                const FlSpot(2, 4),
                const FlSpot(3, 2),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(List<List<String>> data) {
    return Card(
      child: DataTable(
        columns: data[0].map((header) => DataColumn(label: Text(header))).toList(),
        rows: data.skip(1).map((row) => 
          DataRow(cells: row.map((cell) => DataCell(Text(cell))).toList())
        ).toList(),
      ),
    );
  }
}