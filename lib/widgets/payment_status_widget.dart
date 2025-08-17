import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/payment_status_service.dart';
import '../services/auth_service.dart';
import '../services/currency_service.dart';

class PaymentStatusWidget extends StatefulWidget {
  final String? paymentId; // Optional: show specific payment
  final bool showHistory; // Whether to show payment history

  const PaymentStatusWidget({
    super.key,
    this.paymentId,
    this.showHistory = false,
  });

  @override
  State<PaymentStatusWidget> createState() => _PaymentStatusWidgetState();
}

class _PaymentStatusWidgetState extends State<PaymentStatusWidget> {
  late PaymentStatusService _paymentStatusService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _paymentStatusService = PaymentStatusService();
    _authService = Provider.of<AuthService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.paymentId != null) {
      // Show specific payment status
      return _buildPaymentStatus();
    } else if (widget.showHistory) {
      // Show payment history
      return _buildPaymentHistory();
    } else {
      return Container(); // Empty if no specific use case
    }
  }

  Widget _buildPaymentStatus() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _paymentStatusService.watchPaymentStatus(widget.paymentId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorCard('Error loading payment status');
        }

        if (!snapshot.hasData) {
          return _buildLoadingCard('Loading payment status...');
        }

        final paymentData = snapshot.data!;
        final status = paymentData['status'] as String? ?? 'unknown';
        final amount = paymentData['payment_amount'] as double? ?? 0.0;
        final currency = paymentData['payment_currency'] as String? ?? 'DZD';
        final createdAt = paymentData['created_at'] as String?;

        return Card(
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusChip(status),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Amount:'),
                    Consumer<CurrencyService>(
                      builder: (context, currencyService, child) {
                        return Text(
                          currencyService.formatProductPrice(amount, currency),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                if (createdAt != null) ...[
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Date:'),
                      Text(DateTime.parse(createdAt).toString().split('.')[0]),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentHistory() {
    final user = _authService.currentUser;
    if (user == null) {
      return _buildErrorCard('User not authenticated');
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _paymentStatusService.watchUserOrders(user.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorCard('Error loading payment history');
        }

        if (!snapshot.hasData) {
          return _buildLoadingCard('Loading payment history...');
        }

        final payments = snapshot.data!;
        
        if (payments.isEmpty) {
          return Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No payment history found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            final status = payment['status'] as String? ?? 'unknown';
            final amount = payment['total_amount'] as double? ?? 0.0;
            final currency = payment['currency'] as String? ?? 'DZD';
            final productName = payment['product_name'] as String? ?? 'Unknown Product';
            final createdAt = payment['created_at'] as String?;

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(
                  productName,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (createdAt != null)
                      Text(
                        DateTime.parse(createdAt).toString().split('.')[0],
                        style: TextStyle(fontSize: 12),
                      ),
                    SizedBox(height: 4),
                    _buildStatusChip(status),
                  ],
                ),
                trailing: Consumer<CurrencyService>(
                  builder: (context, currencyService, child) {
                    return Text(
                      currencyService.formatProductPrice(amount, currency),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        label = 'Paid';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'failed':
        color = Colors.red;
        label = 'Failed';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoadingCard(String message) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 16),
            SizedBox(width: 8),
            Text(
              message,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}















