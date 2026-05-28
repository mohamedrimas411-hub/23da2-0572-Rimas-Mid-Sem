import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/product_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _categoriesRef => _db.collection('categories');
  CollectionReference get _productsRef => _db.collection('products');
  CollectionReference get _usersRef => _db.collection('users');

  // User Profile Operations
  Stream<Map<String, dynamic>?> getUserProfile(String uid) {
    return _usersRef.doc(uid).snapshots().map((snapshot) {
      return snapshot.data() as Map<String, dynamic>?;
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _usersRef.doc(uid).set(data, SetOptions(merge: true));
  }

  // Fetch Categories
  Stream<List<ProductCategory>> getCategories() {
    return _categoriesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map<ProductCategory>((doc) => ProductCategory.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Fetch Products by Category
  Stream<List<Product>> getProductsByCategory(String categoryName) {
    return _productsRef
        .where('category', isEqualTo: categoryName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map<Product>((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Fetch All Products (for Top Products, etc.)
  Stream<List<Product>> getTopProducts({int limit = 10}) {
    return _productsRef
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map<Product>((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Search Products
  Stream<List<Product>> searchProducts(String query, {String? categoryName}) {
    String standardizedQuery = query.trim().toLowerCase();
    
    if (standardizedQuery.isEmpty) {
      return Stream.value([]);
    }

    Query baseQuery = _productsRef;
    
    if (categoryName != null && categoryName != 'Products' && categoryName != 'Search Results') {
      baseQuery = baseQuery.where('category', isEqualTo: categoryName);
    }

    return baseQuery
        .where('searchKeywords', arrayContains: standardizedQuery)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map<Product>((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Auto Seeding Mechanism
  Future<void> autoSeed() async {
    final productSnapshot = await _productsRef.get();
    final categorySnapshot = await _categoriesRef.get();
    
    bool needsUpdate = false;
    if (productSnapshot.docs.isEmpty || categorySnapshot.docs.isEmpty) {
      needsUpdate = true;
    } else {
      // Check all products for any remaining network images or missing keywords
      for (var doc in productSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String name = data['name']?.toString() ?? '';
        final String imageUrl = data['imageUrl']?.toString() ?? '';
        final hasKeywords = data.containsKey('searchKeywords');
        
        if (!name.startsWith('Zevix') || imageUrl.startsWith('http') || !hasKeywords) {
          needsUpdate = true;
          break;
        }
      }
      
      // Also check categories for network images
      if (!needsUpdate) {
        for (var doc in categorySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final String imageUrl = data['imageUrl']?.toString() ?? '';
          if (imageUrl.startsWith('http')) {
            needsUpdate = true;
            break;
          }
        }
      }
    }

    if (needsUpdate) {
      debugPrint('Seeding/Updating database with local assets...');
      
      // Professional cleanup: clear old/broken data before re-seeding
      final oldCategories = await _categoriesRef.get();
      for (var doc in oldCategories.docs) {
        await doc.reference.delete();
      }
      
      final oldProducts = await _productsRef.get();
      for (var doc in oldProducts.docs) {
        await doc.reference.delete();
      }

      await _seedCategories();
      await _seedProducts();
      debugPrint('Update complete.');
    } else {
      debugPrint('Database already seeded with local assets.');
    }
  }

  Future<void> _seedCategories() async {
    final List<ProductCategory> categories = [
      ProductCategory(
        name: 'Clothing',
        imageUrl: 'assets/images/Clothing/01.jpg',
        subCategories: ['Dresses', 'Pants', 'Jeans', 'Shorts', 'Jackets', 'Shirts', 'T-Shirts'],
      ),
      ProductCategory(
        name: 'Footwear',
        imageUrl: 'assets/images/Footwear/21.jpg',
        subCategories: ['Sneakers', 'Boots', 'Sandals', 'Formal'],
      ),
      ProductCategory(
        name: 'Hoodies',
        imageUrl: 'assets/images/Hoodies/31.jpg',
        subCategories: ['Oversized', 'Zip-up', 'Pullover'],
      ),
      ProductCategory(
        name: 'Accessories',
        imageUrl: 'assets/images/Accessories/11.jpg',
        subCategories: ['Bags', 'Watches', 'Jewelry', 'Sunglasses'],
      ),
    ];

    for (var category in categories) {
      await _categoriesRef.doc(category.name).set(category.toMap());
    }
  }

  Future<void> _seedProducts() async {
    // Branded Names based on visual analysis
    final clothingNames = [
      'Zevix Heritage Utility Over-shirt', 'Zevix Traditional Embroidered Kurta', 'Zevix Textured Linen Casual Shirt',
      'Zevix Minimalist Pale Yellow Shirt', 'Zevix Forest Green Relaxed Shirt', 'Zevix Stealth Bomber Jacket',
      'Zevix Tailored Wool Pants', 'Zevix Summer Breeze Shorts', 'Zevix Heritage Plaid Shirt',
      'Zevix Active Performance Top'
    ];

    final accessoryNames = [
      'Zevix Onyx Leather Bifold Wallet', 'Zevix Urban Anti-theft Sling Bag', 'Zevix Crystal Edition Watch',
      'Zevix Retro Black Shades', 'Zevix Artisan Leather Belt', 'Zevix Minimalist Card Holder',
      'Zevix Aviator Classic Gold', 'Zevix Tech Organizer Pro', 'Zevix Gold Leaf Bracelet',
      'Zevix Premium Canvas Tote'
    ];

    final footwearNames = [
      'Zevix Striped Sport Slides', 'Zevix Elegant Buckle Flats', 'Zevix Premium Oxford Shoes',
      'Zevix Urban Green Sneakers', 'Zevix Classic Tan Sneakers', 'Zevix Urban Street High-Tops',
      'Zevix Classic Canvas Lows', 'Zevix Rugged Terrain Boots', 'Zevix Breeze Mesh Slip-ons',
      'Zevix Elite Oxford Brogues'
    ];

    final hoodieNames = [
      'Zevix Panda Print Fun Hoodie', 'Zevix Peace Graphic Hoodie', 'Zevix TODAY Graphic Hoodie',
      'Zevix Urban Stealth Hoodie', 'Zevix Pastel Breeze Sweatshirt', 'Zevix Vintage Wash Hoodie',
      'Zevix Core Athleisure Hoodie', 'Zevix Arctic Shield Hoodie', 'Zevix Lounge Soft-Touch Hoodie',
      'Zevix Signature Embroidered'
    ];

    List<Map<String, dynamic>> allProducts = [];

    // Clothing
    for (int i = 0; i < 10; i++) {
      final fileName = (i + 1) < 10 ? '0${i + 1}.jpg' : '${i + 1}.jpg';
      allProducts.add({
        'id': 'clothing_${i + 1}',
        'name': clothingNames[i],
        'category': 'Clothing',
        'imageUrl': 'assets/images/Clothing/$fileName',
        'price': 35.0 + (i * 5),
      });
    }

    // Accessories
    for (int i = 0; i < 10; i++) {
      final index = i + 11;
      allProducts.add({
        'id': 'acc_$index',
        'name': accessoryNames[i],
        'category': 'Accessories',
        'imageUrl': 'assets/images/Accessories/$index.jpg',
        'price': 45.0 + (i * 3),
      });
    }

    // Footwear
    for (int i = 0; i < 10; i++) {
      final index = i + 21;
      allProducts.add({
        'id': 'foot_$index',
        'name': footwearNames[i],
        'category': 'Footwear',
        'imageUrl': 'assets/images/Footwear/$index.jpg',
        'price': 65.0 + (i * 10),
      });
    }

    // Hoodies
    for (int i = 0; i < 10; i++) {
      final index = i + 31;
      allProducts.add({
        'id': 'hoodie_$index',
        'name': hoodieNames[i],
        'category': 'Hoodies',
        'imageUrl': 'assets/images/Hoodies/$index.jpg',
        'price': 55.0 + (i * 4),
      });
    }

    for (var data in allProducts) {
      final name = data['name'] as String;
      final category = data['category'] as String;
      
      // Generate keywords for search
      List<String> keywords = [];
      String combined = '$name $category'.toLowerCase();
      keywords.addAll(combined.split(' '));
      // Add substrings for partial matches (optional but good for premium feel)
      for (var word in combined.split(' ')) {
        for (int i = 1; i <= word.length; i++) {
          keywords.add(word.substring(0, i));
        }
      }

      final product = Product(
        id: data['id'],
        name: name,
        description: 'Experience premium comfort and style with this uniquely crafted piece from Zevix.',
        price: data['price'],
        imageUrl: data['imageUrl'],
        category: category,
        searchKeywords: keywords.toSet().toList(), // deduplicate
      );
      await _productsRef.doc(product.id).set(product.toMap());
    }
  }

  // --- Wishlist Operations (Main Collection) ---

  Stream<List<Product>> getWishlist(String uid) {
    return _db
        .collection('wishlist')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map<Product>((doc) => Product.fromFirestore(doc.data()['product'] as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> toggleWishlist(String uid, Product product) async {
    final docId = '${uid}_${product.id}';
    final docRef = _db.collection('wishlist').doc(docId);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'userId': uid,
        'productId': product.id,
        'product': product.toMap(),
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<bool> isProductInWishlist(String uid, String productId) {
    final docId = '${uid}_$productId';
    return _db
        .collection('wishlist')
        .doc(docId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // --- Cart Operations (Main Collection) ---

  Stream<List<Map<String, dynamic>>> getCart(String uid) {
    return _db
        .collection('cart')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'product': Product.fromFirestore(data['product'] as Map<String, dynamic>),
          'quantity': data['quantity'] ?? 1,
        };
      }).toList();
    });
  }

  Future<void> addToCart(String uid, Product product, {int quantity = 1}) async {
    final docId = '${uid}_${product.id}';
    final docRef = _db.collection('cart').doc(docId);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({
        'quantity': FieldValue.increment(quantity),
      });
    } else {
      await docRef.set({
        'userId': uid,
        'productId': product.id,
        'product': product.toMap(),
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> removeFromCart(String uid, String productId) async {
    final docId = '${uid}_$productId';
    await _db.collection('cart').doc(docId).delete();
  }

  Future<void> updateCartQuantity(String uid, String productId, int delta) async {
    final docId = '${uid}_$productId';
    final docRef = _db.collection('cart').doc(docId);
    final doc = await docRef.get();
    
    if (doc.exists) {
      final currentQty = (doc.data() as Map<String, dynamic>)['quantity'] ?? 1;
      final newQty = currentQty + delta;
      
      if (newQty <= 0) {
        await docRef.delete();
      } else {
        await docRef.update({'quantity': newQty});
      }
    }
  }

  // --- Order Operations (Main Collection) ---

  Future<void> placeOrder({
    required String uid,
    required List<Map<String, dynamic>> items,
    required double total,
    required String address,
    required String paymentMethod,
  }) async {
    final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
    
    // Create the order
    await _db.collection('orders').doc(orderId).set({
      'orderId': orderId,
      'userId': uid,
      'items': items.map((item) => {
        'product': (item['product'] as Product).toMap(),
        'quantity': item['quantity'],
      }).toList(),
      'totalAmount': total,
      'shippingAddress': address,
      'paymentMethod': paymentMethod,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Clear the cart for this user
    final cartSnapshot = await _db.collection('cart').where('userId', isEqualTo: uid).get();
    final batch = _db.batch();
    for (var doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> getOrders(String uid) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) => doc.data()).toList();
      // Client-side sorting as a fallback for missing indexes
      docs.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime);
      });
      return docs;
    });
  }

  Future<void> cancelOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).update({
      'status': 'Cancelled',
    });
  }

  // --- Review Operations (Main Collection) ---

  Future<void> addReview({
    required String uid,
    required String productId,
    required String productName,
    required String productImageUrl,
    required String review,
    required double rating,
  }) async {
    final reviewId = '${uid}_${productId}_${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection('reviews').doc(reviewId).set({
      'reviewId': reviewId,
      'userId': uid,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'review': review,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getReviews(String uid) {
    return _db
        .collection('reviews')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) => doc.data()).toList();
      docs.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime);
      });
      return docs;
    });
  }

  Future<void> deleteReview(String reviewId) async {
    await _db.collection('reviews').doc(reviewId).delete();
  }
}
