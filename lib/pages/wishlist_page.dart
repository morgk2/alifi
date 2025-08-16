import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
// import '../widgets/optimized_image.dart';
import '../utils/app_fonts.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sortBy = 'newest'; // newest, price_low, price_high
  String _category = 'All';

  List<_WishlistItem> _items = [];

  Future<void> _loadWishlist() async {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) return;
    try {
      final snap = await FirebaseFirestore.instance.collection('users').doc(user.id).get();
      final data = snap.data();
      final List<dynamic> raw = (data?['wishlist'] as List<dynamic>?) ?? [];

      final List<_WishlistItem> built = [];
      for (final entry in raw) {
        if (entry is! Map) continue;
        final String id = (entry['id'] ?? '').toString();
        final String type = (entry['type'] ?? '').toString();
        if (id.isEmpty || type.isEmpty) continue;
        if (type == 'store') {
          final p = await DatabaseService().getStoreProduct(id);
          if (p != null) {
            built.add(_WishlistItem(
              id: p.id,
              title: p.name,
              price: p.price,
              imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : null,
              category: p.category,
              createdAt: p.createdAt,
              type: 'store',
            ));
          }
        } else if (type == 'aliexpress') {
          built.add(_WishlistItem(
            id: id,
            title: 'AliExpress item',
            price: 0,
            imageUrl: null,
            category: 'AliExpress',
            createdAt: DateTime.now(),
            type: 'aliexpress',
          ));
        }
      }
      setState(() => _items = built);
    } catch (_) {}
  }

  List<_WishlistItem> get _filtered {
    List<_WishlistItem> list = _items
        .where((e) => _category == 'All' || e.category == _category)
        .where((e) => _query.isEmpty || e.title.toLowerCase().contains(_query))
        .toList();

    switch (_sortBy) {
      case 'price_low':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return list;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWishlist());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSort() async {
    String temp = _sortBy;
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sort by', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _sortTile('newest', 'Newest first', Icons.new_releases, temp, (v) => temp = v),
              _sortTile('price_low', 'Price: Low to High', Icons.arrow_upward, temp, (v) => temp = v),
              _sortTile('price_high', 'Price: High to Low', Icons.arrow_downward, temp, (v) => temp = v),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        setState(() => _sortBy = temp);
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _openFilter() async {
    final categories = ['All', 'Food', 'Toys', 'Health', 'Beds', 'Hygiene'];
    String temp = _category;
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filter by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...categories.map((c) => _filterTile(c, c, Icons.category, temp, (v) => temp = v)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        setState(() => _category = temp);
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortTile(String value, String label, IconData icon, String current, void Function(String) onSelect) {
    final selected = value == current;
    return ListTile(
      onTap: () => setState(() => onSelect(value)),
      leading: Icon(icon, color: selected ? const Color(0xFFF59E0B) : Colors.grey[600]),
      title: Text(label, style: TextStyle(color: selected ? const Color(0xFFF59E0B) : Colors.black)),
      trailing: selected ? const Icon(Icons.check_circle, color: Color(0xFFF59E0B)) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _filterTile(String value, String label, IconData icon, String current, void Function(String) onSelect) {
    final selected = value == current;
    return ListTile(
      onTap: () => setState(() => onSelect(value)),
      leading: Icon(icon, color: selected ? const Color(0xFFF59E0B) : Colors.grey[600]),
      title: Text(label, style: TextStyle(color: selected ? const Color(0xFFF59E0B) : Colors.black)),
      trailing: selected ? const Icon(Icons.check_circle, color: Color(0xFFF59E0B)) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
          'assets/images/back_icon.png',
          width: 24,
          height: 24,
          color: Colors.black,
        ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wishlist',
          style: TextStyle(fontFamily: context.titleFont,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset.zero,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Search your wishlist...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sort + Filter controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _openSort,
                    child: _chipButton(
                      icon: Icons.sort,
                      label: _sortBy == 'newest'
                          ? 'Newest'
                          : _sortBy == 'price_low'
                              ? 'Price: Low to High'
                              : 'Price: High to Low',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _openFilter,
                    child: _chipButton(
                      icon: Icons.filter_list,
                      label: _category == 'All' ? 'All Categories' : _category,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Grid of wishlist items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
               itemBuilder: (context, index) {
                final item = items[index];
                return _WishlistCard(
                  item: item,
                  onRemoved: () async {
                    final auth = context.read<AuthService>();
                    final user = auth.currentUser;
                    if (user == null) return;
                    await DatabaseService().toggleWishlistItem(
                      userId: user.id,
                      productId: item.id,
                      productType: item.type,
                    );
                    await _loadWishlist();
                  },
                );
               },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipButton({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[600]),
        ],
      ),
    );
  }
}

class _WishlistItem {
  final String id;
  final String title;
  final double price;
  final String? imageUrl;
  final String category;
  final DateTime createdAt;
  final String type; // 'store' | 'aliexpress'
  _WishlistItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.createdAt,
    required this.type,
  });
}

class _WishlistCard extends StatelessWidget {
  final _WishlistItem item;
  final VoidCallback? onRemoved;
  const _WishlistCard({required this.item, this.onRemoved});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          AspectRatio(
            aspectRatio: 1.2,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                color: Colors.grey[100],
                child: item.imageUrl == null
                    ? const Icon(Icons.image, color: Colors.grey)
                    : Image.network(item.imageUrl!, fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  item.category,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onRemoved,
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}