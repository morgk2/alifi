import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'supabase_notification_bridge.dart';
import 'app_initialization_service.dart';

class NotificationBridgeTest {
  static final NotificationBridgeTest _instance = NotificationBridgeTest._internal();
  factory NotificationBridgeTest() => _instance;
  NotificationBridgeTest._internal();

  /// Test the notification bridge with a simple notification
  Future<void> testDirectNotification({
    required String fcmToken,
    String title = 'Test Notification',
    String body = 'This is a test notification from Supabase bridge',
  }) async {
    try {
      final bridge = AppInitializationService().notificationBridge;
      
      if (bridge == null) {
        if (kDebugMode) {
          print('❌ [BridgeTest] Notification bridge not initialized');
        }
        return;
      }

      if (kDebugMode) {
        print('🧪 [BridgeTest] Sending test notification...');
        print('🧪 [BridgeTest] Token: ${fcmToken.substring(0, 20)}...');
        print('🧪 [BridgeTest] Title: $title');
        print('🧪 [BridgeTest] Body: $body');
      }

      await bridge.sendDirectNotification(
        token: fcmToken,
        title: title,
        body: body,
        type: 'test',
        data: {
          'testId': DateTime.now().millisecondsSinceEpoch.toString(),
          'source': 'supabase_bridge_test',
        },
      );

      if (kDebugMode) {
        print('✅ [BridgeTest] Test notification sent successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [BridgeTest] Failed to send test notification: $e');
      }
      rethrow;
    }
  }

  /// Test sending notification to multiple users
  Future<void> testMultiUserNotification({
    required List<String> userIds,
    String title = 'Multi-User Test',
    String body = 'This is a test notification for multiple users',
  }) async {
    try {
      final bridge = AppInitializationService().notificationBridge;
      
      if (bridge == null) {
        if (kDebugMode) {
          print('❌ [BridgeTest] Notification bridge not initialized');
        }
        return;
      }

      if (kDebugMode) {
        print('🧪 [BridgeTest] Sending multi-user test notification...');
        print('🧪 [BridgeTest] User IDs: $userIds');
        print('🧪 [BridgeTest] Title: $title');
        print('🧪 [BridgeTest] Body: $body');
      }

      await bridge.sendNotificationToUsers(
        userIds: userIds,
        title: title,
        body: body,
        type: 'multi_user_test',
        data: {
          'testId': DateTime.now().millisecondsSinceEpoch.toString(),
          'source': 'supabase_bridge_test',
          'userCount': userIds.length.toString(),
        },
      );

      if (kDebugMode) {
        print('✅ [BridgeTest] Multi-user test notification sent successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [BridgeTest] Failed to send multi-user test notification: $e');
      }
      rethrow;
    }
  }

