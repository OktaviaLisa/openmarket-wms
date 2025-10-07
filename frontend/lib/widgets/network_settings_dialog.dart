import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class NetworkSettingsDialog extends StatefulWidget {
  const NetworkSettingsDialog({Key? key}) : super(key: key);
  
  @override
  _NetworkSettingsDialogState createState() => _NetworkSettingsDialogState();
}

class _NetworkSettingsDialogState extends State<NetworkSettingsDialog> {
  final _hostController = TextEditingController();
  List<String> _customHosts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCustomHosts();
  }

  Future<void> _loadCustomHosts() async {
    final hosts = await NetworkService.getCustomHosts();
    setState(() {
      _customHosts = hosts;
    });
  }

  Future<void> _addHost() async {
    final host = _hostController.text.trim();
    if (host.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Test koneksi
    final isWorking = await NetworkService.testConnection(host);
    
    if (isWorking) {
      await NetworkService.addCustomHost(host);
      ApiService.resetCache();
      AuthService.resetCache();
      _hostController.clear();
      await _loadCustomHosts();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Host $host berhasil ditambahkan')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Host $host tidak dapat diakses')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _removeHost(String host) async {
    await NetworkService.removeCustomHost(host);
    await _loadCustomHosts();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Host $host dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pengaturan Jaringan'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _hostController,
              decoration: InputDecoration(
                labelText: 'IP Address Backend',
                hintText: '192.168.1.100',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _addHost,
              child: _isLoading 
                ? CircularProgressIndicator(strokeWidth: 2)
                : Text('Tambah Host'),
            ),
            SizedBox(height: 16),
            if (_customHosts.isNotEmpty) ...[
              Text('Custom Hosts:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ..._customHosts.map((host) => ListTile(
                title: Text(host),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeHost(host),
                ),
              )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Tutup'),
        ),
      ],
    );
  }
}