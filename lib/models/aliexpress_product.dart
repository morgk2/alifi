import 'package:cloud_firestore/cloud_firestore.dart';

class AliexpressProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String currency;
  final List<String> imageUrls;
  final String affiliateUrl;
  final String category;
  final double rating;
  final int orders;
  final bool isFreeShipping;
  final String shippingTime;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  AliexpressProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.currency,
    required this.imageUrls,
    required this.affiliateUrl,
    required this.category,
    this.rating = 0.0,
    this.orders = 0,
    this.isFreeShipping = false,
    this.shippingTime = '',
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'currency': currency,
      'imageUrls': imageUrls,
      'affiliateUrl': affiliateUrl,
      'category': category,
      'rating': rating,
      'orders': orders,
      'isFreeShipping': isFreeShipping,
      'shippingTime': shippingTime,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
    };
  }

  factory AliexpressProduct.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AliexpressProduct(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'USD',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      affiliateUrl: data['affiliateUrl'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      orders: data['orders'] ?? 0,
      isFreeShipping: data['isFreeShipping'] ?? false,
      shippingTime: data['shippingTime'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Helper method to calculate discount percentage
  int get discountPercentage {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - price) / originalPrice * 100).round();
  }

  // Helper method to format price with currency
  String get formattedPrice => '$currency ${price.toStringAsFixed(2)}';
  String get formattedOriginalPrice => '$currency ${originalPrice.toStringAsFixed(2)}';
} 