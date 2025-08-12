import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/store_product.dart';
import '../models/order.dart' as store_order;
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/currency_service.dart';
import '../services/chargily_pay_service.dart';
import '../services/payment_status_service.dart';
import '../widgets/chargily_payment_webview.dart';
import 'payment_success_page.dart';
import 'payment_failed_page.dart';

class PaymentPage extends StatefulWidget {
  final StoreProduct product;
  final Map<String, dynamic> selectedAddress;
  final double subtotal;
  final double tax;
  final double total;
  final int quantity;

  const PaymentPage({
    super.key,
    required this.product,
    required this.selectedAddress,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.quantity,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _selectedPaymentIndex = -1;
  bool _isProcessing = false;
  late ChargilyPayService _chargilyService;
  late PaymentStatusService _paymentStatusService;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'CIB e-payment', 'icon': 'assets/images/cib_logo.png'},
    {'name': 'EDAHABIA', 'icon': 'assets/images/sb_logo.png'},
  ];

  @override
  void initState() {
    super.initState();
    _chargilyService = ChargilyPayService();
    _chargilyService.initialize();
    _paymentStatusService = PaymentStatusService();
  }

  void _processPayment() async {
    if (_selectedPaymentIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final method = _paymentMethods[_selectedPaymentIndex];
    
    if (method['name'] == 'Payment on Delivery') {
      _processPaymentOnDelivery();
    } else if (method['name'] == 'CIB' || method['name'] == 'EDAHABIA') {
      await _processChargilyPayment(method['name']);
    } else {
      // TODO: Implement other payment methods
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${method['name']} payment coming soon!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _processChargilyPayment(String paymentMethod) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      
      if (user == null) {
        throw Exception('User not found');
      }

      // Generate invoice number
      final invoiceNumber = _chargilyService.generateInvoiceNumber();
      
      // Get the payment amount and currency from the product
      final currencyService = Provider.of<CurrencyService>(context, listen: false);
      final paymentAmount = currencyService.getPaymentAmount(widget.product.price, widget.product.currency);
      final paymentCurrency = currencyService.getPaymentCurrency(widget.product.currency);
      
      // Add app fee of 470 DZD
      const double appFee = 470.0; // App fee in DZD
      final totalAmount = (paymentAmount * widget.quantity) + appFee;
      
      // Create payment
      final payment = await _chargilyService.createPayment(
        client: user.displayName ?? 'Anonymous',
        clientEmail: user.email ?? '',
        invoiceNumber: invoiceNumber,
        amount: totalAmount, // Product price + app fee
        currency: paymentCurrency, // Use product's original currency
        paymentMethod: paymentMethod,
        backUrl: 'https://alifi.app/payment/return',
        webhookUrl: 'https://slkygguxwqzwpnahnici.supabase.co/functions/v1/chargily-webhook',
        description: 'Payment for ${widget.product.name} + App Fee',
        metadata: {
          'userId': user.id,
          'productId': widget.product.id,
          'productName': widget.product.name,
          'quantity': widget.quantity,
          'orderType': 'product_purchase',
          'productCurrency': widget.product.currency,
          'paymentAmount': paymentAmount * widget.quantity,
          'appFee': appFee,
          'totalAmount': totalAmount,
        },
      );

      // Navigate to payment webview
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChargilyPaymentWebView(
              checkoutUrl: payment['checkout_url'],
              backUrl: 'https://your-app.com/payment/return',
              onPaymentComplete: (status) {
                _handlePaymentResult(status, payment['id'], totalAmount);
              },
              onPaymentError: (error) {
                _handlePaymentError(error, totalAmount);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _handlePaymentResult(String status, String paymentId, double dzdAmount) {
    Navigator.of(context).pop(); // Close webview
    
    if (status == 'success') {
      // Start listening for payment status changes
      _listenForPaymentStatus(paymentId, dzdAmount);
    } else if (status == 'cancelled') {
      // Navigate to failed page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentFailedPage(
            amount: dzdAmount, // Pass the converted DZD amount
            paymentMethod: _paymentMethods[_selectedPaymentIndex]['name'],
            errorMessage: 'Payment was cancelled',
            onRetry: () {
              Navigator.of(context).pop();
              _processChargilyPayment(_paymentMethods[_selectedPaymentIndex]['name']);
            },
          ),
        ),
      );
    }
  }

  void _listenForPaymentStatus(String paymentId, double dzdAmount) {
    print('Starting payment status monitoring for: $paymentId');
    
    // Show loading dialog while checking payment status
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Payment icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.payment,
                  color: Colors.blue.shade600,
                  size: 30,
                ),
              ),
              SizedBox(height: 20),
              
              // Title
              Text(
                'Processing Payment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Please wait while we verify your payment',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              
              // Loading indicator
              CupertinoActivityIndicator(
                radius: 16,
                color: Colors.blue.shade600,
              ),
              SizedBox(height: 16),
              
              // Status text
              Text(
                'Verifying payment status...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // First check if payment record exists
    _paymentStatusService.paymentExists(paymentId).then((exists) {
      if (!exists) {
        print('Payment record not found, starting polling...');
        Navigator.of(context).pop(); // Close loading dialog
        _pollPaymentStatus(paymentId, dzdAmount);
        return;
      }
    });

    // Listen for payment status changes
    _paymentStatusService.watchPaymentStatus(paymentId).listen(
      (paymentData) async {
        print('Received payment data in stream: ${paymentData?['status']}');
        
        if (paymentData != null && paymentData['status'] == 'paid') {
          // Payment is successful
          print('Payment confirmed as paid!');
          Navigator.of(context).pop(); // Close loading dialog
          
          // Create order in Firestore if it doesn't exist
          print('🔄 Creating order from payment data...');
          await _paymentStatusService.createOrderFromPayment(paymentData);
          print('✅ Order creation completed');
          
          // Navigate to success page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentSuccessPage(
                amount: dzdAmount,
                paymentMethod: _paymentMethods[_selectedPaymentIndex]['name'],
                orderId: paymentId,
              ),
            ),
          );
        } else if (paymentData != null && paymentData['status'] == 'failed') {
          // Payment failed
          print('Payment failed');
          Navigator.of(context).pop(); // Close loading dialog
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentFailedPage(
                amount: dzdAmount,
                paymentMethod: _paymentMethods[_selectedPaymentIndex]['name'],
                errorMessage: 'Payment failed',
                onRetry: () {
                  Navigator.of(context).pop();
                  _processChargilyPayment(_paymentMethods[_selectedPaymentIndex]['name']);
                },
              ),
            ),
          );
        }
      },
      onError: (error) {
        print('Error in payment status stream: $error');
        // Fallback to polling if streaming fails
        Navigator.of(context).pop(); // Close loading dialog
        _pollPaymentStatus(paymentId, dzdAmount);
      },
    );

    // Set a shorter timeout and start polling immediately as backup
    Future.delayed(Duration(seconds: 15), () {
      if (mounted) {
        print('Stream timeout, starting polling as backup...');
        Navigator.of(context).pop(); // Close loading dialog
        _pollPaymentStatus(paymentId, dzdAmount);
      }
    });
  }

  void _pollPaymentStatus(String paymentId, double dzdAmount) async {
    print('Starting polling for payment: $paymentId');
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Payment icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.sync,
                  color: Colors.orange.shade600,
                  size: 30,
                ),
              ),
              SizedBox(height: 20),
              
              // Title
              Text(
                'Verifying Payment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Checking payment status manually',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              
              // Loading indicator
              CupertinoActivityIndicator(
                radius: 16,
                color: Colors.orange.shade600,
              ),
              SizedBox(height: 16),
              
              // Status text
              Text(
                'Please wait while we verify your payment',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Poll for payment status
    final paymentData = await _paymentStatusService.pollPaymentStatus(paymentId, maxAttempts: 15);
    
    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog
      
      if (paymentData != null && paymentData['status'] == 'paid') {
        // Payment is successful
        print('Payment confirmed via polling!');
        print('🔄 Creating order from payment data (polling)...');
        await _paymentStatusService.createOrderFromPayment(paymentData);
        print('✅ Order creation completed (polling)');
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              amount: dzdAmount,
              paymentMethod: _paymentMethods[_selectedPaymentIndex]['name'],
              orderId: paymentId,
            ),
          ),
        );
      } else {
        // Payment failed or timeout
        print('Payment polling failed or timed out');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentFailedPage(
              amount: dzdAmount,
              paymentMethod: _paymentMethods[_selectedPaymentIndex]['name'],
              errorMessage: 'Payment verification timeout. Please check your payment status manually.',
              onRetry: () {
                Navigator.of(context).pop();
                _processChargilyPayment(_paymentMethods[_selectedPaymentIndex]['name']);
              },
            ),
          ),
        );
      }
    }
  }

  void _handlePaymentError(String error, double dzdAmount) {
    Navigator.of(context).pop(); // Close webview
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentFailedPage(
          amount: dzdAmount, // Pass the converted DZD amount
          paymentMethod: _paymentMethods[_selectedPaymentIndex]['name'],
          errorMessage: error,
          onRetry: () {
            Navigator.of(context).pop();
            _processChargilyPayment(_paymentMethods[_selectedPaymentIndex]['name']);
          },
        ),
      ),
    );
  }

  void _processPaymentOnDelivery() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      
      if (user != null) {
        // Get store information
        final storeDoc = await FirebaseFirestore.instance.collection('users').doc(widget.product.storeId).get();
        final storeName = storeDoc.exists 
            ? (storeDoc.data() as Map<String, dynamic>)['displayName'] ?? 'Store'
            : 'Store';

        // Create the order using the proper DatabaseService method
        final order = store_order.StoreOrder(
          id: '', // Will be generated by Firestore
          customerId: user.id,
          customerName: user.displayName?.isNotEmpty == true ? user.displayName! : 'Anonymous',
          storeId: widget.product.storeId,
          storeName: storeName,
          productId: widget.product.id,
          productName: widget.product.name,
          productImageUrl: widget.product.imageUrls.isNotEmpty ? widget.product.imageUrls.first : '',
          price: widget.product.price,
          quantity: widget.quantity,
          status: 'ordered',
          createdAt: DateTime.now(),
          chatMessageId: '', // Will be set after creating the order
        );

        // Create the order using DatabaseService (this will increment product totalOrders)
        final orderId = await DatabaseService().createOrder(order);

        // Create initial conversation message about the order
        await FirebaseFirestore.instance.collection('chat_messages').add({
          'senderId': user.id,
          'receiverId': widget.product.storeId,
          'message': 'Hello! I just placed an order for ${widget.product.name}. Order ID: $orderId',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'productAttachment': {
            'id': widget.product.id,
            'name': widget.product.name,
            'price': widget.product.price,
            'imageUrl': widget.product.imageUrls.isNotEmpty ? widget.product.imageUrls.first : '',
          },
          'isOrderAttachment': true,
          'orderId': orderId,
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderConfirmationPage(
              orderTotal: widget.total,
              paymentMethod: 'Payment on Delivery',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Order Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: widget.product.imageUrls.isNotEmpty ? widget.product.imageUrls.first : '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/images/photo_loader.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.image, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Consumer<CurrencyService>(
                            builder: (context, currencyService, child) {
                              return Text(
                                'Qty: ${widget.quantity} × ${currencyService.formatPrice(widget.product.price)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Consumer<CurrencyService>(
                  builder: (context, currencyService, child) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal'),
                            Text(currencyService.formatProductPrice(widget.subtotal, widget.product.currency)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax'),
                            Text(currencyService.formatProductPrice(widget.tax, widget.product.currency)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('App Fee'),
                            Text(
                              currencyService.formatProductPrice(470.0, 'DZD'),
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Shipping'),
                    const Text(
                      'Free',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Consumer<CurrencyService>(
                  builder: (context, currencyService, child) {
                    final totalWithAppFee = widget.total + 470.0; // Add app fee to total
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currencyService.formatProductPrice(totalWithAppFee, 'DZD'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // Payment Methods
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Payment method buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPaymentIndex = 0;
                            });
                          },
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: _selectedPaymentIndex == 0 ? const Color(0xFFE3F2FD) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _selectedPaymentIndex == 0 ? const Color(0xFF2196F3) : const Color(0xFFE0E0E0),
                                width: _selectedPaymentIndex == 0 ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/cib_logo.png',
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E0E0),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.payment, color: Color(0xFF757575)),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'CIB e-payment',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPaymentIndex = 1;
                            });
                          },
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: _selectedPaymentIndex == 1 ? const Color(0xFFE3F2FD) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _selectedPaymentIndex == 1 ? const Color(0xFF2196F3) : const Color(0xFFE0E0E0),
                                width: _selectedPaymentIndex == 1 ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/sb_logo.png',
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E0E0),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.payment, color: Color(0xFF757575)),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'EDAHABIA',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Powered by Chargily Pay section
                  const SizedBox(height: 24),
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Powered by',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: Color(0xFF6B46C1),
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Chargily Pay™',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B46C1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C00), // Orange
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isProcessing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Processing...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Place order',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Consumer<CurrencyService>(
                builder: (context, currencyService, child) {
                  final productPriceInDzd = currencyService.getPaymentAmount(widget.product.price, widget.product.currency);
                  final subtotalInDzd = widget.quantity * productPriceInDzd;
                  final totalWithAppFee = subtotalInDzd + 470.0; // App fee
                  return Text(
                    currencyService.formatProductPrice(totalWithAppFee, 'DZD'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderConfirmationPage extends StatelessWidget {
  final double orderTotal;
  final String paymentMethod;

  const OrderConfirmationPage({
    super.key,
    required this.orderTotal,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
                             Consumer<CurrencyService>(
                 builder: (context, currencyService, child) {
                   return Text(
                     'Your order of ${currencyService.formatPrice(orderTotal)} has been confirmed.',
                     style: TextStyle(
                       fontSize: 16,
                       color: Colors.grey[600],
                     ),
                     textAlign: TextAlign.center,
                   );
                 },
               ),
              const SizedBox(height: 24),
              if (paymentMethod == 'Payment on Delivery') ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        color: Colors.green[700],
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Payment on Delivery',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your order has been confirmed! You will pay when the product is delivered to your address.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}