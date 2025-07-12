import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? username;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, bool> linkedAccounts;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.username,
    required this.createdAt,
    required this.lastLoginAt,
    required this.linkedAccounts,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      username: data['username'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      linkedAccounts: Map<String, bool>.from(data['linkedAccounts'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'username': username,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'linkedAccounts': linkedAccounts,
    };
  }

  User copyWith({
    String? email,
    String? displayName,
    String? photoURL,
    String? username,
    DateTime? lastLoginAt,
    Map<String, bool>? linkedAccounts,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      username: username ?? this.username,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
    );
  }
} 