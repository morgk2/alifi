import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String? displayName;
  final String? username;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, bool> linkedAccounts;
  final List<String> followers;
  final List<String> following;
  final int followersCount;
  final int followingCount;
  final List<String> pets;
  final int level;
  final int petsRescued;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.username,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    required this.linkedAccounts,
    this.followers = const [],
    this.following = const [],
    this.followersCount = 0,
    this.followingCount = 0,
    this.pets = const [],
    this.level = 1,
    this.petsRescued = 0,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'username': username,
      'username_lower': username?.toLowerCase(),
      'displayName_lower': displayName?.toLowerCase(),
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'linkedAccounts': linkedAccounts,
      'followers': followers,
      'following': following,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'pets': pets,
      'level': level,
      'petsRescued': petsRescued,
    };
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Handle timestamps that might be null (during document creation)
    DateTime getTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    return User(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      username: data['username'],
      photoURL: data['photoURL'],
      createdAt: getTimestamp(data['createdAt']),
      lastLoginAt: getTimestamp(data['lastLoginAt']),
      linkedAccounts: Map<String, bool>.from(data['linkedAccounts'] ?? {}),
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      pets: List<String>.from(data['pets'] ?? []),
      level: data['level'] ?? 1,
      petsRescued: data['petsRescued'] ?? 0,
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? username,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, bool>? linkedAccounts,
    List<String>? followers,
    List<String>? following,
    int? followersCount,
    int? followingCount,
    List<String>? pets,
    int? level,
    int? petsRescued,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      pets: pets ?? this.pets,
      level: level ?? this.level,
      petsRescued: petsRescued ?? this.petsRescued,
    );
  }
} 