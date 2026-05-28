import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/services/database_service.dart';
import '../models/product_model.dart';
import '../widgets/smart_image.dart';
import '../core/localization_service.dart';
import 'shipping_address_screen.dart';
import 'product_details_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Product? singleProduct;
  const CheckoutScreen({super.key, this.singleProduct});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Cash on Delivery';
  String _shippingAddress = '217A, Main St, Anytown, Sri Lanka';
  List<dynamic> _savedCards = [];
  bool _isLoadingCards = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  Future<void> _loadSavedCards() async {
    final user = AuthService().currentUser;
    if (user != null) {
      final profile = await DatabaseService().getUserProfile(user.uid).first;
      if (profile != null) {
        setState(() {
          if (profile['paymentMethods'] != null) {
            _savedCards = profile['paymentMethods'];
          }
          _isLoadingCards = false;
          
          // Load default address
          if (profile['addresses'] != null) {
            final addresses = profile['addresses'] as List<dynamic>;
            final defaultAddr = addresses.firstWhere((a) => a['isDefault'] == true, orElse: () => addresses.isNotEmpty ? addresses[0] : null);
            if (defaultAddr != null) {
              _shippingAddress = "${defaultAddr['street']}, ${defaultAddr['city']}, ${defaultAddr['zip']}";
            }
          }
        });
      } else {
        setState(() => _isLoadingCards = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    if (user == null) return Scaffold(body: Center(child: Text(LocalizationService().translate('login_to_view_cart'))));

    if (widget.singleProduct != null) {
      // Direct Buy Mode
      double subtotal = widget.singleProduct!.price;
      double tax = subtotal * 0.08;
      double total = subtotal + tax;
      final items = [{'product': widget.singleProduct!, 'quantity': 1}];

      return _buildCheckoutScaffold(context, user.uid, items, subtotal, tax, total);
    }

    // Cart Mode
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseService().getCart(user.uid),
      builder: (context, snapshot) {
        final cartItems = snapshot.data ?? [];
        double subtotal = 0;
        for (var item in cartItems) {
          subtotal += (item['product'] as Product).price * (item['quantity'] as int);
        }
        double tax = subtotal * 0.08;
        double total = subtotal + tax;

        return _buildCheckoutScaffold(context, user.uid, cartItems, subtotal, tax, total);
      }
    );
  }

  Widget _buildCheckoutScaffold(BuildContext context, String uid, List<Map<String, dynamic>> items, double subtotal, double tax, double total) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().translate('checkout'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 120,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).cardColor,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SmartImage(
                  imageUrl: items.isNotEmpty ? (items[0]['product'] as Product).imageUrl : 'assets/images/Footwear/21.jpg',
                  width: double.infinity,
                  height: 120,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(LocalizationService().translate('home_address')),
                  _buildAddressCard(),
                  const SizedBox(height: 32),
                  _buildSectionHeader(LocalizationService().translate('payment_method')),
                  _buildPaymentMethod(LocalizationService().translate('cash_on_delivery'), Icons.payments_outlined, subtitle: LocalizationService().translate('pay_when_receive')),
                  const SizedBox(height: 12),
                  _buildPaymentMethod(LocalizationService().translate('apple_pay'), Icons.apple),
                  const SizedBox(height: 12),
                  if (_isLoadingCards)
                    const Center(child: CircularProgressIndicator())
                  else
                    ..._savedCards.map((card) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPaymentMethod(
                        '${card['type']} •••• ${card['lastFour']}',
                        Icons.credit_card,
                        subtitle: card['cardholderName'],
                      ),
                    )),
                  const SizedBox(height: 32),
                  _buildSectionHeader(LocalizationService().translate('order_summary')),
                  if (items.isEmpty)
                    Text(LocalizationService().translate('no_items'), style: const TextStyle(color: Colors.grey))
                  else
                    ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSummaryItem(
                        item['product'] as Product,
                        item['quantity'] as int,
                      ),
                    )),
                  const SizedBox(height: 32),
                  _buildPromoCodeField(),
                  const SizedBox(height: 32),
                  _buildPriceRow(LocalizationService().translate('subtotal'), LocalizationService().formatPrice(subtotal)),
                  _buildPriceRow(LocalizationService().translate('shipping'), LocalizationService().translate('free'), color: Colors.green),
                  _buildPriceRow(LocalizationService().translate('tax'), LocalizationService().formatPrice(tax)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildPayBar(context, uid, items, total),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
    );
  }

  Widget _buildAddressCard() {
    return GestureDetector(
      onTap: () async {
        final selectedAddress = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShippingAddressScreen()),
        );
        if (selectedAddress != null && mounted) {
          setState(() {
            _shippingAddress = selectedAddress as String;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LocalizationService().translate('home_address'), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text(
                    _shippingAddress,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              child: Text(LocalizationService().translate('select'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String title, IconData icon, {String? subtitle}) {
    final isSelected = _selectedPaymentMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.onSurface : Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  if (subtitle != null) Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300, width: 2),
              ),
              child: isSelected
                  ? Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(Product product, int quantity) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SmartImage(
              imageUrl: product.imageUrl,
              width: 60,
              height: 60,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(LocalizationService().formatPrice(product.price), style: const TextStyle(fontSize: 12, color: AppColors.primary)),
              ],
            ),
          ),
          Text('${LocalizationService().translate('qty')}: $quantity', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPromoCodeField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: LocalizationService().translate('promo_code'),
              prefixIcon: const Icon(Icons.local_offer_outlined),
              fillColor: Theme.of(context).cardColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(100, 56),
          ),
          child: Text(LocalizationService().translate('apply')),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color ?? Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildPayBar(BuildContext context, String uid, List<Map<String, dynamic>> items, double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(LocalizationService().translate('total'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text(LocalizationService().formatPrice(total), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          ElevatedButton(
            onPressed: items.isEmpty ? null : () => _showConfirmationDialog(context, uid, items, total),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              foregroundColor: Theme.of(context).colorScheme.surface,
              minimumSize: const Size(160, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(LocalizationService().translate('pay')),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String uid, List<Map<String, dynamic>> items, double total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(LocalizationService().translate('confirm_payment'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              LocalizationService().translate('confirm_pay_for_items')
                .replaceAll('{price}', LocalizationService().formatPrice(total))
                .replaceAll('{count}', items.length.toString()),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocalizationService().translate('cancel'), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              
              navigator.pop(); // Close dialog
              
              await DatabaseService().placeOrder(
                uid: uid,
                items: items,
                total: total,
                address: _shippingAddress,
                paymentMethod: _selectedPaymentMethod,
              );
              
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text(LocalizationService().translate('order_placed_success')), backgroundColor: Colors.green),
                );
                // We need to go back from the CheckoutScreen as well
                if (Navigator.canPop(this.context)) {
                  Navigator.pop(this.context);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(LocalizationService().translate('confirm_pay')),
          ),
        ],
      ),
    );
  }
}
