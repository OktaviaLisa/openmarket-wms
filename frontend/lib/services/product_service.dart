import '../models/product.dart';

class ProductService {
  static Future<List<Product>> getProducts() async {
    try {
      return [
        Product(
          id: 1,
          name: 'Laptop Dell',
          sku: 'LAPTOP-001',
          category: 1,
          categoryName: 'Electronics',
          description: 'Laptop untuk kantor',
          price: 8500000.0,
          createdAt: DateTime.now(),
        ),
        Product(
          id: 2,
          name: 'Mouse Wireless',
          sku: 'MOUSE-001',
          category: 1,
          categoryName: 'Electronics',
          description: 'Mouse wireless ergonomis',
          price: 150000.0,
          createdAt: DateTime.now(),
        ),
        Product(
          id: 3,
          name: 'Keyboard Mechanical',
          sku: 'KEYBOARD-001',
          category: 1,
          categoryName: 'Electronics',
          description: 'Keyboard gaming mechanical',
          price: 750000.0,
          createdAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}