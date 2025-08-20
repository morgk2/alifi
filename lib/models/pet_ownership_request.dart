import 'package:cloud_firestore/cloud_firestore.dart';

class PetOwnershipRequest {
  final String id;
  final String petId;
  final String petName;
  final String petBreed;
  final double petAge;
  final String? petPhotoUrl;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? message;

  PetOwnershipRequest({
    required this.id,
    required this.petId,
    required this.petName,
    required this.petBreed,
    required this.petAge,
    this.petPhotoUrl,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.message,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'petName': petName,
      'petBreed': petBreed,
      'petAge': petAge,
      'petPhotoUrl': petPhotoUrl,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'message': message,
    };
  }

  factory PetOwnershipRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PetOwnershipRequest(
      id: doc.id,
      petId: data['petId'] ?? '',
      petName: data['petName'] ?? '',
      petBreed: data['petBreed'] ?? '',
      petAge: (data['petAge'] as num?)?.toDouble() ?? 0.0,
      petPhotoUrl: data['petPhotoUrl'],
      fromUserId: data['fromUserId'] ?? '',
      fromUserName: data['fromUserName'] ?? '',
      toUserId: data['toUserId'] ?? '',
      toUserName: data['toUserName'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
      message: data['message'],
    );
  }

  PetOwnershipRequest copyWith({
    String? id,
    String? petId,
    String? petName,
    String? petBreed,
    double? petAge,
    String? petPhotoUrl,
    String? fromUserId,
    String? fromUserName,
    String? toUserId,
    String? toUserName,
    String? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? message,
  }) {
    return PetOwnershipRequest(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petBreed: petBreed ?? this.petBreed,
      petAge: petAge ?? this.petAge,
      petPhotoUrl: petPhotoUrl ?? this.petPhotoUrl,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message ?? this.message,
    );
  }
}


