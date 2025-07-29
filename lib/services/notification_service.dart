import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Global key for showing notifications
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();

  // Stream subscription for chat notifications
  StreamSubscription<List<ChatMessage>>? _chatSubscription;

  void initializeNotifications(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    
    if (currentUser != null && currentUser.accountType == 'store') {
      _listenForNewMessages(currentUser.id);
    }
  }

  void _listenForNewMessages(String storeId) {
    // Listen for messages where the store is the receiver
    _chatSubscription = DatabaseService()
        .getIncomingMessagesForStore(storeId)
        .listen((messages) {
      if (messages.isNotEmpty) {
        final latestMessage = messages.last;
        _showChatNotification(latestMessage);
      }
    });
  }

  void _showChatNotification(ChatMessage message) {
    // Show a sliding notification from the top
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: _buildNotificationContent(message),
        backgroundColor: Colors.white,
        elevation: 8,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Reply',
          textColor: Colors.green,
          onPressed: () {
            // TODO: Navigate to chat
            _navigateToChat(message);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationContent(ChatMessage message) {
    return FutureBuilder<User?>(
      future: DatabaseService().getUser(message.senderId),
      builder: (context, snapshot) {
        final sender = snapshot.data;
        
        return Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: sender?.photoURL != null
                  ? NetworkImage(sender!.photoURL!)
                  : null,
              child: sender?.photoURL == null
                  ? Text(
                      (sender?.displayName ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sender?.displayName ?? 'Customer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToChat(ChatMessage message) {
    // TODO: Implement navigation to chat
    // This will be handled by the main app navigation
  }

  void dispose() {
    _chatSubscription?.cancel();
  }
} 