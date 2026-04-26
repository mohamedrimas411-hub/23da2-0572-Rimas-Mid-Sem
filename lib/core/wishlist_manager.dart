import 'package:flutter/material.dart';
import '../models/product_model.dart';

class WishlistManager {
  static final ValueNotifier<List<Product>> wishlistNotifier = ValueNotifier<List<Product>>([]);

  static List<Product> get items => wishlistNotifier.value;

  static void toggle(Product product) {
    final List<Product> current = List.from(wishlistNotifier.value);
    final int index = current.indexWhere((p) => p.id == product.id);
    
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.add(product);
    }
    
    wishlistNotifier.value = current;
  }

  static bool isFavorite(String productId) {
    return wishlistNotifier.value.any((p) => p.id == productId);
  }
}
