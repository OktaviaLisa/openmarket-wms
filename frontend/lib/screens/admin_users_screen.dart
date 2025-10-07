import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> roles = [
    {'value': 'admin', 'label': 'Admin'},
    {'value': 'warehouse_management', 'label': 'Warehouse Management'},
    {'value': 'operator_gudang', 'label': 'Operator Gudang'},
    {'value': 'checker', 'label': 'Checker'},
    {'value': 'qc', 'label': 'Quality Control'},
    {'value': 'picker', 'label': 'Picker'},
    {'value': 'user', 'label': 'User'},
  ];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final userData = await _apiService.getUsers();
      setState(() {
        users = List<Map<String, dynamic>>.from(userData);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  Future<void> _showUserDialog([Map<String, dynamic>? user]) async {
    final usernameController = TextEditingController(text: user?['username'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController(text: user?['first_name'] ?? '');
    final lastNameController = TextEditingController(text: user?['last_name'] ?? '');
    List<String> selectedRoles = List<String>.from(user?['roles'] ?? [user?['role']].where((r) => r != null));

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(user == null ? 'Add User' : 'Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  enabled: user == null,
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  enabled: user == null,
                ),
                if (user == null)
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                const SizedBox(height: 16),
                const Text('Roles:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...roles.map((role) => CheckboxListTile(
                  title: Text(role['label']),
                  value: selectedRoles.contains(role['value']),
                  onChanged: (bool? value) {
                    setDialogState(() {
                      if (value == true) {
                        selectedRoles.add(role['value']);
                      } else {
                        selectedRoles.remove(role['value']);
                      }
                    });
                  },
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'username': usernameController.text,
                  'email': emailController.text,
                  'first_name': firstNameController.text,
                  'last_name': lastNameController.text,
                  'roles': selectedRoles,
                  'role': selectedRoles.isNotEmpty ? selectedRoles.first : '',
                };

                if (user == null && passwordController.text.isNotEmpty) {
                  data['password'] = passwordController.text;
                }

                try {
                  if (user == null) {
                    await _apiService.createUser(data);
                  } else {
                    await _apiService.updateUser(user['id'], data);
                  }
                  Navigator.pop(context);
                  _loadUsers();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving user: $e')),
                  );
                }
              },
              child: Text(user == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate User'),
        content: const Text('Are you sure you want to deactivate this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteUser(id);
        _loadUsers();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deactivating user: $e')),
          );
        }
      }
    }
  }

  String _getRoleLabel(String role) {
    final roleObj = roles.firstWhere((r) => r['value'] == role, orElse: () => {'label': role});
    return roleObj['label'];
  }

  Color _getRoleColor(String role) {
    const colors = {
      'admin': Colors.red,
      'warehouse_management': Colors.blue,
      'operator_gudang': Colors.purple,
      'checker': Colors.cyan,
      'qc': Colors.orange,
      'picker': Colors.green,
      'user': Colors.grey,
    };
    return colors[role] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showUserDialog(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: users.isEmpty
                  ? const Center(child: Text('No users found'))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final userRoles = List<String>.from(user['roles'] ?? [user['role']].where((r) => r != null));
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(user['username'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'),
                                Text('Email: ${user['email'] ?? ''}'),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  children: userRoles.map((role) => Chip(
                                    label: Text(
                                      _getRoleLabel(role),
                                      style: const TextStyle(fontSize: 10, color: Colors.white),
                                    ),
                                    backgroundColor: _getRoleColor(role),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  )).toList(),
                                ),
                                Chip(
                                  label: Text(
                                    user['is_active'] == true ? 'Active' : 'Inactive',
                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                  ),
                                  backgroundColor: user['is_active'] == true ? Colors.green : Colors.grey,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _showUserDialog(user),
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () => _deleteUser(user['id']),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}