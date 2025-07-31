import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/notification.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead ? Colors.grey.shade200 : Colors.blue.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar/Icon
                _buildAvatar(),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and time
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(notification.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Body
                      Text(
                        notification.body,
                        style: TextStyle(
                          color: notification.isRead ? Colors.grey[600] : Colors.grey[700],
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Unread indicator
                      if (!notification.isRead) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Delete button
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // Different icons for different notification types
    IconData iconData;
    Color iconColor;
    
    switch (notification.type) {
      case NotificationType.chatMessage:
        iconData = Icons.chat_bubble_outline;
        iconColor = Colors.blue;
        break;
      case NotificationType.orderPlaced:
        iconData = Icons.shopping_cart;
        iconColor = Colors.green;
        break;
      case NotificationType.orderConfirmed:
        iconData = Icons.check_circle_outline;
        iconColor = Colors.blue;
        break;
      case NotificationType.orderShipped:
        iconData = Icons.local_shipping_outlined;
        iconColor = Colors.orange;
        break;
      case NotificationType.orderDelivered:
        iconData = Icons.done_all;
        iconColor = Colors.green;
        break;
      case NotificationType.orderCancelled:
        iconData = Icons.cancel_outlined;
        iconColor = Colors.red;
        break;
      case NotificationType.follow:
        iconData = Icons.person_add_outlined;
        iconColor = Colors.purple;
        break;
      case NotificationType.unfollow:
        iconData = Icons.person_remove_outlined;
        iconColor = Colors.grey;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 