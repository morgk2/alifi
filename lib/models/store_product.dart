import 'package:cloud_firestore/cloud_firestore.dart';

class StoreProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final String category;
  final double rating;
  final int totalOrders;
  final bool isFreeShipping;
  final String shippingTime;
  final int stockQuantity;
  final String storeId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  StoreProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.imageUrls,
    required this.category,
    this.rating = 0.0,
    this.totalOrders = 0,
    required this.isFreeShipping,
    required this.shippingTime,
    required this.stockQuantity,
    required this.storeId,
    this.isActive = true,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'imageUrls': imageUrls,
      'category': category,
      'rating': rating,
      'totalOrders': totalOrders,
      'isFreeShipping': isFreeShipping,
      'shippingTime': shippingTime,
      'stockQuantity': stockQuantity,
      'storeId': storeId,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
    };
  }

  factory StoreProduct.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return StoreProduct(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'USD',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalOrders: data['totalOrders'] ?? 0,
      isFreeShipping: data['isFreeShipping'] ?? false,
      shippingTime: data['shippingTime'] ?? '',
      stockQuantity: data['stockQuantity'] ?? 0,
      storeId: data['storeId'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  StoreProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? currency,
    List<String>? imageUrls,
    String? category,
    double? rating,
    int? totalOrders,
    bool? isFreeShipping,
    String? shippingTime,
    int? stockQuantity,
    String? storeId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return StoreProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      isFreeShipping: isFreeShipping ?? this.isFreeShipping,
      shippingTime: shippingTime ?? this.shippingTime,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      storeId: storeId ?? this.storeId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
} 