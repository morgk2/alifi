import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../l10n/app_localizations.dart';

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
    {'name': 'Payment on Delivery', 'icon': 'mail_outline'},
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectAPaymentMethod),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final method = _paymentMethods[_selectedPaymentIndex];
    
    if (method['name'] == 'Payment on Delivery') {
      _processPaymentOnDelivery();
    } else if (method['name'] == 'CIB e-payment' || method['name'] == 'EDAHABIA') {
      // Map display names to API method names
      String apiMethod = method['name'] == 'CIB e-payment' ? 'CIB' : 'EDAHABIA';
      await _processChargilyPayment(apiMethod);
    } else {
      // TODO: Implement other payment methods
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.paymentComingSoon(method['name'])),
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
        clientEmail: user.email,
        invoiceNumber: invoiceNumber,
        amount: totalAmount, // Product price + app fee
        currency: paymentCurrency, // Use product's original currency
        paymentMethod: paymentMethod,
        backUrl: 'https://alifi.app/payment/return',
        webhookUrl: 'https://slkygguxwqzwpnahnici.supabase.co/functions/v1/chargily-webhook',
        description: AppLocalizations.of(context)!.paymentForProductPlusAppFee(widget.product.name),
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
            content: Text(AppLocalizations.of(context)!.errorCreatingPayment(e.toString())),
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
            errorMessage: AppLocalizations.of(context)!.paymentWasCancelled,
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
                AppLocalizations.of(context)!.processingPaymentTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              
              // Subtitle
              Text(
                AppLocalizations.of(context)!.pleaseWaitWhileWeVerifyYourPayment,
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
                AppLocalizations.of(context)!.verifyingPaymentStatus,
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
                errorMessage: AppLocalizations.of(context)!.paymentFailed,
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
                AppLocalizations.of(context)!.verifyingPayment,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              
              // Subtitle
              Text(
                AppLocalizations.of(context)!.checkingPaymentStatusManually,
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
                AppLocalizations.of(context)!.pleaseWaitWhileWeVerifyYourPayment,
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
              errorMessage: AppLocalizations.of(context)!.paymentVerificationTimeout,
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
    setState(() {
      _isProcessing = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      
      if (user == null) {
        throw Exception('User not found');
      }

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
        notes: AppLocalizations.of(context)!.paymentMethodCashOnDelivery,
      );

      // Create the order using DatabaseService (this will increment product totalOrders)
      final orderId = await DatabaseService().createOrder(order);

      // Create initial conversation message about the order
      await FirebaseFirestore.instance.collection('chat_messages').add({
        'senderId': user.id,
        'receiverId': widget.product.storeId,
        'message': AppLocalizations.of(context)!.helloIJustPlacedAnOrder(widget.product.name, orderId),
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

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              amount: widget.total,
              paymentMethod: 'Payment on Delivery',
              orderId: orderId,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorProcessingOrder(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false, bool isHighlighted = false, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal 
                ? const Color(0xFF2196F3)
                : isHighlighted 
                    ? Colors.orange 
                    : isGreen 
                        ? Colors.green 
                        : Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    AppLocalizations.of(context)!.completePayment,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Order Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.orderSummary,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: widget.product.imageUrls.isNotEmpty ? widget.product.imageUrls.first : '',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Image.asset(
                                      'assets/images/photo_loader.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
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
                                        color: Colors.black,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Consumer<CurrencyService>(
                                      builder: (context, currencyService, child) {
                                        return Text(
                                          'Qty: ${widget.quantity} × ${currencyService.formatPrice(widget.product.price)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            height: 1,
                            color: Colors.grey[200],
                          ),
                          const SizedBox(height: 16),
                          Consumer<CurrencyService>(
                            builder: (context, currencyService, child) {
                              return Column(
                                children: [
                                  _buildPriceRow(AppLocalizations.of(context)!.subtotal(widget.quantity), currencyService.formatProductPrice(widget.subtotal, widget.product.currency)),
                                  const SizedBox(height: 12),
                                  _buildPriceRow(AppLocalizations.of(context)!.tax, currencyService.formatProductPrice(widget.tax, widget.product.currency)),
                                  const SizedBox(height: 12),
                                  _buildPriceRow(AppLocalizations.of(context)!.appFee, currencyService.formatProductPrice(470.0, 'DZD'), isHighlighted: true),
                                  const SizedBox(height: 12),
                                  _buildPriceRow(AppLocalizations.of(context)!.shipping, AppLocalizations.of(context)!.free, isGreen: true),
                                  const SizedBox(height: 16),
                                  Container(
                                    height: 1,
                                    color: Colors.grey[200],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildPriceRow(
                                    AppLocalizations.of(context)!.total,
                                    currencyService.formatProductPrice(widget.total + 470.0, 'DZD'),
                                    isTotal: true,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Payment Methods Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.choosePaymentMethod,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // CIB Payment Card
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPaymentIndex = 0;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _selectedPaymentIndex == 0 
                                    ? const Color(0xFF2196F3).withOpacity(0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedPaymentIndex == 0 
                                      ? const Color(0xFF2196F3)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/images/cib_logo.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(Icons.payment, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.cibEpayment,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedPaymentIndex == 0 
                                                ? const Color(0xFF2196F3)
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppLocalizations.of(context)!.paySecurelyWithYourCibCard,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedScale(
                                    scale: _selectedPaymentIndex == 0 ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2196F3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // EDAHABIA Payment Card
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPaymentIndex = 1;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _selectedPaymentIndex == 1 
                                    ? const Color(0xFF2196F3).withOpacity(0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedPaymentIndex == 1 
                                      ? const Color(0xFF2196F3)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/images/sb_logo.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(Icons.payment, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.edahabia,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedPaymentIndex == 1 
                                                ? const Color(0xFF2196F3)
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppLocalizations.of(context)!.payWithYourEdahabiaCard,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedScale(
                                    scale: _selectedPaymentIndex == 1 ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2196F3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Powered by Chargily Pay
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.poweredBy,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SvgPicture.asset(
                                  'assets/images/chargilypaylogo.svg',
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF6B46C1),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Divider
                          Container(
                            height: 1,
                            color: Colors.grey[200],
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                          ),

                          const SizedBox(height: 20),

                          // Payment on Delivery Button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPaymentIndex = 2;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _selectedPaymentIndex == 2 
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedPaymentIndex == 2 
                                      ? Colors.orange
                                      : Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.orange[100],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.mail_outline,
                                      color: Colors.orange,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.paymentOnDelivery,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedPaymentIndex == 2 
                                                ? Colors.orange
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          AppLocalizations.of(context)!.payWhenYourOrderArrives,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedScale(
                                    scale: _selectedPaymentIndex == 2 ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total amount display
              Consumer<CurrencyService>(
                builder: (context, currencyService, child) {
                  final productPriceInDzd = currencyService.getPaymentAmount(widget.product.price, widget.product.currency);
                  final subtotalInDzd = widget.quantity * productPriceInDzd;
                  final totalWithAppFee = subtotalInDzd + 470.0; // App fee
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF2196F3).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.totalAmount,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          currencyService.formatProductPrice(totalWithAppFee, 'DZD'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Payment button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessing
                      ? Row(
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
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.processingPayment,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedPaymentIndex == -1 
                                  ? AppLocalizations.of(context)!.selectPaymentMethod
                                  : AppLocalizations.of(context)!.completeSecurePayment,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
              Text(
                AppLocalizations.of(context)!.orderConfirmed,
                style: const TextStyle(
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
                     AppLocalizations.of(context)!.yourOrderOfHasBeenConfirmed(currencyService.formatPrice(orderTotal)),
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
                        AppLocalizations.of(context)!.paymentOnDelivery,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.yourOrderHasBeenConfirmed,
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
                  child: Text(
                    AppLocalizations.of(context)!.backToHome,
                    style: const TextStyle(
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