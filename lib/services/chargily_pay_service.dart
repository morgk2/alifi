import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChargilyPayService {
  static const String _publicKey = 'test_pk_TC2nBZQQ0KZdWZoVWgvfvBiFzoqcQKjEF6sr0qbi';
  static const String _secretKey = 'test_sk_jHJLZ7pRmxYoK9y8lLdgI3nDYaOfhtZWvEkz93B9';
  
  // Test mode for now
  static const bool _isTestMode = true; // Temporarily switch to live mode
  
  // V2 API endpoints
  static const String _baseUrl = 'https://pay.chargily.net/api/v2';
  static const String _testBaseUrl = 'https://pay.chargily.net/test/api/v2';
  
  final SupabaseClient _supabase = Supabase.instance.client;

  // Initialize Chargily Pay
  Future<void> initialize() async {
    try {
      // Test the API connection
      await _testApiConnection();
      
      if (kDebugMode) {
        print('Chargily Pay initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Chargily Pay: $e');
      }
      rethrow;
    }
  }

  // Test API connection
  Future<void> _testApiConnection() async {
    try {
      if (kDebugMode) {
        print('Testing API connection...');
        print('Using test mode: $_isTestMode');
        print('API key: ${_secretKey.substring(0, 10)}...');
      }
      
      final response = await http.get(
        Uri.parse('${_isTestMode ? _testBaseUrl : _baseUrl}/balance'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_secretKey',
        },
      );
      
      if (kDebugMode) {
        print('API test response: ${response.statusCode}');
        print('API test body: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('API test failed: $e');
      }
      // Don't rethrow for test
    }
  }

  // Create a new payment using V2 Payment Links
  Future<Map<String, dynamic>> createPayment({
    required String client,
    required String clientEmail,
    required String invoiceNumber,
    required double amount,
    required String currency,
    required String paymentMethod, // 'CIB' or 'EDAHABIA'
    required String backUrl,
    required String webhookUrl,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validate payment method
      if (!isValidPaymentMethod(paymentMethod)) {
        throw ArgumentError('Invalid payment method: $paymentMethod');
      }

      // Validate amount - minimum 50 DZD required
      if (amount < 50) {
        throw ArgumentError('Amount must be greater than or equal to 50 DZD');
      }

      // Validate currency - Chargily only accepts DZD
      if (currency.toLowerCase() != 'dzd') {
        throw ArgumentError('Only DZD currency is supported by Chargily');
      }

      // Prepare request body for V2 Checkout
      final requestBody = {
        'amount': amount.toStringAsFixed(2), // Use double with 2 decimal places
        'currency': currency.toLowerCase(), // Ensure currency is lowercase for Chargily API
        'description': description ?? 'Product Payment',
        'success_url': 'https://www.google.com', // Redirect to Google on success
        'locale': 'en',
        'pass_fees_to_customer': false,
        'collect_shipping_address': false,
        if (metadata != null) 'metadata': {
          ...metadata,
          'client': client,
          'client_email': clientEmail,
          'invoice_number': invoiceNumber,
          'payment_method': paymentMethod,
          'back_url': backUrl,
          'webhook_url': webhookUrl,
        },
      };

      if (kDebugMode) {
        print('Making request to: ${_isTestMode ? _testBaseUrl : _baseUrl}/checkouts');
        print('Using test mode: $_isTestMode');
        print('API key: ${_secretKey.substring(0, 10)}...');
        print('Original amount: $amount $currency');
        print('Original currency (before toLowerCase): $currency');
        print('Currency after toLowerCase: ${currency.toLowerCase()}');
        print('Converted price: ${amount.toStringAsFixed(2)} $currency (as double)');
        print('Request body: ${jsonEncode(requestBody)}');
      }

      // Make API request to create payment link
      final response = await http.post(
        Uri.parse('${_isTestMode ? _testBaseUrl : _baseUrl}/checkouts'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_secretKey',
        },
        body: jsonEncode(requestBody),
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (kDebugMode) {
          print('Payment link creation failed with status: ${response.statusCode}');
          print('Response headers: ${response.headers}');
          print('Response body: ${response.body}');
        }
        throw Exception('Payment link creation failed: ${response.statusCode} - ${response.body}');
      }

      final responseData = jsonDecode(response.body);
      final checkoutUrl = responseData['url'] ?? responseData['checkout_url'];

      if (checkoutUrl == null) {
        throw Exception('No checkout URL received');
      }

      // Create payment response map
      final payment = {
        'id': responseData['id'] ?? invoiceNumber,
        'checkout_url': checkoutUrl,
        'status': 'pending',
        'payment_link_id': responseData['id'],
      };

      // Store payment record in Supabase (optional - don't fail if table doesn't exist)
      try {
        await _storePaymentRecord(payment, {
          'client': client,
          'clientEmail': clientEmail,
          'invoiceNumber': invoiceNumber,
          'amount': amount,
          'currency': currency,
          'paymentMethod': paymentMethod,
          'description': description,
          'metadata': metadata,
          'paymentLinkId': responseData['id'],
        });
      } catch (e) {
        if (kDebugMode) {
          print('Warning: Could not store payment record in database: $e');
          print('Payment will continue without database storage');
        }
        // Don't rethrow - payment creation should still succeed
      }

      return payment;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating payment: $e');
      }
      rethrow;
    }
  }

  // Store payment record in Supabase
  Future<void> _storePaymentRecord(
    Map<String, dynamic> payment,
    Map<String, dynamic> paymentData,
  ) async {
    try {
      await _supabase
          .from('chargily_payments')
          .insert({
            'payment_id': payment['id'],
            'checkout_url': payment['checkout_url'],
            'status': 'pending',
            'client': paymentData['client'],
            'client_email': paymentData['clientEmail'],
            'invoice_number': paymentData['invoiceNumber'],
            'amount': paymentData['amount'],
            'currency': paymentData['currency'],
            'payment_method': paymentData['paymentMethod'],
            'description': paymentData['description'],
            'metadata': paymentData['metadata'],
          });

      if (kDebugMode) {
        print('Payment record stored in Supabase: ${payment['id']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error storing payment record: $e');
      }
      rethrow;
    }
  }

  // Get payment status from Supabase
  Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) async {
    try {
      final response = await _supabase
          .from('chargily_payments')
          .select()
          .eq('payment_id', paymentId)
          .single();

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not get payment status from database: $e');
        print('Returning null for payment status');
      }
      return null;
    }
  }

  // Update payment status in Supabase
  Future<void> updatePaymentStatus(
    String paymentId,
    String status,
    Map<String, dynamic>? paymentData,
  ) async {
    try {
      await _supabase
          .from('chargily_payments')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
            if (paymentData != null) ...paymentData,
          })
          .eq('payment_id', paymentId);

      if (kDebugMode) {
        print('Payment status updated: $paymentId -> $status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not update payment status in database: $e');
        print('Payment status update will be skipped');
      }
      // Don't rethrow - this is not critical for payment flow
    }
  }

  // Get payment history for a user
  Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    try {
      final response = await _supabase
          .from('chargily_payments')
          .select()
          .contains('metadata', {'userId': userId})
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not get user payments from database: $e');
        print('Returning empty list for user payments');
      }
      return [];
    }
  }

  // Generate unique invoice number
  String generateInvoiceNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'INV-$timestamp-$random';
  }

  // Validate payment method
  bool isValidPaymentMethod(String method) {
    // V2 API supports CIB and EDAHABIA
    return ['CIB', 'EDAHABIA'].contains(method.toUpperCase());
  }

  // Get payment method display name
  String getPaymentMethodDisplayName(String method) {
    switch (method.toUpperCase()) {
      case 'CIB':
        return 'CIB (Credit Card)';
      case 'EDAHABIA':
        return 'EDAHABIA (Bank Card)';
      default:
        return method;
    }
  }

  // Get payment method icon
  String getPaymentMethodIcon(String method) {
    switch (method.toUpperCase()) {
      case 'CIB':
        return 'assets/images/cib_logo.png';
      case 'EDAHABIA':
        return 'assets/images/sb_logo.png';
      default:
        return 'assets/images/payment_icon.png';
    }
  }
}
