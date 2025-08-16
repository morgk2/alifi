import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import '../models/order.dart' as store_order;

Future<void> testStoreOrder() async {
  try {
    print('🧪 Testing store order creation...');
    
    // Test data
    const testUserId = 'EN21gie1Lpd7qe4WXvZudSNdaVG2'; // Replace with actual user ID
    const testStoreId = 'your_store_id_here'; // Replace with actual store ID
    const testProductId = 'TTes51qRzj4XfY6d5ZWi'; // Replace with actual product ID
    
    print('🔍 Test data:');
    print('  - User ID: $testUserId');
    print('  - Store ID: $testStoreId');
    print('  - Product ID: $testProductId');
    
    // Get store name
    String storeName = 'Test Store';
    try {
      final storeDoc = await FirebaseFirestore.instance.collection('users').doc(testStoreId).get();
      if (storeDoc.exists) {
        final storeData = storeDoc.data() as Map<String, dynamic>;
        storeName = storeData['displayName'] as String? ?? 'Test Store';
        print('✅ Found store name: $storeName');
      } else {
        print('❌ Store not found: $testStoreId');
        return;
      }
    } catch (e) {
      print('❌ Error getting store: $e');
      return;
    }
    
    // Get product info
    String productName = 'Test Product';
    String productImageUrl = '';
    double productPrice = 100.0;
    
    try {
      final productDoc = await FirebaseFirestore.instance.collection('products').doc(testProductId).get();
      if (productDoc.exists) {
        final productData = productDoc.data() as Map<String, dynamic>;
        productName = productData['name'] as String? ?? 'Test Product';
        productPrice = (productData['price'] as num?)?.toDouble() ?? 100.0;
        final imageUrls = productData['imageUrls'] as List<dynamic>?;
        productImageUrl = imageUrls?.isNotEmpty == true ? imageUrls!.first.toString() : '';
        print('✅ Found product: $productName, price: $productPrice');
      } else {
        print('❌ Product not found: $testProductId');
        return;
      }
    } catch (e) {
      print('❌ Error getting product: $e');
      return;
    }
    
    // Create test order
    final order = store_order.StoreOrder(
      id: '',
      customerId: testUserId,
      customerName: 'Test Customer',
      storeId: testStoreId,
      storeName: storeName,
      productId: testProductId,
      productName: productName,
      productImageUrl: productImageUrl,
      price: productPrice,
      quantity: 1,
      status: 'pending',
      createdAt: DateTime.now(),
      chatMessageId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      notes: 'Test order from script',
    );
    
    print('🔍 Creating test order...');
    final orderId = await DatabaseService().createOrder(order);
    print('✅ Test order created: $orderId');
    
    // Create test chat message
    final chatMessageData = {
      'senderId': testUserId,
      'receiverId': testStoreId,
      'message': 'Test order message for $productName. Order ID: $orderId',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'productAttachment': {
        'id': testProductId,
        'name': productName,
        'price': productPrice,
        'imageUrl': productImageUrl,
      },
      'isOrderAttachment': true,
      'orderId': orderId,
      'paymentMethod': 'Test',
      'paymentStatus': 'paid',
    };
    
    print('🔍 Creating test chat message...');
    final chatMessageRef = await FirebaseFirestore.instance.collection('chat_messages').add(chatMessageData);
    print('✅ Test chat message created: ${chatMessageRef.id}');
    
    print('🎉 Test completed successfully!');
    print('Check your orders and messages to see if the test order appears.');
    
  } catch (e) {
    print('❌ Test failed: $e');
  }
}











