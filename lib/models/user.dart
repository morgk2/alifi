import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class User {
  final String id;
  final String email;
  final String? displayName;
  final String? username;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, bool> linkedAccounts;
  final bool isAdmin;
  final String accountType;
  final bool isVerified;
  final String? basicInfo;
  final List<String>? patients;
  final double rating;
  final int totalOrders;
  final List<String>? pets;
  final List<String> followers;
  final List<String> following;
  final int followersCount;
  final int followingCount;
  final List<String> searchTokens;
  final List<String>? products;
  final LatLng? location;  // Added location property
  final List<Map<String, dynamic>>? reviews;  // Added reviews field
  final Map<String, dynamic>? defaultAddress;  // Added default address field
  final List<Map<String, dynamic>>? addresses;  // Added multiple addresses field
  final double dailyRevenue;  // Daily revenue for sellers
  final double totalRevenue;  // Total lifetime revenue for sellers
  final DateTime? lastRevenueUpdate;  // Last time revenue was updated

  String? get firstName => displayName?.split(' ').first;
  String? get lastName => displayName != null && displayName!.split(' ').length > 1 
    ? displayName!.split(' ').sublist(1).join(' ') 
    : null;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.username,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    required this.linkedAccounts,
    this.isAdmin = false,
    this.accountType = 'normal',
    this.isVerified = false,
    this.basicInfo,
    this.patients,
    this.rating = 0.0,
    this.totalOrders = 0,
    this.pets,
    List<String>? followers,
    List<String>? following,
    this.followersCount = 0,
    this.followingCount = 0,
    List<String>? searchTokens,
    this.products,
    this.location,  // Added location parameter
    this.reviews,  // Added reviews parameter
    this.defaultAddress,  // Added default address parameter
    this.addresses,  // Added multiple addresses parameter
    this.dailyRevenue = 0.0,  // Added daily revenue parameter
    this.totalRevenue = 0.0,  // Added total revenue parameter
    this.lastRevenueUpdate,  // Added last revenue update parameter
  }) : 
    this.followers = followers ?? [],
    this.following = following ?? [],
    this.searchTokens = searchTokens ?? [];

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'username': username,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'linkedAccounts': linkedAccounts,
      'isAdmin': isAdmin,
      'accountType': accountType,
      'isVerified': isVerified,
      'basicInfo': basicInfo,
      'patients': patients,
      'rating': rating,
      'totalOrders': totalOrders,
      'pets': pets,
      'followers': followers,
      'following': following,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'searchTokens': searchTokens,
      'products': products,
      'location': location != null ? {
        'latitude': location!.latitude,
        'longitude': location!.longitude,
      } : null,  // Added location to Firestore data
      'reviews': reviews,  // Added reviews to Firestore data
      'defaultAddress': defaultAddress,  // Added default address to Firestore data
      'addresses': addresses,  // Added multiple addresses to Firestore data
      'dailyRevenue': dailyRevenue,  // Added daily revenue to Firestore data
      'totalRevenue': totalRevenue,  // Added total revenue to Firestore data
      'lastRevenueUpdate': lastRevenueUpdate != null ? Timestamp.fromDate(lastRevenueUpdate!) : null,  // Added last revenue update to Firestore data
    };
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse location data
    LatLng? location;
    if (data['location'] != null) {
      final locationData = data['location'] as Map<String, dynamic>;
      location = LatLng(
        locationData['latitude'] as double,
        locationData['longitude'] as double,
      );
    }

    // Handle displayName safely - convert empty strings to null
    final rawDisplayName = data['displayName'];
    final displayName = (rawDisplayName is String && rawDisplayName.trim().isEmpty) ? null : rawDisplayName;
    
    print('🔍 [User.fromFirestore] Raw displayName: "$rawDisplayName"');
    print('🔍 [User.fromFirestore] Raw displayName type: ${rawDisplayName.runtimeType}');
    print('🔍 [User.fromFirestore] Processed displayName: "$displayName"');
    print('🔍 [User.fromFirestore] Processed displayName type: ${displayName.runtimeType}');

    return User(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: displayName,
      username: data['username'],
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      linkedAccounts: Map<String, bool>.from(data['linkedAccounts'] ?? {}),
      isAdmin: data['isAdmin'] ?? false,
      accountType: data['accountType'] ?? 'normal',
      isVerified: data['isVerified'] ?? false,
      basicInfo: data['basicInfo'],
      patients: data['patients'] != null ? List<String>.from(data['patients']) : null,
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalOrders: data['totalOrders'] ?? 0,
      pets: data['pets'] != null ? List<String>.from(data['pets']) : null,
      followers: data['followers'] != null ? List<String>.from(data['followers']) : null,
      following: data['following'] != null ? List<String>.from(data['following']) : null,
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      searchTokens: data['searchTokens'] != null ? List<String>.from(data['searchTokens']) : null,
      products: data['products'] != null ? List<String>.from(data['products']) : null,
      location: location,  // Added location to factory constructor
      reviews: data['reviews'] != null ? List<Map<String, dynamic>>.from(data['reviews']) : null,  // Added reviews to factory constructor
      defaultAddress: data['defaultAddress'] != null ? Map<String, dynamic>.from(data['defaultAddress']) : null,  // Added default address to factory constructor
      addresses: data['addresses'] != null ? List<Map<String, dynamic>>.from(data['addresses']) : null,  // Added multiple addresses to factory constructor
      dailyRevenue: (data['dailyRevenue'] ?? 0.0).toDouble(),  // Added daily revenue to factory constructor
      totalRevenue: (data['totalRevenue'] ?? 0.0).toDouble(),  // Added total revenue to factory constructor
      lastRevenueUpdate: (data['lastRevenueUpdate'] as Timestamp?)?.toDate(),  // Added last revenue update to factory constructor
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
    bool? isAdmin,
    String? accountType,
    bool? isVerified,
    String? basicInfo,
    List<String>? patients,
    double? rating,
    int? totalOrders,
    List<String>? pets,
    List<String>? followers,
    List<String>? following,
    int? followersCount,
    int? followingCount,
    List<String>? searchTokens,
    List<String>? products,
    LatLng? location,  // Added location to copyWith
    List<Map<String, dynamic>>? reviews,  // Added reviews to copyWith
    Map<String, dynamic>? defaultAddress,  // Added default address to copyWith
    List<Map<String, dynamic>>? addresses,  // Added multiple addresses to copyWith
    double? dailyRevenue,  // Added daily revenue to copyWith
    double? totalRevenue,  // Added total revenue to copyWith
    DateTime? lastRevenueUpdate,  // Added last revenue update to copyWith
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
      isAdmin: isAdmin ?? this.isAdmin,
      accountType: accountType ?? this.accountType,
      isVerified: isVerified ?? this.isVerified,
      basicInfo: basicInfo ?? this.basicInfo,
      patients: patients ?? this.patients,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      pets: pets ?? this.pets,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      searchTokens: searchTokens ?? this.searchTokens,
      products: products ?? this.products,
      location: location ?? this.location,  // Added location to copyWith
      reviews: reviews ?? this.reviews,  // Added reviews to copyWith
      defaultAddress: defaultAddress ?? this.defaultAddress,  // Added default address to copyWith
      addresses: addresses ?? this.addresses,  // Added multiple addresses to copyWith
      dailyRevenue: dailyRevenue ?? this.dailyRevenue,  // Added daily revenue to copyWith
      totalRevenue: totalRevenue ?? this.totalRevenue,  // Added total revenue to copyWith
      lastRevenueUpdate: lastRevenueUpdate ?? this.lastRevenueUpdate,  // Added last revenue update to copyWith
    );
  }
} 