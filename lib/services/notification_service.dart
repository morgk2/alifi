import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';
import '../models/user.dart';
import 'push_notification_service.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PushNotificationService _pushNotificationService = PushNotificationService();
  
  CollectionReference get _notificationsCollection => _firestore.collection('notifications');

  // Send a notification
  Future<String> sendNotification(AppNotification notification) async {
    try {
      final docRef = await _notificationsCollection.add(notification.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error sending notification: $e');
      throw e;
    }
  }

  // Get notifications for a user
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _notificationsCollection
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => AppNotification.fromFirestore(doc)).toList();
        });
  }

  // Get unread notifications count
  Stream<int> getUnreadNotificationsCount(String userId) {
    return _notificationsCollection
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      throw e;
    }
  }

  // Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _notificationsCollection
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      throw e;
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      throw e;
    }
  }

  // Send chat message notification
  Future<void> sendChatMessageNotification({
    required String recipientId,
    required String senderId,
    String? senderName,
    String? senderPhotoUrl,
    required String message,
  }) async {
    try {
      final notification = AppNotification.chatMessage(
        id: '', // Will be set by Firestore
        recipientId: recipientId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        message: message,
        createdAt: DateTime.now(),
      );

      await sendNotification(notification);
      
      // Also send push notification
      await _pushNotificationService.sendPushNotification(
        recipientUserId: recipientId,
        title: 'New Message',
        body: message.length > 50 ? '${message.substring(0, 50)}...' : message,
        data: {
          'type': 'chatMessage',
          'senderId': senderId,
          'senderName': senderName,
          'message': message,
        },
      );
    } catch (e) {
      print('Error sending chat message notification: $e');
    }
  }

  // Send order placed notification
  Future<void> sendOrderPlacedNotification({
    required String recipientId,
    required String senderId,
    String? senderName,
    String? senderPhotoUrl,
    required String productName,
    required String orderId,
  }) async {
    try {
      final notification = AppNotification.orderPlaced(
        id: '',
        recipientId: recipientId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        productName: productName,
        orderId: orderId,
        createdAt: DateTime.now(),
      );

      await sendNotification(notification);
      
      // Also send push notification
      await _pushNotificationService.sendPushNotification(
        recipientUserId: recipientId,
        title: 'New Order Received',
        body: 'You received a new order for $productName',
        data: {
          'type': 'orderPlaced',
          'senderId': senderId,
          'senderName': senderName,
          'productName': productName,
          'orderId': orderId,
        },
      );
    } catch (e) {
      print('Error sending order placed notification: $e');
    }
  }

  // Send order status notification
  Future<void> sendOrderStatusNotification({
    required String recipientId,
    required String senderId,
    String? senderName,
    String? senderPhotoUrl,
    required NotificationType statusType,
    required String productName,
    required String orderId,
  }) async {
    try {
      final notification = AppNotification.orderStatus(
        id: '',
        recipientId: recipientId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        statusType: statusType,
        productName: productName,
        orderId: orderId,
        createdAt: DateTime.now(),
      );

      await sendNotification(notification);
      
      // Also send push notification
      String title;
      String body;
      
      switch (statusType) {
        case NotificationType.orderConfirmed:
          title = 'Order Confirmed';
          body = 'Your order for $productName has been confirmed';
          break;
        case NotificationType.orderShipped:
          title = 'Order Shipped';
          body = 'Your order for $productName has been shipped';
          break;
        case NotificationType.orderDelivered:
          title = 'Order Delivered';
          body = 'Your order for $productName has been delivered';
          break;
        case NotificationType.orderCancelled:
          title = 'Order Cancelled';
          body = 'Your order for $productName has been cancelled';
          break;
        default:
          title = 'Order Update';
          body = 'Your order for $productName has been updated';
      }
      
      await _pushNotificationService.sendPushNotification(
        recipientUserId: recipientId,
        title: title,
        body: body,
        data: {
          'type': statusType.name,
          'senderId': senderId,
          'senderName': senderName,
          'productName': productName,
          'orderId': orderId,
        },
      );
    } catch (e) {
      print('Error sending order status notification: $e');
    }
  }

  // Send follow notification
  Future<void> sendFollowNotification({
    required String recipientId,
    required String senderId,
    String? senderName,
    String? senderPhotoUrl,
    required bool isFollowing,
  }) async {
    try {
      final notification = AppNotification.follow(
        id: '',
        recipientId: recipientId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        isFollowing: isFollowing,
        createdAt: DateTime.now(),
      );

      await sendNotification(notification);
    } catch (e) {
      print('Error sending follow notification: $e');
    }
  }

  // Get user info for notifications
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['displayName'] ?? 'User',
          'photoUrl': data['photoURL'],
        };
      }
      return null;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }
} 