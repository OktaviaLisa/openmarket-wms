import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  bool isLoading = true;
  List<Map<String, dynamic>> tenantAdmins = [];
  List<Map<String, dynamic>> warehouseAdmins = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final users = await _apiService.getUsers();
      setState(() {
        tenantAdmins = List<Map<String, dynamic>>.from(users.where((u) => u['role'] == 'tenant_admin'));
        warehouseAdmins = List<Map<String, dynamic>>.from(users.where((u) => u['role'] == 'warehouse_admin'));
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Tenant Admins', tenantAdmins.length, Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Warehouse Admins', warehouseAdmins.length, Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildAdminList('Tenant Admins', tenantAdmins)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildAdminList('Warehouse Admins', warehouseAdmins)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminList(String title, List<Map<String, dynamic>> admins) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  final admin = admins[index];
                  return ListTile(
                    title: Text(admin['username'] ?? ''),
                    subtitle: Text(admin['email'] ?? ''),
                    trailing: Chip(
                      label: Text(admin['is_active'] ? 'Active' : 'Inactive'),
                      backgroundColor: admin['is_active'] ? Colors.green : Colors.grey,
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