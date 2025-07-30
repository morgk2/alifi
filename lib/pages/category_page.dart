import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/marketplace_product.dart';

class CategoryPage extends StatelessWidget {
  final String title;
  final Color accentColor;
  final String imageAsset;

  const CategoryPage({
    Key? key,
    required this.title,
    required this.accentColor,
    required this.imageAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseService _databaseService = DatabaseService();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 180,
            pinned: true,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final percent = ((constraints.maxHeight - kToolbarHeight) / (180 - kToolbarHeight)).clamp(0.0, 1.0);
                return FlexibleSpaceBar(
                  centerTitle: true,
                  title: Opacity(
                    opacity: 1 - percent,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  background: Center(
                    child: Opacity(
                      opacity: percent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor.withOpacity(0.1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(imageAsset, fit: BoxFit.contain),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSearchBar(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: StreamBuilder<List<MarketplaceProduct>>(
              stream: _databaseService.getMarketplaceProducts(category: title),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(child: Center(child: Text('Error:  [${snapshot.error}')));
                }
                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                }
                final products = snapshot.data!;
                if (products.isEmpty) {
                  return const SliverToBoxAdapter(child: Center(child: Text('No products found.')));
                }
                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = products[index];
                      return _buildItemCard(product, accentColor);
                    },
                    childCount: products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search in  [${title.toLowerCase()}...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildItemCard(MarketplaceProduct product, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: product.imageUrls.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(product.imageUrls.first, fit: BoxFit.cover, width: double.infinity),
                  )
                : const Placeholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.price} DZD',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 