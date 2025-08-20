import 'package:flutter/material.dart';
import '../models/order.dart' as store_order;
import '../l10n/app_localizations.dart';

class OrderActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final Color confirmColor;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const OrderActionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText,
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
                        cancelText ?? AppLocalizations.of(context)!.cancel,
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
    required int quantity,
    required VoidCallback onConfirm,
    required BuildContext context,
  }) {
    final totalPrice = price * quantity;
    return OrderActionDialog(
      title: AppLocalizations.of(context)!.placeOrder,
      message: AppLocalizations.of(context)!.areYouSureYouWantToOrder(quantity, productName, totalPrice.toStringAsFixed(2)),
      confirmText: AppLocalizations.of(context)!.placeOrder,
      confirmColor: Colors.green,
      onConfirm: onConfirm,
    );
  }

  static OrderActionDialog confirmOrder({
    required String productName,
    required VoidCallback onConfirm,
    required BuildContext context,
  }) {
    return OrderActionDialog(
      title: AppLocalizations.of(context)!.confirmOrder,
      message: AppLocalizations.of(context)!.confirmThatYouWillFulfill(productName),
      confirmText: AppLocalizations.of(context)!.confirm,
      confirmColor: Colors.blue,
      onConfirm: onConfirm,
    );
  }

  static OrderActionDialog shipOrder({
    required String productName,
    required VoidCallback onConfirm,
    required BuildContext context,
  }) {
    return OrderActionDialog(
      title: AppLocalizations.of(context)!.shipOrder,
      message: AppLocalizations.of(context)!.markOrderAsShipped(productName),
      confirmText: AppLocalizations.of(context)!.ship,
      confirmColor: Colors.orange,
      onConfirm: onConfirm,
    );
  }

  static OrderActionDialog deliverOrder({
    required String productName,
    required VoidCallback onConfirm,
    required BuildContext context,
  }) {
    return OrderActionDialog(
      title: AppLocalizations.of(context)!.deliverOrder,
      message: AppLocalizations.of(context)!.markOrderAsDelivered(productName),
      confirmText: AppLocalizations.of(context)!.deliver,
      confirmColor: Colors.green,
      onConfirm: onConfirm,
    );
  }

  static OrderActionDialog cancelOrder({
    required String productName,
    required VoidCallback onConfirm,
    required BuildContext context,
  }) {
    return OrderActionDialog(
      title: AppLocalizations.of(context)!.cancelOrder,
      message: AppLocalizations.of(context)!.areYouSureYouWantToCancel(productName),
      confirmText: AppLocalizations.of(context)!.cancelOrder,
      confirmColor: Colors.red,
      onConfirm: onConfirm,
    );
  }
}