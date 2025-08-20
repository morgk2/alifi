import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/order.dart' as store_order;
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/currency_service.dart';
import '../pages/discussion_chat_page.dart';

import '../models/user.dart';
import '../dialogs/order_action_dialog.dart';
import '../widgets/product_review_dialog.dart';
import '../widgets/badge_widget.dart';
import 'package:provider/provider.dart';
import '../utils/app_fonts.dart';
import '../l10n/app_localizations.dart';

class UserOrdersPage extends StatefulWidget {
  const UserOrdersPage({super.key});

  @override
  State<UserOrdersPage> createState() => _UserOrdersPageState();
}

class _UserOrdersPageState extends State<UserOrdersPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Mark orders as read when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      if (user != null) {
        // Mark all unread orders as read
        _markOrdersAsRead(user.id);
      }
    });
  }

  Future<void> _markOrdersAsRead(String userId) async {
    try {
      final databaseService = DatabaseService();
      final orders = await databaseService.getUserOrders(userId).first;
      
      for (final order in orders) {
        await databaseService.markOrderAsRead(userId, order.id, 'user');
      }
    } catch (e) {
      print('Error marking orders as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.ordersAndMessages,
          style: TextStyle(color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: context.titleFont,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Pill-shaped navigation panel
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: _selectedIndex == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 20,
                            color: _selectedIndex == 0 ? Colors.green[600] : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.orders,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: _selectedIndex == 0 ? Colors.green[600] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: _selectedIndex == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Consumer<NotificationService>(
                        builder: (context, notificationService, child) {
                          final authService = Provider.of<AuthService>(context, listen: false);
                          final user = authService.currentUser;
                          final unreadMessages = user != null 
                              ? notificationService.getUnreadMessages(user.id)
                              : 0;
                          
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BadgeWidget(
                                count: unreadMessages,
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  size: 20,
                                  color: _selectedIndex == 1 ? Colors.green[600] : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.messages,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: _selectedIndex == 1 ? Colors.green[600] : Colors.grey[600],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildOrdersTab(),
                _buildDiscussionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    print('🔍 [UserOrdersPage] Building orders tab');
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    print('🔍 [UserOrdersPage] Current user: ${user?.id}');
    print('🔍 [UserOrdersPage] User account type: ${user?.accountType}');

    if (user == null) {
      print('🔍 [UserOrdersPage] No user found, showing login message');
      return Center(child: Text(AppLocalizations.of(context)!.pleaseLogInToViewOrders));
    }

    print('🔍 [UserOrdersPage] Setting up getUserOrders stream for user: ${user.id}');
    return StreamBuilder<List<store_order.StoreOrder>>(
      stream: DatabaseService().getUserOrders(user.id),
      builder: (context, snapshot) {
        print('🔍 [UserOrdersPage] StreamBuilder state: ${snapshot.connectionState}');
        print('🔍 [UserOrdersPage] Has error: ${snapshot.hasError}');
        if (snapshot.hasError) {
          print('🔍 [UserOrdersPage] Error details: ${snapshot.error}');
          print('🔍 [UserOrdersPage] Error stack trace: ${snapshot.stackTrace}');
        }
        print('🔍 [UserOrdersPage] Has data: ${snapshot.hasData}');
        if (snapshot.hasData) {
          print('🔍 [UserOrdersPage] Orders data length: ${snapshot.data?.length}');
          if (snapshot.data != null) {
            for (int i = 0; i < snapshot.data!.length; i++) {
              final order = snapshot.data![i];
              print('🔍 [UserOrdersPage] Order $i: ${order.id} - ${order.productName} (${order.status})');
            }
          }
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('🔍 [UserOrdersPage] Showing loading indicator');
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('🔍 [UserOrdersPage] Showing error: ${snapshot.error}');
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
                  AppLocalizations.of(context)!.errorLoadingOrders(snapshot.error.toString()),
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
        print('🔍 [UserOrdersPage] Final orders to display: ${orders.length}');

        if (orders.isEmpty) {
          print('🔍 [UserOrdersPage] No orders to display');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noOrdersYet,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.yourOrdersWillAppearHere,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Debug: UserId=${user.id}',
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

        print('🔍 [UserOrdersPage] Building ListView with ${orders.length} orders');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            print('🔍 [UserOrdersPage] Building order card ${index + 1}/${orders.length}: ${order.productName} (${order.status})');
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(store_order.StoreOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: order.productImageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          fontFamily: 'Inter',
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.storeWithName(order.storeName),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.quantity(order.quantity),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<CurrencyService>(
                  builder: (context, currencyService, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyService.formatPrice(order.price * order.quantity),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.green[600],
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.quantity} × ${currencyService.formatPrice(order.price)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _formatStatusText(order.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    );
                                    },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Progress Bar
            _buildProgressBar(order.status),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (order.status == 'pending')
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.red[200]!,
                        width: 1,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () => _cancelOrder(order.id),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[600],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                if (order.status == 'delivered')
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Report Not Delivered button (smaller)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orange[200]!,
                            width: 1,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => _reportNotDelivered(order.id),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.orange[600],
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.report,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Confirm Delivery button (bigger)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green[600]!.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () => _confirmDelivery(order.id),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.confirmDelivery,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String status) {
    double progress = 0.0;
    int currentStep = 0;
    int totalSteps = 4;

    switch (status) {
      case 'ordered':
        progress = 0.25;
        currentStep = 1;
        break;
      case 'pending':
        progress = 0.25;
        currentStep = 1;
        break;
      case 'confirmed':
        progress = 0.5;
        currentStep = 2;
        break;
      case 'shipped':
        progress = 0.75;
        currentStep = 3;
        break;
      case 'delivered':
        progress = 1.0;
        currentStep = 4;
        break;
      case 'confirmed_delivered':
        progress = 1.0;
        currentStep = 4;
        break;
      case 'disputed_delivery':
        progress = 1.0;
        currentStep = 4;
        break;
      case 'cancelled':
        progress = 0.0;
        currentStep = 0;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.orderProgress,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Inter',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.stepOf(currentStep, totalSteps),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: status == 'cancelled' ? Colors.red[400] : Colors.green[500],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepIndicator(AppLocalizations.of(context)!.ordered, currentStep >= 1, status == 'cancelled'),
              _buildStepIndicator(AppLocalizations.of(context)!.confirmed, currentStep >= 2, status == 'cancelled'),
              _buildStepIndicator(AppLocalizations.of(context)!.shipped, currentStep >= 3, status == 'cancelled'),
              _buildStepIndicator(AppLocalizations.of(context)!.delivered, currentStep >= 4, status == 'cancelled'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(String label, bool isCompleted, bool isCancelled) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCancelled
                ? Colors.red[400]
                : isCompleted
                    ? Colors.green[500]
                    : Colors.grey[300],
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: (isCancelled ? Colors.red[400] : Colors.green[500])!.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                )
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isCancelled
                ? Colors.red[600]
                : isCompleted
                    ? Colors.green[600]
                    : Colors.grey[500],
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w500,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDiscussionsTab() {
    print('🔍 [UserOrdersPage] Building discussions tab');
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    print('🔍 [UserOrdersPage] Current user for discussions: ${user?.id}');

    if (user == null) {
      print('🔍 [UserOrdersPage] No user found for discussions, showing login message');
      return Center(child: Text(AppLocalizations.of(context)!.pleaseLogInToViewDiscussions));
    }

    print('🔍 [UserOrdersPage] Setting up getUserConversations stream for user: ${user.id}');
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseService().getUserConversations(user.id),
      builder: (context, snapshot) {
        print('🔍 [UserOrdersPage] Discussions StreamBuilder state: ${snapshot.connectionState}');
        print('🔍 [UserOrdersPage] Discussions has error: ${snapshot.hasError}');
        if (snapshot.hasError) {
          print('🔍 [UserOrdersPage] Discussions error details: ${snapshot.error}');
          print('🔍 [UserOrdersPage] Discussions error stack trace: ${snapshot.stackTrace}');
        }
        print('🔍 [UserOrdersPage] Discussions has data: ${snapshot.hasData}');
        if (snapshot.hasData) {
          print('🔍 [UserOrdersPage] Conversations data length: ${snapshot.data?.length}');
          if (snapshot.data != null) {
            for (int i = 0; i < snapshot.data!.length; i++) {
              final conversation = snapshot.data![i];
              print('🔍 [UserOrdersPage] Conversation $i: receiverId=${conversation['receiverId']}, message=${conversation['lastMessage']}');
            }
          }
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('🔍 [UserOrdersPage] Showing discussions loading indicator');
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('🔍 [UserOrdersPage] Showing discussions error: ${snapshot.error}');
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
                  AppLocalizations.of(context)!.errorLoadingDiscussions(snapshot.error.toString()),
                  style: TextStyle(fontFamily: 'Inter'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.checkConsoleForErrorDetails,
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

        final conversations = snapshot.data ?? [];
        print('🔍 [UserOrdersPage] Final conversations to display: ${conversations.length}');

        if (conversations.isEmpty) {
          print('🔍 [UserOrdersPage] No conversations to display');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noDiscussionsYet,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.conversationsWithSellersWillAppearHere,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Debug: UserId=${user.id}',
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

        print('🔍 [UserOrdersPage] Building ListView with ${conversations.length} conversations');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            print('🔍 [UserOrdersPage] Building conversation tile ${index + 1}/${conversations.length}: receiverId=${conversation['receiverId']}');
            return _buildDiscussionTile(conversation);
          },
        );
      },
    );
  }

  Widget _buildDiscussionTile(Map<String, dynamic> conversation) {
    print('🔍 [UserOrdersPage] Building discussion tile for receiverId: ${conversation['receiverId']}');
    print('🔍 [UserOrdersPage] Conversation data: $conversation');
    
    // Validate conversation data
    if (conversation['receiverId'] == null) {
      print('🔍 [UserOrdersPage] ERROR: receiverId is null!');
      return _buildErrorTile(AppLocalizations.of(context)!.invalidConversationData);
    }
    
    return FutureBuilder<User?>(
      future: DatabaseService().getUser(conversation['receiverId']),
      builder: (context, snapshot) {
        print('🔍 [UserOrdersPage] FutureBuilder state: ${snapshot.connectionState}');
        print('🔍 [UserOrdersPage] FutureBuilder has data: ${snapshot.hasData}');
        print('🔍 [UserOrdersPage] FutureBuilder has error: ${snapshot.hasError}');
        if (snapshot.hasError) {
          print('🔍 [UserOrdersPage] FutureBuilder error: ${snapshot.error}');
          print('🔍 [UserOrdersPage] FutureBuilder error stack trace: ${snapshot.stackTrace}');
        }
        
        final storeUser = snapshot.data;
        print('🔍 [UserOrdersPage] Store user: ${storeUser?.displayName} (${storeUser?.id})');
        print('🔍 [UserOrdersPage] Store user displayName: "${storeUser?.displayName}"');
        print('🔍 [UserOrdersPage] Store user displayName length: ${storeUser?.displayName?.length}');
        print('🔍 [UserOrdersPage] Store user displayName is null: ${storeUser?.displayName == null}');
        print('🔍 [UserOrdersPage] Store user displayName is empty: ${storeUser?.displayName?.isEmpty}');
        print('🔍 [UserOrdersPage] Store user displayName trimmed: "${storeUser?.displayName?.trim()}"');
        print('🔍 [UserOrdersPage] Store user displayName trimmed length: ${storeUser?.displayName?.trim().length}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.loading,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        
        if (snapshot.hasError) {
          print('🔍 [UserOrdersPage] Error loading user: ${snapshot.error}');
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.red[100],
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.unknownStore,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          color: Colors.red[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.errorLoadingStoreInfo,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (storeUser != null) {
                  _openChat(storeUser);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                                       children: [
                       Builder(
                         builder: (context) {
                           print('🔍 [UserOrdersPage] Building CircleAvatar for user: ${storeUser?.displayName}');
                           print('🔍 [UserOrdersPage] CircleAvatar photoURL: ${storeUser?.photoURL}');
                           print('🔍 [UserOrdersPage] CircleAvatar photoURL is null: ${storeUser?.photoURL == null}');
                           print('🔍 [UserOrdersPage] CircleAvatar storeUser is null: ${storeUser == null}');
                           
                           if (storeUser == null) {
                             print('🔍 [UserOrdersPage] storeUser is null, showing error avatar');
                             return CircleAvatar(
                               radius: 24,
                               backgroundColor: Colors.red[100],
                               child: Icon(
                                 Icons.error_outline,
                                 color: Colors.red[600],
                                 size: 20,
                               ),
                             );
                           }
                           
                           try {
                             print('🔍 [UserOrdersPage] About to call _getInitials with: "${storeUser.displayName}"');
                             final initials = _getInitials(storeUser.displayName);
                             print('🔍 [UserOrdersPage] CircleAvatar initials: "$initials"');
                             
                             return CircleAvatar(
                               radius: 24,
                               backgroundImage: storeUser.photoURL != null
                                   ? CachedNetworkImageProvider(storeUser.photoURL!)
                                   : null,
                               child: storeUser.photoURL == null
                                   ? Text(
                                       initials,
                                       style: const TextStyle(
                                         color: Colors.white,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     )
                                   : null,
                             );
                           } catch (e) {
                             print('🔍 [UserOrdersPage] ERROR in CircleAvatar creation: $e');
                             print('🔍 [UserOrdersPage] ERROR stack trace: ${StackTrace.current}');
                             print('🔍 [UserOrdersPage] ERROR storeUser.displayName: "${storeUser.displayName}"');
                             print('🔍 [UserOrdersPage] ERROR storeUser.displayName type: ${storeUser.displayName.runtimeType}');
                             return CircleAvatar(
                               radius: 24,
                               backgroundColor: Colors.red[100],
                               child: Icon(
                                 Icons.error_outline,
                                 color: Colors.red[600],
                                 size: 20,
                               ),
                             );
                           }
                         },
                       ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            storeUser?.displayName ?? 'Store',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            conversation['lastMessage'] ?? AppLocalizations.of(context)!.noMessagesYet,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontFamily: 'Inter',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(conversation['timestamp']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ordered':
        return Colors.amber;
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'confirmed_delivered':
        return Colors.green[800]!;
      case 'disputed_delivery':
        return Colors.orange[800]!;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatStatusText(String status) {
    switch (status) {
      case 'pending':
        return AppLocalizations.of(context)!.orderStatusPending;
      case 'ordered':
        return AppLocalizations.of(context)!.orderStatusOrdered;
      case 'confirmed':
        return AppLocalizations.of(context)!.orderStatusConfirmed;
      case 'shipped':
        return AppLocalizations.of(context)!.orderStatusShipped;
      case 'delivered':
        return AppLocalizations.of(context)!.orderStatusDelivered;
      case 'confirmed_delivered':
        return AppLocalizations.of(context)!.orderStatusConfirmedDelivered;
      case 'disputed_delivery':
        return AppLocalizations.of(context)!.orderStatusDisputedDelivery;
      case 'cancelled':
        return AppLocalizations.of(context)!.orderStatusCancelled;
      case 'refunded':
        return AppLocalizations.of(context)!.orderStatusRefunded;
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return AppLocalizations.of(context)!.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return AppLocalizations.of(context)!.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return AppLocalizations.of(context)!.minutesAgo(difference.inMinutes);
    } else {
      return AppLocalizations.of(context)!.justNow;
    }
  }

  String _getInitials(String? displayName) {
    print('🔍 [UserOrdersPage] _getInitials called with: "$displayName"');
    print('🔍 [UserOrdersPage] _getInitials displayName is null: ${displayName == null}');
    print('🔍 [UserOrdersPage] _getInitials displayName runtime type: ${displayName.runtimeType}');
    
    // Handle null case
    if (displayName == null) {
      print('🔍 [UserOrdersPage] _getInitials: displayName is null, returning "U"');
      return 'U';
    }
    
    print('🔍 [UserOrdersPage] _getInitials displayName length: ${displayName.length}');
    print('🔍 [UserOrdersPage] _getInitials displayName isEmpty: ${displayName.isEmpty}');
    
    // Handle empty string case
    if (displayName.isEmpty) {
      print('🔍 [UserOrdersPage] _getInitials: displayName is empty, returning "U"');
      return 'U';
    }
    
    // Trim the string
    final trimmedName = displayName.trim();
    print('🔍 [UserOrdersPage] _getInitials displayName trimmed: "$trimmedName"');
    print('🔍 [UserOrdersPage] _getInitials displayName trimmed length: ${trimmedName.length}');
    print('🔍 [UserOrdersPage] _getInitials displayName trimmed isEmpty: ${trimmedName.isEmpty}');
    
    // Handle empty string after trim
    if (trimmedName.isEmpty) {
      print('🔍 [UserOrdersPage] _getInitials: displayName is empty after trim, returning "U"');
      return 'U';
    }
    
    try {
      // Get the first character
      final firstChar = trimmedName[0];
      print('🔍 [UserOrdersPage] _getInitials: first character is "$firstChar"');
      
      // Convert to uppercase
      final result = firstChar.toUpperCase();
      print('🔍 [UserOrdersPage] _getInitials: returning "$result"');
      return result;
    } catch (e) {
      print('🔍 [UserOrdersPage] _getInitials ERROR: $e');
      print('🔍 [UserOrdersPage] _getInitials ERROR stack trace: ${StackTrace.current}');
      print('🔍 [UserOrdersPage] _getInitials ERROR displayName: "$displayName"');
      print('🔍 [UserOrdersPage] _getInitials ERROR trimmedName: "$trimmedName"');
      return 'U';
    }
  }

  Widget _buildErrorTile(String message) {
    print('🔍 [UserOrdersPage] Building error tile with message: $message');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.red[100],
            child: Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: Colors.red[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder(String orderId) async {
    // For now, we'll use a generic message since we don't have the product name
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => OrderActionDialog.cancelOrder(
        productName: 'this product',
        onConfirm: () {
          Navigator.of(context).pop(true);
        },
        context: context,
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService().updateOrderStatus(orderId, 'cancelled');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelivery(String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirm Delivery',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to confirm that this order has been delivered?',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService().updateOrderStatus(orderId, 'confirmed_delivered');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery confirmed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Show product review dialog after confirming delivery
        await _showProductReviewDialog(orderId);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm delivery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reportNotDelivered(String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Report Not Delivered',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to report that this order was not delivered? This will notify the seller and may require further action.',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Report',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService().updateOrderStatus(orderId, 'disputed_delivery');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery issue reported successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to report delivery issue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showProductReviewDialog(String orderId) async {
    try {
      // Get order details to find the product
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      if (user == null) return;

      // Get all user orders to find the specific order
      final orders = await DatabaseService().getUserOrders(user.id).first;
      final order = orders.firstWhere((o) => o.id == orderId);
      
      // Get the product details
      final product = await DatabaseService().getStoreProduct(order.productId);
      if (product == null) return;

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProductReviewDialog(
          productName: product.name,
          productImageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
          productPrice: product.price,
        ),
      );

      if (result != null) {
        await _submitProductReview(order.productId, result['rating'], result['comment']);
      }
    } catch (e) {
      print('Error showing product review dialog: $e');
    }
  }

  Future<void> _submitProductReview(String productId, int rating, String comment) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      if (user == null) return;

      await DatabaseService().addProductReview(
        productId: productId,
        userId: user.id,
        userName: user.displayName ?? 'Anonymous',
        rating: rating,
        comment: comment,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your review!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

    void _openChat(User storeUser) {
    print('🔍 [UserOrdersPage] Opening chat with store user: ${storeUser.displayName} (${storeUser.id})');
    
    // Navigate to the store chat page with a proper product context
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscussionChatPage(
          storeUser: storeUser,
        ),
      ),
    );
  }
} 