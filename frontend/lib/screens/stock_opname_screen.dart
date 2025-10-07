import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StockOpnameScreen extends StatefulWidget {
  const StockOpnameScreen({super.key});

  @override
  State<StockOpnameScreen> createState() => _StockOpnameScreenState();
}

class _StockOpnameScreenState extends State<StockOpnameScreen> {
  final List<Map<String, dynamic>> _opnames = [
    {
      'id': 1,
      'product_name': 'Laptop Dell XPS 13',
      'system_stock': 50,
      'physical_stock': 48,
      'difference': -2,
      'status': 'PENDING',
      'created_at': '2024-01-15',
    },
    {
      'id': 2,
      'product_name': 'Mouse Wireless',
      'system_stock': 100,
      'physical_stock': 102,
      'difference': 2,
      'status': 'APPROVED',
      'created_at': '2024-01-16',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Opname'),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _opnames.length,
        itemBuilder: (context, index) {
          final opname = _opnames[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo[100],
                child: Icon(Icons.inventory_2, color: Colors.indigo[700]),
              ),
              title: Text(opname['product_name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sistem: ${opname['system_stock']} | Fisik: ${opname['physical_stock']}'),
                  Text('Selisih: ${opname['difference']}'),
                  Text('Tanggal: ${opname['created_at']}'),
                ],
              ),
              trailing: _buildStatusChip(opname['status']),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOpnameDialog,
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Opname'),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == 'APPROVED' ? Colors.green : 
                  status == 'REJECTED' ? Colors.red : Colors.orange;
    return Chip(
      label: Text(status, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withAlpha(25),
    );
  }

  void _showAddOpnameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Stock Opname'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              items: ['Laptop Dell XPS 13', 'Mouse Wireless', 'Keyboard']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Stok Fisik'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Catatan'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}