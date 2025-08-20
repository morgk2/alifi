import 'package:cloud_firestore/cloud_firestore.dart';

class PetPost {
  final String id;
  final String petId;
  final String userId; // User who posted
  final String imageUrl;
  final String? caption;
  final List<String> likes;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  PetPost({
    required this.id,
    required this.petId,
    required this.userId,
    required this.imageUrl,
    this.caption,
    this.likes = const [],
    this.likesCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'userId': userId,
      'imageUrl': imageUrl,
      'caption': caption,
      'likes': likes,
      'likesCount': likesCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory PetPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PetPost(
      id: doc.id,
      petId: data['petId'] ?? '',
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'],
      likes: List<String>.from(data['likes'] ?? []),
      likesCount: data['likesCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  PetPost copyWith({
    String? id,
    String? petId,
    String? userId,
    String? imageUrl,
    String? caption,
    List<String>? likes,
    int? likesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetPost(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


