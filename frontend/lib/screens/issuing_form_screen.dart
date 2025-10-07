import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_models.dart';
import '../models/product.dart';
import '../services/transaction_service.dart';
import '../services/product_service.dart';

class IssuingFormScreen extends StatefulWidget {
  @override
  _IssuingFormScreenState createState() => _IssuingFormScreenState();
}

class _IssuingFormScreenState extends State<IssuingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _remarksController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  Customer? _selectedCustomer;
  Product? _selectedProduct;
  Unit? _selectedUnit;
  Location? _selectedLocation;
  
  List<Customer> _customers = [];
  List<Product> _products = [];
  List<Unit> _units = [];
  List<Location> _locations = [];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  Future<void> _loadMasterData() async {
    setState(() => _isLoading = true);
    try {
      _customers = await TransactionService.getCustomers();
      _products = await ProductService.getProducts();
      _units = await TransactionService.getUnits();
      _locations = await TransactionService.getLocations();
      
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCustomer == null || _selectedProduct == null || 
        _selectedUnit == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final request = IssuingRequest(
        issueDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        customerId: _selectedCustomer!.id,
        productId: _selectedProduct!.id,
        quantity: int.parse(_quantityController.text),
        unitId: _selectedUnit!.id,
        locationId: _selectedLocation!.id,
        remarks: _remarksController.text,
      );

      final result = await TransactionService.createIssuing(request);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Issuing created: ${result['document_number']}')),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Pengeluaran Barang'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Informasi Pengeluaran', 
                                 style: Theme.of(context).textTheme.titleLarge),
                            SizedBox(height: 16),
                            
                            // Tanggal Pengeluaran
                            ListTile(
                              title: Text('Tanggal Pengeluaran'),
                              subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                              trailing: Icon(Icons.calendar_today),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now().subtract(Duration(days: 30)),
                                  lastDate: DateTime.now().add(Duration(days: 30)),
                                );
                                if (date != null) {
                                  setState(() => _selectedDate = date);
                                }
                              },
                            ),
                            
                            // Customer
                            DropdownButtonFormField<Customer>(
                              isExpanded: true,
                              decoration: InputDecoration(labelText: 'Customer / Tujuan *'),
                              value: _selectedCustomer,
                              items: _customers.map((customer) {
                                return DropdownMenuItem(
                                  value: customer,
                                  child: Text(customer.name),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedCustomer = value),
                              validator: (value) => value == null ? 'Please select customer' : null,
                            ),
                            SizedBox(height: 16),
                            
                            // Product
                            DropdownButtonFormField<Product>(
                              isExpanded: true,
                              decoration: InputDecoration(labelText: 'Nama Barang *'),
                              value: _selectedProduct,
                              items: _products.map((product) {
                                return DropdownMenuItem(
                                  value: product,
                                  child: Text('${product.name} (${product.sku})'),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedProduct = value),
                              validator: (value) => value == null ? 'Please select product' : null,
                            ),
                            SizedBox(height: 16),
                            
                            // Quantity
                            TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: 'Jumlah Barang *',
                                helperText: 'Stok akan dikurangi otomatis',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter quantity';
                                }
                                final quantity = int.tryParse(value);
                                if (quantity == null || quantity <= 0) {
                                  return 'Please enter valid quantity';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            
                            // Unit
                            DropdownButtonFormField<Unit>(
                              isExpanded: true,
                              decoration: InputDecoration(labelText: 'Satuan *'),
                              value: _selectedUnit,
                              items: _units.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text('${unit.name} (${unit.symbol})'),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedUnit = value),
                              validator: (value) => value == null ? 'Please select unit' : null,
                            ),
                            SizedBox(height: 16),
                            
                            // Location
                            DropdownButtonFormField<Location>(
                              isExpanded: true,
                              decoration: InputDecoration(labelText: 'Lokasi Pengambilan *'),
                              value: _selectedLocation,
                              items: _locations.map((location) {
                                return DropdownMenuItem(
                                  value: location,
                                  child: Text('${location.name} (${location.code})'),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedLocation = value),
                              validator: (value) => value == null ? 'Please select location' : null,
                            ),
                            SizedBox(height: 16),
                            
                            // Remarks
                            TextFormField(
                              controller: _remarksController,
                              decoration: InputDecoration(labelText: 'Catatan'),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Simpan Pengeluaran', style: TextStyle(fontSize: 16)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}