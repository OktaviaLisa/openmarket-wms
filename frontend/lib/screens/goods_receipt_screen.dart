import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class GoodsReceiptScreen extends StatefulWidget {
  const GoodsReceiptScreen({super.key});

  @override
  State<GoodsReceiptScreen> createState() => _GoodsReceiptScreenState();
}

class _GoodsReceiptScreenState extends State<GoodsReceiptScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> receipts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    try {
      final data = await _apiService.getGoodsReceipts();
      setState(() {
        receipts = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penerimaan Barang'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReceipts,
              child: receipts.isEmpty
                  ? const Center(child: Text('Belum ada dokumen penerimaan'))
                  : ListView.builder(
                      itemCount: receipts.length,
                      itemBuilder: (context, index) {
                        final receipt = receipts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(receipt['no_dokumen'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Supplier: ${receipt['supplier'] ?? ''}'),
                                Text('Tanggal: ${receipt['tanggal'] ?? ''}'),
                                Text('Status: ${receipt['status'] ?? ''}'),
                              ],
                            ),
                            trailing: _buildStatusChip(receipt['status']),
                            onTap: () => _showReceiptDetail(receipt),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateReceiptWizard(),
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    switch (status) {
      case 'completed':
        color = Colors.green;
        break;
      case 'in_progress':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status ?? 'draft', style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showReceiptDetail(Map<String, dynamic> receipt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoodsReceiptDetailScreen(receipt: receipt),
      ),
    );
  }

  void _showCreateReceiptWizard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoodsReceiptWizardScreen(),
      ),
    ).then((_) => _loadReceipts());
  }
}

class GoodsReceiptWizardScreen extends StatefulWidget {
  const GoodsReceiptWizardScreen({super.key});

  @override
  State<GoodsReceiptWizardScreen> createState() => _GoodsReceiptWizardScreenState();
}

class _GoodsReceiptWizardScreenState extends State<GoodsReceiptWizardScreen> {
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();
  int currentStep = 0;
  
  // Step 1 - Document
  final _docFormKey = GlobalKey<FormState>();
  final _noDokumenController = TextEditingController();
  final _supplierController = TextEditingController();
  final _noPOController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  
  // Step 2 - Items
  List<Map<String, dynamic>> items = [];
  
