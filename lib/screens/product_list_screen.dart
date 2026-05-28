import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/services/database_service.dart';
import '../models/product_model.dart';
import 'product_details_screen.dart';
import '../core/localization_service.dart';
import '../widgets/smart_image.dart';
import 'cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String categoryName;
  final String? searchQuery;

  const ProductListScreen({super.key, this.categoryName = 'Products', this.searchQuery});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late TextEditingController _searchController;
  bool _isSearching = false;
  String? _currentQuery;
  String _sortBy = 'default';

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.searchQuery;
    _searchController = TextEditingController(text: _currentQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(LocalizationService().translate('sort_by'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSortOption(LocalizationService().translate('price_low_high'), 'price_asc'),
            _buildSortOption(LocalizationService().translate('price_high_low'), 'price_desc'),
            _buildSortOption(LocalizationService().translate('top_rated'), 'rating'),
            _buildSortOption(LocalizationService().translate('default_label'), 'default'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = _sortBy == value;
    return ListTile(
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.primary : Colors.black)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: LocalizationService().translate('search_in_category'),
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _currentQuery = value.trim().isEmpty ? null : value.trim();
                  });
                },
                onSubmitted: (value) {
                  setState(() {
                    _isSearching = false;
                  });
                },
              )
            : Text(_currentQuery != null ? LocalizationService().translate('search_query').replaceAll('{query}', _currentQuery!) : widget.categoryName,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.text = _currentQuery ?? '';
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.tune, color: _sortBy != 'default' ? AppColors.primary : Theme.of(context).colorScheme.onSurface),
            onPressed: _showSortSheet,
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _currentQuery != null
            ? DatabaseService().searchProducts(_currentQuery!, categoryName: widget.categoryName)
            : (widget.categoryName == 'New Arrival' || 
               widget.categoryName == 'Flash Sale' || 
               widget.categoryName == LocalizationService().translate('most_popular') ||
               widget.categoryName == LocalizationService().translate('top_products') ||
               widget.categoryName == LocalizationService().translate('new_items'))
                ? DatabaseService().getTopProducts(limit: 20)
                : DatabaseService().getProductsByCategory(widget.categoryName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          var products = snapshot.data ?? [];
          
          // Apply Sorting
          if (_sortBy == 'price_asc') {
            products.sort((a, b) => a.price.compareTo(b.price));
          } else if (_sortBy == 'price_desc') {
            products.sort((a, b) => b.price.compareTo(a.price));
          } else if (_sortBy == 'rating') {
            products.sort((a, b) => b.rating.compareTo(a.rating));
          }

          if (products.isEmpty) {
            return Center(child: Text(LocalizationService().translate('no_products_found')));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) => _buildProductCard(context, products[index]),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SmartImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StreamBuilder<bool>(
                      stream: AuthService().currentUser != null
                          ? DatabaseService().isProductInWishlist(AuthService().currentUser!.uid, product.id)
                          : Stream.value(false),
                      builder: (context, snapshot) {
                        final isFav = snapshot.data ?? false;
                        return GestureDetector(
                          onTap: () async {
                            final user = AuthService().currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(LocalizationService().translate('login_wishlist'))),
                              );
                              return;
                            }
                            await DatabaseService().toggleWishlist(user.uid, product);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text(LocalizationService().formatPrice(product.price), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(' ${product.rating}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          final user = AuthService().currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(LocalizationService().translate('login_cart'))),
                            );
                            return;
                          }
                          await DatabaseService().addToCart(user.uid, product);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(LocalizationService().translate('added_to_cart_success')),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
