import 'package:flutter/material.dart';
import '../utils/network_debug.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Map<String, dynamic>? testResults;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      isLoading = true;
    });

    try {
      final results = await NetworkDebug.testAllConnections();
      setState(() {
        testResults = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        testResults = {'error': e.toString()};
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runTests,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Network Configuration',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: NetworkDebug.getNetworkInfo(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Text(snapshot.data!);
                        } else {
                          return const Text('No data');
                        }
                      },
                    ),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connection Tests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : testResults == null
                      ? const Center(child: Text('No test results'))
                      : ListView.builder(
                          itemCount: testResults!.length,
                          itemBuilder: (context, index) {
                            final key = testResults!.keys.elementAt(index);
                            final result = testResults![key];
                            
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  result['success'] == true
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: result['success'] == true
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: Text(key),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('URL: ${result['url'] ?? 'N/A'}'),
                                    if (result['success'] == true) ...[
                                      Text('Status: ${result['status_code']}'),
                                      Text('Response Time: ${result['response_time_ms']}ms'),
                                    ] else ...[
                                      Text('Error: ${result['error'] ?? 'Unknown error'}'),
                                      if (result['error_type'] != null)
                                        Text('Type: ${result['error_type']}'),
                                    ],
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}