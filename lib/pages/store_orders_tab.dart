import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/order.dart' as store_order;
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'package:provider/provider.dart';

class StoreOrdersTab extends StatelessWidget {
  const StoreOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    print('🔍 [StoreOrdersTab] build() called');
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    print('🔍 [StoreOrdersTab] Current user: ${user?.id}');
    print('🔍 [StoreOrdersTab] User account type: ${user?.accountType}');

    if (user == null) {
      print('🔍 [StoreOrdersTab] No user found, showing login message');
      return const Center(child: Text('Please log in.'));
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.green,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
                Tab(text: 'All'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrdersList(context, user.id, ['pending', 'confirmed', 'shipped']),
                _buildOrdersList(context, user.id, ['delivered']),
                _buildOrdersList(context, user.id, null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, String storeId, List<String>? statusFilter) {
    print('🔍 [StoreOrdersTab] Building orders list');
    print('🔍 [StoreOrdersTab] StoreId: $storeId');
    print('🔍 [StoreOrdersTab] StatusFilter: $statusFilter');
    
    Stream<List<store_order.StoreOrder>> stream;
    
    if (statusFilter != null) {
      print('🔍 [StoreOrdersTab] Using filtered stream with statusFilter: $statusFilter');
      stream = DatabaseService()
          .getStoreOrders(storeId)
          .map((orders) {
            print('🔍 [StoreOrdersTab] Raw orders received: ${orders.length}');
            final filteredOrders = orders.where((order) => statusFilter.contains(order.status)).toList();
            print('🔍 [StoreOrdersTab] Filtered orders: ${filteredOrders.length}');
            print('🔍 [StoreOrdersTab] Order statuses: ${orders.map((o) => o.status).toList()}');
            return filteredOrders;
          });
    } else {
      print('🔍 [StoreOrdersTab] Using unfiltered stream');
      stream = DatabaseService().getStoreOrders(storeId);
    }

    return StreamBuilder<List<store_order.StoreOrder>>(
      stream: stream,
      builder: (context, snapshot) {
        print('🔍 [StoreOrdersTab] StreamBuilder state: ${snapshot.connectionState}');
        print('🔍 [StoreOrdersTab] Has error: ${snapshot.hasError}');
        if (snapshot.hasError) {
          print('🔍 [StoreOrdersTab] Error details: ${snapshot.error}');
          print('🔍 [StoreOrdersTab] Error stack trace: ${snapshot.stackTrace}');
        }
        print('🔍 [StoreOrdersTab] Has data: ${snapshot.hasData}');
        if (snapshot.hasData) {
          print('🔍 [StoreOrdersTab] Data length: ${snapshot.data?.length}');
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('🔍 [StoreOrdersTab] Showing loading indicator');
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('🔍 [StoreOrdersTab] Showing error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading orders: ${snapshot.error}',
                  style: TextStyle(fontFamily: 'Inter'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Check console for detailed error information',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data ?? [];
        print('🔍 [StoreOrdersTab] Final orders to display: ${orders.length}');

        if (orders.isEmpty) {
          print('🔍 [StoreOrdersTab] No orders to display');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  statusFilter != null 
                      ? 'No ${statusFilter.first} orders yet'
                      : 'No orders yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Orders from customers will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Debug: StoreId=$storeId, Filter=$statusFilter',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        print('🔍 [StoreOrdersTab] Building ListView with ${orders.length} orders');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            print('🔍 [StoreOrdersTab] Building order card ${index + 1}/${orders.length}: ${order.productName} (${order.status})');
            return _buildOrderCard(context, order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, store_order.StoreOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: order.productImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Customer: ${order.customerName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${order.quantity}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${order.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green[600],
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
                const Spacer(),
                if (order.status == 'pending')
                  ElevatedButton(
                    onPressed: () => _updateOrderStatus(context, order.id, 'confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                if (order.status == 'confirmed')
                  ElevatedButton(
                    onPressed: () => _updateOrderStatus(context, order.id, 'shipped'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Ship',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                if (order.status == 'shipped')
                  ElevatedButton(
                    onPressed: () => _updateOrderStatus(context, order.id, 'delivered'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Deliver',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _updateOrderStatus(BuildContext context, String orderId, String newStatus) async {
    try {
      await DatabaseService().updateOrderStatus(orderId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 