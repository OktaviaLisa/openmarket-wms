class Product {
  final int id;
  final String name;
  final String sku;
  final int category;
  final String categoryName;
  final String description;
  final double price;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.categoryName,
    required this.description,
    required this.price,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      category: json['category'],
      categoryName: json['category_name'] ?? '',
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'description': description,
      'price': price.toString(),
    };
  }
}