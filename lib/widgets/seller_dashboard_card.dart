import 'package:alifi/pages/detailed_seller_dashboard_page.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'package:provider/provider.dart';
import 'spinning_loader.dart';

class SellerDashboardCard extends StatelessWidget {
  const SellerDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    // Only show for store accounts
    if (user?.accountType != 'store') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Store Dashboard',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.1,
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: DatabaseService().getStoreDashboardStats(user!.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 200, // Match the final content height
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SpinningLoader(
                          size: 50,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading dashboard...',
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

              if (snapshot.hasError) {
                print('🔍 [SellerDashboardCard] Error: ${snapshot.error}');
                return Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'Error loading dashboard',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                print('🔍 [SellerDashboardCard] No data available');
                return Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'No dashboard data available',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final stats = snapshot.data!.first;
              print('🔍 [SellerDashboardCard] Stats received: $stats');
              
              // Safely extract values with proper type conversion
              final totalSales = (stats['totalSales'] ?? 0.0) as double;
              final engagementCount = (stats['engagementCount'] ?? 0).toString();
              final ordersCount = (stats['ordersCount'] ?? 0).toString();
              final activeOrders = (stats['activeOrders'] ?? 0).toString();
              
              print('🔍 [SellerDashboardCard] Parsed values:');
              print('  - totalSales: $totalSales');
              print('  - engagementCount: $engagementCount');
              print('  - ordersCount: $ordersCount');
              print('  - activeOrders: $activeOrders');

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Sales',
                            '\$${totalSales.toStringAsFixed(2)}',
                            Icons.attach_money,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Engagement',
                            engagementCount,
                            Icons.people,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Orders',
                            ordersCount,
                            Icons.shopping_bag,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Active Orders',
                            activeOrders,
                            Icons.local_shipping,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DetailedSellerDashboardPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.analytics),
                        label: const Text('View All Seller Tools'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 