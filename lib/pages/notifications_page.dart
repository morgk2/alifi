import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../widgets/notification_card.dart';
import 'discussion_chat_page.dart';
import 'detailed_seller_dashboard_page.dart';
import 'user_orders_page.dart';
import 'user_profile_page.dart';
import '../services/database_service.dart';
import '../widgets/custom_snackbar.dart';

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
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context)!.pleaseLoginToViewNotifications),
        ),
      );
    }

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
          AppLocalizations.of(context)!.notifications,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          StreamBuilder<int>(
            stream: _notificationService.getUnreadNotificationsCount(currentUser.id),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              if (unreadCount == 0) return const SizedBox.shrink();
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
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
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () => _markAllAsRead(currentUser.id),
              icon: const Icon(CupertinoIcons.checkmark_circle, color: Colors.grey),
              tooltip: AppLocalizations.of(context)!.markAllAsRead,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Force refresh by rebuilding the stream
          setState(() {});
        },
        child: StreamBuilder<List<AppNotification>>(
          stream: _notificationService.getUserNotifications(currentUser.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              print('🔍 [NotificationsPage] Error loading notifications: ${snapshot.error}');
              print('🔍 [NotificationsPage] Error stack trace: ${snapshot.stackTrace}');
              
              // Extract and log the Firestore index creation link
              final errorString = snapshot.error.toString();
              if (errorString.contains('failed-precondition') && errorString.contains('create_composite')) {
                final startIndex = errorString.indexOf('https://');
                if (startIndex != -1) {
                  final endIndex = errorString.indexOf('"', startIndex);
                  final link = endIndex != -1 
                      ? errorString.substring(startIndex, endIndex)
                      : errorString.substring(startIndex);
                  
                  print('🔗 [NotificationsPage] FIREBASE INDEX CREATION LINK:');
                  print('🔗 [NotificationsPage] $link');
                  print('🔗 [NotificationsPage] Copy this link to create the required Firestore index');
                }
              }
              
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.exclamationmark_circle,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.errorLoadingNotifications,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.errorWithMessage(snapshot.error ?? ''),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // Force rebuild to retry
                              });
                            },
                            child: Text(AppLocalizations.of(context)!.retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.bell_slash,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noNotificationsYet,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.notificationsEmptyHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => _sendTestNotification(currentUser.id),
          icon: const Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.grey, size: 24),
          tooltip: AppLocalizations.of(context)!.sendTestNotificationTooltip,
        ),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) async {
    // Mark as read
    await _notificationService.markNotificationAsRead(notification.id);

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.chatMessage:
        // Navigate to chat with the sender
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
        // Navigate to follower's profile
        _navigateToUserProfile(notification);
        break;
      case NotificationType.unfollow:
        // Navigate to user's profile (who unfollowed)
        _navigateToUserProfile(notification);
        break;
      case NotificationType.appointmentRequest:
      case NotificationType.appointmentUpdate:
      case NotificationType.appointmentReminder:
        // Navigate to appointment details or vet dashboard
        _navigateToAppointment(notification);
        break;
    }
  }

  void _navigateToChat(AppNotification notification) async {
    // Navigate to chat with the sender
    if (notification.senderId != null) {
      final currentUser = context.read<AuthService>().currentUser;
      if (currentUser != null) {
        // Check if user is a seller (store account)
        if (currentUser.accountType == 'store') {
          // Navigate to seller dashboard for store users
          NavigationService.push(
            context,
            const DetailedSellerDashboardPage(),
          );
        } else {
          // Navigate to chat with the sender for regular users
          try {
            final senderUser = await DatabaseService().getUser(notification.senderId!);
            if (senderUser != null && mounted) {
              NavigationService.push(
                context,
                DiscussionChatPage(
                  storeUser: senderUser,
                ),
              );
            } else {
              if (mounted) {
                CustomSnackBarHelper.showError(
                  context,
                  AppLocalizations.of(context)!.unableToOpenChatUserNotFound,
                );
              }
            }
          } catch (e) {
            if (mounted) {
              CustomSnackBarHelper.showError(
                context,
                AppLocalizations.of(context)!.errorOpeningChat(e),
              );
            }
          }
        }
      }
    } else {
      CustomSnackBarHelper.showError(
        context,
        AppLocalizations.of(context)!.unableToOpenChatSenderMissing,
      );
    }
  }

  void _navigateToOrder(AppNotification notification) {
    // Navigate to order details based on user role
    final orderId = notification.relatedId;
    if (orderId != null) {
      final currentUser = context.read<AuthService>().currentUser;
      if (currentUser != null) {
        // Check if user is a seller (has store) or buyer
        if (currentUser.accountType == 'store') {
          // Navigate to seller's order management page
          NavigationService.push(
            context,
            const DetailedSellerDashboardPage(),
          );
        } else {
          // Navigate to buyer's orders page
          NavigationService.push(
            context,
            const UserOrdersPage(),
          );
        }
      }
    } else {
      CustomSnackBarHelper.showError(
        context,
        AppLocalizations.of(context)!.unableToOpenOrderMissing,
      );
    }
  }

  void _navigateToUserProfile(AppNotification notification) async {
    // Navigate to the user's profile (sender for follow/unfollow notifications)
    if (notification.senderId != null) {
      try {
        final user = await DatabaseService().getUser(notification.senderId!);
        if (user != null && mounted) {
          NavigationService.push(
            context,
            UserProfilePage(
              user: user,
            ),
          );
        } else {
          if (mounted) {
            CustomSnackBarHelper.showError(
              context,
              AppLocalizations.of(context)!.unableToOpenProfileUserNotFound,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBarHelper.showError(
            context,
            AppLocalizations.of(context)!.errorOpeningProfile(e),
          );
        }
      }
    } else {
      CustomSnackBarHelper.showError(
        context,
        AppLocalizations.of(context)!.unableToOpenProfileUserMissing,
      );
    }
  }

  void _navigateToAppointment(AppNotification notification) async {
    // For now, just show a message. In the future, you can navigate to appointment details
    CustomSnackBarHelper.showInfo(
      context,
      AppLocalizations.of(context)!.appointmentNotificationNavigationTbd,
      duration: const Duration(seconds: 2),
    );
  }

  void _deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      CustomSnackBarHelper.showSuccess(
        context,
        AppLocalizations.of(context)!.notificationDeleted,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      CustomSnackBarHelper.showError(
        context,
        AppLocalizations.of(context)!.errorDeletingNotification(e),
      );
    }
  }

  void _markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllNotificationsAsRead(userId);
      CustomSnackBarHelper.showSuccess(
        context,
        AppLocalizations.of(context)!.allNotificationsMarkedAsRead,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      CustomSnackBarHelper.showError(
        context,
        AppLocalizations.of(context)!.errorMarkingNotificationsAsRead(e),
      );
    }
  }

  void _sendTestNotification(String userId) async {
    try {
      await _notificationService.sendTestNotification(userId);
      CustomSnackBarHelper.showSuccess(
        context,
        AppLocalizations.of(context)!.testNotificationSent,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      CustomSnackBarHelper.showError(
        context,
        AppLocalizations.of(context)!.errorSendingTestNotification(e),
      );
    }
  }
} 