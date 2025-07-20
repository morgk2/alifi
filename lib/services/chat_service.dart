import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      isUser: data['isUser'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream<List<ChatMessage>> getChatMessages(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chat_messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
        });
  }

  Future<void> addMessage(String userId, ChatMessage message) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('chat_messages')
        .add(message.toFirestore());
  }

  Future<void> clearChat(String userId) async {
    final messages = await _firestore
        .collection('users')
        .doc(userId)
        .collection('chat_messages')
        .get();

    final batch = _firestore.batch();
    for (var message in messages.docs) {
      batch.delete(message.reference);
    }
    await batch.commit();
  }
} 