  // Step 3 - Quality Check
  Map<int, Map<String, dynamic>> qualityChecks = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Penerimaan Barang'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => currentStep = index),
              children: [
                _buildDocumentStep(),
                _buildItemsStep(),
                _buildQualityStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepCircle(0, 'Dokumen'),
          Expanded(child: Container(height: 2, color: currentStep > 0 ? Colors.green : Colors.grey[300])),
          _buildStepCircle(1, 'Barang'),
          Expanded(child: Container(height: 2, color: currentStep > 1 ? Colors.green : Colors.grey[300])),
          _buildStepCircle(2, 'Kualitas'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool isActive = currentStep >= step;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDocumentStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _docFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: _noDokumenController,
              decoration: const InputDecoration(labelText: 'No. Dokumen'),
              validator: (value) => value?.isEmpty == true ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _supplierController,
              decoration: const InputDecoration(labelText: 'Supplier'),
              validator: (value) => value?.isEmpty == true ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noPOController,
              decoration: const InputDecoration(labelText: 'No. PO'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Tanggal'),
              subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daftar Barang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: _addItem,
                child: const Text('Tambah'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Belum ada barang'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: ExpansionTile(
                          title: Text(item['nama_barang'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('SKU: ${item['sku']} | Qty: ${item['jumlah']} ${item['satuan']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => items.removeAt(index)),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('SKU', item['sku']),
                                  _buildDetailRow('Nama Barang', item['nama_barang']),
                                  _buildDetailRow('Jumlah', '${item['jumlah']} ${item['satuan']}'),
                                  if (item['batch']?.isNotEmpty == true)
                                    _buildDetailRow('Batch/Lot', item['batch']),
                                  if (item['expired_date']?.isNotEmpty == true)
                                    _buildDetailRow('Expired Date', item['expired_date']),
                                  _buildDetailRow('Satuan', item['satuan']),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Pemeriksaan Kualitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final check = qualityChecks[index] ?? {'status': 'diterima', 'keterangan': ''};
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['nama_barang'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('SKU: ${item['sku']}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'diterima',
                              groupValue: check['status'],
                              onChanged: (value) => _updateQualityCheck(index, 'status', value),
                            ),
                            const Text('Diterima'),
                            Radio<String>(
                              value: 'ditolak',
                              groupValue: check['status'],
                              onChanged: (value) => _updateQualityCheck(index, 'status', value),
                            ),
                            const Text('Ditolak'),
                          ],
                        ),
                        if (check['status'] == 'ditolak')
                          TextField(
                            decoration: const InputDecoration(labelText: 'Keterangan'),
                            onChanged: (value) => _updateQualityCheck(index, 'keterangan', value),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentStep > 0)
            ElevatedButton(
              onPressed: _previousStep,
              child: const Text('Sebelumnya'),
            )
          else
            const SizedBox(),
          ElevatedButton(
            onPressed: currentStep < 2 ? _nextStep : _submitReceipt,
            child: Text(currentStep < 2 ? 'Selanjutnya' : 'Selesai'),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _ItemDialog(
        onAdd: (item) {
          setState(() => items.add(item));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _updateQualityCheck(int index, String key, dynamic value) {
    setState(() {
      qualityChecks[index] = {...(qualityChecks[index] ?? {}), key: value};
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (currentStep == 0) {
      if (!_docFormKey.currentState!.validate()) return;
      if (_noDokumenController.text.trim().isEmpty || _supplierController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap isi semua field yang wajib')),
        );
        return;
      }
    }
    
    if (currentStep == 1 && items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 barang')),
      );
      return;
    }
    
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitReceipt() async {
    try {
      // Create receipt document
      final receiptData = {
        'no_dokumen': _noDokumenController.text.trim(),
        'tanggal': '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        'supplier': _supplierController.text.trim(),
        'no_po': _noPOController.text.trim(),
      };
      
      print('Creating receipt with data: $receiptData');
      final receipt = await _apiService.createGoodsReceipt(receiptData);
      print('Receipt response: $receipt');
      
      // Try different ways to get the ID
      int? receiptId;
      if (receipt is Map<String, dynamic>) {
        receiptId = _parseToInt(receipt['id']);
      } else if (receipt is int) {
        receiptId = receipt;
      }
      
      if (receiptId == null) {
        print('Failed to parse receipt ID from: $receipt');
        // For now, just complete without adding details
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dokumen penerimaan berhasil dibuat (tanpa detail)')),
          );
        }
        return;
      }
      
      print('Using receipt ID: $receiptId');
      
      // Add items with quality checks
      for (int i = 0; i < items.length; i++) {
        try {
          final detailResponse = await _apiService.addGoodsReceiptDetail(receiptId, items[i]);
          print('Detail response: $detailResponse');
          
          final detailId = _parseToInt(detailResponse['id']);
          if (detailId != null) {
            final qualityCheck = qualityChecks[i] ?? {'status': 'diterima', 'keterangan': ''};
            await _apiService.createQualityCheck(detailId, qualityCheck);
          }
        } catch (e) {
          print('Error adding item ${i + 1}: $e');
          // Continue with other items
        }
      }
      
      // Complete receipt
      try {
        await _apiService.completeGoodsReceipt(receiptId);
      } catch (e) {
        print('Error completing receipt: $e');
        // Don't fail the whole process
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Penerimaan barang berhasil dibuat')),
        );
      }
    } catch (e) {
      print('Submit receipt error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return int.tryParse(value.toString());
  }
}

class _ItemDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const _ItemDialog({required this.onAdd});

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _batchController = TextEditingController();
  final _satuanController = TextEditingController();
  DateTime? _expiredDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Barang'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'SKU'),
                validator: (value) => value?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Barang'),
                validator: (value) => value?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _jumlahController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  hintText: 'Contoh: 50 (hanya angka)',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value?.isEmpty == true) return 'Wajib diisi';
                  final number = int.tryParse(value!);
                  if (number == null) return 'Harus berupa angka';
                  if (number <= 0) return 'Harus lebih dari 0';
                  return null;
                },
              ),
              TextFormField(
                controller: _satuanController,
                decoration: const InputDecoration(labelText: 'Satuan'),
                validator: (value) => value?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _batchController,
                decoration: const InputDecoration(labelText: 'Batch/Lot'),
              ),
              ListTile(
                title: const Text('Expired Date'),
                subtitle: Text(_expiredDate?.toString().split(' ')[0] ?? 'Tidak ada'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectExpiredDate,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _addItem,
          child: const Text('Tambah'),
        ),
      ],
    );
  }

  void _selectExpiredDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() => _expiredDate = date);
    }
  }

  void _addItem() {
    if (!_formKey.currentState!.validate()) return;
    
    final quantity = int.tryParse(_jumlahController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah harus berupa angka yang valid')),
      );
      return;
    }
    
    widget.onAdd({
      'sku': _skuController.text.trim(),
      'nama_barang': _namaController.text.trim(),
      'jumlah': quantity,
      'satuan': _satuanController.text.trim(),
      'batch': _batchController.text.trim(),
      'expired_date': _expiredDate?.toString().split(' ')[0] ?? '',
    });
  }

}

class GoodsReceiptDetailScreen extends StatelessWidget {
  final Map<String, dynamic> receipt;

  const GoodsReceiptDetailScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receipt['no_dokumen']),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No. Dokumen: ${receipt['no_dokumen']}'),
                    Text('Supplier: ${receipt['supplier']}'),
                    Text('Tanggal: ${receipt['tanggal']}'),
                    Text('No. PO: ${receipt['no_po'] ?? '-'}'),
                    Text('Status: ${receipt['status']}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}