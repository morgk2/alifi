import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class User {
  final String id;
  final String email;
  final String? displayName;
  final String? username;
  final String? photoURL;
  final String? coverPhotoURL;
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
  final int petsRescued;  // Number of pets rescued by normal users
  
  // Subscription fields
  final String? subscriptionPlan;  // 'alifi verified', 'alifi affiliated', 'alifi favorite', or null for no subscription
  final String? subscriptionStatus;  // 'active', 'cancelled', 'expired', 'pending'
  final DateTime? subscriptionStartDate;  // When the subscription started
  final DateTime? nextBillingDate;  // Next billing date
  final DateTime? lastBillingDate;  // Last billing date
  final String? paymentMethod;  // 'Cash payment', 'Credit Card', 'Bank Transfer', etc.
  final double? subscriptionAmount;  // Monthly/annual amount
  final String? subscriptionCurrency;  // 'DZD', 'USD', etc.
  final String? subscriptionInterval;  // 'monthly', 'yearly'

  // Business-related fields for vet and store accounts
  final String? businessFirstName;  // First name for business accounts
  final String? businessLastName;   // Last name for business accounts
  final String? businessName;  // Generic business name (clinic/store name)
  final String? businessLocation;  // Generic business location
  final String? city;  // City for business accounts
  final String? phone;  // Phone for business accounts
  final String? clinicName;  // Specific to vet accounts
  final String? clinicLocation;  // Specific to vet accounts
  final String? storeName;  // Specific to store accounts
  final String? storeLocation;  // Specific to store accounts
  
  // Social media fields
  final Map<String, String>? socialMedia;  // Social media usernames/links

  String? get firstName => businessFirstName ?? displayName?.split(' ').first;
  String? get lastName => businessLastName ?? (displayName != null && displayName!.split(' ').length > 1 
    ? displayName!.split(' ').sublist(1).join(' ') 
    : null);

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.username,
    this.photoURL,
    this.coverPhotoURL,
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
    this.petsRescued = 0,  // Added pets rescued parameter
    this.subscriptionPlan,  // Added subscription plan parameter
    this.subscriptionStatus,  // Added subscription status parameter
    this.subscriptionStartDate,  // Added subscription start date parameter
    this.nextBillingDate,  // Added next billing date parameter
    this.lastBillingDate,  // Added last billing date parameter
    this.paymentMethod,  // Added payment method parameter
    this.subscriptionAmount,  // Added subscription amount parameter
    this.subscriptionCurrency,  // Added subscription currency parameter
    this.subscriptionInterval,  // Added subscription interval parameter
    this.businessFirstName,  // Added business first name parameter
    this.businessLastName,  // Added business last name parameter
    this.businessName,  // Added business name parameter
    this.businessLocation,  // Added business location parameter
    this.city,  // Added city parameter
    this.phone,  // Added phone parameter
    this.clinicName,  // Added clinic name parameter
    this.clinicLocation,  // Added clinic location parameter
    this.storeName,  // Added store name parameter
    this.storeLocation,  // Added store location parameter
    this.socialMedia,  // Added social media parameter
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
      'coverPhotoURL': coverPhotoURL,
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
      'petsRescued': petsRescued,  // Added pets rescued to Firestore data
      'subscriptionPlan': subscriptionPlan,  // Added subscription plan to Firestore data
      'subscriptionStatus': subscriptionStatus,  // Added subscription status to Firestore data
      'subscriptionStartDate': subscriptionStartDate != null ? Timestamp.fromDate(subscriptionStartDate!) : null,  // Added subscription start date to Firestore data
      'nextBillingDate': nextBillingDate != null ? Timestamp.fromDate(nextBillingDate!) : null,  // Added next billing date to Firestore data
      'lastBillingDate': lastBillingDate != null ? Timestamp.fromDate(lastBillingDate!) : null,  // Added last billing date to Firestore data
      'paymentMethod': paymentMethod,  // Added payment method to Firestore data
      'subscriptionAmount': subscriptionAmount,  // Added subscription amount to Firestore data
      'subscriptionCurrency': subscriptionCurrency,  // Added subscription currency to Firestore data
      'subscriptionInterval': subscriptionInterval,  // Added subscription interval to Firestore data
      'businessFirstName': businessFirstName,  // Added business first name to Firestore data
      'businessLastName': businessLastName,  // Added business last name to Firestore data
      'businessName': businessName,  // Added business name to Firestore data
      'businessLocation': businessLocation,  // Added business location to Firestore data
      'city': city,  // Added city to Firestore data
      'phone': phone,  // Added phone to Firestore data
      'clinicName': clinicName,  // Added clinic name to Firestore data
      'clinicLocation': clinicLocation,  // Added clinic location to Firestore data
      'storeName': storeName,  // Added store name to Firestore data
      'storeLocation': storeLocation,  // Added store location to Firestore data
      'socialMedia': socialMedia,  // Added social media to Firestore data
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
      petsRescued: data['petsRescued'] ?? 0,  // Added pets rescued to factory constructor
      subscriptionPlan: data['subscriptionPlan'],  // Added subscription plan to factory constructor
      subscriptionStatus: data['subscriptionStatus'],  // Added subscription status to factory constructor
      subscriptionStartDate: (data['subscriptionStartDate'] as Timestamp?)?.toDate(),  // Added subscription start date to factory constructor
      nextBillingDate: (data['nextBillingDate'] as Timestamp?)?.toDate(),  // Added next billing date to factory constructor
      lastBillingDate: (data['lastBillingDate'] as Timestamp?)?.toDate(),  // Added last billing date to factory constructor
      paymentMethod: data['paymentMethod'],  // Added payment method to factory constructor
      subscriptionAmount: (data['subscriptionAmount'] ?? 0.0).toDouble(),  // Added subscription amount to factory constructor
      subscriptionCurrency: data['subscriptionCurrency'],  // Added subscription currency to factory constructor
      subscriptionInterval: data['subscriptionInterval'],  // Added subscription interval to factory constructor
      businessFirstName: data['businessFirstName'],  // Added business first name to factory constructor
      businessLastName: data['businessLastName'],  // Added business last name to factory constructor
      businessName: data['businessName'],  // Added business name to factory constructor
      businessLocation: data['businessLocation'],  // Added business location to factory constructor
      city: data['city'],  // Added city to factory constructor
      phone: data['phone'],  // Added phone to factory constructor
      clinicName: data['clinicName'],  // Added clinic name to factory constructor
      clinicLocation: data['clinicLocation'],  // Added clinic location to factory constructor
      storeName: data['storeName'],  // Added store name to factory constructor
      storeLocation: data['storeLocation'],  // Added store location to factory constructor
      socialMedia: data['socialMedia'] != null ? Map<String, String>.from(data['socialMedia']) : null,  // Added social media to factory constructor
      coverPhotoURL: data['coverPhotoURL'],
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? username,
    String? photoURL,
    String? coverPhotoURL,
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
    int? petsRescued,  // Added pets rescued to copyWith
    String? subscriptionPlan,  // Added subscription plan to copyWith
    String? subscriptionStatus,  // Added subscription status to copyWith
    DateTime? subscriptionStartDate,  // Added subscription start date to copyWith
    DateTime? nextBillingDate,  // Added next billing date to copyWith
    DateTime? lastBillingDate,  // Added last billing date to copyWith
    String? paymentMethod,  // Added payment method to copyWith
    double? subscriptionAmount,  // Added subscription amount to copyWith
    String? subscriptionCurrency,  // Added subscription currency to copyWith
    String? subscriptionInterval,  // Added subscription interval to copyWith
    String? businessFirstName,  // Added business first name to copyWith
    String? businessLastName,  // Added business last name to copyWith
    String? businessName,  // Added business name to copyWith
    String? businessLocation,  // Added business location to copyWith
    String? city,  // Added city to copyWith
    String? phone,  // Added phone to copyWith
    String? clinicName,  // Added clinic name to copyWith
    String? clinicLocation,  // Added clinic location to copyWith
    String? storeName,  // Added store name to copyWith
    String? storeLocation,  // Added store location to copyWith
    Map<String, String>? socialMedia,  // Added social media to copyWith
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoURL: photoURL ?? this.photoURL,
      coverPhotoURL: coverPhotoURL ?? this.coverPhotoURL,
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
      petsRescued: petsRescued ?? this.petsRescued,  // Added pets rescued to copyWith
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,  // Added subscription plan to copyWith
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,  // Added subscription status to copyWith
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,  // Added subscription start date to copyWith
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,  // Added next billing date to copyWith
      lastBillingDate: lastBillingDate ?? this.lastBillingDate,  // Added last billing date to copyWith
      paymentMethod: paymentMethod ?? this.paymentMethod,  // Added payment method to copyWith
      subscriptionAmount: subscriptionAmount ?? this.subscriptionAmount,  // Added subscription amount to copyWith
      subscriptionCurrency: subscriptionCurrency ?? this.subscriptionCurrency,  // Added subscription currency to copyWith
      subscriptionInterval: subscriptionInterval ?? this.subscriptionInterval,  // Added subscription interval to copyWith
      businessFirstName: businessFirstName ?? this.businessFirstName,  // Added business first name to copyWith
      businessLastName: businessLastName ?? this.businessLastName,  // Added business last name to copyWith
      businessName: businessName ?? this.businessName,  // Added business name to copyWith
      businessLocation: businessLocation ?? this.businessLocation,  // Added business location to copyWith
      city: city ?? this.city,  // Added city to copyWith
      phone: phone ?? this.phone,  // Added phone to copyWith
      clinicName: clinicName ?? this.clinicName,  // Added clinic name to copyWith
      clinicLocation: clinicLocation ?? this.clinicLocation,  // Added clinic location to copyWith
      storeName: storeName ?? this.storeName,  // Added store name to copyWith
      storeLocation: storeLocation ?? this.storeLocation,  // Added store location to copyWith
      socialMedia: socialMedia ?? this.socialMedia,  // Added social media to copyWith
    );
  }
} 