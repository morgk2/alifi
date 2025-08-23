import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';
import 'push_notification_service.dart';
import 'in_app_notification_controller.dart';
import 'dart:convert'; // Added for jsonEncode
import 'package:http/http.dart' as http; // Added for http

class NotificationService extends ChangeNotifier {
  static NotificationService? _instance;
  static NotificationService get instance {
    _instance ??= NotificationService._internal();
    return _instance!;
  }
  
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PushNotificationService _pushNotificationService = PushNotificationService();
  
  CollectionReference get _notificationsCollection => _firestore.collection('notifications');

  // Track unread counts for different users
  Map<String, int> _unreadOrders = {};
  Map<String, int> _unreadMessages = {};
  Map<String, int> _sellerUnreadOrders = {};
  Map<String, int> _sellerUnreadMessages = {};

  // In-app banner listener state
  StreamSubscription<QuerySnapshot>? _notificationsSubscription;
  bool _skipInitialNotificationBatch = true;

  // Track last message timestamp to avoid duplicate notifications
  Map<String, DateTime> _lastMessageTimestamp = {};

  // Track if listeners are already initialized
  Map<String, bool> _listenersInitialized = {};

  // Initialize the service
  Future<void> initialize() async {
    try {
      print('🔔 [NotificationService] Initializing...');
      await _pushNotificationService.initialize();
      print('🔔 [NotificationService] Initialized successfully');
    } catch (e) {
      print('❌ [NotificationService] Error initializing: $e');
    }
  }

  // Getters for unread counts
  int getUnreadOrders(String userId) => _unreadOrders[userId] ?? 0;
  int getUnreadMessages(String userId) => _unreadMessages[userId] ?? 0;
  int getSellerUnreadOrders(String sellerId) => _sellerUnreadOrders[sellerId] ?? 0;
  int getSellerUnreadMessages(String sellerId) => _sellerUnreadMessages[sellerId] ?? 0;

  // Initialize listeners for a user
  void initializeListeners(String userId, String accountType) {
    print('🔔 [NotificationService] initializeListeners called for user: $userId, type: $accountType');
    
    // Check if listeners are already initialized for this user
    final listenerKey = '${userId}_$accountType';
    if (_listenersInitialized[listenerKey] == true) {
      print('🔔 [NotificationService] Listeners already initialized for user: $userId, type: $accountType - SKIPPING');
      return;
    }
    
    print('🔔 [NotificationService] Setting up listeners for user: $userId, type: $accountType');
    
    if (accountType == 'store') {
      _listenToSellerOrders(userId);
      _listenToSellerMessages(userId);
    } else {
      _listenToBuyerOrders(userId);
      _listenToBuyerMessages(userId);
    }
    // Start listening for new notifications to show in-app banner
    startInAppBannerListener(userId);
    
    // Mark listeners as initialized for this user
    _listenersInitialized[listenerKey] = true;
    print('🔔 [NotificationService] Listeners initialized for user: $userId, type: $accountType');
  }

