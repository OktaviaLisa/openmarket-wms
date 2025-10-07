import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  final List<Map<String, dynamic>> _returns = [
    {
      'id': 1,
      'product_name': 'Laptop Dell XPS 13',
      'quantity': 2,
      'return_type': 'CUSTOMER',
      'reason': 'Defective product',
      'status': 'PENDING',
      'created_at': '2024-01-15',
    },
    {
      'id': 2,
      'product_name': 'Mouse Wireless',
      'quantity': 3,
      'return_type': 'SUPPLIER',
      'reason': 'Wrong specification',
      'status': 'APPROVED',
      'created_at': '2024-01-16',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengembalian Barang'),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _returns.length,
        itemBuilder: (context, index) {
          final returnItem = _returns[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amber[100],
                child: Icon(Icons.keyboard_return, color: Colors.amber[700]),
              ),
              title: Text(returnItem['product_name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jumlah: ${returnItem['quantity']} unit'),
                  Text('Tipe: ${returnItem['return_type']}'),
                  Text('Alasan: ${returnItem['reason']}'),
                  Text('Tanggal: ${returnItem['created_at']}'),
                ],
              ),
              trailing: _buildStatusChip(returnItem['status']),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReturnDialog,
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Return'),
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

  void _showAddReturnDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Pengembalian'),
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
            TextFormField(
              decoration: const InputDecoration(labelText: 'Jumlah'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              items: ['CUSTOMER', 'SUPPLIER']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Alasan'),
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