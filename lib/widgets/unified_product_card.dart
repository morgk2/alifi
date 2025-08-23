import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/aliexpress_product.dart';
import '../models/store_product.dart';
import '../services/currency_service.dart';
import '../services/currency_service.dart' show Currency;
import '../services/device_performance.dart';
import 'optimized_image.dart';
import 'optimized_shadow.dart';
import 'spinning_loader.dart';
import 'currency_symbol.dart';
import '../pages/product_details_page.dart';
import 'skeleton_loader.dart';

class UnifiedProductCard extends StatefulWidget {
  final dynamic product;
  final double width;
  final double height;
  final bool showDetails;

  const UnifiedProductCard({
    super.key,
    required this.product,
    required this.width,
    required this.height,
    this.showDetails = true,
  });

  @override
  State<UnifiedProductCard> createState() => _UnifiedProductCardState();
}

class _UnifiedProductCardState extends State<UnifiedProductCard> {
  late final DevicePerformance _devicePerformance;
  late bool _isLowEndDevice;

  @override
  void initState() {
    super.initState();
    _devicePerformance = DevicePerformance();
    _isLowEndDevice = _devicePerformance.performanceTier == PerformanceTier.low;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(
                product: widget.product,
              ),
            ),
          );
        },
        child: OptimizedShadow(
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getProductType() == 'store'
                    ? Colors.green[200]!
                    : Colors.orange[100]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: OptimizedImage(
                        imageUrl: _getImageUrl(),
                        width: widget.width,
                        height: widget.height * 0.35, // Reduced image height to give more space to info
                        fit: BoxFit.cover,
                        placeholder: Container(
                          width: widget.width,
                          height: widget.height * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: const Center(
                            child: ShimmerLoader(
                              child: SizedBox.expand(),
                            ),
                          ),
                        ),
                        errorWidget: Container(
                          width: widget.width,
                          height: widget.height * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: const Center(
                            child: Icon(Icons.error, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    if (_getProductType() == 'store')
                      Positioned(
                        top: 8,
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
                            'Store',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (widget.showDetails) ...[
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getProductName(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Consumer<CurrencyService>(
                          builder: (context, currencyService, child) {
                            return Row(
                              children: [
                                currencyService.currentCurrency == Currency.DZD
                                  ? Row(
                                      children: [
                                                                          CurrencySymbol(
                                    size: 18,
                                    color: _getProductType() == 'store' ? Colors.green : Colors.orange,
                                  ),
                                        const SizedBox(width: 2),
                                        Text(
                                          currencyService.formatProductPrice(_getPrice(), _getCurrency()),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: _getProductType() == 'store' ? Colors.green : Colors.orange,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      currencyService.formatPrice(_getPrice()),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _getProductType() == 'store' ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                if (_getOriginalPrice() > _getPrice()) ...[
                                  const SizedBox(width: 8),
                                  currencyService.currentCurrency == Currency.DZD
                                    ? Row(
                                        children: [
                                                                                  CurrencySymbol(
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                          const SizedBox(width: 2),
                                          Text(
                                            currencyService.formatPrice(_getOriginalPrice()),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        currencyService.formatPrice(_getOriginalPrice()),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _getRating().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_getOrders()} orders',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getProductType() {
    if (widget.product is AliexpressProduct) {
      return 'aliexpress';
    } else if (widget.product is StoreProduct) {
      return 'store';
    }
    return 'unknown';
  }

  String _getImageUrl() {
    if (widget.product is AliexpressProduct) {
      final aliProduct = widget.product as AliexpressProduct;
      return aliProduct.imageUrls.isNotEmpty ? aliProduct.imageUrls.first : '';
    } else if (widget.product is StoreProduct) {
      final storeProduct = widget.product as StoreProduct;
      return storeProduct.imageUrls.isNotEmpty ? storeProduct.imageUrls.first : '';
    }
    return '';
  }

  String _getProductName() {
    if (widget.product is AliexpressProduct) {
      return (widget.product as AliexpressProduct).name;
    } else if (widget.product is StoreProduct) {
      return (widget.product as StoreProduct).name;
    }
    return 'Unknown Product';
  }

  double _getPrice() {
    if (widget.product is AliexpressProduct) {
      return (widget.product as AliexpressProduct).price;
    } else if (widget.product is StoreProduct) {
      return (widget.product as StoreProduct).price;
    }
    return 0.0;
  }

  double _getOriginalPrice() {
    if (widget.product is AliexpressProduct) {
      return (widget.product as AliexpressProduct).originalPrice;
    } else if (widget.product is StoreProduct) {
      // StoreProduct doesn't have originalPrice, so return the current price
      // This means no discount will be shown for store products
      return (widget.product as StoreProduct).price;
    }
    return 0.0;
  }

  double _getRating() {
    if (widget.product is AliexpressProduct) {
      return (widget.product as AliexpressProduct).rating;
    } else if (widget.product is StoreProduct) {
      return (widget.product as StoreProduct).rating;
    }
    return 0.0;
  }

  int _getOrders() {
    if (widget.product is AliexpressProduct) {
      return (widget.product as AliexpressProduct).orders;
    } else if (widget.product is StoreProduct) {
      return (widget.product as StoreProduct).totalOrders;
    }
    return 0;
  }

  String _getCurrency() {
    if (widget.product is AliexpressProduct) {
      return (widget.product as AliexpressProduct).currency;
    } else if (widget.product is StoreProduct) {
      return (widget.product as StoreProduct).currency;
    }
    return 'USD'; // Default fallback
  }
}