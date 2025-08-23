import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/aliexpress_product.dart';
import '../models/store_product.dart';
import '../services/database_service.dart';
import '../services/device_performance.dart';
import '../icons.dart';
import 'unified_product_card.dart';
import 'skeleton_loader.dart';
import '../pages/marketplace_page.dart';
import '../l10n/app_localizations.dart';

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
  late final DevicePerformance _devicePerformance;
  late bool _isLowEndDevice;

  @override
  void initState() {
    super.initState();
    _devicePerformance = DevicePerformance();
    _isLowEndDevice = _devicePerformance.performanceTier == PerformanceTier.low;
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
    final l10n = AppLocalizations.of(context)!;
    
    // Use const for static values
    const double borderRadius = 20.0;
    
    // Optimize shadow based on device performance
    final BoxShadow boxShadow = _isLowEndDevice 
        ? const BoxShadow(
            color: Color(0x0D000000), // 5% opacity
            blurRadius: 5,
            offset: Offset(0, 5),
            spreadRadius: 1,
          )
        : BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          );
    
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
          boxShadow: [boxShadow],
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
                  Text(
                    l10n.youMayBeInterested,
                    style: const TextStyle(
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
                    child: const Icon(
                      CupertinoIcons.chevron_right,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Products list
            SizedBox(
              height: 320, // Increased height to accommodate larger cards with more info
              child: LayoutBuilder(
                                  builder: (context, constraints) {
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
                                l10n.errorLoadingProducts,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadProducts,
                                child: Text(l10n.retry),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return _buildSkeletonProducts();
                      }

                      final combinedProducts = snapshot.data!;
                      final allProducts = combinedProducts['products'] ?? [];
                      
                      if (allProducts.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.noProductsAvailable,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        );
                      }

                      // Limit to maximum 5 cards
                      final limitedProducts = allProducts.take(5).toList();

                      // Use optimized ListView with caching and recycling
                      return ListView.builder(
                        controller: widget.scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        itemCount: limitedProducts.length,
                        // Add key for better recycling
                        key: const PageStorageKey('product_list'),
                        // Optimize for performance
                        cacheExtent: itemWidth * 2, // Cache 2 items ahead
                        itemExtent: itemWidth + 16, // Fixed item width for better performance
                        addAutomaticKeepAlives: false, // Don't keep invisible items alive
                        addRepaintBoundaries: true, // Add repaint boundaries for better performance
                        itemBuilder: (context, index) {
                          final product = limitedProducts[index];
                          // Use const for padding to avoid recreation
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: LazyProductCard(
                              product: product,
                              width: itemWidth,
                              height: 420, // Increased card height to fit all content
                              showDetails: true,
                              scrollController: widget.scrollController,
                              index: index,
                            ),
                          );
                        },
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
                    
                    // Limit to maximum 5 cards for pagination dots
                    final limitedProducts = allProducts.take(5).toList();
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        limitedProducts.length,
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

  Widget _buildSkeletonProducts() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = MediaQuery.of(context).size.width * 0.45;
        // Calculate how many skeleton cards can fit on screen
        final cardsPerScreen = (constraints.maxWidth / (itemWidth + 16)).floor();
        final numberOfSkeletons = cardsPerScreen.clamp(2, 5); // Show 2-5 skeleton cards
        
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: numberOfSkeletons,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _buildSkeletonProductCard(itemWidth),
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonProductCard(double width) {
    return Container(
      width: width,
      height: 420, // Match the new card height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            width: double.infinity,
            height: 147, // 35% of 420 height
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const ShimmerLoader(
              child: SizedBox.expand(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder
                ShimmerLoader(
                  child: SkeletonLoader(
                    width: double.infinity,
                    height: 16,
                    baseColor: Colors.grey.withOpacity(0.2),
                    highlightColor: Colors.grey.withOpacity(0.1),
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle placeholder
                ShimmerLoader(
                  child: SkeletonLoader(
                    width: 120,
                    height: 14,
                    baseColor: Colors.grey.withOpacity(0.2),
                    highlightColor: Colors.grey.withOpacity(0.1),
                  ),
                ),
                const SizedBox(height: 12),
                // Price placeholder
                Row(
                  children: [
                    ShimmerLoader(
                      child: SkeletonLoader(
                        width: 60,
                        height: 18,
                        baseColor: Colors.grey.withOpacity(0.2),
                        highlightColor: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ShimmerLoader(
                      child: Container(
                        width: 40,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Rating and orders placeholder
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    ShimmerLoader(
                      child: SkeletonLoader(
                        width: 30,
                        height: 12,
                        baseColor: Colors.grey.withOpacity(0.2),
                        highlightColor: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ShimmerLoader(
                      child: SkeletonLoader(
                        width: 50,
                        height: 12,
                        baseColor: Colors.grey.withOpacity(0.2),
                        highlightColor: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LazyProductCard extends StatefulWidget {
  final dynamic product;
  final double width;
  final double height;
  final bool showDetails;
  final ScrollController scrollController;
  final int index;

  const LazyProductCard({
    super.key,
    required this.product,
    required this.width,
    required this.height,
    required this.showDetails,
    required this.scrollController,
    required this.index,
  });

  @override
  State<LazyProductCard> createState() => _LazyProductCardState();
}

class _LazyProductCardState extends State<LazyProductCard> {
  final _visibilityKey = GlobalKey();
  bool _isVisible = false;
  bool _isLoaded = false;
  
  @override
  void initState() {
    super.initState();
    // Use a more efficient approach with fewer listeners
    widget.scrollController.addListener(_onScroll);
    // Initial visibility check after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // Only check visibility during scrolling, not on every frame
    // This reduces the number of calculations
    _checkVisibility();
  }

  void _checkVisibility() {
    if (!mounted) return;
    
    // Use more efficient visibility detection
    final RenderObject? renderObject = _visibilityKey.currentContext?.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;
    
    final RenderBox renderBox = renderObject as RenderBox;
    final viewportWidth = MediaQuery.of(context).size.width;
    
    // Get the widget's position relative to the viewport
    final Offset position = renderBox.localToGlobal(Offset.zero);
    
    // Calculate if the widget is visible in the viewport with a buffer zone
    // This prevents excessive rebuilds when items are just at the edge
    final double bufferZone = viewportWidth * 0.2; // 20% buffer on each side
    final bool isNowVisible = position.dx < viewportWidth + bufferZone && 
                           position.dx + renderBox.size.width > -bufferZone;
    
    // Only update state if visibility changed
    if (isNowVisible != _isVisible) {
      setState(() {
        _isVisible = isNowVisible;
        if (isNowVisible && !_isLoaded) {
          // Add a small delay to show skeleton loader for better UX
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _isLoaded = true;
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show skeleton loader for non-visible items or when not loaded yet
    if (!_isVisible && !_isLoaded) {
      return Container(
        key: _visibilityKey,
        width: widget.width,
        height: widget.height,
        child: _buildSkeletonCard(),
      );
    }

    // Show skeleton loader while loading, then the actual card
    if (_isVisible && !_isLoaded) {
      return Container(
        key: _visibilityKey,
        width: widget.width,
        height: widget.height,
        child: _buildSkeletonCard(),
      );
    }

    // Once loaded, keep the card in memory to prevent rebuilding when scrolling back
    return KeyedSubtree(
      key: _visibilityKey,
      child: UnifiedProductCard(
        product: widget.product,
        width: widget.width,
        height: widget.height,
        showDetails: widget.showDetails,
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder with shimmer
          Container(
            width: double.infinity,
            height: widget.height * 0.35,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const ShimmerLoader(
              child: SizedBox.expand(),
            ),
          ),
          // Product info section (white background appears first)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  ShimmerLoader(
                    child: SkeletonLoader(
                      width: double.infinity,
                      height: 16,
                      baseColor: Colors.grey.withOpacity(0.2),
                      highlightColor: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle placeholder
                  ShimmerLoader(
                    child: SkeletonLoader(
                      width: 120,
                      height: 14,
                      baseColor: Colors.grey.withOpacity(0.2),
                      highlightColor: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Price placeholder
                  Row(
                    children: [
                      ShimmerLoader(
                        child: SkeletonLoader(
                          width: 60,
                          height: 18,
                          baseColor: Colors.grey.withOpacity(0.2),
                          highlightColor: Colors.grey.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ShimmerLoader(
                        child: Container(
                          width: 40,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rating and orders placeholder
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ShimmerLoader(
                        child: SkeletonLoader(
                          width: 30,
                          height: 12,
                          baseColor: Colors.grey.withOpacity(0.2),
                          highlightColor: Colors.grey.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ShimmerLoader(
                        child: SkeletonLoader(
                          width: 50,
                          height: 12,
                          baseColor: Colors.grey.withOpacity(0.2),
                          highlightColor: Colors.grey.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}