class StoreItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stockQuantity;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final bool isAvailable;

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stockQuantity,
    required this.tags,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
  });

  // Mock data for development
  static List<StoreItem> get mockItems => [
        const StoreItem(
          id: 'item_001',
          name: 'Premium Pet Food',
          description: 'High-quality nutrition for your furry friend',
          price: 2499.99,
          imageUrl: 'assets/images/pet_food.png',
          category: 'Food',
          stockQuantity: 50,
          tags: ['food', 'nutrition', 'premium'],
          rating: 4.8,
          reviewCount: 156,
          isAvailable: true,
        ),
        const StoreItem(
          id: 'item_002',
          name: 'Cozy Pet Bed',
          description: 'Comfortable bed for cats and small dogs',
          price: 3999.99,
          imageUrl: 'assets/images/pet_bed.png',
          category: 'Accessories',
          stockQuantity: 25,
          tags: ['bed', 'comfort', 'sleep'],
          rating: 4.9,
          reviewCount: 89,
          isAvailable: true,
        ),
        const StoreItem(
          id: 'item_003',
          name: 'Interactive Toy Set',
          description: 'Set of engaging toys for mental stimulation',
          price: 1899.99,
          imageUrl: 'assets/images/toy_set.png',
          category: 'Toys',
          stockQuantity: 75,
          tags: ['toys', 'interactive', 'mental health'],
          rating: 4.7,
          reviewCount: 203,
          isAvailable: true,
        ),
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'stockQuantity': stockQuantity,
        'tags': tags,
        'rating': rating,
        'reviewCount': reviewCount,
        'isAvailable': isAvailable,
      };

  factory StoreItem.fromJson(Map<String, dynamic> json) => StoreItem(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String,
        category: json['category'] as String,
        stockQuantity: json['stockQuantity'] as int,
        tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['reviewCount'] as int,
        isAvailable: json['isAvailable'] as bool,
      );
}
