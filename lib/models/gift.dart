import 'package:cloud_firestore/cloud_firestore.dart';

class Gift {
  final String id;
  final String gifterId;
  final String gifterName;
  final String? gifterPhotoUrl;
  final String gifteeId;
  final String productId;
  final String productName;
  final String productImageUrl;
  final String productType; // 'store' or 'aliexpress'
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;
  final DateTime? updatedAt;

  Gift({
    required this.id,
    required this.gifterId,
    required this.gifterName,
    this.gifterPhotoUrl,
    required this.gifteeId,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.productType,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Gift.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Gift(
      id: doc.id,
      gifterId: data['gifterId'],
      gifterName: data['gifterName'],
      gifterPhotoUrl: data['gifterPhotoUrl'],
      gifteeId: data['gifteeId'],
      productId: data['productId'],
      productName: data['productName'],
      productImageUrl: data['productImageUrl'],
      productType: data['productType'],
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gifterId': gifterId,
      'gifterName': gifterName,
      'gifterPhotoUrl': gifterPhotoUrl,
      'gifteeId': gifteeId,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'productType': productType,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
} 