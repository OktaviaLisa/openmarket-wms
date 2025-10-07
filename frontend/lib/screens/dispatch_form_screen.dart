import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DispatchFormScreen extends StatefulWidget {
  const DispatchFormScreen({super.key});

  @override
  State<DispatchFormScreen> createState() => _DispatchFormScreenState();
}

class _DispatchFormScreenState extends State<DispatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  List<Map<String, dynamic>> _inventory = [];
  Map<String, dynamic>? _selectedProduct;
  bool _isLoading = false;
  bool _isLoadingInventory = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoadingInventory = true);
    try {
      final apiService = ApiService();
      final inventory = await apiService.getInventory();
      setState(() {
        _inventory = inventory.where((item) => item['quantity'] > 0).toList();
        _isLoadingInventory = false;
      });
    } catch (e) {
      setState(() => _isLoadingInventory = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading inventory: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onProductSelected(Map<String, dynamic>? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _locationController.text = product['location'] ?? '';
      }
    });
  }

  Future<void> _saveDispatch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu')),
      );
      return;
    }

    final quantity = int.parse(_quantityController.text);
    final availableStock = _selectedProduct!['quantity'] as int;
    
    if (quantity > availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jumlah melebihi stok tersedia ($availableStock)')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      await apiService.createDispatch({
        'product_name': _selectedProduct!['product_name'],
        'category': _selectedProduct!['category'],
        'quantity': quantity,
        'location': _locationController.text,
        'notes': _notesController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengeluaran berhasil disimpan dan inventory diperbarui'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pengeluaran'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoadingInventory
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Product Dropdown
                    DropdownButtonFormField<Map<String, dynamic>>(
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedProduct,
                      items: _inventory.map((product) {
                        return DropdownMenuItem(
                          value: product,
                          child: Text(
                            '${product['product_name']} (Stok: ${product['quantity']})',
                          ),
                        );
                      }).toList(),
                      onChanged: _onProductSelected,
                      validator: (value) => value == null ? 'Pilih produk terlebih dahulu' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Category (Auto-filled)
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      initialValue: _selectedProduct?['category'] ?? '',
                    ),
                    const SizedBox(height: 16),
                    
                    // Available Stock Info
                    if (_selectedProduct != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          'Stok Tersedia: ${_selectedProduct!['quantity']} unit',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    // Quantity Input
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Keluar',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty == true) return 'Wajib diisi';
                        final quantity = int.tryParse(value!);
                        if (quantity == null || quantity <= 0) return 'Harus angka positif';
                        if (_selectedProduct != null && quantity > _selectedProduct!['quantity']) {
                          return 'Melebihi stok tersedia';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Location (Auto-filled from inventory)
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveDispatch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Simpan Pengeluaran'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}