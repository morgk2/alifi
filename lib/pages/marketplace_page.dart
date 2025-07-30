import 'package:flutter/material.dart';
import '../models/marketplace_product.dart';
import '../services/database_service.dart';
import '../widgets/spinning_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'product_details_page.dart';
import '../models/aliexpress_product.dart';
import '../models/store_product.dart';
import 'user_orders_page.dart';
import 'category_page.dart';
import 'dart:async';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> with TickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isSearchMode = false;
  String _sortBy = 'orders'; // 'orders', 'price_low', 'price_high', 'newest'
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _searchFadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _searchFadeAnimation;
  
  // Search debouncing
  Timer? _searchDebounceTimer;
  String _currentSearchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {'icon': 'assets/images/food.png', 'name': 'Food'},
    {'icon': 'assets/images/toys.png', 'name': 'Toys'},
    {'icon': 'assets/images/health.png', 'name': 'Health'},
    {'icon': 'assets/images/beds.png', 'name': 'Beds'},
    {'icon': 'assets/images/hygiene.png', 'name': 'Hygiene'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchFadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _searchFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchFadeController, curve: Curves.easeInOut),
    );

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchFadeController.dispose();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final hasText = _searchController.text.trim().isNotEmpty;
    final query = _searchController.text.trim();
    
    // Update search mode immediately
    if (hasText != _isSearchMode) {
      setState(() {
        _isSearchMode = hasText;
      });
      
      if (_isSearchMode) {
        _fadeController.forward();
        _searchFadeController.forward();
      } else {
        _fadeController.reverse();
        _searchFadeController.reverse();
      }
    }
    
    // Debounce the search query update
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentSearchQuery = query;
        });
      }
    });
  }

  Widget _buildSearchControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Order by button
          Expanded(
            child: GestureDetector(
              onTap: _showSortDialog,
      child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
          children: [
                    Icon(Icons.sort, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      _getSortDisplayText(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter button
          Expanded(
            child: GestureDetector(
              onTap: _showFilterDialog,
                    child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                  color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      _getFilterDisplayText(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[600]),
                  ],
                ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  String _getSortDisplayText() {
    switch (_sortBy) {
      case 'orders':
        return 'Most Orders';
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'newest':
        return 'Newest First';
      default:
        return 'Sort by';
    }
  }

  String _getFilterDisplayText() {
    if (_selectedCategory == 'All') {
      return 'All Categories';
    }
    return _selectedCategory;
  }

  void _showSortDialog() {
    String tempSortBy = _sortBy;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
              child: Column(
              mainAxisSize: MainAxisSize.min,
                children: [
                const Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSortOption('orders', 'Most Orders', Icons.trending_up, tempSortBy, (value) {
                  setDialogState(() {
                    tempSortBy = value;
                  });
                }),
                _buildSortOption('price_low', 'Price: Low to High', Icons.arrow_upward, tempSortBy, (value) {
                  setDialogState(() {
                    tempSortBy = value;
                  });
                }),
                _buildSortOption('price_high', 'Price: High to Low', Icons.arrow_downward, tempSortBy, (value) {
                  setDialogState(() {
                    tempSortBy = value;
                  });
                }),
                _buildSortOption('newest', 'Newest First', Icons.new_releases, tempSortBy, (value) {
                  setDialogState(() {
                    tempSortBy = value;
                  });
                }),
                const SizedBox(height: 24),
                  Row(
                    children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                        style: TextStyle(
                            color: Colors.grey,
                          fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _sortBy = tempSortBy;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    String tempCategory = _selectedCategory;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
                      children: [
                const Text(
                  'Filter by Category',
                  style: TextStyle(
                    fontSize: 20,
                            fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                _buildFilterOption('All', 'All Categories', Icons.category, tempCategory, (value) {
                  setDialogState(() {
                    tempCategory = value;
                  });
                }),
                ..._categories.map((category) => _buildFilterOption(
                  category['name'],
                  category['name'],
                  Icons.category,
                  tempCategory,
                  (value) {
                    setDialogState(() {
                      tempCategory = value;
                    });
                  },
                )),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = tempCategory;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Done',
                              style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon, String currentValue, Function(String) onChanged) {
    final isSelected = currentValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
          color: isSelected ? Colors.orange[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
                    size: 20,
              color: isSelected ? Colors.orange : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.orange : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, size: 20, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value, String label, IconData icon, String currentValue, Function(String) onChanged) {
    final isSelected = currentValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
                  children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.orange : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.orange : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, size: 20, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  // Remove the old dropdown methods
  void _showSortOptions() {
    // Removed - replaced with custom dialog
  }

  void _showFilterOptions() {
    // Removed - replaced with custom dialog
  }

  PopupMenuItem<String> _buildMenuItem(String value, String text, IconData icon) {
    // Removed - no longer needed
    return PopupMenuItem<String>(value: value, child: const SizedBox.shrink());
  }

  void _onSortSelected(String value) {
    // Removed - no longer needed
  }

  void _onFilterSelected(String value) {
    // Removed - no longer needed
  }

  Widget _buildCategories() {
    return Column(
      children: [
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
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => CategoryPage(
                        title: category['name'],
                        accentColor: Colors.orange,
                        imageAsset: category['icon'],
                      ),
                      transitionsBuilder: (_, animation, __, child) =>
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        ),
                    ),
                  );
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
      ],
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<MarketplaceProduct>>(
      stream: _databaseService.searchMarketplaceProducts(
        query: _currentSearchQuery,
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        sortBy: _sortBy,
        limit: 50,
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
        
        if (products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No products found for "${_currentSearchQuery}"',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24), // Added more spacing
              Text(
                '${products.length} results found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _buildSearchResultCard(products[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegularSections() {
    return Column(
      children: [
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
                  child: StreamBuilder<List<MarketplaceProduct>>(
                    stream: _databaseService.getNewMarketplaceProducts(limit: 10),
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
                  child: StreamBuilder<List<MarketplaceProduct>>(
                    stream: _databaseService.getRecommendedMarketplaceProducts(limit: 10),
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
        // Popular Products section
                    Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                      const Icon(Icons.trending_up, color: Colors.black),
                          const SizedBox(width: 8),
                          const Text(
                'Popular Products',
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
                  child: StreamBuilder<List<MarketplaceProduct>>(
                    stream: _databaseService.getMarketplaceProducts(
                      category: _selectedCategory == 'All' ? null : _selectedCategory,
                      limit: 20,
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
    );
  }

  Widget _buildProductCard(MarketplaceProduct product, {bool isLarge = false}) {
    final discountPercentage = product.originalPrice > 0
        ? ((1 - (product.price / product.originalPrice)) * 100).round()
        : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              product: product.type == 'aliexpress'
                  ? product.toAliexpress()
                  : product.toStore(),
            ),
          ),
        );
      },
      child: Container(
        width: isLarge ? 160 : double.infinity,
        margin: EdgeInsets.only(right: isLarge ? 16 : 0, bottom: isLarge ? 0 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: product.type == 'store'
                ? Colors.green[200]!
                : (isLarge ? Colors.grey[200]! : Colors.orange[100]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: product.type == 'store' ? Colors.green : Colors.orange,
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
                          '${product.totalOrders} orders',
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

  Widget _buildSearchResultCard(MarketplaceProduct product) {
    final discountPercentage = product.originalPrice > 0
        ? ((1 - (product.price / product.originalPrice)) * 100).round()
        : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              product: product.type == 'aliexpress'
                  ? product.toAliexpress()
                  : product.toStore(),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: product.type == 'store'
                ? Colors.green[200]!
                : Colors.orange[100]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrls.first,
                    height: 120,
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
                if (product.type == 'store')
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: product.type == 'store' ? Colors.green : Colors.orange,
                        ),
                      ),
                      if (discountPercentage > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '\$${product.originalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.totalOrders}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
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
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserOrdersPage(),
                    ),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.green[600],
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              title: const Text(
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
                
                // Search Controls (only visible when searching)
                AnimatedBuilder(
                  animation: _searchFadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _searchFadeAnimation.value,
                      child: _isSearchMode ? _buildSearchControls() : const SizedBox.shrink(),
                    );
                  },
                ),
                
                // Categories (fade out when searching)
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: _isSearchMode ? const SizedBox.shrink() : _buildCategories(),
                    );
                  },
                ),
                
                // Search Results (fade in when searching)
                AnimatedBuilder(
                  animation: _searchFadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _searchFadeAnimation.value,
                      child: _isSearchMode ? _buildSearchResults() : const SizedBox.shrink(),
                    );
                  },
                ),
                
                // Regular sections (fade out when searching)
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: _isSearchMode ? const SizedBox.shrink() : _buildRegularSections(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 