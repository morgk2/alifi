import 'package:cloud_firestore/cloud_firestore.dart';

class StoreOrder {
  final String id;
  final String customerId;
  final String customerName;
  final String storeId;
  final String storeName;
  final String productId;
  final String productName;
  final String productImageUrl;
  final double price;
  final int quantity;
  final String status; // 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final String chatMessageId; // Reference to the chat message that created this order

  StoreOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.storeId,
    required this.storeName,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.price,
    required this.quantity,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    required this.chatMessageId,
  });

  factory StoreOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoreOrder(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      storeId: data['storeId'] ?? '',
      storeName: data['storeName'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productImageUrl: data['productImageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'],
      chatMessageId: data['chatMessageId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'storeId': storeId,
      'storeName': storeName,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'price': price,
      'quantity': quantity,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'notes': notes,
      'chatMessageId': chatMessageId,
    };
  }

  StoreOrder copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? storeId,
    String? storeName,
    String? productId,
    String? productName,
    String? productImageUrl,
    double? price,
    int? quantity,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? chatMessageId,
  }) {
    return StoreOrder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      chatMessageId: chatMessageId ?? this.chatMessageId,
    );
  }
} 