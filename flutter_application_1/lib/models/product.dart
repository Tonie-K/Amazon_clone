class Product {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final double price;
  final String category;
  final int stock;
  final double rating;
  final String? specBadge;
  final bool isSponsored;
  final Map<String, dynamic> attributes;

  Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    required this.rating,
    this.specBadge,
    this.isSponsored = false,
    this.attributes = const {},
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      specBadge: json['specBadge']?.toString(),
      isSponsored: json['isSponsored'] == true,
      attributes: json['attributes'] != null && json['attributes'] is Map
          ? Map<String, dynamic>.from(json['attributes'])
          : {},
    );
  }
}
