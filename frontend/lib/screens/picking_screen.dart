import 'package:flutter/material.dart';

class PickingScreen extends StatefulWidget {
  const PickingScreen({super.key});

  @override
  _PickingScreenState createState() => _PickingScreenState();
}

class _PickingScreenState extends State<PickingScreen> {
  List<Map<String, dynamic>> pickingTasks = [
    {
      'id': 1,
      'order_id': 'ORD-001',
      'product': 'Laptop Dell',
      'quantity': 2,
      'location': 'A1-B2',
      'status': 'pending'
    },
    {
      'id': 2,
      'order_id': 'ORD-002',
      'product': 'Wireless Mouse',
      'quantity': 5,
      'location': 'B3-C1',
      'status': 'pending'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picking Tasks'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pickingTasks.length,
        itemBuilder: (context, index) {
          final task = pickingTasks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.shopping_cart, color: Colors.white),
              ),
              title: Text('${task['product']} (${task['quantity']} pcs)'),
              subtitle: Text('Order: ${task['order_id']} | Location: ${task['location']}'),
              trailing: ElevatedButton(
                onPressed: () {
                  setState(() {
                    task['status'] = 'completed';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item picked successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Pick'),
              ),
            ),
          );
        },
      ),
    );
  }
}