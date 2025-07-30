import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const NotificationBadge({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    
    if (currentUser == null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return StreamBuilder<int>(
      stream: NotificationService().getUnreadNotificationsCount(currentUser.id),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        
        return GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              child,
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
} 