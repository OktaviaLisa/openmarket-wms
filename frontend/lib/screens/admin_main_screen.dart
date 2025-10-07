import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_products_screen.dart';
import 'admin_users_screen.dart';
import 'admin_inventory_screen.dart';
import 'admin_reports_screen.dart';
import 'profile_screen.dart';

class AdminMainScreen extends StatefulWidget {
  final String token;
  final String username;
  
  const AdminMainScreen({
    super.key,
    required this.token,
    required this.username,
  });

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late final List<String> _titles;

  @override
  void initState() {
    super.initState();
    _screens = [
      const AdminDashboardScreen(),
      const AdminProductsScreen(),
      const AdminUsersScreen(),
      const AdminInventoryScreen(),
      const AdminReportsScreen(),
      ProfileScreen(username: widget.username),
    ];
    _titles = [
      'Dashboard',
      'Products',
      'Users',
      'Inventory',
      'Reports',
      'Profile',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warehouse),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}