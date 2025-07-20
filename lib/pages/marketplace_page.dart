import 'package:flutter/material.dart';
import '../models/aliexpress_product.dart';
import '../services/database_service.dart';
import '../widgets/spinning_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'product_details_page.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _categories = [
    {'icon': 'assets/images/food.png', 'name': 'Food'},
    {'icon': 'assets/images/toys.png', 'name': 'Toys'},
    {'icon': 'assets/images/health.png', 'name': 'Health'},
    {'icon': 'assets/images/beds.png', 'name': 'Beds'},
    {'icon': 'assets/images/hygiene.png', 'name': 'Hygiene'},
  ];

  Widget _buildProductCard(AliexpressProduct product, {bool isLarge = false}) {
    final discountPercentage = product.originalPrice > 0
        ? ((1 - (product.price / product.originalPrice)) * 100).round()
        : 0;

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
        width: isLarge ? 160 : double.infinity,
        margin: EdgeInsets.only(right: isLarge ? 16 : 0, bottom: isLarge ? 0 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isLarge ? Colors.grey[200]! : Colors.orange[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: product.imageUrls.first,
                height: isLarge ? 140 : 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SpinningLoader(color: Colors.orange),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.error, color: Colors.grey[400]),
                ),
              ),
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
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      if (discountPercentage > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '\$${product.originalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!isLarge) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
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
                          '${product.orders} orders',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (product.isFreeShipping) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Free Shipping',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            expandedHeight: 120,
            toolbarHeight: 60,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              title: Text(
                    'Marketplace',
                    style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w900,
                ),
              ),
              background: Container(color: Colors.white),
            ),
          ),
          // Content
          SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Search bar
                    Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                      controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search items, products...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                            border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Categories
                    SizedBox(
                  height: 90,
                  child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = isSelected ? 'All' : category['name'];
                          });
                        },
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Image.asset(
                                category['icon'],
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category['name'],
                                style: TextStyle(
                                  color: isSelected ? Colors.orange : Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                      ),
                    ),
                const SizedBox(height: 20),
                // New Listings section
                    Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                      const Icon(Icons.star, color: Colors.black),
                          const SizedBox(width: 8),
                          const Text(
                            'New Listings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  child: StreamBuilder<List<AliexpressProduct>>(
                    stream: _databaseService.getAliexpressListings(
                      category: _selectedCategory == 'All' ? null : _selectedCategory,
                      limit: 5,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: SpinningLoader(
                            size: 40,
                            color: Colors.orange,
                          ),
                        );
                      }

                      final products = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(products[index], isLarge: true);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Recommended section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                        children: [
                      const Icon(Icons.recommend, color: Colors.black),
                      const SizedBox(width: 8),
                      const Text(
                        'Recommended',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  child: StreamBuilder<List<AliexpressProduct>>(
                    stream: _databaseService.getRecommendedListings(limit: 5),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: SpinningLoader(
                            size: 40,
                            color: Colors.orange,
                          ),
                        );
                      }

                      final products = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(products[index], isLarge: true);
                        },
                      );
                    },
                      ),
                    ),
                    const SizedBox(height: 24),
                // Top Sellers section
                    Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                      const Icon(Icons.trending_up, color: Colors.black),
                          const SizedBox(width: 8),
                          const Text(
                            'Top sellers',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StreamBuilder<List<AliexpressProduct>>(
                    stream: _databaseService.getAliexpressListings(
                      category: _selectedCategory == 'All' ? null : _selectedCategory,
                      limit: 10,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: SpinningLoader(
                            size: 40,
                            color: Colors.orange,
      ),
    );
  }

                      final products = snapshot.data!;
                      return Column(
                        children: products
                            .map((product) => _buildProductCard(product))
                            .toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 