import 'package:cloud_firestore/cloud_firestore.dart';

class PetProfile {
  final String id;
  final String petId;
  final String petName;
  final String? profilePictureUrl;
  final String? bio;
  final List<String> followers;
  final List<String> following;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  PetProfile({
    required this.id,
    required this.petId,
    required this.petName,
    this.profilePictureUrl,
    this.bio,
    required this.followers,
    required this.following,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'petId': petId,
      'petName': petName,
      'profilePictureUrl': profilePictureUrl,
      'bio': bio,
      'followers': followers,
      'following': following,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory PetProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PetProfile(
      id: doc.id,
      petId: data['petId'] ?? '',
      petName: data['petName'] ?? '',
      profilePictureUrl: data['profilePictureUrl'],
      bio: data['bio'],
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      postsCount: data['postsCount'] ?? 0,
      isPublic: data['isPublic'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  PetProfile copyWith({
    String? id,
    String? petId,
    String? petName,
    String? profilePictureUrl,
    String? bio,
    List<String>? followers,
    List<String>? following,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetProfile(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


