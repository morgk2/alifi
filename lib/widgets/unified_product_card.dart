import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/aliexpress_product.dart';
import '../models/store_product.dart';
import '../pages/product_details_page.dart';
import 'placeholder_image.dart';

class UnifiedProductCard extends StatelessWidget {
  final dynamic product; // Can be either AliexpressProduct or StoreProduct
  final double width;
  final double height;
  final bool showDetails;

  const UnifiedProductCard({
    super.key,
    required this.product,
    this.width = 200,
    this.height = 300,
    this.showDetails = true,
  });

  bool get isAliexpressProduct => product is AliexpressProduct;
  bool get isStoreProduct => product is StoreProduct;

  String get productName => isAliexpressProduct 
      ? (product as AliexpressProduct).name 
      : (product as StoreProduct).name;

  String get productImage => isAliexpressProduct 
      ? (product as AliexpressProduct).imageUrls.first 
      : (product as StoreProduct).imageUrls.first;

  double get productPrice => isAliexpressProduct 
      ? (product as AliexpressProduct).price 
      : (product as StoreProduct).price;

  String get productCurrency => isAliexpressProduct 
      ? (product as AliexpressProduct).currency 
      : (product as StoreProduct).currency;

  double get productRating => isAliexpressProduct 
      ? (product as AliexpressProduct).rating 
      : (product as StoreProduct).rating;

  bool get isFreeShipping => isAliexpressProduct 
      ? (product as AliexpressProduct).isFreeShipping 
      : (product as StoreProduct).isFreeShipping;

  int get discountPercentage {
    if (isAliexpressProduct) {
      return (product as AliexpressProduct).discountPercentage;
    }
    return 0; // Store products don't have discount percentage in the model
  }

  String get formattedPrice => '$productCurrency ${productPrice.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with 1:1 aspect ratio
            Expanded(
              flex: 3, // Take up more space for the image
              child: Stack(
                children: [
                  // Main image - make it square
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: productImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const PlaceholderImage(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        errorWidget: (context, url, error) => const PlaceholderImage(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                  // Product type badge - smaller and positioned better
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isAliexpressProduct ? Colors.blue : Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAliexpressProduct ? 'Ali' : 'Store',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                  // Discount badge - smaller and positioned better
                  if (discountPercentage > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-$discountPercentage%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  // Free shipping badge - smaller and positioned better
                  if (isFreeShipping)
                    Positioned(
                      top: discountPercentage > 0 ? 32 : 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Free',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product details - more compact
            if (showDetails)
              Expanded(
                flex: 2, // Take up less space for details
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name - smaller text
                      Text(
                        productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Price and rating - more compact
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedPrice,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                if (isAliexpressProduct && discountPercentage > 0)
                                  Text(
                                    (product as AliexpressProduct).formattedOriginalPrice,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Rating
                          if (productRating > 0)
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.amber[700],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  productRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}