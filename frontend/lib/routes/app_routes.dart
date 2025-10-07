import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/picking_screen.dart';
import '../screens/checking_screen.dart';
import '../screens/quality_control_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/stock_opname_screen.dart';
import '../screens/stock_movement_screen.dart';
import '../screens/inventory_monitoring_screen.dart';
import '../screens/reception_screen.dart';
import '../screens/dispatch_screen.dart';
import '../screens/returns_screen.dart';
import '../screens/inventory_reports_screen.dart';
import '../screens/goods_receipt_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_products_screen.dart';
import '../screens/admin_users_screen.dart';
import '../screens/admin_inventory_screen.dart';
import '../screens/admin_reports_screen.dart';
import '../screens/transaction_list_screen.dart';
import '../screens/receiving_form_screen.dart';
import '../screens/issuing_form_screen.dart';
import '../screens/admin_main_dashboard.dart';
import '../screens/category_management_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    // Core routes
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    // Admin routes
    '/admin-dashboard': (context) => const AdminMainDashboard(),
    '/admin-dashboard-old': (context) => const AdminDashboardScreen(),
    '/admin-products': (context) => const AdminProductsScreen(),
    '/admin-users': (context) => const AdminUsersScreen(),
    '/admin-inventory': (context) => const AdminInventoryScreen(),
    '/admin-reports': (context) => const AdminReportsScreen(),
    
    // Warehouse routes
    '/goods-receipt': (context) => const GoodsReceiptScreen(),
    '/picking': (context) => const PickingScreen(),
    '/checking': (context) => const CheckingScreen(),
    '/quality-control': (context) => const QualityControlScreen(),
    '/inventory': (context) => const InventoryScreen(),
    '/stock-opname': (context) => const StockOpnameScreen(),
    '/stock-movement': (context) => const StockMovementScreen(),
    '/inventory-monitoring': (context) => const InventoryMonitoringScreen(),
    '/reception': (context) => const ReceptionScreen(),
    '/dispatch': (context) => const DispatchScreen(),
    '/returns': (context) => const ReturnsScreen(),
    '/inventory-reports': (context) => const InventoryReportsScreen(),
    
    // Dashboard menu routes
    '/move-location': (context) => const StockMovementScreen(),
    '/inbound': (context) => const ReceptionScreen(),
    '/outbound': (context) => const DispatchScreen(),
    '/locations': (context) => const InventoryScreen(),
    '/transactions': (context) => const TransactionListScreen(),
    '/receiving-form': (context) => ReceivingFormScreen(),
    '/issuing-form': (context) => IssuingFormScreen(),
    '/category-management': (context) => const CategoryManagementScreen(),
  };
}