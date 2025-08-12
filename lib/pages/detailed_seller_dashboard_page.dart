import 'package:alifi/models/store_product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/currency_service.dart';
import '../services/notification_service.dart';
import '../widgets/sales_chart_widget.dart';
import '../widgets/badge_widget.dart';
import 'store/add_product_page.dart';
import 'store_messages_tab.dart';
import 'store_orders_tab.dart';
import '../l10n/app_localizations.dart';

class DetailedSellerDashboardPage extends StatefulWidget {
  const DetailedSellerDashboardPage({super.key});

  @override
  State<DetailedSellerDashboardPage> createState() =>
      _DetailedSellerDashboardPageState();
}

class _DetailedSellerDashboardPageState extends State<DetailedSellerDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          l10n.sellerDashboard,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      body: Column(
        children: [
          // Floating pill-shaped TabBar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.transparent,
              indicatorWeight: 0,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.orange.withOpacity(0.15),
              ),
              labelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              tabs: [
                Tab(
                  icon: Image.asset(
                    'assets/images/overview.png',
                    width: 40,
                    height: 40,
                  ),
                  text: l10n.overview,
                ),
                Tab(
                  icon: Image.asset(
                    'assets/images/products.png',
                    width: 40,
                    height: 40,
                  ),
                  text: l10n.products,
                ),
                Tab(
                  icon: Consumer<NotificationService>(
                    builder: (context, notificationService, child) {
                      final authService = Provider.of<AuthService>(context, listen: false);
                      final user = authService.currentUser;
                      final unreadOrders = user != null 
                          ? notificationService.getSellerUnreadOrders(user.id)
                          : 0;
                      
                      return BadgeWidget(
                        count: unreadOrders,
                        child: Image.asset(
                          'assets/images/orders.png',
                          width: 40,
                          height: 40,
                        ),
                      );
                    },
                  ),
                  text: l10n.orders,
                ),
                Tab(
                  icon: Consumer<NotificationService>(
                    builder: (context, notificationService, child) {
                      final authService = Provider.of<AuthService>(context, listen: false);
                      final user = authService.currentUser;
                      final unreadMessages = user != null 
                          ? notificationService.getSellerUnreadMessages(user.id)
                          : 0;
                      
                      return BadgeWidget(
                        count: unreadMessages,
                        child: Image.asset(
                          'assets/images/messages.png',
                          width: 40,
                          height: 40,
                        ),
                      );
                    },
                  ),
                  text: l10n.messages,
                ),
              ],
            ),
          ),
          // TabBarView content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildProductsTab(),
                _buildOrdersTab(),
                _buildMessagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final l10n = AppLocalizations.of(context)!;
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return Center(child: Text(l10n.pleaseLogIn));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.revenueAnalytics,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          // Sales Analytics Cards
          StreamBuilder<Map<String, dynamic>>(
            stream: DatabaseService().getStoreSalesAnalytics(user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Image.asset(
                    'assets/images/loading.png',
                    width: 32,
                    height: 32,
                    color: const Color(0xFFF59E0B),
                  ),
                );
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              final analytics = snapshot.data ?? {
                'todaySales': 0.0,
                'weekSales': 0.0,
                'monthSales': 0.0,
                'totalSales': 0.0,
                'orderCount': 0,
              };
              
              return Column(
                children: [
                  // Today's Sales
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.today_rounded,
                              color: Colors.green[600],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.todaysSales,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Consumer<CurrencyService>(
                          builder: (context, currencyService, child) {
                            return Text(
                              currencyService.formatPrice(analytics['todaySales']),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                                fontFamily: 'InterDisplay',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Weekly and Monthly Sales Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_view_week_rounded,
                                    color: Colors.blue[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.thisWeek,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Consumer<CurrencyService>(
                                builder: (context, currencyService, child) {
                                  return Text(
                                    currencyService.formatPrice(analytics['weekSales']),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                      fontFamily: 'InterDisplay',
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.purple[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    color: Colors.purple[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.thisMonth,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.purple[700],
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Consumer<CurrencyService>(
                                builder: (context, currencyService, child) {
                                  return Text(
                                    currencyService.formatPrice(analytics['monthSales']),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple[700],
                                      fontFamily: 'InterDisplay',
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            l10n.keyMetrics,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: DatabaseService().getStoreDashboardStats(user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Image.asset(
                    'assets/images/loading.png',
                    width: 32,
                    height: 32,
                    color: const Color(0xFFF59E0B),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data available.'));
              }
              final stats = snapshot.data!.first;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  Consumer<CurrencyService>(
                    builder: (context, currencyService, child) {
                      return _buildStatCard(
                        l10n.totalSales,
                        currencyService.formatPrice((stats['totalSales'] as num).toDouble()),
                        Icons.attach_money_rounded,
                        Colors.green,
                      );
                    },
                  ),
                  _buildStatCard(
                    l10n.uniqueCustomers,
                    stats['engagementCount'].toString(),
                    Icons.people_alt_rounded,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    l10n.totalOrders,
                    stats['ordersCount'].toString(),
                    Icons.shopping_bag_rounded,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    l10n.activeOrders,
                    stats['activeOrders'].toString(),
                    Icons.local_shipping_rounded,
                    Colors.purple,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Sales Analytics',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
            stream: DatabaseService().getStoreSalesChartData(user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Image.asset(
                    'assets/images/loading.png',
                    width: 32,
                    height: 32,
                    color: const Color(0xFFF59E0B),
                  ),
                );
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              final chartData = snapshot.data ?? {
                'weekly': <Map<String, dynamic>>[],
                'monthly': <Map<String, dynamic>>[],
              };
              
              return SalesChartWidget(
                chartData: chartData,
                title: 'Sales Analytics',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'InterDisplay',
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Center(child: Text('Please log in.'));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<StoreProduct>>(
        stream: DatabaseService().getProductsByStore(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Image.asset(
                'assets/images/loading.png',
                width: 32,
                height: 32,
                color: const Color(0xFFF59E0B),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You have no products yet.',
                style: TextStyle(
                    fontSize: 18, color: Colors.grey, fontFamily: 'Inter'),
              ),
            );
          }

          final products = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrls.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/loading.png',
                                width: 24,
                                height: 24,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.error,
                              color: Colors.grey[400],
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Consumer<CurrencyService>(
                              builder: (context, currencyService, child) {
                                return Row(
                                  children: [
                                    Text(
                                      currencyService.formatPrice(product.price),
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (product.totalOrders > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${product.totalOrders} orders',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Action Buttons
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                              onPressed: () {
                                // TODO: Implement edit product
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                              onPressed: () {
                                // TODO: Implement delete product
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductPage(),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
        shape: const CircleBorder(),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return const StoreOrdersTab();
  }

  Widget _buildMessagesTab() {
    return const StoreMessagesTab();
  }
} 