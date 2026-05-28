import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/product_model.dart';
import '../core/services/auth_service.dart';
import '../core/services/database_service.dart';
import 'checkout_screen.dart';
import '../core/localization_service.dart';
import '../widgets/smart_image.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String _selectedSize = 'M';
  String _selectedMaterial = 'Cotton 95%';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Share.share(
                LocalizationService().translate('check_out_amazing_product')
                  .replaceAll('{name}', widget.product.name)
                  .replaceAll('{price}', LocalizationService().formatPrice(widget.product.price))
              );
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SmartImage(
              imageUrl: widget.product.imageUrl,
              width: double.infinity,
              height: 500,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 8, color: AppColors.primary),
                      SizedBox(width: 4),
                      Icon(Icons.circle, size: 8, color: Colors.grey),
                      SizedBox(width: 4),
                      Icon(Icons.circle, size: 8, color: Colors.grey),
                      SizedBox(width: 4),
                      Icon(Icons.circle, size: 8, color: Colors.grey),
                      SizedBox(width: 4),
                      Icon(Icons.circle, size: 8, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocalizationService().formatPrice(widget.product.price),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  Text(LocalizationService().translate('specifications'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(LocalizationService().translate('material'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChip(LocalizationService().translate('cotton_95')),
                      const SizedBox(width: 12),
                      _buildChip(LocalizationService().translate('nylon_5')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(LocalizationService().translate('size'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSizeChip('S'),
                      const SizedBox(width: 12),
                      _buildSizeChip('M'),
                      const SizedBox(width: 12),
                      _buildSizeChip('L'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => _showSizeGuide(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(LocalizationService().translate('size_guide'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(LocalizationService().translate('delivery'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildDeliveryOption(LocalizationService().translate('standart'), LocalizationService().translate('delivery_time_standard'), LocalizationService().formatPrice(3.00)),
                  const SizedBox(height: 12),
                  _buildDeliveryOption(LocalizationService().translate('express'), LocalizationService().translate('delivery_time_express'), LocalizationService().formatPrice(12.00)),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      StreamBuilder<bool>(
                        stream: AuthService().currentUser != null
                            ? DatabaseService().isProductInWishlist(AuthService().currentUser!.uid, widget.product.id)
                            : Stream.value(false),
                        builder: (context, snapshot) {
                          final isFavorite = snapshot.data ?? false;
                          return GestureDetector(
                            onTap: () async {
                              final user = AuthService().currentUser;
                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(LocalizationService().translate('login_to_use_wishlist'))),
                                );
                                return;
                              }
                              await DatabaseService().toggleWishlist(user.uid, widget.product);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: isFavorite ? AppColors.primary : Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                                color: isFavorite ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                              ),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final user = AuthService().currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(LocalizationService().translate('login_to_view_cart'))),
                              );
                              return;
                            }
                            await DatabaseService().addToCart(user.uid, widget.product);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(LocalizationService().translate('added_to_cart_success')),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.onSurface,
                            foregroundColor: Theme.of(context).colorScheme.surface,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(LocalizationService().translate('add_to_cart')),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutScreen(singleProduct: widget.product),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(LocalizationService().translate('buy_now')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(LocalizationService().translate('rating_reviews'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const Icon(Icons.star_border, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text('4/5', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: SmartImage(
                            imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(LocalizationService().translate('sample_reviewer'), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.orange, size: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    LocalizationService().translate('sample_review_text'),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text(LocalizationService().translate('view_all_reviews')),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    final isSelected = _selectedMaterial == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMaterial = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildSizeChip(String label) {
    final isSelected = _selectedSize == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSize = label;
        });
      },
      child: Container(
        width: 50,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryOption(String title, String subtitle, String price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showSizeGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text(LocalizationService().translate('size_chart'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(LocalizationService().translate('measurements_cm'), style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Table(
              border: TableBorder.all(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
              children: [
                _buildTableRow([
                  LocalizationService().translate('size'),
                  LocalizationService().translate('chest'),
                  LocalizationService().translate('waist'),
                  LocalizationService().translate('length')
                ], isHeader: true),
                _buildTableRow(['S', '92-96', '78-82', '68']),
                _buildTableRow(['M', '97-101', '83-87', '70']),
                _buildTableRow(['L', '102-106', '88-92', '72']),
                _buildTableRow(['XL', '107-111', '93-97', '74']),
              ],
            ),
            const SizedBox(height: 32),
            Text(LocalizationService().translate('how_to_measure'), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(LocalizationService().translate('measure_chest_desc'), style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 4),
            Text(LocalizationService().translate('measure_waist_desc'), style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(color: isHeader ? AppColors.primary.withValues(alpha: 0.1) : null),
      children: cells.map((cell) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          cell,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: isHeader ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      )).toList(),
    );
  }
}
