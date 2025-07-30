import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  chatMessage,
  orderPlaced,
  orderConfirmed,
  orderShipped,
  orderDelivered,
  orderCancelled,
  follow,
  unfollow,
}

class AppNotification {
  final String id;
  final String recipientId;
  final String senderId;
  final String? senderName;
  final String? senderPhotoUrl;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId; // For related items like orderId, chatId, etc.

  AppNotification({
    required this.id,
    required this.recipientId,
    required this.senderId,
    this.senderName,
    this.senderPhotoUrl,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.relatedId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'type': type.name,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'relatedId': relatedId,
    };
  }

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      recipientId: data['recipientId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'],
      senderPhotoUrl: data['senderPhotoUrl'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.chatMessage,
      ),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      data: data['data'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      relatedId: data['relatedId'],
    );
  }

  // Factory methods for different notification types
  factory AppNotification.chatMessage({
    required String id,
    required String recipientId,
    required String senderId,
    String? senderName,
    String? senderPhotoUrl,
    required String message,
    required DateTime createdAt,
  }) {
    return AppNotification(
      id: id,
      recipientId: recipientId,
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      type: NotificationType.chatMessage,
      title: 'New Message',
      body: message.length > 50 ? '${message.substring(0, 50)}...' : message,
      data: {'message': message},
      createdAt: createdAt,
    );
  }

  factory AppNotification.orderPlaced({
    required String id,
    required String recipientId,
    required String senderId,
    String? senderName,
    String? senderPhotoUrl,
    required String productName,
    required String orderId,
    required DateTime createdAt,
  }) {
    return AppNotification(
      id: id,
      recipientId: recipientId,
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      type: NotificationType.orderPlaced,
      title: 'New Order Received',
      body: 'You received a new order for $productName',
      data: {'productName': productName, 'orderId': orderId},
      createdAt: createdAt,
      relatedId: orderId,
    );
  }

  factory AppNotification.orderStatus({
    required String id,
    required String recipientId,
    required String senderId,
    String? senderName,
    String? senderPhotoUrl,
    required NotificationType statusType,
    required String productName,
    required String orderId,
    required DateTime createdAt,
  }) {
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

    return AppNotification(
      id: id,
      recipientId: recipientId,
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      type: statusType,
      title: title,
      body: body,
      data: {'productName': productName, 'orderId': orderId},
      createdAt: createdAt,
      relatedId: orderId,
    );
  }

  factory AppNotification.follow({
    required String id,
    required String recipientId,
    required String senderId,
    String? senderName,
    String? senderPhotoUrl,
    required bool isFollowing,
    required DateTime createdAt,
  }) {
    return AppNotification(
      id: id,
      recipientId: recipientId,
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      type: isFollowing ? NotificationType.follow : NotificationType.unfollow,
      title: isFollowing ? 'New Follower' : 'User Unfollowed',
      body: isFollowing 
          ? '$senderName started following you'
          : '$senderName unfollowed you',
      data: {'isFollowing': isFollowing},
      createdAt: createdAt,
    );
  }
} 