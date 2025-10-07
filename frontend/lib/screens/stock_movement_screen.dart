import 'package:flutter/material.dart';

class StockMovementScreen extends StatefulWidget {
  const StockMovementScreen({super.key});

  @override
  State<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends State<StockMovementScreen> {
  final List<Map<String, dynamic>> _movements = [
    {
      'id': 1,
      'product_name': 'Laptop Dell XPS 13',
      'movement_type': 'IN',
      'quantity': 10,
      'from_location': 'Supplier',
      'to_location': 'Gudang A',
      'reference_type': 'RECEPTION',
      'created_at': '2024-01-15 10:30',
    },
    {
      'id': 2,
      'product_name': 'Mouse Wireless',
      'movement_type': 'TRANSFER',
      'quantity': 5,
      'from_location': 'Gudang A',
      'to_location': 'Gudang B',
      'reference_type': 'TRANSFER',
      'created_at': '2024-01-16 14:20',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Movement'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _movements.length,
        itemBuilder: (context, index) {
          final movement = _movements[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal[100],
                child: Icon(_getMovementIcon(movement['movement_type']), 
                          color: Colors.teal[700]),
              ),
              title: Text(movement['product_name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${movement['movement_type']} - ${movement['quantity']} unit'),
                  Text('${movement['from_location']} → ${movement['to_location']}'),
                  Text('${movement['created_at']}'),
                ],
              ),
              trailing: _buildMovementTypeChip(movement['movement_type']),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMovementDialog,
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Movement'),
      ),
    );
  }

  IconData _getMovementIcon(String type) {
    switch (type) {
      case 'IN': return Icons.arrow_downward;
      case 'OUT': return Icons.arrow_upward;
      case 'TRANSFER': return Icons.swap_horiz;
      default: return Icons.move_up;
    }
  }

  Widget _buildMovementTypeChip(String type) {
    Color color = type == 'IN' ? Colors.green : 
                  type == 'OUT' ? Colors.red : Colors.blue;
    return Chip(
      label: Text(type, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withAlpha(25),
    );
  }

  void _showAddMovementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Stock Movement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              items: ['Laptop Dell XPS 13', 'Mouse Wireless']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              items: ['IN', 'OUT', 'TRANSFER']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Jumlah'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Dari Lokasi'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Ke Lokasi'),
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