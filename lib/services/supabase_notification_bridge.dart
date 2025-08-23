import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';

class SupabaseNotificationBridge {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _supabaseUrl;
  final String _supabaseAnonKey;
  
  // Stream subscriptions for Firestore listeners
  List<StreamSubscription> _subscriptions = [];

  SupabaseNotificationBridge({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) : _supabaseUrl = supabaseUrl,
       _supabaseAnonKey = supabaseAnonKey;

  /// Initialize the bridge by setting up Firestore listeners
  void initialize() {
    _setupChatListeners();
    _setupOrderListeners();
    _setupAppointmentListeners();
    _setupUserListeners();
  }

  /// Clean up all listeners
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Set up listeners for chat messages
  void _setupChatListeners() {
    // Listen for new chat messages
    final chatSubscription = _firestore
        .collection('chats')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _handleNewChat(change.doc);
        } else if (change.type == DocumentChangeType.modified) {
          _handleChatUpdate(change.doc);
        }
      }
    });

    _subscriptions.add(chatSubscription);
  }

  /// Set up listeners for orders
  void _setupOrderListeners() {
    final orderSubscription = _firestore
        .collection('orders')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _handleNewOrder(change.doc);
        } else if (change.type == DocumentChangeType.modified) {
          _handleOrderUpdate(change.doc);
        }
      }
    });

    _subscriptions.add(orderSubscription);
  }

  /// Set up listeners for appointments
  void _setupAppointmentListeners() {
    final appointmentSubscription = _firestore
        .collection('appointments')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _handleNewAppointment(change.doc);
        } else if (change.type == DocumentChangeType.modified) {
          _handleAppointmentUpdate(change.doc);
        }
      }
    });

    _subscriptions.add(appointmentSubscription);
  }

  /// Set up listeners for user updates (FCM token changes)
  void _setupUserListeners() {
    final userSubscription = _firestore
        .collection('users')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          _handleUserUpdate(change.doc);
        }
      }
    });

    _subscriptions.add(userSubscription);
  }

  /// Handle new chat creation
  void _handleNewChat(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null && data['messages'] != null) {
      _triggerSupabaseFunction('firestore-bridge', {
        'event': 'document.created',
        'collection': 'chats',
        'documentId': doc.id,
        'data': data,
      });
    }
  }

  /// Handle chat updates (new messages)
  void _handleChatUpdate(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null && data['messages'] != null) {
      _triggerSupabaseFunction('firestore-bridge', {
        'event': 'document.updated',
        'collection': 'chats',
        'documentId': doc.id,
        'data': data,
      });
    }
  }

  /// Handle new order creation
  void _handleNewOrder(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null) {
      _triggerSupabaseFunction('firestore-bridge', {
        'event': 'document.created',
        'collection': 'orders',
        'documentId': doc.id,
        'data': data,
      });
    }
  }

  /// Handle order updates
  void _handleOrderUpdate(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null) {
      _triggerSupabaseFunction('firestore-bridge', {
        'event': 'document.updated',
        'collection': 'orders',
        'documentId': doc.id,
        'data': data,
      });
    }
  }

  /// Handle new appointment creation
  void _handleNewAppointment(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null) {
      _triggerSupabaseFunction('firestore-bridge', {
        'event': 'document.created',
        'collection': 'appointments',
        'documentId': doc.id,
        'data': data,
      });
    }
  }

  /// Handle appointment updates
  void _handleAppointmentUpdate(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null) {
      _triggerSupabaseFunction('firestore-bridge', {
        'event': 'document.updated',
        'collection': 'appointments',
        'documentId': doc.id,
        'data': data,
      });
    }
  }

  /// Handle user updates (FCM token changes)
  void _handleUserUpdate(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null && data['fcmToken'] != null) {
      // Update FCM token in Supabase if needed
      _updateSupabaseFCMToken(doc.id, data['fcmToken']);
    }
  }

  /// Trigger a Supabase Edge Function
  Future<void> _triggerSupabaseFunction(String functionName, Map<String, dynamic> payload) async {
    try {
      final url = '$_supabaseUrl/functions/v1/$functionName';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Supabase function $functionName triggered successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to trigger Supabase function $functionName: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error triggering Supabase function $functionName: $e');
      }
    }
  }

  /// Update FCM token in Supabase
  Future<void> _updateSupabaseFCMToken(String userId, String fcmToken) async {
    try {
      final url = '$_supabaseUrl/rest/v1/users';
      
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_supabaseAnonKey',
          'apikey': _supabaseAnonKey,
        },
        body: jsonEncode({
          'id': userId,
          'fcm_token': fcmToken,
          'last_token_update': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('FCM token updated in Supabase for user: $userId');
        }
      } else {
        if (kDebugMode) {
          print('Failed to update FCM token in Supabase: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating FCM token in Supabase: $e');
      }
    }
  }

  /// Send a direct notification through Supabase
  Future<void> sendDirectNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? type,
  }) async {
    await _triggerSupabaseFunction('send-push-notification', {
      'token': token,
      'title': title,
      'body': body,
      'data': data,
      'type': type,
    });
  }

  /// Send notification to multiple users
  Future<void> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? type,
  }) async {
    // Get FCM tokens for all users
    final tokens = <String>[];
    
    for (final userId in userIds) {
      try {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>?;
          if (userData != null && userData['fcmToken'] != null) {
            tokens.add(userData['fcmToken']);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error getting FCM token for user $userId: $e');
        }
      }
    }

    // Send notification to each token
    for (final token in tokens) {
      await sendDirectNotification(
        token: token,
        title: title,
        body: body,
        data: data,
        type: type,
      );
    }
  }
}
