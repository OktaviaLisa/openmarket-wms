import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_models.dart';
import '../services/transaction_service.dart';
import 'reception_form_screen.dart';
import 'dispatch_form_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  TransactionListScreenState createState() => TransactionListScreenState();
}

class TransactionListScreenState extends State<TransactionListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Receiving> _receivings = [];
  List<Issuing> _issuings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final receivings = await TransactionService.getReceivings();
      final issuings = await TransactionService.getIssuings();
      
      setState(() {
        _receivings = receivings;
        _issuings = issuings;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Barang'),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Penerimaan', icon: Icon(Icons.arrow_downward)),
            Tab(text: 'Pengeluaran', icon: Icon(Icons.arrow_upward)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReceivingList(),
                _buildIssuingList(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReceivingList() {
    if (_receivings.isEmpty) {
      return const Center(
        child: Text('Belum ada data penerimaan barang'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _receivings.length,
        itemBuilder: (context, index) {
          final receiving = _receivings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: const Icon(Icons.arrow_downward, color: Colors.white),
              ),
              title: Text(receiving.documentNumber ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Produk: ${receiving.productName }'),
                  Text('Supplier: ${receiving.supplierName }'),
                  Text('Jumlah: ${receiving.quantity} ${receiving.unitSymbol }'),
                ],
              ),
              trailing: Text(
                DateFormat('dd/MM/yyyy').format(receiving.receiveDate  ),
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () => _showTransactionDetail(receiving),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIssuingList() {
    if (_issuings.isEmpty) {
      return const Center(
        child: Text('Belum ada data pengeluaran barang'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _issuings.length,
        itemBuilder: (context, index) {
          final issuing = _issuings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red,
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
              title: Text(issuing.documentNumber ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Produk: ${issuing.productName }'),
                  Text('Customer: ${issuing.customerName }'),
                  Text('Jumlah: ${issuing.quantity} ${issuing.unitSymbol }'),
                ],
              ),
              trailing: Text(
                DateFormat('dd/MM/yyyy').format(issuing.issueDate ),
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () => _showTransactionDetail(issuing),
            ),
          );
        },
      ),
    );
  }

  void _showTransactionDetail(dynamic transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Transaksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No. Dokumen: ${transaction.documentNumber ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Produk: ${transaction.productName ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Jumlah: ${transaction.quantity} ${transaction.unitSymbol ?? ''}'),
            const SizedBox(height: 8),
            Text('Lokasi: ${transaction.locationName ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Catatan: ${transaction.remarks ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Transaksi'),
        content: const Text('Pilih jenis transaksi yang ingin ditambahkan:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReceptionFormScreen()),
              );
            },
            child: const Text('Penerimaan'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DispatchFormScreen()),
              );
            },
            child: const Text('Pengeluaran'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}