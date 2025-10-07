import 'package:flutter/material.dart';

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key});

  @override
  ReturnScreenState createState() => ReturnScreenState();
}

class ReturnScreenState extends State<ReturnScreen> {
  final List<Map<String, dynamic>> _returns = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Returns'),
        backgroundColor: Colors.purple,
      ),
      body: ListView.builder(
        itemCount: _returns.length,
        itemBuilder: (context, index) {
          final returnItem = _returns[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(returnItem['product_name'] ?? 'Unknown Product'),
              subtitle: Text('Qty: ${returnItem['quantity']} - Type: ${returnItem['return_type']}'),
              trailing: _buildStatusChip(returnItem['status']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReturnDialog(),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'QUALITY_CHECK':
        color = Colors.purple;
        break;
      case 'APPROVED':
        color = Colors.green;
        break;
      case 'REJECTED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(label: Text(status), backgroundColor: color.withAlpha(51));
  }

  void _showAddReturnDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Return'),
        content: const Text('Return form will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}