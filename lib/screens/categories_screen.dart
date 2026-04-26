import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'product_list_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.grey.shade200,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildCategoryItem(
                  context,
                  'Clothing',
                  'https://images.unsplash.com/photo-1516762689617-e1cffcef479d?w=100&h=100&fit=crop',
                  isExpanded: true,
                ),
                _buildCategoryItem(
                  context,
                  'Footwear',
                  'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=100&h=100&fit=crop',
                ),
                _buildCategoryItem(
                  context,
                  'Hoodies',
                  'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=100&h=100&fit=crop',
                ),
                _buildCategoryItem(
                  context,
                  'Accessories',
                  'https://images.unsplash.com/photo-1617038220319-276d3cfab638?w=100&h=100&fit=crop',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, String imageUrl, {bool isExpanded = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl, width: 40, height: 40, fit: BoxFit.cover),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen(categoryName: title)));
            },
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildSubCategory(context, 'Dresses'),
                  _buildSubCategory(context, 'Pants'),
                  _buildSubCategory(context, 'Jeans'),
                  _buildSubCategory(context, 'Shorts'),
                  _buildSubCategory(context, 'Jackets'),
                  _buildSubCategory(context, 'Hoodies'),
                  _buildSubCategory(context, 'Shirts'),
                  _buildSubCategory(context, 'Polo'),
                  _buildSubCategory(context, 'T-Shirts'),
                  _buildSubCategory(context, 'Tunics'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubCategory(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen(categoryName: title)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(title, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
