import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart' as store_order;
import '../services/database_service.dart';

class PaymentStatusService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();

  // Stream to listen for payment status changes
  Stream<Map<String, dynamic>?> watchPaymentStatus(String paymentId) {
    print('Starting to watch payment status for: $paymentId');
    return _supabase
        .from('chargily_payments')
        .stream(primaryKey: ['payment_id'])
        .eq('payment_id', paymentId)
        .map((data) {
          print('Received payment data: ${data.length} records');
          if (data.isNotEmpty) {
            print('Payment status: ${data.first['status']}');
            return data.first;
          }
          print('No payment data found');
          return null;
        })
        .handleError((error) {
          print('Error in payment status stream: $error');
          return null;
        });
  }

  // Stream to listen for new orders
  Stream<List<Map<String, dynamic>>> watchUserOrders(String userId) {
    return _supabase
        .from('store_orders')
        .stream(primaryKey: ['id'])
        .eq('customer_id', userId)
        .order('created_at', ascending: false);
  }

  // Check payment status manually
  Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) async {
    try {
      print('Checking payment status for: $paymentId');
      
      // First try chargily_payments table
      try {
        print('Querying chargily_payments table...');
        final response = await _supabase
            .from('chargily_payments')
            .select()
            .eq('payment_id', paymentId)
            .single();
        
        print('Payment found in chargily_payments: ${response['status']}');
        return response;
      } catch (e) {
        print('Payment not found in chargily_payments: $e');
        print('Checking store_orders...');
      }
      
      // Fallback to store_orders table
      try {
        final orderResponse = await _supabase
            .from('store_orders')
            .select()
            .eq('payment_id', paymentId)
            .single();
        
        if (orderResponse.isNotEmpty) {
          // Convert order data to payment format
          final paymentData = {
            'payment_id': paymentId,
            'status': orderResponse['status'] == 'paid' ? 'paid' : 'pending',
            'payment_amount': orderResponse['total_amount'],
            'payment_currency': orderResponse['currency'],
            'metadata': {
              'userId': orderResponse['customer_id'],
              'productId': orderResponse['product_id'],
              'productName': orderResponse['product_name'],
              'quantity': orderResponse['quantity'],
            }
          };
          
          print('Payment found in store_orders: ${paymentData['status']}');
          return paymentData;
        }
      } catch (e) {
        print('Error checking store_orders: $e');
      }
      
      return null;
    } catch (e) {
      print('Error getting payment status: $e');
      return null;
    }
  }

  // Check if payment record exists
  Future<bool> paymentExists(String paymentId) async {
    try {
      // First check chargily_payments table
      final response = await _supabase
          .from('chargily_payments')
          .select('payment_id')
          .eq('payment_id', paymentId)
          .limit(1);
      
      if (response.isNotEmpty) {
        print('Payment $paymentId exists in chargily_payments: true');
        return true;
      }
      
      // If not found, check store_orders table as fallback
      final orderResponse = await _supabase
          .from('store_orders')
          .select('payment_id')
          .eq('payment_id', paymentId)
          .limit(1);
      
      final exists = orderResponse.isNotEmpty;
      print('Payment $paymentId exists in store_orders: $exists');
      return exists;
    } catch (e) {
      print('Error checking if payment exists: $e');
      return false;
    }
  }

  // Create order in Firestore when payment is successful
  Future<void> createOrderFromPayment(Map<String, dynamic> paymentData) async {
    try {
      print('Creating order from payment data: ${paymentData['payment_id']}');
      
      // Extract metadata from different possible locations
      Map<String, dynamic>? metadata;
      
      // First try direct metadata field
      if (paymentData['metadata'] != null) {
        metadata = paymentData['metadata'] as Map<String, dynamic>;
        print('Found metadata in direct field');
      }
      // Then try webhook_data.data.metadata (Chargily structure)
      else if (paymentData['webhook_data'] != null) {
        final webhookData = paymentData['webhook_data'] as Map<String, dynamic>;
        if (webhookData['data'] != null) {
          final data = webhookData['data'] as Map<String, dynamic>;
          if (data['metadata'] != null) {
            metadata = data['metadata'] as Map<String, dynamic>;
            print('Found metadata in webhook_data.data.metadata');
          }
        }
      }
      
      if (metadata == null) {
        print('No metadata found in payment data');
        print('Available fields: ${paymentData.keys.toList()}');
        return;
      }

      print('Extracted metadata: $metadata');

      final userId = metadata['userId'] as String?;
      final productId = metadata['productId'] as String?;
      final productName = metadata['productName'] as String?;
      
      // Handle quantity as either int or String
      int? quantity;
      final rawQuantity = metadata['quantity'];
      if (rawQuantity != null) {
        if (rawQuantity is int) {
          quantity = rawQuantity;
        } else if (rawQuantity is String) {
          quantity = int.tryParse(rawQuantity);
        }
      }
      
      // Handle paymentAmount as either int or double
      double? paymentAmount;
      final rawPaymentAmount = metadata['paymentAmount'];
      if (rawPaymentAmount != null) {
        if (rawPaymentAmount is int) {
          paymentAmount = rawPaymentAmount.toDouble();
        } else if (rawPaymentAmount is double) {
          paymentAmount = rawPaymentAmount;
        } else if (rawPaymentAmount is String) {
          paymentAmount = double.tryParse(rawPaymentAmount);
        }
      }
      
      final productCurrency = metadata['productCurrency'] as String?;

      print('Extracted values: userId=$userId, productId=$productId, productName=$productName');

      if (userId == null || productId == null || productName == null) {
        print('Missing required metadata for order creation');
        print('userId: $userId, productId: $productId, productName: $productName');
        return;
      }

      // Get store information from the product
      String storeId = metadata['storeId'] as String? ?? '';
      String storeName = metadata['storeName'] as String? ?? 'Store';
      String productImageUrl = metadata['productImageUrl'] as String? ?? '';
      
      print('🔍 Store info from metadata: storeId=$storeId, storeName=$storeName');
      
            // Always try to get the correct product information first
      if (productId != null) {
        print('🔍 Fetching product information: $productId');
        try {
          // Try storeproducts collection first
          var productDoc = await FirebaseFirestore.instance.collection('storeproducts').doc(productId).get();
          String collectionName = 'storeproducts';
          
          // If not found in storeproducts, try products collection
          if (!productDoc.exists) {
            print('🔍 Product not found in storeproducts, trying products collection...');
            productDoc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
            collectionName = 'products';
          }
          
          if (productDoc.exists) {
            final productData = productDoc.data() as Map<String, dynamic>;
            print('🔍 Product data found in $collectionName: $productData');
            
            // Get store ID from product
            storeId = productData['storeId'] as String? ?? '';
            print('🔍 Found storeId in product: $storeId');
            
            // Get product image URL
            final imageUrls = productData['imageUrls'] as List<dynamic>?;
            productImageUrl = imageUrls?.isNotEmpty == true ? imageUrls!.first.toString() : '';
            print('🔍 Found product image URL: $productImageUrl');
            
            // Get actual product price from product document
            final actualPrice = (productData['price'] as num?)?.toDouble() ?? paymentAmount ?? 0.0;
            print('🔍 Product price from document: $actualPrice');
            paymentAmount = actualPrice; // Use the actual product price
            
            // Get store name from users collection
            if (storeId.isNotEmpty) {
              final storeDoc = await FirebaseFirestore.instance.collection('users').doc(storeId).get();
              if (storeDoc.exists) {
                final storeData = storeDoc.data() as Map<String, dynamic>;
                storeName = storeData['displayName'] as String? ?? 'Store';
                print('🔍 Found store name: $storeName');
              } else {
                print('❌ Store document not found: $storeId');
              }
            } else {
              print('❌ No storeId found in product data');
            }
          } else {
            print('❌ Product document not found in both collections: $productId');
            print('🔍 Available products in storeproducts collection:');
            try {
              final productsQuery = await FirebaseFirestore.instance.collection('storeproducts').limit(5).get();
              for (var doc in productsQuery.docs) {
                print('  - ${doc.id}: ${doc.data()}');
              }
            } catch (e) {
              print('❌ Error listing storeproducts: $e');
            }
          }
        } catch (e) {
          print('❌ Error getting product information: $e');
        }
      }
      
      print('🔍 Final store info: storeId=$storeId, storeName=$storeName');
      print('🔍 Product image URL: $productImageUrl');

      // Create order in Firestore (matching chat-based order pattern)
      print('🔍 Creating order with:');
      print('  - customerId: $userId');
      print('  - storeId: $storeId');
      print('  - productId: $productId');
      print('  - productName: $productName');
      print('  - price: $paymentAmount');
      print('  - quantity: $quantity');
      print('  - productImageUrl: $productImageUrl');
      
      final order = store_order.StoreOrder(
        id: '', // Will be generated by Firestore
        customerId: userId,
        customerName: metadata['client'] as String? ?? 'Anonymous',
        storeId: storeId,
        storeName: storeName,
        productId: productId,
        productName: productName,
        productImageUrl: productImageUrl,
        price: paymentAmount ?? 0.0,
        quantity: quantity ?? 1,
        status: 'pending', // Use 'pending' like chat-based orders
        createdAt: DateTime.now(),
        chatMessageId: 'payment_${paymentData['payment_id']}', // Use payment ID as chat message ID
        notes: 'Payment ID: ${paymentData['payment_id']} | Method: ${metadata['payment_method'] ?? 'Chargily'} | Status: Paid',
      );

      print('🔍 Calling DatabaseService.createOrder...');
      final orderId = await _databaseService.createOrder(order);
      print('✅ Order created in Firestore for payment: ${paymentData['payment_id']}');
      print('Order ID: $orderId');
      print('Order details: ${order.productName} x${order.quantity} for ${order.customerName}');
      print('Order status: ${order.status}');

      // Create chat message for the order (like payment on delivery)
      try {
        print('🔍 Creating chat message:');
        print('  - senderId: $userId');
        print('  - receiverId: $storeId');
        print('  - orderId: $orderId');
        
        final chatMessageData = {
          'senderId': userId,
          'receiverId': storeId,
          'message': 'Hello! I just placed a paid order for $productName. Order ID: $orderId | Payment ID: ${paymentData['payment_id']}',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'productAttachment': {
            'id': productId,
            'name': productName,
            'price': paymentAmount ?? 0.0,
            'imageUrl': metadata['productImageUrl'] as String? ?? '',
          },
          'isOrderAttachment': true,
          'orderId': orderId,
          'paymentMethod': metadata['payment_method'] ?? 'Chargily',
          'paymentStatus': 'paid',
        };
        
        print('🔍 Chat message data: $chatMessageData');
        
        final chatMessageRef = await FirebaseFirestore.instance.collection('chat_messages').add(chatMessageData);
        print('✅ Chat message created for order: $orderId');
        print('✅ Chat message ID: ${chatMessageRef.id}');
      } catch (e) {
        print('❌ Error creating chat message: $e');
        print('❌ Error details: ${e.toString()}');
      }
    } catch (e) {
      print('❌ Error creating order from payment: $e');
    }
  }

  // Poll payment status (fallback method)
  Future<Map<String, dynamic>?> pollPaymentStatus(String paymentId, {int maxAttempts = 10}) async {
    print('Starting to poll payment status for: $paymentId');
    
    for (int i = 0; i < maxAttempts; i++) {
      print('Polling attempt ${i + 1}/$maxAttempts');
      
      try {
        final status = await getPaymentStatus(paymentId);
        
        if (status != null) {
          print('Payment status: ${status['status']}');
          if (status['status'] == 'paid') {
            print('Payment confirmed as paid!');
            return status;
          }
        } else {
          print('No payment data found yet');
        }
      } catch (e) {
        print('Error polling payment status: $e');
      }
      
      // Wait 3 seconds before next attempt
      await Future.delayed(Duration(seconds: 3));
    }
    
    print('Payment polling timed out after $maxAttempts attempts');
    return null;
  }

  // Check if order already exists
  Future<bool> orderExists(String paymentId) async {
    try {
      final response = await _supabase
          .from('store_orders')
          .select('id')
          .eq('payment_id', paymentId)
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get user's payment history
  Future<List<Map<String, dynamic>>> getUserPaymentHistory(String userId) async {
    try {
      final response = await _supabase
          .from('chargily_payments')
          .select()
          .contains('metadata', {'userId': userId})
          .order('created_at', ascending: false);
      
      return response;
    } catch (e) {
      print('Error getting user payment history: $e');
      return [];
    }
  }
}
