import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryDropdown extends StatefulWidget {
  final int? selectedCategoryId;
  final Function(int?) onChanged;
  final String? hintText;

  const CategoryDropdown({
    Key? key,
    this.selectedCategoryId,
    required this.onChanged,
    this.hintText,
  }) : super(key: key);

  @override
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return DropdownButtonFormField<int>(
      value: widget.selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Kategori',
        hintText: widget.hintText ?? 'Pilih kategori',
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<int>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: widget.onChanged,
      validator: (value) {
        if (value == null) {
          return 'Kategori harus dipilih';
        }
        return null;
      },
    );
  }
}