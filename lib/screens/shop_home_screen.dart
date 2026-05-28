import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/services/database_service.dart';
import '../models/product_model.dart';
import 'product_details_screen.dart';
import 'product_list_screen.dart';
import 'categories_screen.dart';
import 'wishlist_screen.dart';
import 'notifications_screen.dart';
import '../core/localization_service.dart';
import '../widgets/smart_image.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
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

  bool _showSearchField = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (_showSearchField) _buildAnimatedSearchField(),
              const HomeBanner(),
              _buildSectionHeader(context, LocalizationService().translate('categories'), () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen()));
              }),
              _buildCategoriesGrid(context),
              _buildSectionHeader(context, LocalizationService().translate('top_products'), () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen(categoryName: LocalizationService().translate('top_products'))));
              }),
              _buildTopProductsList(),
              _buildSectionHeader(context, LocalizationService().translate('new_items'), () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen(categoryName: LocalizationService().translate('new_items'))));
              }),
              _buildNewItemsGrid(context),
              _buildSectionHeader(context, LocalizationService().translate('most_popular'), () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen(categoryName: LocalizationService().translate('most_popular'))));
              }),
              _buildMostPopularGrid(context),
              const SizedBox(height: 100), // Added padding for bottom bar
            ],
          ),
        ),
        if (_searchController.text.isNotEmpty) _buildSearchOverlay(),
      ],
    );
  }

  Widget _buildSearchOverlay() {
    return Container(
      margin: const EdgeInsets.only(top: 80),
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

  Widget _buildHeader() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Z E V I X',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 8,
              color: AppColors.primary,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.refresh, color: iconColor, size: 22),
                onPressed: () async {
                  setState(() {}); // Trigger rebuild
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(LocalizationService().translate('refreshing')), duration: const Duration(seconds: 1)),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.search, color: iconColor, size: 22),
                onPressed: () {
                  setState(() {
                    _showSearchField = !_showSearchField;
                    if (!_showSearchField) {
                      _searchController.clear();
                    }
                  });
                },
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_none, color: iconColor, size: 22),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                    },
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.favorite_border, color: iconColor, size: 22),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        onSubmitted: (_) => _onSearch(),
        decoration: InputDecoration(
          hintText: LocalizationService().translate('search_products'),
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
          prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          suffixIcon: IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            onPressed: () {
              _searchController.clear();
              setState(() => _showSearchField = false);
            },
          ),
          fillColor: Theme.of(context).cardColor,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  // Banner method was moved to HomeBanner widget to prevent full-screen flickering

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                children: [
                  Text(LocalizationService().translate('see_all'), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
    return StreamBuilder<List<ProductCategory>>(
      stream: DatabaseService().getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        }
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) return const SizedBox();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85, // Slightly taller to prevent text overflow
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length > 4 ? 4 : categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(context, LocalizationService().translate(category.name), category.imageUrl);
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, String name, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen(categoryName: name)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SmartImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsList() {
    return SizedBox(
      height: 90,
      child: StreamBuilder<List<Product>>(
        stream: DatabaseService().getTopProducts(limit: 8),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2)));
          }
          final topProducts = snapshot.data ?? [];
          if (topProducts.isEmpty) return const SizedBox();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: topProducts.length,
            itemBuilder: (context, index) {
              final product = topProducts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
                  );
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ClipOval(
                    child: SmartImage(
                      imageUrl: product.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        },
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
        _buildProductCard(context, LocalizationService().translate('elegant_flats'), 17.00, 'assets/images/Footwear/22.jpg'),
        _buildProductCard(context, LocalizationService().translate('oxford_shoes'), 32.00, 'assets/images/Footwear/23.jpg'),
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
                  child: SmartImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
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
                              SnackBar(content: Text(LocalizationService().translate('login_to_use_wishlist'))),
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
          const SizedBox(height: 8),
          Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Text(LocalizationService().formatPrice(price), style: const TextStyle(fontWeight: FontWeight.bold)),
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
        _buildPopularItem(context, LocalizationService().translate('new_tag'), 'assets/images/Hoodies/31.jpg', tagKey: 'new_item'),
        _buildPopularItem(context, LocalizationService().translate('sale_tag'), 'assets/images/Hoodies/32.jpg', tagKey: 'sale_item'),
        _buildPopularItem(context, LocalizationService().translate('hot_tag'), 'assets/images/Hoodies/33.jpg', tagKey: 'hot_item'),
      ],
    );
  }

  Widget _buildPopularItem(BuildContext context, String tag, String imageUrl, {String? tagKey}) {
    final product = Product(
      id: tag.toLowerCase(),
      name: tagKey != null ? LocalizationService().translate(tagKey) : '$tag Item',
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
                  child: SmartImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(4)),
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

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < 3 - 1) { // 3 is banner items count
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> bannerItems = [
      {
        'title': LocalizationService().translate('flash_sale'),
        'subtitle': LocalizationService().translate('up_to_50_off'),
        'image': 'assets/images/Clothing/06.jpg',
        'color': '0xFF81C7D4',
        'category': 'Flash Sale'
      },
      {
        'title': LocalizationService().translate('new_arrival'),
        'subtitle': LocalizationService().translate('autumn_collection'),
        'image': 'assets/images/Hoodies/31.jpg',
        'color': '0xFFD4A5A5',
        'category': 'New Arrival'
      },
      {
        'title': LocalizationService().translate('footwear_pro'),
        'subtitle': LocalizationService().translate('step_into_style'),
        'image': 'assets/images/Footwear/21.jpg',
        'color': '0xFF9DC08B',
        'category': 'Footwear'
      },
    ];

    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemCount: bannerItems.length,
        itemBuilder: (context, index) {
          final item = bannerItems[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductListScreen(categoryName: item['category']!),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(int.parse(item['color']!)),
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
                        Text(
                          item['title']!,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          item['subtitle']!,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(bannerItems.length, (dotIndex) {
                            return Container(
                              margin: const EdgeInsets.only(right: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == dotIndex ? Colors.white : Colors.white54,
                              ),
                            );
                          }),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(12)),
                      child: SmartImage(
                        imageUrl: item['image']!,
                        height: 160,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
