import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../widgets/notification_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view notifications'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
        actions: [
          StreamBuilder<int>(
            stream: _notificationService.getUnreadNotificationsCount(currentUser.id),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              if (unreadCount == 0) return const SizedBox.shrink();
              
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          IconButton(
            onPressed: () => _markAllAsRead(currentUser.id),
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _notificationService.getUserNotifications(currentUser.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll see notifications here when you receive messages, orders, or follows',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationCard(
                notification: notification,
                onTap: () => _handleNotificationTap(notification),
                onDelete: () => _deleteNotification(notification.id),
              );
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) async {
    // Mark as read
    await _notificationService.markNotificationAsRead(notification.id);

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.chatMessage:
        // Navigate to chat
        _navigateToChat(notification);
        break;
      case NotificationType.orderPlaced:
      case NotificationType.orderConfirmed:
      case NotificationType.orderShipped:
      case NotificationType.orderDelivered:
      case NotificationType.orderCancelled:
        // Navigate to order details
        _navigateToOrder(notification);
        break;
      case NotificationType.follow:
      case NotificationType.unfollow:
        // Navigate to user profile
        _navigateToUserProfile(notification);
        break;
    }
  }

  void _navigateToChat(AppNotification notification) {
    // TODO: Navigate to chat with the sender
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${notification.senderName ?? 'user'}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToOrder(AppNotification notification) {
    // TODO: Navigate to order details
    final orderId = notification.relatedId;
    if (orderId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening order details'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToUserProfile(AppNotification notification) {
    // TODO: Navigate to user profile
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${notification.senderName ?? 'user'}\'s profile'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllNotificationsAsRead(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking notifications as read: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 