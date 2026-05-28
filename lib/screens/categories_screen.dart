import 'package:flutter/material.dart';
import '../core/services/database_service.dart';
import '../core/localization_service.dart';
import '../models/product_model.dart';
import 'product_list_screen.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import '../widgets/smart_image.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductListScreen(
            categoryName: LocalizationService().translate('search_results'),
            searchQuery: query,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().translate('all_categories'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _onSearch(),
                  decoration: InputDecoration(
                    hintText: LocalizationService().translate('search'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<List<ProductCategory>>(
                  stream: DatabaseService().getCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('${LocalizationService().translate('error')}: ${snapshot.error}'));
                    }
                    final categories = snapshot.data ?? [];
                    if (categories.isEmpty) {
                      return Center(child: Text(LocalizationService().translate('no_categories')));
                    }
                    return ListView.builder(
                      itemCount: categories.length,
                      padding: const EdgeInsets.only(bottom: 100),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _buildCategoryItem(
                          context,
                          LocalizationService().translate(category.name),
                          category.imageUrl,
                          category.subCategories,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (_searchController.text.isNotEmpty) _buildSearchOverlay(),
        ],
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      color: Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      child: StreamBuilder<List<Product>>(
        stream: DatabaseService().searchProducts(_searchController.text),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ));
          }
          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(LocalizationService().translate('no_results'), style: const TextStyle(color: Colors.grey)),
            );
          }
          return ListView.builder(
            itemCount: results.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final product = results[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SmartImage(imageUrl: product.imageUrl, width: 50, height: 50),
                ),
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(LocalizationService().formatPrice(product.price)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, String imageUrl, List<String> subCategories) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SmartImage(imageUrl: imageUrl, width: 40, height: 40),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen(categoryName: title)));
        },
      ),
    );
  }
}
