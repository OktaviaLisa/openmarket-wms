import 'package:flutter/material.dart';

class CheckingScreen extends StatefulWidget {
  const CheckingScreen({super.key});

  @override
  _CheckingScreenState createState() => _CheckingScreenState();
}

class _CheckingScreenState extends State<CheckingScreen> {
  List<Map<String, dynamic>> checkingTasks = [
    {
      'id': 1,
      'batch_id': 'BCH-001',
      'product': 'Office Chair',
      'quantity': 10,
      'expected': 10,
      'status': 'pending'
    },
    {
      'id': 2,
      'batch_id': 'BCH-002',
      'product': 'Laptop Dell',
      'quantity': 5,
      'expected': 5,
      'status': 'pending'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checking Tasks'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: checkingTasks.length,
        itemBuilder: (context, index) {
          final task = checkingTasks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.check_circle, color: Colors.white),
              ),
              title: Text('${task['product']}'),
              subtitle: Text('Batch: ${task['batch_id']} | Expected: ${task['expected']} | Found: ${task['quantity']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        task['status'] = 'rejected';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item rejected!')),
                      );
                    },
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        task['status'] = 'approved';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item approved!')),
                      );
                    },
                    icon: const Icon(Icons.check, color: Colors.green),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}