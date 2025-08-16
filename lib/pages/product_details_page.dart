import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/aliexpress_product.dart';
import '../models/store_product.dart';
import '../models/user.dart';
import '../models/marketplace_product.dart';
import '../services/navigation_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/spinning_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'user_profile_page.dart';
import '../services/database_service.dart';
import '../services/currency_service.dart';
import '../services/currency_service.dart' show Currency;
import '../widgets/currency_symbol.dart';
import 'package:alifi/dialogs/gift_user_search_dialog.dart' as gift_dialog;
import 'package:alifi/pages/store_chat_page.dart';
import 'package:alifi/pages/checkout_page.dart';
import '../widgets/product_review_card.dart';
import '../l10n/app_localizations.dart';
import '../widgets/pinch_zoom_image.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';
import '../utils/app_fonts.dart';

class ProductDetailsPage extends StatefulWidget {
  final dynamic product;  // Can be either AliexpressProduct or StoreProduct

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool get isStoreProduct => widget.product is StoreProduct;
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWishlistState());
  }

  Future<void> _loadWishlistState() async {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) return;
    final type = isStoreProduct ? 'store' : 'aliexpress';
    final id = isStoreProduct ? (widget.product as StoreProduct).id : (widget.product as AliexpressProduct).id;
    final inList = await DatabaseService().isInWishlist(userId: user.id, productId: id, productType: type);
    if (mounted) setState(() => _isWishlisted = inList);
  }

  Future<void> _toggleWishlist() async {
    final auth = context.read<AuthService>();
    final notify = context.read<NotificationService>();
    final user = auth.currentUser;
    if (user == null) return;
    final type = isStoreProduct ? 'store' : 'aliexpress';
    final id = isStoreProduct ? (widget.product as StoreProduct).id : (widget.product as AliexpressProduct).id;
    await DatabaseService().toggleWishlistItem(userId: user.id, productId: id, productType: type);
    if (mounted) setState(() => _isWishlisted = !_isWishlisted);

    if (isStoreProduct && _isWishlisted) {
      final storeProduct = widget.product as StoreProduct;
      await notify.sendWishlistNotification(
        storeOwnerId: storeProduct.storeId,
        wisherUserId: user.id,
        wisherName: user.displayName,
        wisherPhotoUrl: user.photoURL,
        productName: storeProduct.name,
        productId: storeProduct.id,
      );
    }
  }

  Widget _buildRelatedProductCard(MarketplaceProduct product) {
    final discountPercentage = product.originalPrice > 0
        ? ((1 - (product.price / product.originalPrice)) * 100).round()
        : 0;

    return GestureDetector(
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
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: product.type == 'store'
                ? Colors.green[200]!
                : Colors.grey[200]!,
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
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      'assets/images/photo_loader.png',
                      fit: BoxFit.cover,
                      height: 140,
                      width: double.infinity,
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Store',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
                                    size: 16,
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
                            :                             Text(
                              currencyService.formatProductPrice(product.price, product.currency),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: product.type == 'store' ? Colors.green : Colors.orange,
                              ),
                            ),
                          if (discountPercentage > 0) ...[
                            const SizedBox(width: 8),
                            currencyService.currentCurrency == Currency.DZD
                              ? Row(
                                  children: [
                                    CurrencySymbol(
                                      size: 12,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenGallery(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              '${initialIndex + 1} / ${widget.product.imageUrls.length}',
              style: const TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(widget.product.imageUrls[index]),
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.black,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.white, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                initialScale: PhotoViewComputedScale.contained,
              );
            },
            itemCount: widget.product.imageUrls.length,
            loadingBuilder: (context, event) => Container(
              color: Colors.black,
              child: Center(
                child: Image.asset(
                  'assets/images/photo_loader.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            pageController: PageController(initialPage: initialIndex),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final discountPercentage = isStoreProduct ? 0 : widget.product.originalPrice > 0
        ? ((1 - (widget.product.price / widget.product.originalPrice)) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.productDetails,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isStoreProduct)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Store',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              _isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: _isWishlisted ? Colors.red : Colors.black,
            ),
            onPressed: _toggleWishlist,
            tooltip: l10n.addToWishlist,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: widget.product.imageUrls.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _showFullScreenGallery(index);
                        },
                        child: CachedNetworkImage(
                          imageUrl: widget.product.imageUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[100],
                            child: Image.asset(
                              'assets/images/photo_loader.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.grey[400], size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
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
                // Page indicator
                if (widget.product.imageUrls.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.product.imageUrls.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price and Discount
                  Consumer<CurrencyService>(
                    builder: (context, currencyService, child) {
                      return Row(
                        children: [
                          currencyService.currentCurrency == Currency.DZD
                            ? Row(
                                children: [
                                  CurrencySymbol(
                                    size: 24,
                                    color: isStoreProduct ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    currencyService.formatProductPrice(widget.product.price, widget.product.currency),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isStoreProduct ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                currencyService.formatProductPrice(widget.product.price, widget.product.currency),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isStoreProduct ? Colors.green : Colors.orange,
                                ),
                              ),
                          if (discountPercentage > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '-$discountPercentage%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Ratings and Orders
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        isStoreProduct 
                            ? '${(widget.product as StoreProduct).rating.toStringAsFixed(1)}'
                            : '${widget.product.rating.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.shopping_bag, color: Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        isStoreProduct 
                            ? '${(widget.product as StoreProduct).totalOrders} orders'
                            : '${widget.product.totalOrders} orders',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Shipping Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_shipping_outlined,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.product.isFreeShipping ? l10n.freeShipping : l10n.shippingFeeApplies,
                              style: TextStyle(
                                color: widget.product.isFreeShipping ? Colors.green : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (widget.product.shippingTime.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                'Delivery in ${widget.product.shippingTime} days',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isStoreProduct) ...[
                    const SizedBox(height: 16),
                    // Store Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FutureBuilder<User?>(
                        future: DatabaseService().getUser(widget.product.storeId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: SpinningLoader());
                          }
                          if (!snapshot.hasData) {
                            return const Text('Store not found');
                          }
                          final store = snapshot.data!;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundImage: store.photoURL != null
                                  ? NetworkImage(store.photoURL!)
                                  : null,
                              child: store.photoURL == null
                                  ? const Icon(Icons.store)
                                  : null,
                            ),
                            title: Text(
                              store.displayName ?? 'Store',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              store.basicInfo ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: TextButton(
                              onPressed: () {
                                NavigationService.push(
                                  context,
                                  UserProfilePage(user: store),
                                );
                              },
                              child: Text(l10n.viewStore),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Description
                  Text(
                    l10n.description,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.card_giftcard),
                      label: Text(l10n.buyAsAGift),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => gift_dialog.GiftUserSearchDialog(
                            productId: widget.product.id,
                            productName: widget.product is AliexpressProduct
                                ? (widget.product as AliexpressProduct).name
                                : (widget.product is StoreProduct
                                    ? (widget.product as StoreProduct).name
                                    : (widget.product as MarketplaceProduct).name),
                            productImage: widget.product is AliexpressProduct
                                ? (widget.product as AliexpressProduct).imageUrls.isNotEmpty 
                                    ? (widget.product as AliexpressProduct).imageUrls.first
                                    : ''
                                : (widget.product is StoreProduct
                                    ? (widget.product as StoreProduct).imageUrls.isNotEmpty
                                        ? (widget.product as StoreProduct).imageUrls.first
                                        : ''
                                    : (widget.product as MarketplaceProduct).imageUrls.isNotEmpty
                                        ? (widget.product as MarketplaceProduct).imageUrls.first
                                        : ''),
                            productPrice: widget.product is AliexpressProduct
                                ? (widget.product as AliexpressProduct).price
                                : (widget.product is StoreProduct
                                    ? (widget.product as StoreProduct).price
                                    : (widget.product as MarketplaceProduct).price),
                            productType: widget.product is AliexpressProduct
                                ? 'aliexpress'
                                : (widget.product is StoreProduct ? 'store' : 'marketplace'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            isStoreProduct ? Colors.green : Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                  if (!isStoreProduct) ...[
                    const SizedBox(height: 24),
                    // Transparency section for AliExpress products
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.affiliateDisclosure,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.affiliateDisclosureText,
                            style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  // Reviews Section (only for store products)
                  if (isStoreProduct) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            l10n.customerReviews,
                            style: TextStyle(fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: context.titleFont,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, size: 14, color: Colors.orange[700]),
                                const SizedBox(width: 4),
                                Text(
                                  '${(widget.product as StoreProduct).rating.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange[700],
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: DatabaseService().getProductReviews((widget.product as StoreProduct).id),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              child: Text(l10n.errorLoadingReviews(snapshot.error.toString())),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                              child: SpinningLoader(
                                size: 30,
                                color: Colors.orange,
                              ),
                            );
                          }

                          final reviews = snapshot.data!;

                          if (reviews.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(32),
                              child: const Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.rate_review_outlined,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'No reviews yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Be the first to review this product',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              return ProductReviewCard(
                                review: reviews[index],
                                showProduct: false,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // You may be interested too
                  Text(
                    l10n.youMayBeInterestedToo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: StreamBuilder<List<MarketplaceProduct>>(
                      stream: DatabaseService().getMarketplaceProducts(
                        category: widget.product.category,
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

                        final products = snapshot.data!
                            .where((p) => p.id != (isStoreProduct
                                ? (widget.product as StoreProduct).id
                                : (widget.product as AliexpressProduct).id))
                            .toList();

                        if (products.isEmpty) {
                          return Center(
                            child: Text(l10n.noRelatedProductsFound),
                          );
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _buildRelatedProductCard(products[index]);
                          },
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
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isStoreProduct) {
                        // Navigate to checkout page
                        NavigationService.push(
                          context,
                          CheckoutPage(product: widget.product),
                        );
                      } else {
                        // For Aliexpress products, open affiliate link
                        final url = Uri.parse((widget.product as AliexpressProduct).affiliateUrl);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Order Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () async {
                    if (isStoreProduct) {
                      // Get store user information and navigate to chat
                      try {
                        final storeUser = await DatabaseService().getUser(widget.product.storeId);
                        if (storeUser != null) {
                          NavigationService.push(
                            context,
                            StoreChatPage(
                              product: widget.product,
                              storeUser: storeUser,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to open chat: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(
                    CupertinoIcons.chat_bubble_2,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowItWorksDialog extends StatefulWidget {
  const _HowItWorksDialog();

  @override
  State<_HowItWorksDialog> createState() => _HowItWorksDialogState();
}

class _HowItWorksDialogState extends State<_HowItWorksDialog> {
  final TextEditingController _addressController = TextEditingController();
  String? _selectedCity;
  final List<String> _wilayas = [
    'Adrar', 'Chlef', 'Laghouat', 'Oum El Bouaghi', 'Batna', 'Béjaïa', 'Biskra', 'Béchar', 'Blida', 'Bouira',
    'Tamanrasset', 'Tébessa', 'Tlemcen', 'Tiaret', 'Tizi Ouzou', 'Algiers', 'Djelfa', 'Jijel', 'Sétif', 'Saïda',
    'Skikda', 'Sidi Bel Abbès', 'Annaba', 'Guelma', 'Constantine', 'Médéa', 'Mostaganem', 'M’Sila', 'Mascara', 'Ouargla',
    'Oran', 'El Bayadh', 'Illizi', 'Bordj Bou Arréridj', 'Boumerdès', 'El Tarf', 'Tindouf', 'Tissemsilt', 'El Oued', 'Khenchela',
    'Souk Ahras', 'Tipaza', 'Mila', 'Aïn Defla', 'Naâma', 'Aïn Témouchent', 'Ghardaïa', 'Relizane', 'Timimoun', 'Bordj Badji Mokhtar',
    'Ouled Djellal', 'Béni Abbès', 'In Salah', 'In Guezzam', 'Touggourt', 'Djanet', 'El M’Ghair', 'El Meniaa'
  ];

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    l10n.howDoesItWork,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 15, height: 1.5),
                  children: [
                    TextSpan(text: 'You enter your address, and your city and then you make sure you send '),
                    TextSpan(
                      text: 'MONEY_AMOUNT',
                      style: TextStyle(color: Color(0xFFF5A623), fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' to this ccp address '),
                    TextSpan(
                      text: '000000000000000000000000000000',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' and then send the proof of payment in this email '),
                    TextSpan(
                      text: 'payment@alifi.app',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ", we'll make sure to get your product shipped as soon as possible"),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Enter your address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                items: _wilayas
                    .map((city) => DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCity = value),
                decoration: InputDecoration(
                  hintText: 'Select your city',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF5A623),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 