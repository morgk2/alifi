import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/marketplace_product.dart';
import '../services/navigation_service.dart';
import '../services/currency_service.dart';
import '../services/currency_service.dart' show Currency;
import '../widgets/optimized_image.dart';
import '../widgets/optimized_shadow.dart';
import '../widgets/spinning_loader.dart';
import '../widgets/currency_symbol.dart';
import '../pages/product_details_page.dart';

class LazyMarketplaceProductCard extends StatefulWidget {
  final MarketplaceProduct product;
  final int index;
  final bool isHorizontal;

  const LazyMarketplaceProductCard({
    super.key,
    required this.product,
    required this.index,
    this.isHorizontal = false,
  });

  @override
  State<LazyMarketplaceProductCard> createState() => _LazyMarketplaceProductCardState();
}

class _LazyMarketplaceProductCardState extends State<LazyMarketplaceProductCard> {
  @override
  Widget build(BuildContext context) {
    // Show actual product card directly
    return _buildProductCard(widget.product);
  }

  Widget _buildProductCard(MarketplaceProduct product) {
    final discountPercentage = product.originalPrice > 0
        ? ((1 - (product.price / product.originalPrice)) * 100).round()
        : 0;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          NavigationService.push(
            context,
            ProductDetailsPage(
              product: product.type == 'aliexpress'
                  ? product.toAliexpress()
                  : product.toStore(),
            ),
          );
        },
        child: Container(
          width: widget.isHorizontal ? 160 : double.infinity,
          margin: EdgeInsets.only(
            right: widget.isHorizontal ? 16 : 0,
            bottom: widget.isHorizontal ? 0 : 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: product.type == 'store'
                  ? Colors.green[200]!
                  : Colors.orange[100]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset.zero,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: OptimizedImage(
                      imageUrl: product.imageUrls.first,
                      height: widget.isHorizontal ? 140 : 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: Image.asset(
                        'assets/images/photo_loader.png',
                        fit: BoxFit.cover,
                        height: widget.isHorizontal ? 140 : 120,
                        width: double.infinity,
                      ),
                      errorWidget: Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.error, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  if (product.type == 'store')
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
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
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
                                      color: product.type == 'store' ? Colors.green : Colors.orange,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      currencyService.formatProductPrice(product.price, product.currency),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: product.type == 'store' ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                  ],
                                )
                              :                               Text(
                                currencyService.formatProductPrice(product.price, product.currency),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: product.type == 'store' ? Colors.green : Colors.orange,
                                ),
                              ),
                            if (product.originalPrice > product.price) ...[
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
                                        currencyService.formatProductPrice(product.originalPrice, product.currency),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  )
                                :                                 Text(
                                  currencyService.formatProductPrice(product.originalPrice, product.currency),
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
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${product.totalOrders} orders',
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
          ),
        ),
      ),
    );
  }
}