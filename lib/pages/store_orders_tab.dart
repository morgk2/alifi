import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/order.dart' as store_order;
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../dialogs/order_action_dialog.dart';
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
          // Modern iOS-style segmented control
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(50),
            ),
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.transparent,
              indicatorWeight: 0,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(46),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 14,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(order.status).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Product details
            Row(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: order.productImageUrl,
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
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
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
                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.customerName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Qty: ${order.quantity}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${order.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Colors.green,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Action button
            if (order.status == 'pending' || order.status == 'confirmed' || order.status == 'shipped')
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    String newStatus = '';
                    switch (order.status) {
                      case 'pending':
                        newStatus = 'confirmed';
                        break;
                      case 'confirmed':
                        newStatus = 'shipped';
                        break;
                      case 'shipped':
                        newStatus = 'delivered';
                        break;
                    }
                    _updateOrderStatus(context, order.id, newStatus);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getStatusColor(order.status),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    order.status == 'pending' ? 'Confirm Order' :
                    order.status == 'confirmed' ? 'Ship Order' :
                    order.status == 'shipped' ? 'Mark as Delivered' : '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
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
    // Show confirmation dialog based on the action
    bool? confirmed;
    
    switch (newStatus) {
      case 'confirmed':
        confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Prevent accidental dismissal
          builder: (context) => OrderActionDialog.confirmOrder(
            productName: 'this product',
            onConfirm: () {
              Navigator.of(context).pop(true);
            },
          ),
        );
        break;
      case 'shipped':
        confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Prevent accidental dismissal
          builder: (context) => OrderActionDialog.shipOrder(
            productName: 'this product',
            onConfirm: () {
              Navigator.of(context).pop(true);
            },
          ),
        );
        break;
      case 'delivered':
        confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Prevent accidental dismissal
          builder: (context) => OrderActionDialog.deliverOrder(
            productName: 'this product',
            onConfirm: () {
              Navigator.of(context).pop(true);
            },
          ),
        );
        break;
      default:
        confirmed = true; // For other statuses, proceed without confirmation
    }

    if (confirmed != true) {
      return; // User cancelled
    }

    try {
      // Check if context is still valid before proceeding
      if (!context.mounted) {
        print('Context is no longer mounted, aborting order status update');
        return;
      }

      await DatabaseService().updateOrderStatus(orderId, newStatus);
      
      // Check if context is still valid before showing snackbar
      if (!context.mounted) {
        print('Context is no longer mounted, cannot show success message');
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Check if context is still valid before showing error message
      if (!context.mounted) {
        print('Context is no longer mounted, cannot show error message');
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order status: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
} 