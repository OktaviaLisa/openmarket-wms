import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class DispatchScreen extends StatefulWidget {
  const DispatchScreen({super.key});

  @override
  State<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen> {
  List<Map<String, dynamic>> _dispatches = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadDispatches();
  }

  Future<void> _loadDispatches() async {
    try {
      // Load dari database dulu
      print('🔄 Loading dispatches from API...');
      final apiDispatches = await _apiService.getDispatches();
      print('✅ API response: ${apiDispatches.length} dispatches');
      
      setState(() {
        _dispatches = apiDispatches.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
      await _saveDispatches(); // Backup ke local
      return;
    } catch (e) {
      print('❌ Database tidak tersedia: $e');
    }
    
    // Fallback ke local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final dispatchesJson = prefs.getString('dispatches');
      
      if (dispatchesJson != null && dispatchesJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(dispatchesJson);
        setState(() {
          _dispatches = decoded.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() {
          _dispatches = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _dispatches = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDispatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dispatchesJson = json.encode(_dispatches);
      await prefs.setString('dispatches', dispatchesJson);
    } catch (e) {
      print('Error saving dispatches: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran Barang'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _dispatches.length,
              itemBuilder: (context, index) {
          final dispatch = _dispatches[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red[100],
                child: Icon(Icons.output_rounded, color: Colors.red[700]),
              ),
              title: Text(dispatch['product_name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jumlah: ${dispatch['quantity']} unit'),
                  Text('Customer: ${dispatch['customer']}'),
                  Text('Tanggal: ${dispatch['created_at']}'),
                ],
              ),
              trailing: _buildStatusChip(dispatch['status']),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDispatchDialog,
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Cepat'),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == 'DELIVERED' ? Colors.green : 
                  status == 'SHIPPED' ? Colors.blue : Colors.orange;
    return Chip(
      label: Text(status, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withAlpha(25),
    );
  }

  void _showAddDispatchDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddDispatchDialog(),
    ).then((result) async {
      if (result != null) {
        try {
          // Simpan ke database dulu
          print('💾 Saving dispatch to database...');
          final apiResult = await _apiService.createDispatch({
            'product_name': result['product_name'],
            'quantity': result['quantity'],
            'customer': result['customer'],
            'location': 'Warehouse A',
            'notes': result['notes'] ?? '',
            'status': result['status'],
          });
          print('✅ Dispatch saved to database: $apiResult');
          
          // Reload data dari database
          await _loadDispatches();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pengeluaran barang "${result['product_name']}" berhasil disimpan ke database'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          print('❌ Error saving to database: $e');
          // Fallback ke local storage
          setState(() {
            _dispatches.add(result);
          });
          await _saveDispatches();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pengeluaran barang "${result['product_name']}" disimpan lokal (database tidak tersedia)'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    });
  }
}

class AddDispatchDialog extends StatefulWidget {
  const AddDispatchDialog({super.key});

  @override
  AddDispatchDialogState createState() => AddDispatchDialogState();
}

class AddDispatchDialogState extends State<AddDispatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _customerController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedStatus = 'PENDING';
  DateTime _selectedDate = DateTime.now();
  
  final List<String> _statusOptions = ['PENDING', 'SHIPPED', 'DELIVERED'];
  
  final List<String> _productSuggestions = [
    'Laptop Dell XPS 13',
    'Mouse Wireless Logitech',
    'Keyboard Mechanical',
    'Monitor LED 24"',
    'Printer Canon',
    'Scanner Epson',
    'Webcam HD',
    'Headset Gaming',
  ];

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _customerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[700],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.output_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tambah Pengeluaran Barang',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Produk
                      _buildFormField(
                        label: 'Nama Produk *',
                        hint: 'Contoh: Laptop Dell XPS 13',
                        controller: _productNameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama produk wajib diisi';
                          }
                          return null;
                        },
                        suffixIcon: PopupMenuButton<String>(
                          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                          onSelected: (value) {
                            _productNameController.text = value;
                          },
                          itemBuilder: (context) => _productSuggestions
                              .map((product) => PopupMenuItem(
                                    value: product,
                                    child: Text(product),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Jumlah
                      _buildFormField(
                        label: 'Jumlah *',
                        hint: 'Masukkan angka (contoh: 50)',
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Jumlah wajib diisi';
                          }
                          final quantity = int.tryParse(value.trim());
                          if (quantity == null || quantity <= 0) {
                            return 'Jumlah harus lebih dari 0';
                          }
                          return null;
                        },
                        suffixText: 'unit',
                      ),
                      const SizedBox(height: 16),
                      
                      // Customer
                      _buildFormField(
                        label: 'Customer *',
                        hint: 'Contoh: PT. ABC Company',
                        controller: _customerController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Customer wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            value: _selectedStatus,
                            items: _statusOptions.map((status) {
                              String displayText = status == 'PENDING' ? 'Menunggu' :
                                                 status == 'SHIPPED' ? 'Dikirim' : 'Terkirim';
                              return DropdownMenuItem(value: status, child: Text(displayText));
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) setState(() => _selectedStatus = value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Tanggal
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal Pengeluaran *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                                  const SizedBox(width: 12),
                                  Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                                  const Spacer(),
                                  Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Catatan
                      _buildFormField(
                        label: 'Catatan (Opsional)',
                        hint: 'Tambahkan catatan jika diperlukan...',
                        controller: _notesController,
                        maxLines: 3,
                        validator: null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    String? suffixText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            suffixIcon: suffixIcon,
            suffixText: suffixText,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newDispatch = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'product_name': _productNameController.text.trim(),
        'quantity': int.parse(_quantityController.text.trim()),
        'customer': _customerController.text.trim(),
        'status': _selectedStatus,
        'created_at': '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        'notes': _notesController.text.trim(),
      };
      
      Navigator.pop(context, newDispatch);
    }
  }
}