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
  });
}

class Category {
  final String name;
  final String imageUrl;
  final List<String> subCategories;

  Category({
    required this.name,
    required this.imageUrl,
    required this.subCategories,
  });
}
