import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/safe_parser.dart';
import '../services/api_service.dart';
import 'reception_form_screen.dart';

class ReceptionScreen extends StatefulWidget {
  const ReceptionScreen({super.key});

  @override
  ReceptionScreenState createState() => ReceptionScreenState();
}

class ReceptionScreenState extends State<ReceptionScreen> {
  List<Map<String, dynamic>> _receptions = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadReceptions();
  }

  Future<void> _loadReceptions() async {
    try {
      // Coba load dari database dulu
      final apiReceptions = await _apiService.getReceptions();
      if (apiReceptions.isNotEmpty) {
        setState(() {
          _receptions = apiReceptions.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
        print('✅ Data dari database: ${_receptions.length} items');
        // Juga simpan ke local storage sebagai backup
        await _saveReceptions();
        return;
      }
    } catch (e) {
      print('⚠️ Database tidak tersedia: $e');
    }
    
    // Fallback ke local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final receptionsJson = prefs.getString('receptions');
      
      if (receptionsJson != null && receptionsJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(receptionsJson);
        setState(() {
          _receptions = decoded.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
        print('✅ Data dari local: ${_receptions.length} items');
      } else {
        // Default data
        setState(() {
          _receptions = [];
          _isLoading = false;
        });
        print('ℹ️ Tidak ada data');
      }
    } catch (e) {
      print('❌ Error loading: $e');
      setState(() {
        _receptions = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _saveReceptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final receptionsJson = json.encode(_receptions);
      await prefs.setString('receptions', receptionsJson);
      print('✅ Data tersimpan: ${_receptions.length} items');
    } catch (e) {
      print('❌ Error saving: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penerimaan Barang'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _receptions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _receptions.length,
              itemBuilder: (context, index) {
                final reception = _receptions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[100],
                      child: Icon(
                        Icons.input_rounded,
                        color: Colors.orange[700],
                      ),
                    ),
                    title: Text(
                      reception['product_name'] ?? 'Produk Tidak Diketahui',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jumlah: ${SafeParser.parseInt(reception['quantity'])} unit'),
                        Text('Supplier: ${reception['supplier'] ?? 'N/A'}'),
                        Text('Tanggal: ${reception['date'] ?? 'N/A'}'),
                      ],
                    ),
                    trailing: _buildStatusChip(reception['status']),
                    isThreeLine: true,
                    onLongPress: () => _showDeleteDialog(index, reception),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: () => _showAddReceptionDialog(),
            backgroundColor: Colors.orange[700],
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Cepat'),
            heroTag: "add_btn",
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data penerimaan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk menambah penerimaan barang',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String displayText;
    switch (status.toLowerCase()) {
      case 'pending':
      case 'menunggu':
        color = Colors.orange;
        displayText = 'Menunggu';
        break;
      case 'received':
      case 'diterima':
        color = Colors.blue;
        displayText = 'Diterima';
        break;
      case 'quality_check':
      case 'qc':
        color = Colors.purple;
        displayText = 'QC';
        break;
      case 'completed':
      case 'selesai':
        color = Colors.green;
        displayText = 'Selesai';
        break;
      default:
        color = Colors.grey;
        displayText = status;
    }
    return Chip(
      label: Text(
        displayText,
        style: TextStyle(
          color: _getColorShade(color),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color.withAlpha(25),
      side: BorderSide(color: color.withAlpha(76)),
    );
  }

  Color _getColorShade(Color color) {
    if (color == Colors.orange) return Colors.orange.shade700;
    if (color == Colors.blue) return Colors.blue.shade700;
    if (color == Colors.purple) return Colors.purple.shade700;
    if (color == Colors.green) return Colors.green.shade700;
    return Colors.grey.shade700;
  }



  void _showAddReceptionDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddReceptionDialog(),
    ).then((result) async {
      if (result != null) {
        try {
          // Simpan ke database dulu
          await _apiService.createReception({
            'product_name': result['product_name'],
            'quantity': result['quantity'],
            'category': result['supplier'],
            'location': 'Warehouse A',
            'notes': result['notes'] ?? '',
            'status': result['status'] ?? 'pending',
          });
          
          // Reload data dari database
          await _loadReceptions();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Penerimaan barang "${result['product_name']}" berhasil disimpan ke database'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          // Fallback ke local storage jika database gagal
          setState(() {
            _receptions.add(result);
          });
          await _saveReceptions();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Penerimaan barang "${result['product_name']}" disimpan lokal (database tidak tersedia)'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    });
  }

  void _showDeleteDialog(int index, Map<String, dynamic> reception) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Penerimaan'),
        content: Text('Apakah Anda yakin ingin menghapus penerimaan "${reception['product_name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _receptions.removeAt(index);
              });
              await _saveReceptions();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Penerimaan "${reception['product_name']}" berhasil dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddReceptionDialog extends StatefulWidget {
  const AddReceptionDialog({super.key});

  @override
  AddReceptionDialogState createState() => AddReceptionDialogState();
}

class AddReceptionDialogState extends State<AddReceptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _supplierController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedStatus = 'quality_check'; // Always quality_check for reception
  DateTime _selectedDate = DateTime.now();
  
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
    _supplierController.dispose();
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
                color: Colors.orange[700],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.input_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tambah Penerimaan Barang',
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
                      // Petunjuk Pengisian
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Isi semua field yang wajib (*) dengan benar',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Nama Produk
                      _buildFormField(
                        label: 'Nama Produk *',
                        hint: 'Contoh: Laptop Dell XPS 13',
                        controller: _productNameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama produk wajib diisi';
                          }
                          if (value.trim().length < 3) {
                            return 'Nama produk minimal 3 karakter';
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
                        hint: 'Masukkan angka saja (contoh: 50)',
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
                          // Hapus semua karakter non-digit
                          final cleanValue = value.trim().replaceAll(RegExp(r'[^0-9]'), '');
                          if (cleanValue.isEmpty) {
                            return 'Jumlah harus berupa angka saja (contoh: 50)';
                          }
                          final quantity = int.tryParse(cleanValue);
                          if (quantity == null) {
                            return 'Format jumlah tidak valid';
                          }
                          if (quantity <= 0) {
                            return 'Jumlah harus lebih dari 0';
                          }
                          if (quantity > 10000) {
                            return 'Jumlah maksimal 10.000';
                          }
                          return null;
                        },
                        suffixText: 'unit',
                      ),
                      const SizedBox(height: 16),
                      
                      // Supplier
                      _buildFormField(
                        label: 'Supplier *',
                        hint: 'Contoh: PT. Tech Solutions',
                        controller: _supplierController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Supplier wajib diisi';
                          }
                          if (value.trim().length < 3) {
                            return 'Nama supplier minimal 3 karakter';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),
                      
                      // Tanggal
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal Penerimaan *',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, 
                                       color: Colors.grey[600], size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.arrow_drop_down, 
                                       color: Colors.grey[600]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Catatan (Optional)
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
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orange,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Parse quantity dengan ekstraksi angka dari teks campuran
      final quantityText = _quantityController.text.trim();
      
      if (quantityText.isEmpty) {
        _showErrorSnackBar('Jumlah tidak boleh kosong');
        return;
      }
      
      // Ekstrak hanya angka dari input (menghapus teks seperti "ton", "kg", dll)
      final cleanQuantityText = quantityText.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (cleanQuantityText.isEmpty) {
        _showErrorSnackBar('Tidak ada angka yang valid. Contoh yang benar: 50');
        return;
      }
      
      final quantity = int.tryParse(cleanQuantityText);
      if (quantity == null) {
        _showErrorSnackBar('Format jumlah tidak valid. Masukkan angka saja.');
        return;
      }
      
      if (quantity <= 0) {
        _showErrorSnackBar('Jumlah harus lebih dari 0');
        return;
      }
      
      if (quantity > 10000) {
        _showErrorSnackBar('Jumlah maksimal 10.000');
        return;
      }
      
      // Validasi field wajib lainnya
      if (_productNameController.text.trim().isEmpty) {
        _showErrorSnackBar('Nama produk tidak boleh kosong');
        return;
      }
      
      if (_supplierController.text.trim().isEmpty) {
        _showErrorSnackBar('Supplier tidak boleh kosong');
        return;
      }
      
      final newReception = {
        'id': Random().nextInt(10000),
        'product_name': _productNameController.text.trim(),
        'quantity': quantity, // sudah dipastikan valid
        'supplier': _supplierController.text.trim(),
        'status': _selectedStatus,
        'date': '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        'notes': _notesController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      Navigator.pop(context, newReception);
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}