  // Listen for new notifications and show in-app banner
  void startInAppBannerListener(String userId) {
    // Cancel previous subscription if any
    _notificationsSubscription?.cancel();
    _skipInitialNotificationBatch = true;

    _notificationsSubscription = _notificationsCollection
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      if (_skipInitialNotificationBatch) {
        // Skip the initial batch to avoid showing banners for historical notifications
        _skipInitialNotificationBatch = false;
        return;
      }

      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          try {
            final notif = AppNotification.fromFirestore(change.doc);
            // Choose best image depending on type and payload
            String? imageUrl = notif.senderPhotoUrl;
            final data = notif.data;
            if ((imageUrl == null || imageUrl.isEmpty) && data != null) {
              final dynamicImg = data['imageUrl'] ?? data['productImageUrl'] ?? data['storeImageUrl'] ?? data['photoUrl'] ?? data['avatarUrl'];
              if (dynamicImg is String && dynamicImg.isNotEmpty) {
                imageUrl = dynamicImg;
              }
            }
            InAppNotificationController().show(
              title: notif.title,
              body: notif.body,
              imageUrl: imageUrl,
            );
          } catch (e) {
            debugPrint('Error showing in-app notification banner: $e');
          }
        }
      }
    }, onError: (e) {
      debugPrint('Error listening to notifications for in-app banner: $e');
    });
  }

  // Listen to buyer orders
  void _listenToBuyerOrders(String userId) {
    _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .where('status', whereIn: ['ordered', 'pending', 'confirmed', 'shipped'])
        .snapshots()
        .listen((snapshot) {
      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final isRead = data['isRead'] ?? false;
        if (!isRead) {
          unreadCount++;
        }
      }
      _unreadOrders[userId] = unreadCount;
      notifyListeners();
    });
  }

  // Listen to buyer messages
  void _listenToBuyerMessages(String userId) {
    print('🔔 [NotificationService] Setting up buyer messages listener for user: $userId');
    
    _firestore
        .collection('chatMessages')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      print('🔔 [NotificationService] Buyer messages snapshot received for user: $userId');
      print('🔔 [NotificationService] Total messages in snapshot: ${snapshot.docs.length}');
      
      _unreadMessages[userId] = snapshot.docs.length;
      notifyListeners();

      // Show in-app banner for newly added unread messages
      for (final change in snapshot.docChanges) {
        print('🔔 [NotificationService] Document change type: ${change.type}');
        
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          final String senderId = data['senderId'] as String? ?? '';
          final String receiverId = data['receiverId'] as String? ?? '';
          final String messageText = (data['message'] ?? data['text'] ?? '').toString();
          final timestamp = (data['timestamp'] as Timestamp).toDate();

          print('🔔 [NotificationService] New message detected:');
          print('🔔 [NotificationService] - Sender: $senderId');
          print('🔔 [NotificationService] - Receiver: $receiverId');
          print('🔔 [NotificationService] - Current user: $userId');
          print('🔔 [NotificationService] - Message: $messageText');

          // EARLY EXIT: If this user is the sender, skip notification completely
          if (senderId == userId) {
            print('🔔 [NotificationService] ❌ EARLY EXIT: Current user is the SENDER - skipping notification');
            continue;
          }

          // Check if this is a truly new message (not from initial load)
          final lastTimestamp = _lastMessageTimestamp[userId];
          if (lastTimestamp != null && timestamp.isBefore(lastTimestamp)) {
            print('🔔 [NotificationService] Skipping old message from initial load');
            continue;
          }

          // Update last message timestamp
          _lastMessageTimestamp[userId] = timestamp;

          // CRITICAL FIX: Only send notification if this user is the RECEIVER and NOT the sender
          if (receiverId == userId && senderId != userId) {
            print('🔔 [NotificationService] ✅ This user is the RECEIVER - sending notification');
            print('🔔 [NotificationService] Sender: $senderId');
            print('🔔 [NotificationService] Message: $messageText');
            print('🔔 [NotificationService] Timestamp: $timestamp');

            // Send push notification for new incoming message
            _sendPushNotificationForIncomingMessage(senderId, userId, messageText);

            getUserInfo(senderId).then((senderInfo) {
              final String title = senderInfo?['name'] as String? ?? 'New Message';
              final String body = messageText.isNotEmpty ? messageText : 'You received a new message';
              final String? imageUrl = senderInfo?['photoUrl'] as String?;
              InAppNotificationController().show(
                title: title,
                body: body,
                imageUrl: imageUrl,
              );
            }).catchError((e) {
              debugPrint('Error fetching sender info for banner: $e');
            });
          } else {
            print('🔔 [NotificationService] ❌ This user is the SENDER - NOT sending notification');
            print('🔔 [NotificationService] Sender: $senderId, Receiver: $receiverId, Current: $userId');
            print('🔔 [NotificationService] receiverId == userId: ${receiverId == userId}');
            print('🔔 [NotificationService] senderId != userId: ${senderId != userId}');
          }
        }
      }
    });
  }

  // Send push notification for incoming message
  Future<void> _sendPushNotificationForIncomingMessage(String senderId, String receiverId, String message) async {
    try {
      print('🔔 [NotificationService] Sending push notification for incoming message');
      print('🔔 [NotificationService] From: $senderId, To: $receiverId');
      
      // Get sender info
      final senderInfo = await getUserInfo(senderId);
      final senderName = senderInfo?['name'] as String? ?? 'Someone';
      
      print('🔔 [NotificationService] Sender name: $senderName');
      
      // Get recipient's FCM token from Firestore
      print('🔔 [NotificationService] Getting recipient FCM token from Firestore...');
      final recipientDoc = await _firestore.collection('users').doc(receiverId).get();
      
      if (!recipientDoc.exists) {
        print('❌ [NotificationService] Recipient not found in Firestore: $receiverId');
        return;
      }
      
      final recipientData = recipientDoc.data() as Map<String, dynamic>;
      final fcmToken = recipientData['fcmToken'] as String?;
      
      if (fcmToken == null) {
        print('❌ [NotificationService] No FCM token found for recipient: $receiverId');
        return;
      }
      
      print('🔔 [NotificationService] Using recipient FCM token: ${fcmToken.substring(0, 20)}...');
      
      // Send push notification via Supabase with customized title
      final supabaseUrl = 'https://slkygguxwqzwpnahnici.supabase.co';
      final supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsa3lnZ3V4d3F6d3BuYWhuaWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxMjM4OTcsImV4cCI6MjA2ODY5OTg5N30.-UNi-pJzCvzM3I1CdUHg230gDH14_pZix7DVqQQ2P_A';
      
      // Customize title to show sender's name
      final String customTitle = senderName;
      final String customBody = message.length > 50 ? '${message.substring(0, 50)}...' : message;
      
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/send-push-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $supabaseAnonKey',
        },
        body: jsonEncode({
          'token': fcmToken,
          'title': customTitle,
          'body': customBody,
          'data': {
            'type': 'chatMessage',
            'senderId': senderId,
            'senderName': senderName,
            'senderPhotoUrl': senderInfo?['photoUrl'],
            'message': message,
          },
        }),
      );
      
      print('🔔 [NotificationService] Supabase response status: ${response.statusCode}');
      print('🔔 [NotificationService] Supabase response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ [NotificationService] Push notification sent successfully for incoming message');
      } else {
        print('❌ [NotificationService] Failed to send push notification for incoming message: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [NotificationService] Error sending push notification for incoming message: $e');
    }
  }

  // Listen to seller orders
  void _listenToSellerOrders(String sellerId) {
    _firestore
        .collection('orders')
        .where('storeId', isEqualTo: sellerId)
        .where('status', whereIn: ['ordered', 'pending', 'confirmed', 'shipped'])
        .snapshots()
        .listen((snapshot) {
      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final isRead = data['isRead'] ?? false;
        if (!isRead) {
          unreadCount++;
        }
      }
      _sellerUnreadOrders[sellerId] = unreadCount;
      notifyListeners();
    });
  }

  // Listen to seller messages
  void _listenToSellerMessages(String sellerId) {
    print('🔔 [NotificationService] Setting up seller messages listener for user: $sellerId');
    
    _firestore
        .collection('chatMessages')
        .where('receiverId', isEqualTo: sellerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      print('🔔 [NotificationService] Seller messages snapshot received for user: $sellerId');
      print('🔔 [NotificationService] Total messages in snapshot: ${snapshot.docs.length}');
      
      _sellerUnreadMessages[sellerId] = snapshot.docs.length;
      notifyListeners();

      // Show in-app banner for newly added unread messages
      for (final change in snapshot.docChanges) {
        print('🔔 [NotificationService] Document change type: ${change.type}');
        
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          final String senderId = data['senderId'] as String? ?? '';
          final String receiverId = data['receiverId'] as String? ?? '';
          final String messageText = (data['message'] ?? data['text'] ?? '').toString();
          final timestamp = (data['timestamp'] as Timestamp).toDate();

          print('🔔 [NotificationService] New message detected for seller:');
          print('🔔 [NotificationService] - Sender: $senderId');
          print('🔔 [NotificationService] - Receiver: $receiverId');
          print('🔔 [NotificationService] - Current user: $sellerId');
          print('🔔 [NotificationService] - Message: $messageText');

          // EARLY EXIT: If this user is the sender, skip notification completely
          if (senderId == sellerId) {
            print('🔔 [NotificationService] ❌ EARLY EXIT: Current user is the SENDER - skipping notification');
            continue;
          }

          // Check if this is a truly new message (not from initial load)
          final lastTimestamp = _lastMessageTimestamp[sellerId];
          if (lastTimestamp != null && timestamp.isBefore(lastTimestamp)) {
            print('🔔 [NotificationService] Skipping old message from initial load');
            continue;
          }

          // Update last message timestamp
          _lastMessageTimestamp[sellerId] = timestamp;

          // CRITICAL FIX: Only send notification if this user is the RECEIVER and NOT the sender
          if (receiverId == sellerId && senderId != sellerId) {
            print('🔔 [NotificationService] ✅ This user is the RECEIVER - sending notification');
            print('🔔 [NotificationService] Sender: $senderId');
            print('🔔 [NotificationService] Message: $messageText');
            print('🔔 [NotificationService] Timestamp: $timestamp');

            // Send push notification for new incoming message
            _sendPushNotificationForIncomingMessage(senderId, sellerId, messageText);

            getUserInfo(senderId).then((senderInfo) {
              final String title = senderInfo?['name'] as String? ?? 'New Message';
              final String body = messageText.isNotEmpty ? messageText : 'You received a new message';
              final String? imageUrl = senderInfo?['photoUrl'] as String?;
              InAppNotificationController().show(
                title: title,
                body: body,
                imageUrl: imageUrl,
              );
            }).catchError((e) {
              debugPrint('Error fetching sender info for banner: $e');
            });
          } else {
            print('🔔 [NotificationService] This user is the SENDER - NOT sending notification');
            print('🔔 [NotificationService] Sender: $senderId, Receiver: $receiverId, Current: $sellerId');
          }
        }
      }
    });
  }

  // Mark order as read
  Future<void> markOrderAsRead(String userId, String orderId, String accountType) async {
    try {
      if (accountType == 'store') {
        await _firestore
            .collection('orders')
            .doc(orderId)
            .update({'isRead': true});
      } else {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(orderId)
            .update({'isRead': true});
      }
    } catch (e) {
      print('Error marking order as read: $e');
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _firestore
          .collection('chat_messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  // Mark all messages as read for a conversation
  Future<void> markAllMessagesAsRead(String userId, String otherUserId) async {
    try {
      final batch = _firestore.batch();
      
      // Mark messages where user is receiver
      final messagesQuery = _firestore
          .collection('chat_messages')
          .where('senderId', isEqualTo: otherUserId)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false);
      
      final messagesSnapshot = await messagesQuery.get();
      for (var doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
    } catch (e) {
      print('Error marking all messages as read: $e');
    }
  }

  // Clear all unread counts for a user
  void clearUnreadCounts(String userId) {
    _unreadOrders[userId] = 0;
    _unreadMessages[userId] = 0;
    _sellerUnreadOrders[userId] = 0;
    _sellerUnreadMessages[userId] = 0;
    notifyListeners();
  }

  // Dispose listeners
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }

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
    print('🔍 [NotificationService] Getting notifications for user: $userId');
    
    return _notificationsCollection
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          print('🔍 [NotificationService] Received snapshot with ${snapshot.docs.length} documents');
          try {
            final notifications = snapshot.docs.map((doc) {
              try {
                return AppNotification.fromFirestore(doc);
              } catch (e) {
                print('🔍 [NotificationService] Error parsing document ${doc.id}: $e');
                print('🔍 [NotificationService] Document data: ${doc.data()}');
                rethrow;
              }
            }).toList();
            print('🔍 [NotificationService] Successfully parsed ${notifications.length} notifications');
            return notifications;
          } catch (e) {
            print('🔍 [NotificationService] Error in getUserNotifications stream: $e');
            rethrow;
          }
        })
        .handleError((error) {
          print('🔍 [NotificationService] Stream error in getUserNotifications: $error');
          throw error;
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
      print('🔔 [NotificationService] Starting chat message notification for recipient: $recipientId');
      print('🔔 [NotificationService] Sender: $senderId ($senderName)');
      print('🔔 [NotificationService] Message: $message');
      
      final notification = AppNotification.chatMessage(
        id: '', // Will be set by Firestore
        recipientId: recipientId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        message: message,
        createdAt: DateTime.now(),
      );

      // Always store notification in Firestore
      await sendNotification(notification);
      print('🔔 [NotificationService] Notification stored in Firestore');
      
      // Try to send push notification, but don't fail if it doesn't work
      try {
        print('🔔 [NotificationService] Attempting to send push notification...');
        print('🔔 [NotificationService] Push notification service: $_pushNotificationService');
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
        print('🔔 [NotificationService] Push notification sent successfully');
      } catch (pushError) {
        print('❌ [NotificationService] Push notification failed for chat message: $pushError');
        print('❌ [NotificationService] But notification was stored in Firestore');
        // Don't rethrow - we want to continue even if push notifications fail
      }
    } catch (e) {
      print('❌ [NotificationService] Error sending chat message notification: $e');
      throw e;
    }
  }

  // Send wishlist (favorite) notification to store owner
  Future<void> sendWishlistNotification({
    required String storeOwnerId,
    required String wisherUserId,
    String? wisherName,
    String? wisherPhotoUrl,
    required String productName,
    required String productId,
  }) async {
    try {
      final notification = AppNotification(
        id: '',
        recipientId: storeOwnerId,
        senderId: wisherUserId,
        senderName: wisherName,
        senderPhotoUrl: wisherPhotoUrl,
        type: NotificationType.follow, // reuse a generic type; can add specific later
        title: 'New Wishlist',
        body: '${wisherName ?? 'Someone'} added $productName to their wishlist',
        data: {
          'type': 'wishlist',
          'productId': productId,
          'productName': productName,
        },
        isRead: false,
        createdAt: DateTime.now(),
        relatedId: productId,
      );

      await sendNotification(notification);

      try {
        await _pushNotificationService.sendPushNotification(
          recipientUserId: storeOwnerId,
          title: 'New Wishlist',
          body: '${wisherName ?? 'Someone'} added $productName to their wishlist',
          data: {
            'type': 'wishlist',
            'productId': productId,
            'productName': productName,
          },
        );
      } catch (_) {}
    } catch (e) {
      debugPrint('Error sending wishlist notification: $e');
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

      // Always store notification in Firestore
      await sendNotification(notification);
      
      // Try to send push notification, but don't fail if it doesn't work
      try {
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
      } catch (pushError) {
        print('Push notification failed for order placed, but notification was stored: $pushError');
        // Don't rethrow - we want to continue even if push notifications fail
      }
    } catch (e) {
      print('Error sending order placed notification: $e');
      throw e;
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

      // Always store notification in Firestore
      await sendNotification(notification);
      
      // Try to send push notification, but don't fail if it doesn't work
      try {
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
      } catch (pushError) {
        print('Push notification failed for order status, but notification was stored: $pushError');
        // Don't rethrow - we want to continue even if push notifications fail
      }
    } catch (e) {
      print('Error sending order status notification: $e');
      throw e;
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

  // Send test notification for debugging
  Future<void> sendTestNotification(String userId) async {
    try {
      final notification = AppNotification(
        id: '',
        recipientId: userId,
        senderId: 'system',
        senderName: 'System',
        senderPhotoUrl: null,
        type: NotificationType.chatMessage,
        title: 'Test Notification',
        body: 'This is a test notification to verify the notification system is working.',
        data: {'test': true},
        isRead: false,
        createdAt: DateTime.now(),
        relatedId: null,
      );

      // Store notification in Firestore
      await sendNotification(notification);
      
      // Try to send push notification
      try {
        await _pushNotificationService.sendPushNotification(
          recipientUserId: userId,
          title: 'Test Notification',
          body: 'This is a test notification to verify the notification system is working.',
          data: {
            'type': 'test',
            'test': true,
          },
        );
      } catch (pushError) {
        print('Push notification failed for test, but notification was stored: $pushError');
      }
      
      print('Test notification sent successfully');
    } catch (e) {
      print('Error sending test notification: $e');
      throw e;
    }
  }
} 