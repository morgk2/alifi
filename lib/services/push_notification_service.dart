import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';
import 'auth_service.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Initialize push notifications
  Future<void> initialize() async {
    try {
      print('Initializing push notifications...');
      
      // Request permission for iOS with proper error handling
      NotificationSettings settings;
      try {
        settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
      } catch (e) {
        print('Error requesting notification permission: $e');
        return;
      }

      print('Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted permission');
        
        // Initialize local notifications first
        await _initializeLocalNotifications();
        
        // Get FCM token with retry logic
        String? token;
        int retryCount = 0;
        while (token == null && retryCount < 3) {
          try {
            token = await _firebaseMessaging.getToken();
            if (token != null) {
              print('FCM Token: $token');
              // Store token in Firestore for the current user
              await _storeFCMToken(token);
            }
          } catch (e) {
            print('Error getting FCM token (attempt ${retryCount + 1}): $e');
            retryCount++;
            if (retryCount < 3) {
              await Future.delayed(Duration(seconds: retryCount));
            }
          }
        }

        // Handle token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _storeFCMToken(newToken);
        });

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle notification taps when app is opened from background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
        
        print('Push notifications initialized successfully');
      } else {
        print('User declined or has not accepted permission: ${settings.authorizationStatus}');
      }
    } catch (e) {
      print('Error initializing push notifications: $e');
      // Don't rethrow - we don't want to crash the app
    }
  }

  // Store FCM token in Firestore
  Future<void> _storeFCMToken(String token) async {
    try {
      // Get current user ID from AuthService
      final authService = AuthService();
      final currentUser = authService.currentUser;
      
      if (currentUser != null) {
        await _firestore
            .collection('users')
            .doc(currentUser.id)
            .update({
              'fcmToken': token,
              'lastTokenUpdate': FieldValue.serverTimestamp(),
            });
        print('FCM token stored for user: ${currentUser.id}');
      } else {
        print('No current user found, cannot store FCM token');
      }
    } catch (e) {
      print('Error storing FCM token: $e');
    }
  }

  // Update FCM token for a specific user
  Future<void> updateFCMTokenForUser(String userId, String token) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            'fcmToken': token,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          });
      print('FCM token updated for user: $userId');
    } catch (e) {
      print('Error updating FCM token for user $userId: $e');
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: false, // We'll handle this separately
        requestBadgePermission: false, // We'll handle this separately
        requestSoundPermission: false, // We'll handle this separately
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      print('Local notifications initialized successfully');
    } catch (e) {
      print('Error initializing local notifications: $e');
      // Don't rethrow - we don't want to crash the app
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      
      // Show local notification
      _showLocalNotification(message);
    }
  }

  // Handle notification tap when app is opened from background
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    // TODO: Navigate to appropriate screen based on notification type
    _handleNotificationNavigation(message.data);
  }

  // Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on notification data
    if (response.payload != null) {
      // Parse payload and navigate
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'alifi_notifications',
      'Alifi Notifications',
      channelDescription: 'Notifications for Alifi app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  // Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // TODO: Implement navigation logic based on notification type
    // Example:
    // if (data['type'] == 'chat') {
    //   // Navigate to chat
    // } else if (data['type'] == 'order') {
    //   // Navigate to order details
    // }
  }

  // Send push notification to specific user
  Future<void> sendPushNotification({
    required String recipientUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get recipient's FCM token from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(recipientUserId)
          .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final fcmToken = userData['fcmToken'] as String?;

      if (fcmToken == null) return;

      // Send notification using Firebase Functions or your backend
      // This would typically be done through a Cloud Function
      await _sendNotificationToToken(
        token: fcmToken,
        title: title,
        body: body,
        data: data,
      );
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  // Send notification to specific FCM token
  Future<void> _sendNotificationToToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // This would typically be done through a Cloud Function
    // For now, we'll just print the notification details
    print('Sending notification to token: $token');
    print('Title: $title');
    print('Body: $body');
    print('Data: $data');
    
    // TODO: Implement actual FCM sending through Cloud Functions
    // Example Cloud Function call:
    // await FirebaseFunctions.instance
    //     .httpsCallable('sendNotification')
    //     .call({
    //       'token': token,
    //       'title': title,
    //       'body': body,
    //       'data': data,
    //     });
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  
  // Store notification in Firestore for when app opens
  await _storeBackgroundNotification(message);
}

// Store background notification
Future<void> _storeBackgroundNotification(RemoteMessage message) async {
  try {
    final notification = AppNotification(
      id: '', // Will be set by Firestore
      recipientId: message.data['recipientId'] ?? '',
      senderId: message.data['senderId'] ?? '',
      senderName: message.data['senderName'],
      senderPhotoUrl: message.data['senderPhotoUrl'],
      type: _getNotificationTypeFromString(message.data['type'] ?? ''),
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      data: message.data,
      isRead: false,
      createdAt: DateTime.now(),
      relatedId: message.data['relatedId'],
    );

    await FirebaseFirestore.instance
        .collection('notifications')
        .add(notification.toFirestore());
  } catch (e) {
    print('Error storing background notification: $e');
  }
}

// Helper function to convert string to NotificationType
NotificationType _getNotificationTypeFromString(String type) {
  switch (type) {
    case 'chatMessage':
      return NotificationType.chatMessage;
    case 'orderPlaced':
      return NotificationType.orderPlaced;
    case 'orderConfirmed':
      return NotificationType.orderConfirmed;
    case 'orderShipped':
      return NotificationType.orderShipped;
    case 'orderDelivered':
      return NotificationType.orderDelivered;
    case 'orderCancelled':
      return NotificationType.orderCancelled;
    case 'follow':
      return NotificationType.follow;
    case 'unfollow':
      return NotificationType.unfollow;
    default:
      return NotificationType.chatMessage;
  }
} 