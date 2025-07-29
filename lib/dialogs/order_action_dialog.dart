import 'package:flutter/material.dart';
import '../models/order.dart' as store_order;

class OrderActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const OrderActionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText = 'Cancel',
    this.confirmColor = Colors.blue,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: confirmColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      _getIconForAction(title),
                      color: confirmColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Message
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Divider
            Container(
              height: 1,
              color: Colors.grey[200],
            ),
            // Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(false);
                      onCancel?.call();
                    },
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Vertical Divider
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey[200],
                ),
                // Confirm Button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(true);
                      onConfirm?.call();
                    },
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        confirmText,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          color: confirmColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForAction(String action) {
    switch (action.toLowerCase()) {
      case 'place order':
        return Icons.shopping_cart_outlined;
      case 'confirm order':
        return Icons.check_circle_outline;
      case 'ship order':
        return Icons.local_shipping_outlined;
      case 'deliver order':
        return Icons.delivery_dining_outlined;
      case 'cancel order':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  // Convenience constructors for different actions
  static OrderActionDialog placeOrder({
    required String productName,
    required double price,
    required VoidCallback onConfirm,
  }) {
    return OrderActionDialog(
      title: 'Place Order',
      message: 'Are you sure you want to order "$productName" for \$${price.toStringAsFixed(2)}?',
      confirmText: 'Place Order',
      confirmColor: Colors.green,
      onConfirm: onConfirm,
    );
  }

  static OrderActionDialog confirmOrder({
    required String productName,
    required VoidCallback onConfirm,
  }) {
    return OrderActionDialog(
      title: 'Confirm Order',
      message: 'Confirm that you will fulfill the order for "$productName"?',
      confirmText: 'Confirm',
      confirmColor: Colors.blue,
      onConfirm: onConfirm,
    );
  }

  static OrderActionDialog shipOrder({
    required String productName,
    required VoidCallback onConfirm,
  }) {
    return OrderActionDialog(
      title: 'Ship Order',
      message: 'Mark the order for "$productName" as shipped?',
      confirmText: 'Ship',
      confirmColor: Colors.orange,
      onConfirm: onConfirm,
    );
  }

  static OrderActionDialog deliverOrder({
    required String productName,
    required VoidCallback onConfirm,
  }) {
    return OrderActionDialog(
      title: 'Deliver Order',
      message: 'Mark the order for "$productName" as delivered?',
      confirmText: 'Deliver',
      confirmColor: Colors.green,
      onConfirm: onConfirm,
    );
  }

  static OrderActionDialog cancelOrder({
    required String productName,
    required VoidCallback onConfirm,
  }) {
    return OrderActionDialog(
      title: 'Cancel Order',
      message: 'Are you sure you want to cancel the order for "$productName"?',
      confirmText: 'Cancel Order',
      confirmColor: Colors.red,
      onConfirm: onConfirm,
    );
  }
}