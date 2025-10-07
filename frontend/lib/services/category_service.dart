import '../models/category.dart';
import 'api_service.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<Category>> getCategories() async {
    final response = await _apiService.getCategories();
    return response.map<Category>((json) => Category.fromJson(json)).toList();
  }

  Future<Category> createCategory(String name, String? description) async {
    final data = {
      'name': name,
      if (description != null) 'description': description,
    };
    final response = await _apiService.createCategory(data);
    return Category.fromJson(response);
  }

  Future<Category> updateCategory(int id, String name, String? description) async {
    final data = {
      'name': name,
      if (description != null) 'description': description,
    };
    final response = await _apiService.updateCategory(id, data);
    return Category.fromJson(response);
  }

  Future<void> deleteCategory(int id) async {
    await _apiService.deleteCategory(id);
  }
}