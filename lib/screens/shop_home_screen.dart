import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/wishlist_manager.dart';
import '../models/product_model.dart';
import 'product_details_screen.dart';
import 'product_list_screen.dart';

class ShopHomeScreen extends StatelessWidget {
  const ShopHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildFlashSaleBanner(),
              _buildSectionHeader(context, 'Categories', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListScreen(categoryName: 'All Categories')));
              }),
              _buildCategoriesGrid(context),
              _buildSectionHeader(context, 'Top Products', null),
              _buildTopProductsList(),
              _buildSectionHeader(context, 'New Items', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListScreen(categoryName: 'New Items')));
              }),
              _buildNewItemsGrid(context),
              _buildSectionHeader(context, 'Most Popular', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListScreen(categoryName: 'Most Popular')));
              }),
              _buildMostPopularGrid(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'Shop',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                fillColor: Colors.grey.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSaleBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF81C7D4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Flash Sale',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Up to 50%',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Spacer(),
                const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.white),
                    SizedBox(width: 4),
                    Icon(Icons.circle, size: 8, color: Colors.white54),
                    SizedBox(width: 4),
                    Icon(Icons.circle, size: 8, color: Colors.white54),
                    SizedBox(width: 4),
                    Icon(Icons.circle, size: 8, color: Colors.white54),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.network(
              'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400',
              height: 160,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                children: [
                  const Text('See All', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildCategoryCard(context, 'Clothing', [
          'https://images.unsplash.com/photo-1516762689617-e1cffcef479d?w=100',
          'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=100',
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=100',
          'https://images.unsplash.com/photo-1534030347209-467a5b0ad3e6?w=100',
        ]),
        _buildCategoryCard(context, 'Footwear', [
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=100',
          'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=100',
          'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=100',
          'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=100',
        ]),
        _buildCategoryCard(context, 'Accessories', [
          'https://images.unsplash.com/photo-1617038220319-276d3cfab638?w=100',
          'https://images.unsplash.com/photo-1627123424574-724758594e93?w=100',
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=100',
          'https://images.unsplash.com/photo-1509319117193-57bab727e09d?w=100',
        ]),
        _buildCategoryCard(context, 'Hoodies', [
          'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=100',
          'https://images.unsplash.com/photo-1578587018452-892bacefd3f2?w=100',
          'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=100',
          'https://images.unsplash.com/photo-1509942704431-43b48105d18b?w=100',
        ]),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, String name, List<String> images) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen(categoryName: name)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(images[index], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsList() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          width: 60,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewItemsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.7,
      children: [
        _buildProductCard(context, 'Nike Mens Flex Control TR3 Sneaker', 17.00, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300'),
        _buildProductCard(context, 'White men\'s sneaker sports casual urban shoes', 32.00, 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=300'),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, String name, double price, String imageUrl) {
    final product = Product(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      description: 'A stylish and comfortable product from our collection.',
      price: price,
      imageUrl: imageUrl,
      category: 'General',
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: ValueListenableBuilder<List<Product>>(
                    valueListenable: WishlistManager.wishlistNotifier,
                    builder: (context, wishlist, child) {
                      final bool isFav = WishlistManager.isFavorite(product.id);
                      return GestureDetector(
                        onTap: () => WishlistManager.toggle(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
          const SizedBox(height: 8),
          Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Text('\$${price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMostPopularGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.6,
      children: [
        _buildPopularItem(context, 'New', 'https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?w=200'),
        _buildPopularItem(context, 'Sale', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200'),
        _buildPopularItem(context, 'Hot', 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=200'),
      ],
    );
  }

  Widget _buildPopularItem(BuildContext context, String tag, String imageUrl) {
    final product = Product(
      id: tag.toLowerCase(),
      name: '$tag Item',
      description: 'Popular choice for our customers.',
      price: 19.99,
      imageUrl: imageUrl,
      category: 'Popular',
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                ),
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    child: const Text('1780❤️', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
