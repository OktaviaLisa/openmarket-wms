import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class QualityControlScreen extends StatefulWidget {
  const QualityControlScreen({super.key});

  @override
  State<QualityControlScreen> createState() => _QualityControlScreenState();
}

class _QualityControlScreenState extends State<QualityControlScreen> {
  List<Map<String, dynamic>> _qualityChecks = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadQualityChecks();
  }

  Future<void> _loadQualityChecks() async {
    try {
      // Load existing QC records
      final existingQCs = await _apiService.getQualityChecks();
      final qcMap = <int, Map<String, dynamic>>{};
      for (var qc in existingQCs) {
        qcMap[qc['id']] = qc;
      }
      
      // Load receptions with quality_check status
      final receptions = await _apiService.getReceptions();
      final qualityCheckItems = <Map<String, dynamic>>[];
      
      for (var item in receptions) {
        if (item['status'] == 'quality_check') {
          final existingQC = qcMap[item['id']];
          qualityCheckItems.add({
            'id': item['id'],
            'product_name': item['product_name'],
            'supplier': item['supplier'],
            'quantity': item['quantity'],
            'location': item['location'],
            'notes': item['notes'],
            'date': item['date'],
            'status': existingQC?['status'] ?? 'PENDING',
            'check_type': 'INCOMING',
          });
        }
      }
      
      setState(() {
        _qualityChecks = qualityCheckItems;
        _isLoading = false;
      });
      print('✅ QC data loaded: ${_qualityChecks.length} items');
    } catch (e) {
      print('❌ Error loading QC data: $e');
      setState(() {
        _qualityChecks = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Control'),
        backgroundColor: Colors.deepPurple[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _qualityChecks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _qualityChecks.length,
                  itemBuilder: (context, index) {
                    final check = _qualityChecks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple[100],
                          child: Icon(Icons.verified, color: Colors.deepPurple[700]),
                        ),
                        title: Text(check['product_name'] ?? 'Produk Tidak Diketahui'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Supplier: ${check['supplier'] ?? 'N/A'}'),
                            Text('Jumlah: ${check['quantity']} unit'),
                            Text('Lokasi: ${check['location'] ?? 'N/A'}'),
                            Text('Tanggal: ${check['date'] ?? 'N/A'}'),
                          ],
                        ),
                        trailing: _buildStatusChip(check['status'] ?? 'PENDING'),
                        isThreeLine: true,
                        onTap: () => _showQualityCheckDialog(check),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Belum ada barang untuk Quality Control', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Tambahkan barang di Penerimaan Barang terlebih dahulu', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadQualityChecks(),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String displayText;
    switch (status) {
      case 'PASS':
        color = Colors.green;
        displayText = 'Lulus';
        break;
      case 'FAIL':
        color = Colors.red;
        displayText = 'Gagal';
        break;
      case 'PENDING':
      default:
        color = Colors.orange;
        displayText = 'Menunggu';
    }
    return Chip(
      label: Text(displayText, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withAlpha(25),
    );
  }

  void _showQualityCheckDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quality Check'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk: ${item['product_name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Supplier: ${item['supplier'] ?? 'N/A'}'),
            Text('Jumlah: ${item['quantity']} unit'),
            Text('Lokasi: ${item['location'] ?? 'N/A'}'),
            if (item['notes'] != null && item['notes'].toString().isNotEmpty)
              Text('Catatan: ${item['notes']}'),
            const SizedBox(height: 20),
            const Text('Pilih hasil Quality Check:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updateQCStatus(item, 'PASS');
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text('LULUS', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updateQCStatus(item, 'FAIL');
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text('GAGAL', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _updateQCStatus(Map<String, dynamic> item, String status) async {
    try {
      // Save QC record to database
      await _apiService.createQualityCheckRecord({
        'reception_id': item['id'],
        'product_name': item['product_name'],
        'quantity': item['quantity'],
        'status': status,
        'notes': 'QC performed via mobile app',
      });
      
      // Update local state
      setState(() {
        final index = _qualityChecks.indexWhere((check) => check['id'] == item['id']);
        if (index != -1) {
          _qualityChecks[index]['status'] = status;
        }
      });
      
      // Jika status PASS, simpan ke inventory
      if (status == 'PASS') {
        try {
          await _saveToInventory(item);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item['product_name']} - Lulus QC dan disimpan ke inventory'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item['product_name']} - Lulus QC tapi gagal simpan ke inventory'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item['product_name']} - Gagal QC'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan hasil QC: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveToInventory(Map<String, dynamic> item) async {
    final inventoryItem = {
      'product_name': item['product_name'],
      'category': item['supplier'] ?? 'General',
      'quantity': item['quantity'],
      'location': item['location'] ?? 'Warehouse A',
      'min_stock': 10,
    };
    
    try {
      final result = await _apiService.createInventoryItem(inventoryItem);
      print('✅ Item saved to inventory: ${item['product_name']} - $result');
    } catch (e) {
      print('❌ Failed to save to inventory: $e');
      throw e;
    }
  }

  void _showAddQualityCheckDialog() {
    // Tidak diperlukan lagi karena data otomatis dari receptions
  }
}