import 'aliexpress_product.dart';
import 'store_product.dart';

class MarketplaceProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String currency;
  final List<String> imageUrls;
  final String category;
  final double rating;
  final int totalOrders;
  final bool isFreeShipping;
  final String shippingTime;
  final bool isActive;
  final String? storeId;  // null for AliExpress products
  final String? affiliateUrl;  // null for store products
  final String type;  // 'store' or 'aliexpress'
  final DateTime createdAt;

  const MarketplaceProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.currency,
    required this.imageUrls,
    required this.category,
    required this.rating,
    required this.totalOrders,
    required this.isFreeShipping,
    required this.shippingTime,
    required this.isActive,
    this.storeId,
    this.affiliateUrl,
    required this.type,
    required this.createdAt,
  });

  factory MarketplaceProduct.fromAliexpress(AliexpressProduct product) {
    return MarketplaceProduct(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      originalPrice: product.originalPrice,
      currency: product.currency,
      imageUrls: product.imageUrls,
      category: product.category,
      rating: product.rating,
      totalOrders: product.orders,
      isFreeShipping: product.isFreeShipping,
      shippingTime: product.shippingTime,
      isActive: true,
      affiliateUrl: product.affiliateUrl,
      type: 'aliexpress',
      createdAt: product.createdAt,
    );
  }

  factory MarketplaceProduct.fromStore(StoreProduct product) {
    return MarketplaceProduct(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      originalPrice: product.price,  // Store products don't have original price
      currency: product.currency,
      imageUrls: product.imageUrls,
      category: product.category,
      rating: product.rating,
      totalOrders: product.totalOrders,
      isFreeShipping: product.isFreeShipping,
      shippingTime: product.shippingTime,
      isActive: product.isActive,
      storeId: product.storeId,
      type: 'store',
      createdAt: product.createdAt,
    );
  }

  AliexpressProduct toAliexpress() {
    if (type != 'aliexpress') throw Exception('Not an AliExpress product');
    final now = DateTime.now();
    return AliexpressProduct(
      id: id,
      name: name,
      description: description,
      price: price,
      originalPrice: originalPrice,
      currency: currency,
      imageUrls: imageUrls,
      category: category,
      rating: rating,
      orders: totalOrders,
      isFreeShipping: isFreeShipping,
      shippingTime: shippingTime,
      affiliateUrl: affiliateUrl!,
      createdAt: now,
      lastUpdatedAt: now,
    );
  }

  StoreProduct toStore() {
    if (type != 'store') throw Exception('Not a store product');
    final now = DateTime.now();
    return StoreProduct(
      id: id,
      name: name,
      description: description,
      price: price,
      currency: currency,
      imageUrls: imageUrls,
      category: category,
      rating: rating,
      totalOrders: totalOrders,
      isFreeShipping: isFreeShipping,
      shippingTime: shippingTime,
      stockQuantity: 0,  // This would need to be added to the interface if important
      storeId: storeId!,
      isActive: isActive,
      createdAt: now,
      lastUpdatedAt: now,
    );
  }
} 