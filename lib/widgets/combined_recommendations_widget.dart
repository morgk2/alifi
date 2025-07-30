import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/aliexpress_product.dart';
import '../models/store_product.dart';
import '../services/database_service.dart';
import '../icons.dart';
import 'unified_product_card.dart';
import 'scrollable_fade_container.dart';
import 'spinning_loader.dart';
import '../pages/marketplace_page.dart';

class CombinedRecommendationsWidget extends StatefulWidget {
  final ScrollController scrollController;
  final int limit;

  const CombinedRecommendationsWidget({
    super.key,
    required this.scrollController,
    this.limit = 10,
  });

  @override
  State<CombinedRecommendationsWidget> createState() => _CombinedRecommendationsWidgetState();
}

class _CombinedRecommendationsWidgetState extends State<CombinedRecommendationsWidget> {
  final DatabaseService _databaseService = DatabaseService();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);
  Future<Map<String, List<dynamic>>>? _productsFuture;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    _loadProducts();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _loadProducts() {
    _productsFuture = _getCombinedProducts();
  }

  void _onScroll() {
    final position = widget.scrollController.position;
    if (position.pixels > 0) {
      final itemWidth = MediaQuery.of(context).size.width * 0.6;
      final currentPage = (position.pixels / (itemWidth + 16)).round();
      if (_currentPageNotifier.value != currentPage) {
        _currentPageNotifier.value = currentPage;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                SvgPicture.string(
                  AppIcons.storeIcon,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'You may be Interested',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MarketplacePage(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'See all',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Products list
          SizedBox(
            height: 280, // Increased height to accommodate the new card layout
            child: LayoutBuilder(
              builder: (context, constraints) {
                final containerWidth = constraints.maxWidth;
                final itemWidth = MediaQuery.of(context).size.width * 0.45; // Slightly smaller width for better fit

                return FutureBuilder<Map<String, List<dynamic>>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print('Error loading combined products: ${snapshot.error}');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading products',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadProducts,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return Container(
                        height: 260, // Match the final card height
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SpinningLoader(
                                size: 60, // Larger size for better visibility
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading products...',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final combinedProducts = snapshot.data!;
                    final allProducts = combinedProducts['products'] ?? [];
                    
                    if (allProducts.isEmpty) {
                      return Center(
                        child: Text(
                          'No products available',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      );
                    }

                    final totalWidth = itemWidth * allProducts.length +
                        16.0 * (allProducts.length - 1);

                    return ScrollableFadeContainer(
                      scrollController: widget.scrollController,
                      containerWidth: containerWidth,
                      contentWidth: totalWidth,
                      child: ListView.builder(
                        controller: widget.scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        itemCount: allProducts.length,
                        itemBuilder: (context, index) {
                          final product = allProducts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: UnifiedProductCard(
                              product: product,
                              width: itemWidth,
                              height: 260, // Adjusted height for better proportions
                              showDetails: true,
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Pagination dots
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: _currentPageNotifier,
            builder: (context, currentPage, child) {
              return FutureBuilder<Map<String, List<dynamic>>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  
                  final combinedProducts = snapshot.data!;
                  final allProducts = combinedProducts['products'] ?? [];
                  
                  if (allProducts.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      allProducts.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPage == index
                              ? const Color(0xFFF59E0B)
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<Map<String, List<dynamic>>> _getCombinedProducts() async {
    try {
      print('Loading combined products...');
      
      // First, try to load only AliExpress products to test
      List<AliexpressProduct> aliProducts = [];
      try {
        aliProducts = await _databaseService.getRecommendedListings(limit: widget.limit).first;
        print('Loaded ${aliProducts.length} AliExpress products');
      } catch (e) {
        print('Error loading AliExpress products: $e');
        aliProducts = [];
      }
      
      // Try to load store products
      List<StoreProduct> storeProducts = [];
      try {
        storeProducts = await _databaseService.getPopularStoreProducts(limit: widget.limit ~/ 2).first;
        print('Loaded ${storeProducts.length} store products');
      } catch (e) {
        print('Error loading store products: $e');
        // Continue with empty store products
        storeProducts = [];
      }
      
      // If we have no products at all, show a message
      if (aliProducts.isEmpty && storeProducts.isEmpty) {
        print('No products found from either source');
        // For testing, let's create some mock data
        print('Creating mock data for testing...');
        aliProducts = [
          AliexpressProduct(
            id: 'mock_1',
            name: 'Pet Toy Set',
            description: 'Interactive toys for pets',
            price: 15.99,
            originalPrice: 25.99,
            currency: 'USD',
            imageUrls: ['https://via.placeholder.com/300x200?text=Pet+Toy'],
            affiliateUrl: 'https://example.com',
            category: 'Toys',
            rating: 4.5,
            orders: 1234,
            isFreeShipping: true,
            shippingTime: '7-15 days',
            createdAt: DateTime.now(),
            lastUpdatedAt: DateTime.now(),
          ),
          AliexpressProduct(
            id: 'mock_2',
            name: 'Pet Food Bowl',
            description: 'Stainless steel food bowl',
            price: 8.99,
            originalPrice: 12.99,
            currency: 'USD',
            imageUrls: ['https://via.placeholder.com/300x200?text=Pet+Bowl'],
            affiliateUrl: 'https://example.com',
            category: 'Food',
            rating: 4.2,
            orders: 856,
            isFreeShipping: false,
            shippingTime: '10-20 days',
            createdAt: DateTime.now(),
            lastUpdatedAt: DateTime.now(),
          ),
        ];
      }
      
      // Combine and shuffle the products
      final allProducts = <dynamic>[];
      allProducts.addAll(aliProducts);
      allProducts.addAll(storeProducts);
      allProducts.shuffle(); // Randomize the order
      
      print('Total combined products: ${allProducts.length}');
      
      return {
        'products': allProducts,
        'aliexpress': aliProducts,
        'store': storeProducts,
      };
    } catch (e) {
      print('Error in _getCombinedProducts: $e');
      print('Stack trace: ${StackTrace.current}');
      // Return empty data on error
      return {
        'products': <dynamic>[],
        'aliexpress': <AliexpressProduct>[],
        'store': <StoreProduct>[],
      };
    }
  }
}