  /// Test chat message notification
  Future<void> testChatNotification({
    required String recipientUserId,
    required String senderName,
    required String message,
  }) async {
    try {
      final bridge = AppInitializationService().notificationBridge;
      
      if (bridge == null) {
        if (kDebugMode) {
          print('❌ [BridgeTest] Notification bridge not initialized');
        }
        return;
      }

      if (kDebugMode) {
        print('🧪 [BridgeTest] Sending chat test notification...');
        print('🧪 [BridgeTest] Recipient: $recipientUserId');
        print('🧪 [BridgeTest] Sender: $senderName');
        print('🧪 [BridgeTest] Message: $message');
      }

      // Get recipient's FCM token
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(recipientUserId)
          .get();

      if (!userDoc.exists) {
        if (kDebugMode) {
          print('❌ [BridgeTest] Recipient user not found');
        }
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      final fcmToken = userData?['fcmToken'] as String?;

      if (fcmToken == null) {
        if (kDebugMode) {
          print('❌ [BridgeTest] Recipient has no FCM token');
        }
        return;
      }

      await bridge.sendDirectNotification(
        token: fcmToken,
        title: 'New message from $senderName',
        body: message.length > 50 ? '${message.substring(0, 50)}...' : message,
        type: 'chat_message',
        data: {
          'senderName': senderName,
          'message': message,
          'chatId': 'test_chat_${DateTime.now().millisecondsSinceEpoch}',
          'testId': DateTime.now().millisecondsSinceEpoch.toString(),
          'source': 'supabase_bridge_test',
        },
      );

      if (kDebugMode) {
        print('✅ [BridgeTest] Chat test notification sent successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [BridgeTest] Failed to send chat test notification: $e');
      }
      rethrow;
    }
  }

  /// Test order notification
  Future<void> testOrderNotification({
    required String recipientUserId,
    required String orderId,
    required String productName,
    required String status,
  }) async {
    try {
      final bridge = AppInitializationService().notificationBridge;
      
      if (bridge == null) {
        if (kDebugMode) {
          print('❌ [BridgeTest] Notification bridge not initialized');
        }
        return;
      }

      if (kDebugMode) {
        print('🧪 [BridgeTest] Sending order test notification...');
        print('🧪 [BridgeTest] Recipient: $recipientUserId');
        print('🧪 [BridgeTest] Order ID: $orderId');
        print('🧪 [BridgeTest] Product: $productName');
        print('🧪 [BridgeTest] Status: $status');
      }

      // Get recipient's FCM token
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(recipientUserId)
          .get();

      if (!userDoc.exists) {
        if (kDebugMode) {
          print('❌ [BridgeTest] Recipient user not found');
        }
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      final fcmToken = userData?['fcmToken'] as String?;

      if (fcmToken == null) {
        if (kDebugMode) {
          print('❌ [BridgeTest] Recipient has no FCM token');
        }
        return;
      }

      String title, body;
      switch (status) {
        case 'confirmed':
          title = 'Order Confirmed';
          body = 'Your order for $productName has been confirmed';
          break;
        case 'shipped':
          title = 'Order Shipped';
          body = 'Your order for $productName has been shipped';
          break;
        case 'delivered':
          title = 'Order Delivered';
          body = 'Your order for $productName has been delivered';
          break;
        case 'cancelled':
          title = 'Order Cancelled';
          body = 'Your order for $productName has been cancelled';
          break;
        default:
          title = 'Order Update';
          body = 'Your order for $productName has been updated';
      }

      await bridge.sendDirectNotification(
        token: fcmToken,
        title: title,
        body: body,
        type: 'order_$status',
        data: {
          'orderId': orderId,
          'productName': productName,
          'status': status,
          'testId': DateTime.now().millisecondsSinceEpoch.toString(),
          'source': 'supabase_bridge_test',
        },
      );

      if (kDebugMode) {
        print('✅ [BridgeTest] Order test notification sent successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [BridgeTest] Failed to send order test notification: $e');
      }
      rethrow;
    }
  }

  /// Run all tests
  Future<void> runAllTests({
    required String testFcmToken,
    required String testUserId,
  }) async {
    if (kDebugMode) {
      print('🧪 [BridgeTest] Starting comprehensive bridge tests...');
    }

    try {
      // Test 1: Direct notification
      await testDirectNotification(fcmToken: testFcmToken);

      // Test 2: Multi-user notification
      await testMultiUserNotification(userIds: [testUserId]);

      // Test 3: Chat notification
      await testChatNotification(
        recipientUserId: testUserId,
        senderName: 'Test User',
        message: 'This is a test chat message from the Supabase bridge!',
      );

      // Test 4: Order notification
      await testOrderNotification(
        recipientUserId: testUserId,
        orderId: 'test_order_${DateTime.now().millisecondsSinceEpoch}',
        productName: 'Test Product',
        status: 'confirmed',
      );

      if (kDebugMode) {
        print('✅ [BridgeTest] All tests completed successfully!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [BridgeTest] Some tests failed: $e');
      }
      rethrow;
    }
  }
}



