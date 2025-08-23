import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';
import 'in_app_notification_controller.dart';
import 'auth_service.dart';
import 'dart:convert';
import 'database_service.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
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

        // Background messages are handled in main.dart

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
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
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

      // Create notification channel for Android
      if (!kIsWeb) {
        await _createNotificationChannel();
      }
      
      print('Local notifications initialized successfully');
    } catch (e) {
      print('Error initializing local notifications: $e');
      // Don't rethrow - we don't want to crash the app
    }
  }

  // Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'alifi_notifications', // id
        'Alifi Notifications', // title
        description: 'Notifications for Alifi app',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
        showBadge: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      
      print('Android notification channel created');
    } catch (e) {
      print('Error creating notification channel: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    // Customize title for chat messages to show sender's name
    String title;
    if (message.data['type'] == 'chatMessage' && message.data['senderName'] != null) {
      title = message.data['senderName'] as String;
    } else {
      title = message.notification?.title 
          ?? (message.data['title'] as String?) 
          ?? 'Notification';
    }
    
    final String body = message.notification?.body 
        ?? (message.data['body'] as String?) 
        ?? (message.data['message'] as String?) 
        ?? '';

    String? imageUrl;
    // Prefer sender/store/product photos; fall back to generic data image keys
    imageUrl = (message.data['senderPhotoUrl']
          ?? message.data['productImageUrl']
          ?? message.data['storeImageUrl']
          ?? message.data['imageUrl']
          ?? message.data['photoUrl']
          ?? message.data['avatarUrl']) as String?;

    // Show in-app banner on all platforms
    try {
      InAppNotificationController().show(
        title: title,
        body: body,
        imageUrl: imageUrl,
      );
    } catch (e) {
      print('Error showing in-app notification banner: $e');
    }

    // Only show local notifications on mobile/desktop (plugin not supported on web)
    if (!kIsWeb && message.notification != null) {
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
    // Customize title for chat messages
    String title;
    if (message.data['type'] == 'chatMessage' && message.data['senderName'] != null) {
      title = message.data['senderName'] as String;
    } else {
      title = message.notification?.title ?? 'Notification';
    }
    
    String body = message.notification?.body ?? '';
    if (body.isEmpty && message.data['message'] != null) {
      body = message.data['message'] as String;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'alifi_notifications',
      'Alifi Notifications',
      channelDescription: 'Notifications for Alifi app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: 'ic_notification', // Use the notification icon
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'chat_message', // iOS notification category
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
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
      print('📱 [PushNotificationService] Starting push notification for user: $recipientUserId');
      print('📱 [PushNotificationService] Title: $title');
      print('📱 [PushNotificationService] Body: $body');
      
      // Get recipient's FCM token from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(recipientUserId)
          .get();

      if (!userDoc.exists) {
        print('❌ [PushNotificationService] User document not found: $recipientUserId');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final fcmToken = userData['fcmToken'] as String?;

      if (fcmToken == null) {
        print('❌ [PushNotificationService] No FCM token found for user: $recipientUserId');
        return;
      }

      print('✅ [PushNotificationService] Found FCM token: ${fcmToken.substring(0, 20)}...');

      // Send notification using Supabase Edge Function
      await _sendNotificationToToken(
        token: fcmToken,
        title: title,
        body: body,
        data: data,
      );
      
      print('✅ [PushNotificationService] Push notification sent successfully');
    } catch (e) {
      print('❌ [PushNotificationService] Error sending push notification: $e');
    }
  }

  // Send notification to specific FCM token
  Future<void> _sendNotificationToToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? type,
  }) async {
    try {
      print('📱 [PushNotificationService] Sending notification to token: ${token.substring(0, 20)}...');
      print('📱 [PushNotificationService] Title: $title');
      print('📱 [PushNotificationService] Body: $body');
      print('📱 [PushNotificationService] Data: $data');
      
      // Use Supabase Edge Function instead of Firebase Cloud Functions
      final supabaseUrl = 'https://slkygguxwqzwpnahnici.supabase.co';
      final supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsa3lnZ3V4d3F6d3BuYWhuaWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxMjM4OTcsImV4cCI6MjA2ODY5OTg5N30.-UNi-pJzCvzM3I1CdUHg230gDH14_pZix7DVqQQ2P_A';
      
      // Convert all data values to strings for FCM compatibility
      Map<String, String> stringData = {};
      if (data != null) {
        data.forEach((key, value) {
          stringData[key] = value.toString();
        });
      }
      
      final requestBody = {
        'token': token,
        'title': title,
        'body': body,
        'data': stringData,
        'type': type ?? 'general',
      };
      
      print('📱 [PushNotificationService] Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/send-push-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $supabaseAnonKey',
        },
        body: jsonEncode(requestBody),
      );
      
      print('📱 [PushNotificationService] Response status: ${response.statusCode}');
      print('📱 [PushNotificationService] Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          print('✅ [PushNotificationService] Notification sent successfully via Supabase: ${result['messageId']}');
        } else {
          print('❌ [PushNotificationService] Failed to send notification via Supabase: ${result}');
        }
      } else {
        print('❌ [PushNotificationService] Supabase function error: ${response.statusCode} - ${response.body}');
        // Try to parse error details
        try {
          final errorResult = jsonDecode(response.body);
          print('❌ [PushNotificationService] Error details: ${errorResult['error']}');
          print('❌ [PushNotificationService] Error details: ${errorResult['details']}');
        } catch (e) {
          print('❌ [PushNotificationService] Could not parse error response');
        }
      }
      
      // Also show local notification as fallback
      await _showTestLocalNotification(title, body, data);
      
    } catch (e) {
      print('❌ [PushNotificationService] Error calling Supabase notification function: $e');
      // Show local notification as fallback
      await _showTestLocalNotification(title, body, data);
    }
  }

      // Show test local notification
    Future<void> _showTestLocalNotification(String title, String body, Map<String, dynamic>? data) async {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'alifi_test_notifications',
        'Alifi Test Notifications',
        channelDescription: 'Test notifications for Alifi app',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: 'ic_notification', // Use the notification icon
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
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: data?.toString() ?? 'test',
    );
    
    print('Test local notification sent: $title - $body');
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      print('Error checking notification status: $e');
      return false;
    }
  }

  // Request permission again (for when user initially denied)
  Future<bool> requestPermissionAgain() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
                     settings.authorizationStatus == AuthorizationStatus.provisional;
      
      if (granted) {
        // Re-initialize if permission was granted
        await initialize();
      }
      
      return granted;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  // Send a test notification
  Future<void> testNotification() async {
    try {
      print('🧪 [TEST] Starting comprehensive notification test...');
      
      // First, check notification status
      await checkNotificationStatus();
      
      // Then, test FCM token flow
      await testFCMTokenFlow();
      
      // Test chat message notification
      await testChatMessageNotification();
      
      // Test chat message through DatabaseService
      await testChatMessageThroughDatabase();
      
      // Test chat notification via Supabase directly
      await testChatNotificationViaSupabase();
      
      // Then send local notification
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
        999, // Use a unique ID for test notifications
        'Test Notification',
        'This is a test notification from Alifi!',
        platformChannelSpecifics,
        payload: 'test_notification',
      );
      
      print('✅ [TEST] Local test notification sent successfully');
    } catch (e) {
      print('❌ [TEST] Error sending test notification: $e');
      rethrow;
    }
  }

  // Send appointment reminder notification
  Future<void> sendAppointmentReminder({
    required String recipientUserId,
    required String petName,
    required String appointmentType,
    required String time,
    required String vetName,
    required String appointmentId,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'alifi_appointments',
        'Appointment Reminders',
        channelDescription: 'Reminders for pet care appointments',
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

      final title = 'Appointment Reminder';
      final body = 'Your $appointmentType appointment for $petName is in 2 hours at $time with $vetName';

      await _localNotifications.show(
        appointmentId.hashCode, // Use appointment ID hash as notification ID
        title,
        body,
        platformChannelSpecifics,
        payload: jsonEncode({
          'type': 'appointment_reminder',
          'appointmentId': appointmentId,
          'petName': petName,
          'appointmentType': appointmentType,
          'time': time,
          'vetName': vetName,
        }),
      );

      // Also send push notification if user has FCM token
      await sendPushNotification(
        recipientUserId: recipientUserId,
        title: title,
        body: body,
        data: {
          'type': 'appointment_reminder',
          'appointmentId': appointmentId,
          'petName': petName,
          'appointmentType': appointmentType,
          'time': time,
          'vetName': vetName,
        },
      );
      
      print('Appointment reminder sent successfully for $petName');
    } catch (e) {
      print('Error sending appointment reminder: $e');
      rethrow;
    }
  }

  // Send simple test notification (for debugging)
  Future<void> sendSimpleTestNotification() async {
    try {
      print('Sending simple test notification...');
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'alifi_simple_test',
        'Simple Test Notifications',
        channelDescription: 'Simple test notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher', // Use the app icon as fallback
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
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        '🔔 Test Message',
        'This is a simple test notification!',
        platformChannelSpecifics,
        payload: 'simple_test',
      );
      
      print('✅ Simple test notification sent successfully');
    } catch (e) {
      print('❌ Error sending simple test notification: $e');
      rethrow;
    }
  }

  // Test Supabase function directly (for debugging)
  Future<void> testSupabaseFunction() async {
    try {
      print('🧪 Testing Supabase function directly...');
      
      // Debug AuthService state
      final authService = AuthService();
      print('🔍 AuthService initialized: ${authService.isInitialized}');
      print('🔍 AuthService loading: ${authService.isLoadingUser}');
      print('🔍 AuthService authenticated: ${authService.isAuthenticated}');
      print('🔍 AuthService guest mode: ${authService.isGuestMode}');
      
      // Check Firebase Auth directly
      final firebaseUser = FirebaseAuth.instance.currentUser;
      print('🔍 Firebase current user: ${firebaseUser?.email ?? 'null'}');
      print('🔍 Firebase user ID: ${firebaseUser?.uid ?? 'null'}');
      
      // Get current user's FCM token
      final currentUser = authService.currentUser;
      if (currentUser == null) {
        print('❌ No current user found in AuthService');
        print('🔍 Trying to get user from Firebase directly...');
        
        if (firebaseUser != null) {
          // Try to get user data directly from Firestore
          final userDoc = await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .get();
          
          if (userDoc.exists) {
            print('✅ Found user in Firestore: ${userDoc.data()}');
            final userData = userDoc.data() as Map<String, dynamic>;
            final fcmToken = userData['fcmToken'] as String?;
            
            if (fcmToken != null) {
              print('✅ Found FCM token: ${fcmToken.substring(0, 20)}...');
              await _testSupabaseWithToken(fcmToken);
            } else {
              print('❌ No FCM token found in Firestore');
            }
          } else {
            print('❌ User document not found in Firestore');
          }
        }
        return;
      }

      // Get FCM token from current user
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.id)
          .get();

      if (!userDoc.exists) {
        print('❌ User document not found in Firestore');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final fcmToken = userData['fcmToken'] as String?;

      if (fcmToken == null) {
        print('❌ FCM token not found for current user');
        return;
      }

      print('✅ Found FCM token: ${fcmToken.substring(0, 20)}...');
      await _testSupabaseWithToken(fcmToken);
      
    } catch (e) {
      print('❌ Error testing Supabase function: $e');
    }
  }

  // Helper method to test Supabase with a token
  Future<void> _testSupabaseWithToken(String fcmToken) async {
  try {
    // Test Supabase function directly
    final supabaseUrl = 'https://slkygguxwqzwpnahnici.supabase.co';
    final supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsa3lnZ3V4d3F6d3BuYWhuaWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxMjM4OTcsImV4cCI6MjA2ODY5OTg5N30.-UNi-pJzCvzM3I1CdUHg230gDH14_pZix7DVqQQ2P_A';
    
    final response = await http.post(
      Uri.parse('$supabaseUrl/functions/v1/send-push-notification'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $supabaseAnonKey',
      },
      body: jsonEncode({
        'token': fcmToken,
        'title': '🧪 Direct Supabase Test',
        'body': 'Testing Supabase function directly!',
        'data': {'type': 'test', 'timestamp': DateTime.now().toString()},
        'type': 'test',
      }),
    );
    
    print('📡 Supabase response status: ${response.statusCode}');
    print('📡 Supabase response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        print('✅ Supabase function test successful: ${result['messageId']}');
      } else {
        print('❌ Supabase function returned error: ${result}');
      }
    } else {
      print('❌ Supabase function HTTP error: ${response.statusCode}');
    }
    
  } catch (e) {
    print('❌ Error in _testSupabaseWithToken: $e');
  }
}

  // Test FCM token storage and retrieval
  Future<void> testFCMTokenFlow() async {
    try {
      print('🧪 [TEST] Starting FCM token flow test...');
      
      // Get current user
      final authService = AuthService();
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        print('❌ [TEST] No current user found');
        return;
      }
      
      print('🧪 [TEST] Current user: ${currentUser.id}');
      
      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      print('🧪 [TEST] Current FCM token: ${token?.substring(0, 20)}...');
      
      if (token == null) {
        print('❌ [TEST] FCM token is null - this is the problem!');
        return;
      }
      
      // Store token
      await _storeFCMToken(token);
      print('🧪 [TEST] FCM token stored');
      
      // Retrieve token from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.id)
          .get();
      
      if (!userDoc.exists) {
        print('❌ [TEST] User document not found in Firestore');
        return;
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final storedToken = userData['fcmToken'] as String?;
      
      print('🧪 [TEST] Stored FCM token: ${storedToken?.substring(0, 20)}...');
      
      if (storedToken == null) {
        print('❌ [TEST] No FCM token found in Firestore');
        return;
      }
      
      if (storedToken == token) {
        print('✅ [TEST] FCM token matches! Storage and retrieval working correctly');
      } else {
        print('❌ [TEST] FCM token mismatch!');
        print('🧪 [TEST] Original: ${token.substring(0, 20)}...');
        print('🧪 [TEST] Stored: ${storedToken.substring(0, 20)}...');
      }
      
      // Test sending a notification to self
      print('🧪 [TEST] Testing self-notification...');
      await sendPushNotification(
        recipientUserId: currentUser.id,
        title: 'FCM Test',
        body: 'This is a test notification to verify FCM is working',
        data: {'type': 'test'},
      );
      
    } catch (e) {
      print('❌ [TEST] Error in FCM token flow test: $e');
    }
  }

  // Test chat message notification
  Future<void> testChatMessageNotification() async {
    try {
      print('🧪 [TEST] Testing chat message notification...');
      
      // Get current user
      final authService = AuthService();
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        print('❌ [TEST] No current user found');
        return;
      }
      
      print('🧪 [TEST] Current user: ${currentUser.id}');
      
      // Send a chat message notification to self (for testing)
      await sendPushNotification(
        recipientUserId: currentUser.id,
        title: 'Test Chat Message',
        body: 'This is a test chat message notification',
        data: {
          'type': 'chatMessage',
          'senderId': 'test-sender',
          'senderName': 'Test Sender',
          'message': 'This is a test chat message notification',
        },
      );
      
      print('✅ [TEST] Chat message notification test completed');
    } catch (e) {
      print('❌ [TEST] Error in chat message notification test: $e');
    }
  }

  // Test sending a chat message through DatabaseService
  Future<void> testChatMessageThroughDatabase() async {
    try {
      print('🧪 [TEST] Testing chat message through DatabaseService...');
      
      // Get current user
      final authService = AuthService();
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        print('❌ [TEST] No current user found');
        return;
      }
      
      print('🧪 [TEST] Current user: ${currentUser.id}');
      
      // Send a chat message to self (for testing)
      print('🧪 [TEST] About to call DatabaseService().sendChatMessage...');
      final messageId = await DatabaseService().sendChatMessage(
        currentUser.id, // sender
        currentUser.id, // receiver (self)
        'This is a test chat message from DatabaseService - ' + DateTime.now().toString(),
      );
      
      print('✅ [TEST] Chat message sent through DatabaseService, messageId: $messageId');
    } catch (e) {
      print('❌ [TEST] Error sending chat message through DatabaseService: $e');
      print('❌ [TEST] Stack trace: ${StackTrace.current}');
    }
  }

  // Test chat notification via Supabase directly
  Future<void> testChatNotificationViaSupabase() async {
    try {
      print('🧪 [TEST] Testing chat notification via Supabase directly...');
      
      // Get current user
      final authService = AuthService();
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        print('❌ [TEST] No current user found');
        return;
      }
      
      print('🧪 [TEST] Current user: ${currentUser.id}');
      
      // Call Supabase function directly
      final supabaseUrl = 'https://slkygguxwqzwpnahnici.supabase.co';
      final supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsa3lnZ3V4d3F6d3BuYWhuaWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxMjM4OTcsImV4cCI6MjA2ODY5OTg5N30.-UNi-pJzCvzM3I1CdUHg230gDH14_pZix7DVqQQ2P_A';
      
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/send-chat-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $supabaseAnonKey',
        },
        body: jsonEncode({
          'recipientId': currentUser.id,
          'senderId': 'test-sender-id',
          'senderName': 'Test Sender',
          'message': 'This is a test chat notification via Supabase - ' + DateTime.now().toString(),
        }),
      );
      
      print('🧪 [TEST] Supabase response status: ${response.statusCode}');
      print('🧪 [TEST] Supabase response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ [TEST] Chat notification sent successfully via Supabase');
      } else {
        print('❌ [TEST] Failed to send chat notification via Supabase: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [TEST] Error sending chat notification via Supabase: $e');
    }
  }

  // Check notification permissions and channel status
  Future<void> checkNotificationStatus() async {
    try {
      print('🔍 [STATUS] Checking notification status...');
      
      // Check Firebase Messaging settings
      final settings = await _firebaseMessaging.getNotificationSettings();
      print('🔍 [STATUS] Firebase Messaging Settings:');
      print('  - Authorization Status: ${settings.authorizationStatus}');
      print('  - Alert: ${settings.alert}');
      print('  - Badge: ${settings.badge}');
      print('  - Sound: ${settings.sound}');
      print('  - Announcement: ${settings.announcement}');
      print('  - Car Play: ${settings.carPlay}');
      print('  - Critical Alert: ${settings.criticalAlert}');
      
      // Check if we have a token
      final token = await _firebaseMessaging.getToken();
      print('�� [STATUS] FCM Token: ${token?.substring(0, 20)}...');
      
      // Check Android notification channels (if on Android)
      if (!kIsWeb) {
        try {
          final androidChannels = await _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()?.getNotificationChannels();
          print('🔍 [STATUS] Android Notification Channels:');
          if (androidChannels != null) {
            for (final channel in androidChannels) {
              print('  - ${channel.id}: ${channel.name} (importance: ${channel.importance})');
            }
          }
        } catch (e) {
          print('🔍 [STATUS] Could not check Android channels: $e');
        }
      }
      
    } catch (e) {
      print('❌ [STATUS] Error checking notification status: $e');
    }
  }

  // Get current FCM token
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      print('❌ [PushNotificationService] Error getting FCM token: $e');
      return null;
    }
  }
} 