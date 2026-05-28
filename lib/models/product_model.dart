class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final List<String> sizes;
  final List<String> materials;
  final double rating;
  final int reviewsCount;
  final List<String> searchKeywords;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.sizes = const ['S', 'M', 'L', 'XL'],
    this.materials = const ['Cotton 95%', 'Nylon 5%'],
    this.rating = 4.5,
    this.reviewsCount = 120,
    this.searchKeywords = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'sizes': sizes,
      'materials': materials,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'searchKeywords': searchKeywords,
    };
  }

  factory Product.fromFirestore(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      sizes: List<String>.from(data['sizes'] ?? []),
      materials: List<String>.from(data['materials'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
    );
  }
}

class ProductCategory {
  final String name;
  final String imageUrl;
  final List<String> subCategories;

  ProductCategory({
    required this.name,
    required this.imageUrl,
    required this.subCategories,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'subCategories': subCategories,
    };
  }

  factory ProductCategory.fromFirestore(Map<String, dynamic> data) {
    return ProductCategory(
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      subCategories: List<String>.from(data['subCategories'] ?? []),
    );
  }
}
