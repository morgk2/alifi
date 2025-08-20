import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? productAttachment;
  final bool isOrderAttachment;
  final Map<String, dynamic>? petIdentification;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.productAttachment,
    this.isOrderAttachment = false,
    this.petIdentification,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'productAttachment': productAttachment,
      'isOrderAttachment': isOrderAttachment,
      'petIdentification': petIdentification,
    };
  }

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      productAttachment: data['productAttachment'],
      isOrderAttachment: data['isOrderAttachment'] ?? false,
      petIdentification: data['petIdentification'],
    );
  }
} 