import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:latlong2/latlong.dart' show Distance, LengthUnit;
import '../models/user.dart';
import '../models/pet.dart';
import '../models/lost_pet.dart';
import '../models/store_product.dart';
import 'local_storage_service.dart';
import 'package:uuid/uuid.dart';
import '../models/aliexpress_product.dart';
import '../models/marketplace_product.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert'; // Added for json.decode
import 'package:http/http.dart' as http; // Added for http.get
import 'package:alifi/models/gift.dart';
import '../models/chat_message.dart';
import '../models/order.dart' as store_order;
import 'notification_service.dart';
import '../models/notification.dart';
import '../models/appointment.dart';
import '../models/time_slot.dart';
import '../models/adoption_listing.dart';
import '../services/device_performance.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'storage_service.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();
  late final DevicePerformance _devicePerformance;
  late bool _isLowEndDevice;
  
  // Cache for frequently accessed data
  final Map<String, dynamic> _cache = {};
  final Duration _cacheExpiry = const Duration(minutes: 5);

  DatabaseService() {
    _devicePerformance = DevicePerformance();
    _isLowEndDevice = _devicePerformance.performanceTier == PerformanceTier.low;
  }

  // Get appropriate limit based on device performance
  int _getOptimizedLimit(int defaultLimit) {
    return _isLowEndDevice ? (defaultLimit ~/ 2) : defaultLimit;
  }

  // Cache management
  void _setCache(String key, dynamic data) {
    _cache[key] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
  }

  dynamic _getCache(String key) {
    final cached = _cache[key];
    if (cached != null) {
      final timestamp = cached['timestamp'] as DateTime;
      if (DateTime.now().difference(timestamp) < _cacheExpiry) {
        return cached['data'];
      }
    }
    return null;
  }

  void _clearCache() {
    _cache.clear();
  }

  // Collections
  CollectionReference get _usersCollection => _db.collection('users');
  CollectionReference get _petsCollection => _db.collection('pets');
  CollectionReference get _lostPetsCollection => _db.collection('lost_pets');
  CollectionReference get _storeProductsCollection => _db.collection('storeproducts');
  CollectionReference get _giftsCollection => _db.collection('gifts');
  CollectionReference get _chatMessagesCollection => _db.collection('chatMessages');
  CollectionReference get _ordersCollection => _db.collection('orders');
  CollectionReference get _appointmentsCollection => _db.collection('appointments');
  CollectionReference get _vetSchedulesCollection => _db.collection('vetSchedules');
  CollectionReference get _subscriptionsCollection => _db.collection('subscriptions');
  CollectionReference get _adoptionListingsCollection => _db.collection('adoption_listings');

  // Wishlist operations
  Future<void> toggleWishlistItem({
    required String userId,
    required String productId,
    required String productType, // 'store' | 'aliexpress'
  }) async {
    try {
      final userDoc = _usersCollection.doc(userId);
      final userSnapshot = await userDoc.get();
      final data = userSnapshot.data() as Map<String, dynamic>? ?? {};
      final List<dynamic> current = (data['wishlist'] as List<dynamic>?) ?? [];

      final entry = {'id': productId, 'type': productType};
      final exists = current.any((e) => e is Map && e['id'] == productId && e['type'] == productType);

      if (exists) {
        // Remove
        final updated = current.where((e) => !(e is Map && e['id'] == productId && e['type'] == productType)).toList();
        await userDoc.update({'wishlist': updated});
      } else {
        // Add
        current.add(entry);
        await userDoc.set({'wishlist': current}, SetOptions(merge: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isInWishlist({
    required String userId,
    required String productId,
    required String productType,
  }) async {
    try {
      final snap = await _usersCollection.doc(userId).get();
      final data = snap.data() as Map<String, dynamic>?;
      if (data == null) return false;
      final List<dynamic> current = (data['wishlist'] as List<dynamic>?) ?? [];
      return current.any((e) => e is Map && e['id'] == productId && e['type'] == productType);
    } catch (e) {
      return false;
    }
  }

  // Single document for all locations in 'locations' collection
  DocumentReference get _vetLocationsDoc => _db.collection('locations').doc('vets');
  DocumentReference get _storeLocationsDoc => _db.collection('locations').doc('stores');

  // Add migration method for locations
  Future<void> migrateLocations() async {
    try {
      print('Starting location migration...');
      
      // Create batch for atomic operations
      final batch = _db.batch();
      int operationCount = 0;
      
      // Create the locations document references
      final vetsDoc = _db.collection('locations').doc('vets');
      final storesDoc = _db.collection('locations').doc('stores');
      
      // Get existing locations first
      print('Fetching existing locations...');
      final existingVetsDoc = await vetsDoc.get();
      final existingStoresDoc = await storesDoc.get();
      
      // Extract existing locations
      Map<String, dynamic> existingVetLocations = 
        existingVetsDoc.data()?['locations'] ?? {};
      Map<String, dynamic> existingStoreLocations = 
        existingStoresDoc.data()?['locations'] ?? {};
      
      print('Found ${existingVetLocations.length} existing vet locations');
      print('Found ${existingStoreLocations.length} existing store locations');
      
      // Get all vet locations
      print('Fetching vet locations from old collection...');
      final vetDocs = await _db.collection('vet_locations').get();
      
      // Prepare vet locations data
      Map<String, dynamic> vetLocations = Map.from(existingVetLocations);
      int newVetCount = 0;
      for (var doc in vetDocs.docs) {
        final data = doc.data();
        if (data['location'] != null && !vetLocations.containsKey(doc.id)) {
          // Get place details for each vet
          final details = await _getPlaceDetails(doc.id);
          vetLocations[doc.id] = {
            'location': data['location'],
            'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
            'name': details?['name'] ?? 'Unknown Vet',
            'vicinity': details?['vicinity'] ?? 'Location unavailable',
            'openingHours': details?['opening_hours'],
          };
          newVetCount++;
          print('Added vet: ${details?['name'] ?? 'Unknown Vet'}');
        }
      }
      
      // Set vet locations if there are new ones
      if (newVetCount > 0) {
        batch.set(vetsDoc, {'locations': vetLocations}, SetOptions(merge: true));
        print('Prepared $newVetCount new vet locations');
        operationCount++;
      } else {
        print('No new vet locations to migrate');
      }
      
      // Get all store locations
      print('Fetching store locations from old collection...');
      final storeDocs = await _db.collection('store_locations').get();
      
      // Prepare store locations data
      Map<String, dynamic> storeLocations = Map.from(existingStoreLocations);
      int newStoreCount = 0;
      for (var doc in storeDocs.docs) {
        final data = doc.data();
        if (data['location'] != null && !storeLocations.containsKey(doc.id)) {
          // Get place details for each store
          final details = await _getPlaceDetails(doc.id);
          storeLocations[doc.id] = {
            'location': data['location'],
            'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
            'name': details?['name'] ?? 'Unknown Store',
            'vicinity': details?['vicinity'] ?? 'Location unavailable',
            'openingHours': details?['opening_hours'],
          };
          newStoreCount++;
          print('Added store: ${details?['name'] ?? 'Unknown Store'}');
        }
      }
      
      // Set store locations if there are new ones
      if (newStoreCount > 0) {
        batch.set(storesDoc, {'locations': storeLocations}, SetOptions(merge: true));
        print('Prepared $newStoreCount new store locations');
        operationCount++;
      } else {
        print('No new store locations to migrate');
      }
      
      // Commit the batch if there are any changes
      if (operationCount > 0) {
        print('Committing changes...');
        await batch.commit();
        print('Migration completed successfully');
        print('Total locations after migration:');
        print('- Vets: ${vetLocations.length}');
        print('- Stores: ${storeLocations.length}');
      } else {
        print('No new locations to migrate');
      }
      
    } catch (e) {
      print('Error during migration: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.gomaps.pro/maps/api/place/details/json'
      '?place_id=$placeId'
      '&key=AlzaSylphbmAZJYT82Ie_cY1MVEbiQ4NRUxaqIo'
      '&fields=name,vicinity,opening_hours'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['result'];
        }
      }
    } catch (e) {
      print('Error getting place details: $e');
    }
    return null;
  }

  // User Operations
  Future<void> createUser(User user) async {
    final userData = user.toFirestore();
    
    // Generate search tokens
    final tokens = <String>{};
    if (user.displayName != null) {
      tokens.addAll(_generateSearchTokens(user.displayName!));
    }
    if (user.username != null) {
      tokens.addAll(_generateSearchTokens(user.username!));
    }
    tokens.addAll(_generateSearchTokens(user.email));
    
    // Add search tokens to user data
    userData['searchTokens'] = tokens.toList();
    
    // Add lowercase fields for fallback search queries
    userData['displayName_lower'] = user.displayName?.toLowerCase();
    userData['username_lower'] = user.username?.toLowerCase();
    userData['email_lower'] = user.email.toLowerCase();
    
    await _usersCollection.doc(user.id).set(userData);
  }

  Future<void> updateUser(User user) async {
    final userData = user.toFirestore();
    
    // Generate search tokens
    final tokens = <String>{};
    if (user.displayName != null) {
      tokens.addAll(_generateSearchTokens(user.displayName!));
    }
    if (user.username != null) {
      tokens.addAll(_generateSearchTokens(user.username!));
    }
    tokens.addAll(_generateSearchTokens(user.email));
    
    // Add search tokens to user data
    userData['searchTokens'] = tokens.toList();
    
    // Add lowercase fields for fallback search queries
    userData['displayName_lower'] = user.displayName?.toLowerCase();
    userData['username_lower'] = user.username?.toLowerCase();
    userData['email_lower'] = user.email.toLowerCase();
    
    await _usersCollection.doc(user.id).set(userData, SetOptions(merge: true));
  }

  Future<void> migrateVetUsers() async {
    // Get all vet users
    final snapshot = await _usersCollection
        .where('accountType', isEqualTo: 'vet')
        .get();

    // Update each vet user with default values for new fields if they don't exist
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final updates = <String, dynamic>{};

      // Add basicInfo if it doesn't exist
      if (!data.containsKey('basicInfo')) {
        updates['basicInfo'] = '';
      }

      // Add patients if it doesn't exist
      if (!data.containsKey('patients')) {
        updates['patients'] = [];
      }

      // Add rating if it doesn't exist
      if (!data.containsKey('rating')) {
        updates['rating'] = 0.0;
      }

      // Only update if there are new fields to add
      if (updates.isNotEmpty) {
        await doc.reference.set(updates, SetOptions(merge: true));
      }
    }
  }

  Future<void> updateAllUserCounts() async {
    try {
      print('Starting user counts migration...');
      
      // Limit to recent users to avoid timeout
      final snapshot = await _usersCollection
          .orderBy('lastLoginAt', descending: true)
          .limit(100) // Only process recent 100 users
          .get();
      
      int processedCount = 0;
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          
          // Get the actual arrays
          final followers = List<String>.from(data['followers'] ?? []);
          final following = List<String>.from(data['following'] ?? []);
          
          // Get the current counts
          final currentFollowersCount = data['followersCount'] ?? 0;
          final currentFollowingCount = data['followingCount'] ?? 0;
          
          // Check if counts need updating
          if (currentFollowersCount != followers.length || currentFollowingCount != following.length) {
            await doc.reference.update({
              'followersCount': followers.length,
              'followingCount': following.length,
            });
            processedCount++;
          }
        } catch (e) {
          print('Error updating counts for user ${doc.id}: $e');
          // Continue with next user
        }
      }
      print('User counts migration completed. Updated $processedCount users.');
    } catch (e) {
      print('Error in updateAllUserCounts: $e');
      // Don't rethrow - we don't want to crash the app
    }
  }

  Future<void> updateUserVerificationStatus(String userId, bool isVerified) async {
    await _usersCollection.doc(userId).update({
      'isVerified': isVerified,
    });
  }

  Future<void> updateUserField(String userId, Map<String, dynamic> fields) async {
    await _usersCollection.doc(userId).update(fields);
  }

  Future<void> updateUserAccountType(String userId, String accountType) async {
    if (!['normal', 'store', 'vet'].contains(accountType)) {
      throw ArgumentError('Invalid account type. Must be one of: normal, store, vet');
    }
    await _usersCollection.doc(userId).update({
      'accountType': accountType,
    });
  }

  Future<void> updateUserLocation(String userId, latlong.LatLng location) async {
    try {
      await _usersCollection.doc(userId).update({
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ [DatabaseService] User location updated successfully');
    } catch (e) {
      print('❌ [DatabaseService] Error updating user location: $e');
      rethrow;
    }
  }

  /// Convert a normal user to a vet or store account and create their subscription
  Future<void> convertUserToVetOrStore({
    required String userId,
    required String accountType,
    required String firstName,
    required String lastName,
    required String businessName,
    required String businessLocation,
    required String city,
    required String phone,
    required String subscriptionPlan,
    required double amount,
    required String currency,
    required String paymentMethod,
  }) async {
    if (!['vet', 'store'].contains(accountType)) {
      throw ArgumentError('Invalid account type. Must be one of: vet, store');
    }

    try {
      // Start a transaction to ensure data consistency
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get the user document
        final userDoc = await transaction.get(_usersCollection.doc(userId));
        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData['accountType'] != 'normal') {
          throw Exception('User is already a ${userData['accountType']} account');
        }

        // Update user account type and add business information
        final nextBilling = DateTime.now().add(const Duration(days: 30));
        final updates = <String, dynamic>{
          'accountType': accountType,
          'businessFirstName': firstName,
          'businessLastName': lastName,
          'businessName': businessName,
          'businessLocation': businessLocation,
          'city': city,
          'phone': phone,
          'basicInfo': 'Professional ${accountType == 'vet' ? 'veterinarian' : 'pet store'} in $city',
          'isVerified': true,
          'subscriptionPlan': subscriptionPlan,
          'subscriptionStatus': 'active',
          'subscriptionStartDate': FieldValue.serverTimestamp(),
          'nextBillingDate': Timestamp.fromDate(nextBilling),
          'lastBillingDate': FieldValue.serverTimestamp(),
          'paymentMethod': paymentMethod,
          'subscriptionAmount': amount,
          'subscriptionCurrency': currency,
          'subscriptionInterval': 'monthly',
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Add account-specific fields
        if (accountType == 'vet') {
          updates['clinicName'] = businessName;
          updates['clinicLocation'] = businessLocation;
          updates['patients'] = [];
          updates['rating'] = 0.0;
        } else if (accountType == 'store') {
          updates['storeName'] = businessName;
          updates['storeLocation'] = businessLocation;
          updates['rating'] = 0.0;
        }

        transaction.update(_usersCollection.doc(userId), updates);

        // Create subscription
        final subscriptionData = {
          'userId': userId,
          'plan': subscriptionPlan,
          'status': 'active',
          'amount': amount,
          'currency': currency,
          'interval': 'monthly',
          'paymentMethod': paymentMethod,
          'startDate': FieldValue.serverTimestamp(),
          'nextBillingDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
          'lastBillingDate': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        transaction.set(_subscriptionsCollection.doc(userId), subscriptionData);
      });

      print('✅ [DatabaseService] Successfully converted user $userId to $accountType account');
    } catch (e) {
      print('❌ [DatabaseService] Error converting user to $accountType: $e');
      rethrow;
    }
  }

  Future<List<User>> getAllUsers({int limit = 50, DocumentSnapshot? startAfter}) async {
    Query query = _usersCollection.orderBy('lastLoginAt', descending: true).limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
  }

  Future<User?> getUser(String userId) async {
    print('🔍 [DatabaseService] getUser called with userId: $userId');
    try {
      final doc = await _usersCollection.doc(userId).get();
      print('🔍 [DatabaseService] getUser document exists: ${doc.exists}');
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        print('🔍 [DatabaseService] getUser document data: $data');
        print('🔍 [DatabaseService] getUser displayName from data: ${data?['displayName']}');
        print('🔍 [DatabaseService] getUser displayName type: ${data?['displayName'].runtimeType}');
        
        final user = User.fromFirestore(doc);
        print('🔍 [DatabaseService] getUser created user: ${user.displayName}');
        print('🔍 [DatabaseService] getUser user displayName type: ${user.displayName.runtimeType}');
        return user;
      } else {
        print('🔍 [DatabaseService] getUser document does not exist');
        return null;
      }
    } catch (e) {
      print('🔍 [DatabaseService] getUser ERROR: $e');
      print('🔍 [DatabaseService] getUser ERROR stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Get random vets and stores for recommendations
  Future<List<User>> getRandomVetsAndStores({int limit = 10}) async {
    try {
      final vetQuery = _usersCollection
          .where('accountType', isEqualTo: 'vet')
          .limit(limit ~/ 2);
      
      final storeQuery = _usersCollection
          .where('accountType', isEqualTo: 'store')
          .limit(limit ~/ 2);
      
      final vetSnapshot = await vetQuery.get();
      final storeSnapshot = await storeQuery.get();
      
      final List<User> results = [];
      
      // Add vets
      for (final doc in vetSnapshot.docs) {
        try {
          results.add(User.fromFirestore(doc));
        } catch (e) {
          print('Error parsing vet user: $e');
        }
      }
      
      // Add stores
      for (final doc in storeSnapshot.docs) {
        try {
          results.add(User.fromFirestore(doc));
        } catch (e) {
          print('Error parsing store user: $e');
        }
      }
      
      // Shuffle for randomness
      results.shuffle();
      
      return results;
    } catch (e) {
      print('Error getting random vets and stores: $e');
      return [];
    }
  }

  // Get vets near a specific location
  Future<List<User>> getVetsNearLocation(
    latlong.LatLng location, {
    double radiusKm = 50.0,
  }) async {
    try {
      final distance = const Distance();
      final allVets = await getAllVets();
      
      return allVets.where((vet) {
        if (vet.location == null) return false;
        
        final distanceInKm = distance.as(
          LengthUnit.Kilometer,
          location,
          vet.location!,
        );
        return distanceInKm <= radiusKm;
      }).toList();
    } catch (e) {
      print('Error getting vets near location: $e');
      return [];
    }
  }

  // Get vets by subscription plan
  Future<List<User>> getVetsBySubscription(List<String> subscriptionPlans) async {
    try {
      // First, get all users and filter for vets
      final querySnapshot = await _usersCollection.get();
      final allUsers = querySnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
      
      // Filter for vets with specific subscription plans
      final vets = allUsers.where((user) {
        final accountType = user.accountType.toLowerCase();
        final subscriptionPlan = user.subscriptionPlan?.toLowerCase() ?? '';
        
        // Check if user is a vet (exclude stores)
        final businessName = user.businessName?.toLowerCase() ?? '';
        final clinicName = user.clinicName?.toLowerCase() ?? '';
        final storeName = user.storeName?.toLowerCase() ?? '';
        
        // Explicitly exclude stores
        if (accountType == 'store' || storeName.isNotEmpty) {
          return false;
        }
        
        final isVet = accountType == 'vet' || 
                     accountType == 'veterinary' || 
                     accountType == 'veterinarian' ||
                     businessName.contains('vet') ||
                     businessName.contains('veterinary') ||
                     businessName.contains('clinic') ||
                     clinicName.contains('vet') ||
                     clinicName.contains('veterinary') ||
                     clinicName.contains('clinic');
        
        // Check if user has one of the required subscription plans
        final hasRequiredSubscription = subscriptionPlans.any((plan) => 
          subscriptionPlan.contains(plan.toLowerCase())
        );
        
        return isVet && hasRequiredSubscription;
      }).toList();
      
      return vets;
    } catch (e) {
      print('Error getting vets by subscription: $e');
      return [];
    }
  }

  // Get top vets by rating
  Future<List<User>> getTopVetsByRating({int limit = 10}) async {
    try {
      // First, get all users and filter for vets
      final querySnapshot = await _usersCollection.get();
      final allUsers = querySnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
      
      // Filter for vets only (exclude stores)
      final vets = allUsers.where((user) {
        final accountType = user.accountType.toLowerCase();
        final businessName = user.businessName?.toLowerCase() ?? '';
        final clinicName = user.clinicName?.toLowerCase() ?? '';
        final storeName = user.storeName?.toLowerCase() ?? '';
        
        // Explicitly exclude stores
        if (accountType == 'store' || storeName.isNotEmpty) {
          return false;
        }
        
        // Include only vet-related accounts
        return accountType == 'vet' || 
               accountType == 'veterinary' || 
               accountType == 'veterinarian' ||
               businessName.contains('vet') ||
               businessName.contains('veterinary') ||
               businessName.contains('clinic') ||
               clinicName.contains('vet') ||
               clinicName.contains('veterinary') ||
               clinicName.contains('clinic');
      }).toList();
      
      // Sort by rating
      vets.sort((a, b) => b.rating.compareTo(a.rating));
      
      // Take top limit
      final topVets = vets.take(limit).toList();
      
      return topVets;
    } catch (e) {
      print('Error getting top vets by rating: $e');
      return [];
    }
  }

  // Get top vets by follower count
  Future<List<User>> getTopVetsByFollowers({int limit = 10}) async {
    try {
      // First, get all users and filter for vets
      final querySnapshot = await _usersCollection.get();
      final allUsers = querySnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
      
      // Filter for vets only (exclude stores)
      final vets = allUsers.where((user) {
        final accountType = user.accountType.toLowerCase();
        final businessName = user.businessName?.toLowerCase() ?? '';
        final clinicName = user.clinicName?.toLowerCase() ?? '';
        final storeName = user.storeName?.toLowerCase() ?? '';
        
        // Explicitly exclude stores
        if (accountType == 'store' || storeName.isNotEmpty) {
          return false;
        }
        
        // Include only vet-related accounts
        return accountType == 'vet' || 
               accountType == 'veterinary' || 
               accountType == 'veterinarian' ||
               businessName.contains('vet') ||
               businessName.contains('veterinary') ||
               businessName.contains('clinic') ||
               clinicName.contains('vet') ||
               clinicName.contains('veterinary') ||
               clinicName.contains('clinic');
      }).toList();
      
      print('🔍 [DatabaseService] Total users found: ${allUsers.length}');
      print('🔍 [DatabaseService] Vets found: ${vets.length}');
      
      // Sort by follower count
      vets.sort((a, b) => (b.followersCount).compareTo(a.followersCount));
      
      // Take top limit
      final topVets = vets.take(limit).toList();
      
      print('🔍 [DatabaseService] Top vets by followers: ${topVets.length}');
      for (var vet in topVets) {
        print('🔍 [DatabaseService] Vet: ${vet.displayName}, Followers: ${vet.followersCount}');
      }
      
      return topVets;
    } catch (e) {
      print('Error getting top vets by followers: $e');
      return [];
    }
  }

  // Get all vets
  Future<List<User>> getAllVets() async {
    try {
      // First, get all users and filter for vets
      final querySnapshot = await _usersCollection.get();
      final allUsers = querySnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
      
      // Filter for vets only (exclude stores)
      final vets = allUsers.where((user) {
        final accountType = user.accountType.toLowerCase();
        final businessName = user.businessName?.toLowerCase() ?? '';
        final clinicName = user.clinicName?.toLowerCase() ?? '';
        final storeName = user.storeName?.toLowerCase() ?? '';
        
        // Explicitly exclude stores
        if (accountType == 'store' || storeName.isNotEmpty) {
          return false;
        }
        
        // Include only vet-related accounts
        return accountType == 'vet' || 
               accountType == 'veterinary' || 
               accountType == 'veterinarian' ||
               businessName.contains('vet') ||
               businessName.contains('veterinary') ||
               businessName.contains('clinic') ||
               clinicName.contains('vet') ||
               clinicName.contains('veterinary') ||
               clinicName.contains('clinic');
      }).toList();
      
      return vets;
    } catch (e) {
      print('Error getting all vets: $e');
      return [];
    }
  }

  // User Search Operations
  Future<List<User>> searchUsers({
    String? displayName,
    String? username,
    String? email,
    int limit = 10,
  }) async {
    if ((displayName?.isEmpty ?? true) && 
        (username?.isEmpty ?? true) && 
        (email?.isEmpty ?? true)) {
      return [];
    }

    final searchTerm = (displayName ?? username ?? email ?? '').toLowerCase();
    if (searchTerm.isEmpty) return [];

    // Split the query into words for AND matching
    final queryWords = searchTerm.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final searchTokens = queryWords.expand(_generateSearchTokens).toSet().toList();

    // Fetch a superset of users using arrayContainsAny
    final querySnapshot = await _usersCollection
        .where('searchTokens', arrayContainsAny: searchTokens)
        .get();
    final users = querySnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();

    // Filter: Only include users where ALL query words are present in their tokens
    final filtered = users.where((user) {
      final tokens = user.searchTokens.map((t) => t.toLowerCase()).toSet();
      return queryWords.every((word) =>
        tokens.contains(word) ||
        tokens.contains(word.replaceAll(RegExp(r'[^a-z0-9]'), '')) // ignore punctuation
      );
    }).toList();

    // If not enough results, fall back to prefix and exact matches
    if (filtered.length < limit) {
      final prefixMatches = <User>[];
      final seenIds = filtered.map((u) => u.id).toSet();
      final exactQuery = await _usersCollection
          .where('displayName_lower', isGreaterThanOrEqualTo: searchTerm)
          .where('displayName_lower', isLessThan: searchTerm + '\uf8ff')
          .get();
      for (var doc in exactQuery.docs) {
        final user = User.fromFirestore(doc);
        if (!seenIds.contains(user.id)) prefixMatches.add(user);
      }
      final usernameQuery = await _usersCollection
          .where('username_lower', isGreaterThanOrEqualTo: searchTerm)
          .where('username_lower', isLessThan: searchTerm + '\uf8ff')
          .get();
      for (var doc in usernameQuery.docs) {
        final user = User.fromFirestore(doc);
        if (!seenIds.contains(user.id)) prefixMatches.add(user);
      }
      final emailQuery = await _usersCollection
          .where('email_lower', isGreaterThanOrEqualTo: searchTerm)
          .where('email_lower', isLessThan: searchTerm + '\uf8ff')
          .get();
      for (var doc in emailQuery.docs) {
        final user = User.fromFirestore(doc);
        if (!seenIds.contains(user.id)) prefixMatches.add(user);
      }
      filtered.addAll(prefixMatches);
    }

    // Sort results by relevance
    filtered.sort((a, b) {
      final aName = a.displayName?.toLowerCase() ?? '';
      final bName = b.displayName?.toLowerCase() ?? '';
      final aUsername = a.username?.toLowerCase() ?? '';
      final bUsername = b.username?.toLowerCase() ?? '';
      final aEmail = a.email.toLowerCase();
      final bEmail = b.email.toLowerCase();
      // Exact matches get highest priority
      if (aName == searchTerm && bName != searchTerm) return -1;
      if (bName == searchTerm && aName != searchTerm) return 1;
      if (aUsername == searchTerm && bUsername != searchTerm) return -1;
      if (bUsername == searchTerm && aUsername != searchTerm) return 1;
      if (aEmail == searchTerm && bEmail != searchTerm) return -1;
      if (bEmail == searchTerm && aEmail != searchTerm) return 1;
      // Then sort by starts with
      if (aName.startsWith(searchTerm) && !bName.startsWith(searchTerm)) return -1;
      if (bName.startsWith(searchTerm) && !aName.startsWith(searchTerm)) return 1;
      if (aUsername.startsWith(searchTerm) && !bUsername.startsWith(searchTerm)) return -1;
      if (bUsername.startsWith(searchTerm) && !aUsername.startsWith(searchTerm)) return 1;
      if (aEmail.startsWith(searchTerm) && !bEmail.startsWith(searchTerm)) return -1;
      if (bEmail.startsWith(searchTerm) && !aEmail.startsWith(searchTerm)) return 1;
      // Then sort by contains
      if (aName.contains(searchTerm) && !bName.contains(searchTerm)) return -1;
      if (bName.contains(searchTerm) && !aName.contains(searchTerm)) return 1;
      if (aUsername.contains(searchTerm) && !bUsername.contains(searchTerm)) return -1;
      if (bUsername.contains(searchTerm) && !aUsername.contains(searchTerm)) return 1;
      if (aEmail.contains(searchTerm) && !bEmail.contains(searchTerm)) return -1;
      if (bEmail.contains(searchTerm) && !aEmail.contains(searchTerm)) return 1;
      // Finally sort alphabetically
      return aName.compareTo(bName);
    });

    // Return limited results
    return filtered.take(limit).toList();
  }

  // Helper method to generate search tokens for fuzzy matching
  List<String> _generateSearchTokens(String text) {
    final tokens = <String>{};
    final normalized = text.toLowerCase().trim();
    
    // Add the full normalized text
    tokens.add(normalized);
    
    // Add each word separately
    tokens.addAll(normalized.split(RegExp(r'\s+')));
    
    // Add partial matches (n-grams) for words longer than 3 characters
    if (normalized.length > 3) {
      for (int i = 3; i <= normalized.length; i++) {
        tokens.add(normalized.substring(0, i));
      }
    }
    
    // Add common typo variations for words longer than 3 characters
    if (normalized.length > 3) {
      tokens.addAll(_generateTypoVariations(normalized));
    }
    
    return tokens.toList();
  }

  // Helper method to generate common typo variations
  Set<String> _generateTypoVariations(String text) {
    final variations = <String>{};
    
    // Handle common character substitutions
    final substitutions = {
      'a': ['e'],
      'e': ['a', 'i'],
      'i': ['e', 'y'],
      'o': ['u'],
      'u': ['o'],
      'y': ['i'],
    };
    
    // Generate variations with character substitutions
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final possibleSubstitutions = substitutions[char] ?? [];
      for (final sub in possibleSubstitutions) {
        variations.add(text.substring(0, i) + sub + text.substring(i + 1));
      }
    }
    
    return variations;
  }

  Future<void> updateUserSearchTokens(String userId) async {
    final user = await getUser(userId);
    if (user == null) return;

    final tokens = <String>{};
    
    // Add tokens for display name
    if (user.displayName != null) {
      tokens.addAll(_generateSearchTokens(user.displayName!));
    }
    
    // Add tokens for username
    if (user.username != null) {
      tokens.addAll(_generateSearchTokens(user.username!));
    }
    
    // Add tokens for email
    tokens.addAll(_generateSearchTokens(user.email));

    // Update user document with search tokens and lowercase fields
    await _usersCollection.doc(userId).update({
      'searchTokens': tokens.toList(),
      'displayName_lower': user.displayName?.toLowerCase(),
      'username_lower': user.username?.toLowerCase(),
      'email_lower': user.email.toLowerCase(),
    });
  }

  // Migration function to add missing search fields to existing users
  Future<void> migrateUserSearchFields() async {
    try {
      print('🔄 [DatabaseService] Starting user search fields migration...');
      
      // Get all users in batches
      QuerySnapshot snapshot = await _usersCollection.get();
      int updated = 0;
      int total = snapshot.docs.length;
      
      for (DocumentSnapshot doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) continue;
          
          // Check if user is missing search fields
          final needsUpdate = data['displayName_lower'] == null || 
                             data['username_lower'] == null || 
                             data['email_lower'] == null ||
                             data['searchTokens'] == null;
          
          if (needsUpdate) {
            final user = User.fromFirestore(doc);
            
            // Generate search tokens
            final tokens = <String>{};
            if (user.displayName != null) {
              tokens.addAll(_generateSearchTokens(user.displayName!));
            }
            if (user.username != null) {
              tokens.addAll(_generateSearchTokens(user.username!));
            }
            tokens.addAll(_generateSearchTokens(user.email));
            
            // Update with missing fields
            await _usersCollection.doc(doc.id).update({
              'searchTokens': tokens.toList(),
              'displayName_lower': user.displayName?.toLowerCase(),
              'username_lower': user.username?.toLowerCase(),
              'email_lower': user.email.toLowerCase(),
            });
            
            updated++;
            if (updated % 10 == 0) {
              print('🔄 [DatabaseService] Updated $updated/$total users...');
            }
          }
        } catch (e) {
          print('❌ [DatabaseService] Error updating user ${doc.id}: $e');
        }
      }
      
      print('✅ [DatabaseService] Migration completed: $updated/$total users updated');
    } catch (e) {
      print('❌ [DatabaseService] Migration failed: $e');
      rethrow;
    }
  }

  // User Follow/Unfollow Operations
  Future<void> followUser(String currentUserId, String targetUserId) async {
    final batch = _db.batch();
    
    await _db.runTransaction((transaction) async {
      // Get both user documents
      final currentUserDoc = await transaction.get(_usersCollection.doc(currentUserId));
      final targetUserDoc = await transaction.get(_usersCollection.doc(targetUserId));
      
      if (!currentUserDoc.exists || !targetUserDoc.exists) {
        throw Exception('One or both users do not exist');
      }

      // Get current arrays
      final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
      final targetUserData = targetUserDoc.data() as Map<String, dynamic>;
      
      final following = List<String>.from(currentUserData['following'] ?? []);
      final followers = List<String>.from(targetUserData['followers'] ?? []);
      
      // Check if already following
      if (following.contains(targetUserId)) {
        return; // Already following, no need to do anything
      }
      
      // Add to arrays if not already present
      following.add(targetUserId);
      followers.add(currentUserId);
      
      // Update both documents atomically
      transaction.update(_usersCollection.doc(currentUserId), {
        'following': following,
        'followingCount': following.length,
      });
      
      transaction.update(_usersCollection.doc(targetUserId), {
        'followers': followers,
        'followersCount': followers.length,
      });
    });
    
    // Send follow notification after successful transaction
    try {
      final notificationService = NotificationService();
      final currentUser = await getUser(currentUserId);
      final targetUser = await getUser(targetUserId);
      
      if (currentUser != null && targetUser != null) {
        await notificationService.sendFollowNotification(
          recipientId: targetUserId,
          senderId: currentUserId,
          senderName: currentUser.displayName,
          senderPhotoUrl: currentUser.photoURL,
          isFollowing: true,
        );
        print('🔔 [DatabaseService] Follow notification sent from ${currentUser.displayName} to ${targetUser.displayName}');
      }
    } catch (e) {
      print('🔔 [DatabaseService] Error sending follow notification: $e');
      // Don't throw - we don't want to fail the follow operation if notification fails
    }
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    await _db.runTransaction((transaction) async {
      // Get both user documents
      final currentUserDoc = await transaction.get(_usersCollection.doc(currentUserId));
      final targetUserDoc = await transaction.get(_usersCollection.doc(targetUserId));
      
      if (!currentUserDoc.exists || !targetUserDoc.exists) {
        throw Exception('One or both users do not exist');
      }

      // Get current arrays
      final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
      final targetUserData = targetUserDoc.data() as Map<String, dynamic>;
      
      final following = List<String>.from(currentUserData['following'] ?? []);
      final followers = List<String>.from(targetUserData['followers'] ?? []);
      
      // Check if not following
      if (!following.contains(targetUserId)) {
        return; // Not following, no need to do anything
      }
      
      // Remove from arrays
      following.remove(targetUserId);
      followers.remove(currentUserId);
      
      // Update both documents atomically
      transaction.update(_usersCollection.doc(currentUserId), {
        'following': following,
        'followingCount': following.length,
      });
      
      transaction.update(_usersCollection.doc(targetUserId), {
        'followers': followers,
        'followersCount': followers.length,
      });
    });
    
    // No notification for unfollow - removed as requested
  }

  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    try {
      // Get the target user's document
      final doc = await _usersCollection.doc(targetUserId).get();
      if (!doc.exists) return false;

      // Check if currentUserId is in the followers array
      final data = doc.data() as Map<String, dynamic>;
      final followers = List<String>.from(data['followers'] ?? []);
      return followers.contains(currentUserId);
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  // Stream for real-time follower count
  Stream<int> getFollowerCount(String userId) {
    return _usersCollection
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 0;
          final data = doc.data() as Map<String, dynamic>;
          final followers = List<String>.from(data['followers'] ?? []);
          return followers.length;
        });
  }

  // Stream for real-time user data
  Stream<User?> getUserStream(String userId) {
    return _usersCollection
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? User.fromFirestore(doc) : null);
  }

  // User location operations
  Stream<List<User>> getUsersWithLocation() {
    return _usersCollection
        .where('location', isNull: false)  // Only get users with location data
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromFirestore(doc))
            .toList());
  }

  // Pet Operations
  Future<String> createPet(Pet pet, {bool isGuest = false}) async {
    if (isGuest) {
      final localPet = pet.copyWith(
        id: _uuid.v4(),
        ownerId: 'guest',
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
      );
      await _localStorage.addGuestPet(localPet);
      return localPet.id;
    } else {
      final docRef = await _petsCollection.add(pet.toFirestore());
      return docRef.id;
    }
  }

  Future<void> deletePet(String petId, {bool isGuest = false}) async {
    if (isGuest) {
      await _localStorage.deleteGuestPet(petId);
    } else {
      try {
        // First, get the pet's image URLs before deleting
        final petDoc = await _petsCollection.doc(petId).get();
        if (petDoc.exists) {
          final pet = Pet.fromFirestore(petDoc);
          
                  // Delete pet photos from Supabase storage
        if (pet.imageUrls.isNotEmpty) {
          print('Found ${pet.imageUrls.length} photos to delete for pet: ${pet.name}');
          print('Supabase client: $_supabase');
          final storageService = StorageService(_supabase);
            
            for (final imageUrl in pet.imageUrls) {
              try {
                print('Processing image URL: $imageUrl');
                
                // Extract file path from the URL
                // URL format: https://xxx.supabase.co/storage/v1/object/public/pet-photos/filename.jpg
                final uri = Uri.parse(imageUrl);
                final pathSegments = uri.pathSegments;
                print('Path segments: $pathSegments');
                
                if (pathSegments.length >= 5 && pathSegments[3] == 'public' && pathSegments[4] == 'pet-photos') {
                  final fileName = pathSegments.sublist(5).join('/');
                  print('Extracted filename: $fileName');
                  await storageService.deleteFile(fileName);
                  print('Successfully deleted pet photo: $fileName');
                } else {
                  print('Invalid URL format for Supabase storage. Expected format: /storage/v1/object/public/pet-photos/filename');
                  print('Actual path segments: $pathSegments');
                }
              } catch (e) {
                print('Error deleting pet photo $imageUrl: $e');
                print('Stack trace: ${StackTrace.current}');
                // Continue with other photos even if one fails
              }
            }
          } else {
            print('No photos found for pet: ${pet.name}');
          }
        }
        
        // Now delete the pet document
        await _petsCollection.doc(petId).delete();
        print('Deleted pet document: $petId');
      } catch (e) {
        print('Error deleting pet: $e');
        rethrow;
      }
    }
  }

  Stream<List<Pet>> getUserPets(String userId, {bool isGuest = false}) {
    print('🔍 [DatabaseService] getUserPets called for userId: $userId, isGuest: $isGuest');
    
    if (isGuest) {
      return Stream.fromFuture(_localStorage.getGuestPets());
    } else {
      try {
        return _petsCollection
            .where('ownerId', isEqualTo: userId)
            .where('isActive', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .handleError((error) {
              print('🔍 [DatabaseService] Error in getUserPets stream: $error');
              return [];
            })
            .map((snapshot) {
              print('🔍 [DatabaseService] getUserPets received ${snapshot.docs.length} documents');
              return snapshot.docs.map((doc) {
                try {
                  return Pet.fromFirestore(doc);
                } catch (e) {
                  print('🔍 [DatabaseService] Error parsing pet document ${doc.id}: $e');
                  return null;
                }
              }).where((pet) => pet != null).cast<Pet>().toList();
            });
      } catch (e) {
        print('🔍 [DatabaseService] Exception in getUserPets: $e');
        return Stream.value([]);
      }
    }
  }

  Future<List<Pet>> getPets(List<String> petIds) async {
    if (petIds.isEmpty) return [];
    
    final pets = <Pet>[];
    // Firestore has a limit of 10 items for 'in' queries, so we need to batch
    for (var i = 0; i < petIds.length; i += 10) {
      final batch = petIds.skip(i).take(10).toList();
      final snapshot = await _petsCollection.where(FieldPath.documentId, whereIn: batch).get();
      pets.addAll(snapshot.docs.map((doc) => Pet.fromFirestore(doc)));
    }
    return pets;
  }

  // Lost Pet Operations
  Future<String> reportLostPet({
    required String name,
    required String species,
    required String userId,
    required latlong.LatLng location,
    required String address,
    required String description,
    required List<String> contactNumbers,
    required double reward,
    required DateTime lastSeenDate,
    String? existingPetId, // Add parameter for existing pet ID
  }) async {
    try {
      String petId;
      
      if (existingPetId != null) {
        // Use existing pet
        petId = existingPetId;
        
        // Update the existing pet to mark it as lost
        await _petsCollection.doc(existingPetId).update({
          'tags': FieldValue.arrayUnion(['lost']),
          'lastUpdatedAt': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        // Create a new pet for lost pet report
        final pet = Pet(
          id: '', // Will be set by Firestore
          name: name,
          species: species,
          breed: '', // Default empty for lost pet reports
          color: '', // Default empty for lost pet reports
          age: 0, // Default for lost pet reports
          gender: '', // Default empty for lost pet reports
          imageUrls: [], // No images for lost pet reports
          ownerId: userId,
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          medicalInfo: {}, // Empty for lost pet reports
          dietaryInfo: {}, // Empty for lost pet reports
          tags: ['lost'], // Tag as lost
          isActive: true,
        );

        // Create the pet in Firestore
        final petDocRef = await _petsCollection.add(pet.toFirestore());
        petId = petDocRef.id;
      }

      // Now create the lost pet record
      final lostPetData = {
        'petId': petId,
        'location': GeoPoint(location.latitude, location.longitude),
      'address': address,
        'additionalInfo': description,
        'contactNumbers': contactNumbers,
        'isFound': false,
      'lastSeenDate': Timestamp.fromDate(lastSeenDate),
        'reportedByUserId': userId,
      'reportedDate': Timestamp.fromDate(DateTime.now()),
        'reward': reward,
      };

      // Add to lost_pets collection
      final lostPetDocRef = await _lostPetsCollection.add(lostPetData);
      
      print('Created lost pet report with ID: ${lostPetDocRef.id}'); // Debug log
      return lostPetDocRef.id;
    } catch (e) {
      print('Error reporting lost pet: $e'); // Debug log
      rethrow;
    }
  }

  // Get all lost pets without distance filtering
  Stream<List<LostPet>> getAllLostPets() {
    return _lostPetsCollection
        .where('isFound', isEqualTo: false)
        .snapshots()
        .asyncMap((snapshot) async {
          final pets = <LostPet>[];
          for (var doc in snapshot.docs) {
            try {
              final lostPet = await LostPet.fromFirestore(doc, _db);
              if (lostPet != null) {
                pets.add(lostPet);
              }
            } catch (e) {
              print('Error converting lost pet doc ${doc.id}: $e'); // Debug log
            }
          }
          return pets;
        });
  }

  // Get nearby lost pets with improved map-based distance filtering
  Stream<List<LostPet>> getNearbyLostPets({
    required latlong.LatLng userLocation,
    double radiusInKm = 10,
  }) {
    print('🗺️ [DatabaseService] Getting nearby lost pets for user location: ${userLocation.latitude}, ${userLocation.longitude} within ${radiusInKm}km radius');
    return _lostPetsCollection
        .where('isFound', isEqualTo: false)
        .snapshots()
        .asyncMap((snapshot) async {
          final pets = <LostPet>[];
          print('🔍 [DatabaseService] Processing ${snapshot.docs.length} lost pet documents');
          
          for (var doc in snapshot.docs) {
            try {
              final lostPet = await LostPet.fromFirestore(doc, _db);
              if (lostPet != null) {
                // Use multiple distance calculation methods for accuracy
                final distance = _calculatePreciseDistance(userLocation, lostPet.location);
                
                print('📍 [DatabaseService] Pet "${lostPet.pet.name}" at (${lostPet.location.latitude.toStringAsFixed(6)}, ${lostPet.location.longitude.toStringAsFixed(6)}) - distance: ${distance.toStringAsFixed(3)}km');
                
                // Map-based filtering: Check if pet is within the specified radius
                if (_isWithinMapRadius(userLocation, lostPet.location, radiusInKm)) {
                  pets.add(lostPet);
                  print('✅ [DatabaseService] Added pet "${lostPet.pet.name}" to nearby list (${distance.toStringAsFixed(3)}km away)');
                } else {
                  print('❌ [DatabaseService] Pet "${lostPet.pet.name}" is outside radius (${distance.toStringAsFixed(3)}km > ${radiusInKm}km)');
                }
              }
            } catch (e) {
              print('❌ [DatabaseService] Error converting lost pet doc ${doc.id}: $e');
            }
          }
          
          // Sort pets by distance (closest first)
          pets.sort((a, b) {
            final distanceA = _calculatePreciseDistance(userLocation, a.location);
            final distanceB = _calculatePreciseDistance(userLocation, b.location);
            return distanceA.compareTo(distanceB);
          });
          
          print('🎯 [DatabaseService] Returning ${pets.length} nearby pets (sorted by distance)');
          return pets;
        });
  }

  // Calculate precise distance using haversine formula with error checking
  double _calculatePreciseDistance(latlong.LatLng point1, latlong.LatLng point2) {
    try {
      // Validate coordinates
      if (!_isValidCoordinate(point1) || !_isValidCoordinate(point2)) {
        print('⚠️ [DatabaseService] Invalid coordinates detected');
        return double.infinity; // Return infinite distance for invalid coordinates
      }
      
      // Use Distance package with haversine formula for accuracy
      final distance = const Distance().as(
        LengthUnit.Kilometer,
        point1,
        point2,
      );
      
      // Additional validation - distance should be reasonable (not negative or extremely large)
      if (distance < 0 || distance > 20000) { // Max distance on Earth is ~20,000km
        print('⚠️ [DatabaseService] Unrealistic distance calculated: ${distance}km');
        return double.infinity;
      }
      
      return distance;
    } catch (e) {
      print('❌ [DatabaseService] Error calculating distance: $e');
      return double.infinity;
    }
  }

  // Check if coordinates are valid
  bool _isValidCoordinate(latlong.LatLng coord) {
    return coord.latitude.abs() <= 90.0 && 
           coord.longitude.abs() <= 180.0 &&
           !coord.latitude.isNaN && 
           !coord.longitude.isNaN &&
           !coord.latitude.isInfinite && 
           !coord.longitude.isInfinite;
  }

  // Map-based radius checking with boundary validation
  bool _isWithinMapRadius(latlong.LatLng userLocation, latlong.LatLng petLocation, double radiusInKm) {
    // Calculate precise distance
    final distance = _calculatePreciseDistance(userLocation, petLocation);
    
    // Check if distance is valid and within radius
    if (distance == double.infinity) {
      return false;
    }
    
    // Additional boundary checks for map accuracy
    final isWithinRadius = distance <= radiusInKm;
    
    // Log detailed information for debugging
    if (isWithinRadius) {
      print('🟢 [DatabaseService] Pet is within ${radiusInKm}km radius: ${distance.toStringAsFixed(3)}km');
    } else {
      print('🔴 [DatabaseService] Pet is outside ${radiusInKm}km radius: ${distance.toStringAsFixed(3)}km');
    }
    
    return isWithinRadius;
  }

  // Get recent lost pets
  Stream<List<LostPet>> getRecentLostPets({int limit = 10}) {
    return _lostPetsCollection
        .where('isFound', isEqualTo: false)
        .orderBy('reportedDate', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
          final pets = <LostPet>[];
          for (var doc in snapshot.docs) {
            try {
            final lostPet = await LostPet.fromFirestore(doc, _db);
            if (lostPet != null) {
                pets.add(lostPet);
              }
            } catch (e) {
              print('Error converting lost pet doc ${doc.id}: $e'); // Debug log
            }
          }
          return pets;
        });
  }

  // Mark lost pet as found
  Future<void> markLostPetAsFound(String lostPetId) async {
    try {
      await _lostPetsCollection.doc(lostPetId).update({
        'isFound': true,
        'foundDate': FieldValue.serverTimestamp(),
      });
      print('Marked lost pet $lostPetId as found');
    } catch (e) {
      print('Error marking lost pet as found: $e');
      rethrow;
    }
  }

  // Check if a pet is currently lost
  Future<bool> isPetLost(String petId) async {
    try {
      final snapshot = await _lostPetsCollection
          .where('petId', isEqualTo: petId)
          .where('isFound', isEqualTo: false)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if pet is lost: $e');
      return false;
    }
  }

  // Leaderboard Operations
  Stream<List<User>> getLeaderboardUsers({int limit = 50}) {
    return _usersCollection
        .orderBy('level', descending: true)
        .orderBy('petsRescued', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => User.fromFirestore(doc)).toList());
  }

  // Guest Mode Operations
  Future<void> transferGuestPetsToUser(String userId) async {
    final guestPets = await _localStorage.getGuestPets();
    for (var pet in guestPets) {
      final updatedPet = pet.copyWith(
        ownerId: userId,
        lastUpdatedAt: DateTime.now(),
      );
      await createPet(updatedPet);
    }
    await _localStorage.clearGuestData();
  }

  // AliExpress Product Operations
  Future<void> addAliexpressProduct(AliexpressProduct product) async {
    await _db.collection('aliexpress_products').add(product.toFirestore());
  }

  Future<void> updateAliexpressProduct(AliexpressProduct product) async {
    await _db.collection('aliexpress_products').doc(product.id).update(product.toFirestore());
  }

  Future<void> deleteAliexpressProduct(String productId) async {
    await _db.collection('aliexpress_products').doc(productId).delete();
  }

  Stream<List<AliexpressProduct>> getAliexpressProducts({
    String? category,
    bool? isFreeShipping,
    bool onlyDiscounted = false,
    int limit = 10,
  }) {
    Query query = _db.collection('aliexpress_products');

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (isFreeShipping != null) {
      query = query.where('isFreeShipping', isEqualTo: isFreeShipping);
    }

    if (onlyDiscounted) {
      query = query.where('originalPrice', isGreaterThan: 0);
    }

    return query
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AliexpressProduct.fromFirestore(doc))
            .toList());
  }

  Stream<List<AliexpressProduct>> getRecommendedProducts({int limit = 10}) {
    return _db
        .collection('aliexpress_products')
        .orderBy('orders', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AliexpressProduct.fromFirestore(doc))
            .toList());
  }

  Stream<List<AliexpressProduct>> getDiscountedProducts({int limit = 10}) {
    return _db
        .collection('aliexpress_products')
        .where('originalPrice', isGreaterThan: 0)
        .orderBy('originalPrice', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AliexpressProduct.fromFirestore(doc))
            .toList());
  }

  // AliExpress Listings Operations
  Stream<List<AliexpressProduct>> getAliexpressListings({
    String? category,
    bool? isFreeShipping,
    bool onlyDiscounted = false,
    int limit = 10,
  }) {
    final optimizedLimit = _getOptimizedLimit(limit);
    final cacheKey = 'aliexpress_${category}_${isFreeShipping}_${onlyDiscounted}_$optimizedLimit';
    
    print('Fetching AliExpress listings with filters:');
    print('- Category: ${category ?? 'All'}');
    print('- Free Shipping Only: $isFreeShipping');
    print('- Discounted Only: $onlyDiscounted');
    print('- Optimized Limit: $optimizedLimit');

    Query query = _db.collection('aliexpresslistings');

    if (category != null && category != 'All') {
      print('🔍 [DatabaseService] Filtering AliExpress by category: "$category"');
      // Try exact match first, then try case-insensitive alternatives
      query = query.where('category', isEqualTo: category);
    }

    if (isFreeShipping != null) {
      query = query.where('isFreeShipping', isEqualTo: isFreeShipping);
    }

    if (onlyDiscounted) {
      query = query.where('originalPrice', isGreaterThan: 0);
    }

    return query
        .orderBy('createdAt', descending: true)
        .limit(optimizedLimit)
        .snapshots()
        .map((snapshot) {
          print('Found ${snapshot.docs.length} listings');
          
          // Debug: Print unique categories in the results
          final categories = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['category'] ?? 'no-category';
          }).toSet();
          print('🔍 [DatabaseService] Categories found in AliExpress: $categories');
          
          // Debug: Print first few products with their categories
          if (snapshot.docs.isNotEmpty) {
            print('🔍 [DatabaseService] Sample AliExpress products:');
            for (int i = 0; i < snapshot.docs.length && i < 3; i++) {
              final data = snapshot.docs[i].data() as Map<String, dynamic>;
              print('  - ${data['title']}: category="${data['category']}"');
            }
          }
          final products = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            print('Processing listing: ${data['title']}');
            try {
              return AliexpressProduct(
                id: doc.id,
                name: data['title'] ?? '',
                description: data['description'] ?? '',
                price: (data['price'] ?? 0.0).toDouble(),
                originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
                currency: data['currency'] ?? 'USD',
                imageUrls: List<String>.from(data['photos'] ?? []),
                affiliateUrl: data['affiliateUrl'] ?? '',
                category: data['category'] ?? '',
                rating: (data['rating'] ?? 0.0).toDouble(),
                orders: data['orders'] ?? 0,
                isFreeShipping: data['isFreeShipping'] ?? false,
                shippingTime: data['shippingTime'] ?? '',
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              );
            } catch (e) {
              print('Error processing listing ${doc.id}: $e');
              print('Data: $data');
              rethrow;
            }
          }).toList();
          
          // Cache the results
          _setCache(cacheKey, products);
          return products;
        });
  }

  Stream<List<AliexpressProduct>> getRecommendedListings({int limit = 10}) {
    final optimizedLimit = _getOptimizedLimit(limit);
    final cacheKey = 'recommended_aliexpress_$optimizedLimit';
    
    return _db
        .collection('aliexpresslistings')
        .orderBy('orders', descending: true)
        .limit(optimizedLimit)
        .snapshots()
        .map((snapshot) {
          final products = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return AliexpressProduct(
              id: doc.id,
              name: data['title'] ?? '',
              description: data['description'] ?? '',
              price: (data['price'] ?? 0.0).toDouble(),
              originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
              currency: data['currency'] ?? 'USD',
              imageUrls: List<String>.from(data['photos'] ?? []),
              affiliateUrl: data['affiliateUrl'] ?? '',
              category: data['category'] ?? '',
              rating: (data['rating'] ?? 0.0).toDouble(),
              orders: data['orders'] ?? 0,
              isFreeShipping: data['isFreeShipping'] ?? false,
              shippingTime: data['shippingTime'] ?? '',
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();
          
          // Cache the results
          _setCache(cacheKey, products);
          return products;
        });
  }

  Stream<List<AliexpressProduct>> getDiscountedListings({int limit = 10}) {
    return _db
        .collection('aliexpresslistings')
        .where('originalPrice', isGreaterThan: 0)
        .orderBy('originalPrice', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return AliexpressProduct(
              id: doc.id,
              name: data['title'] ?? '',
              description: data['description'] ?? '',
              price: (data['price'] ?? 0.0).toDouble(),
              originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
              currency: data['currency'] ?? 'USD',
              imageUrls: List<String>.from(data['photos'] ?? []),
              affiliateUrl: data['affiliateUrl'] ?? '',
              category: data['category'] ?? '',
              rating: (data['rating'] ?? 0.0).toDouble(),
              orders: data['orders'] ?? 0,
              isFreeShipping: data['isFreeShipping'] ?? false,
              shippingTime: data['shippingTime'] ?? '',
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();
        });
  }

  // Adoption Center Operations
  Stream<List<Pet>> getNearbyPets() {
    return _petsCollection
        .where('isForAdoption', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList());
  }

  Stream<List<Pet>> getNewListings() {
    return _petsCollection
        .where('isForAdoption', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList());
  }

  // Adoption Listing Operations
  Future<String> createAdoptionListing(AdoptionListing listing) async {
    try {
      final docRef = await _adoptionListingsCollection.add(listing.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating adoption listing: $e');
      rethrow;
    }
  }

  Future<void> updateAdoptionListing(AdoptionListing listing) async {
    try {
      await _adoptionListingsCollection.doc(listing.id).update(listing.toFirestore());
    } catch (e) {
      print('Error updating adoption listing: $e');
      rethrow;
    }
  }

  Future<void> deleteAdoptionListing(String listingId) async {
    try {
      await _adoptionListingsCollection.doc(listingId).delete();
    } catch (e) {
      print('Error deleting adoption listing: $e');
      rethrow;
    }
  }

  Stream<List<AdoptionListing>> getAdoptionListings() {
    return _adoptionListingsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(_getOptimizedLimit(30))
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AdoptionListing.fromFirestore(doc)).toList());
  }

  Stream<List<AdoptionListing>> getNearbyAdoptionListings(latlong.LatLng userLocation, {double radiusKm = 50}) {
    // For now, return all listings. In the future, implement geospatial queries
    return _adoptionListingsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(_getOptimizedLimit(10))
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AdoptionListing.fromFirestore(doc)).toList());
  }

  Future<AdoptionListing?> getAdoptionListing(String listingId) async {
    try {
      final doc = await _adoptionListingsCollection.doc(listingId).get();
      if (doc.exists) {
        return AdoptionListing.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting adoption listing: $e');
      return null;
    }
  }

  Stream<List<AdoptionListing>> getUserAdoptionListings(String userId) {
    return _adoptionListingsCollection
        .where('ownerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AdoptionListing.fromFirestore(doc)).toList());
  }

  Future<void> updatePet(Pet pet, {bool isGuest = false}) async {
    if (isGuest) {
      await _localStorage.updateGuestPet(pet);
    } else {
      await _petsCollection.doc(pet.id).update(pet.toFirestore());
    }
  }

  Future<void> updatePetPhotos(String petId, List<String> newImageUrls) async {
    await _petsCollection.doc(petId).update({
      'imageUrls': newImageUrls,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Pet?> getPet(String petId) async {
    final doc = await _petsCollection.doc(petId).get();
    return doc.exists ? Pet.fromFirestore(doc) : null;
  }

  // Store Product Operations
  Future<String> createStoreProduct(StoreProduct product) async {
    try {
      // Create the product
      final docRef = await _storeProductsCollection.add(product.toFirestore());
      
      // Add product ID to store's products array
      await _usersCollection.doc(product.storeId).update({
        'products': FieldValue.arrayUnion([docRef.id]),
      });
      
      return docRef.id;
    } catch (e) {
      print('Error creating store product: $e');
      rethrow;
    }
  }

  Future<void> updateStoreProduct(StoreProduct product) async {
    try {
      await _storeProductsCollection.doc(product.id).update(product.toFirestore());
    } catch (e) {
      print('Error updating store product: $e');
      rethrow;
    }
  }

  Future<void> deleteStoreProduct(String productId, String storeId) async {
    try {
      // Remove product from store's products array
      await _usersCollection.doc(storeId).update({
        'products': FieldValue.arrayRemove([productId]),
      });
      
      // Delete the product
      await _storeProductsCollection.doc(productId).delete();
    } catch (e) {
      print('Error deleting store product: $e');
      rethrow;
    }
  }

  Future<StoreProduct?> getStoreProduct(String productId) async {
    try {
      final doc = await _storeProductsCollection.doc(productId).get();
      if (doc.exists) {
        return StoreProduct.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting store product: $e');
      return null;
    }
  }

  Stream<List<StoreProduct>> getStoreProducts({
    String? category,
    bool? isFreeShipping,
    String? storeId,
    int limit = 10,
  }) {
    final optimizedLimit = _getOptimizedLimit(limit);
    final cacheKey = 'store_products_${category}_${isFreeShipping}_${storeId}_$optimizedLimit';
    
    Query query = _storeProductsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (category != null) {
      print('🔍 [DatabaseService] Filtering Store products by category: "$category"');
      query = query.where('category', isEqualTo: category);
    }

    if (isFreeShipping != null) {
      query = query.where('isFreeShipping', isEqualTo: isFreeShipping);
    }

    if (storeId != null) {
      query = query.where('storeId', isEqualTo: storeId);
    }

    return query
        .limit(optimizedLimit)
        .snapshots()
        .map((snapshot) {
          // Debug: Print unique categories in the results
          final categories = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['category'] ?? 'no-category';
          }).toSet();
          print('🔍 [DatabaseService] Categories found in Store products: $categories');
          
          final products = snapshot.docs
              .map((doc) => StoreProduct.fromFirestore(doc))
              .toList();
          
          // Cache the results
          _setCache(cacheKey, products);
          return products;
        });
  }

  Stream<List<StoreProduct>> getPopularStoreProducts({int limit = 10}) {
    final optimizedLimit = _getOptimizedLimit(limit);
    final cacheKey = 'popular_store_products_$optimizedLimit';
    
    return _storeProductsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('totalOrders', descending: true)
        .limit(optimizedLimit)
        .snapshots()
        .map((snapshot) {
          final products = snapshot.docs
              .map((doc) => StoreProduct.fromFirestore(doc))
              .toList();
          
          // Cache the results
          _setCache(cacheKey, products);
          return products;
        });
  }

  Future<List<StoreProduct>> getStoreProductsByIds(List<String> productIds) async {
    if (productIds.isEmpty) return [];
    
    final products = <StoreProduct>[];
    // Firestore has a limit of 10 items for 'in' queries, so we need to batch
    for (var i = 0; i < productIds.length; i += 10) {
      final batch = productIds.skip(i).take(10).toList();
      final snapshot = await _storeProductsCollection
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      products.addAll(snapshot.docs.map((doc) => StoreProduct.fromFirestore(doc)));
    }
    return products;
  }

  Future<void> addProductReview({
    required String productId,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    try {
      // Add review to product's reviews subcollection
      await _storeProductsCollection
          .doc(productId)
          .collection('reviews')
          .add({
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update product's average rating
      await _updateProductRating(productId);

      // Update seller's overall rating based on all product reviews
      final product = await getStoreProduct(productId);
      if (product != null) {
        await _updateSellerRating(product.storeId);
      }

      print('Product review added successfully');
    } catch (e) {
      print('Error adding product review: $e');
      throw e;
    }
  }

  Future<void> _updateProductRating(String productId) async {
    try {
      // Get all reviews for this product
      final reviewsSnapshot = await _storeProductsCollection
          .doc(productId)
          .collection('reviews')
          .get();

      if (reviewsSnapshot.docs.isEmpty) return;

      // Calculate average rating
      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data();
        totalRating += (data['rating'] ?? 0).toDouble();
      }
      
      final averageRating = totalRating / reviewsSnapshot.docs.length;

      // Update product with new average rating
      await _storeProductsCollection.doc(productId).update({
        'rating': averageRating,
        'reviewCount': reviewsSnapshot.docs.length,
      });

      print('Product rating updated to $averageRating');
    } catch (e) {
      print('Error updating product rating: $e');
      throw e;
    }
  }

  Future<void> _updateSellerRating(String sellerId) async {
    try {
      final sellerReviews = await getSellerReviews(sellerId);
      final averageRating = sellerReviews['averageRating'] as double;
      
      // Update seller's rating in their user document
      await _usersCollection.doc(sellerId).update({
        'rating': averageRating,
      });

      print('Seller rating updated to $averageRating');
    } catch (e) {
      print('Error updating seller rating: $e');
      throw e;
    }
  }

  Stream<List<Map<String, dynamic>>> getProductReviews(String productId) {
    return _storeProductsCollection
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'userId': data['userId'] ?? '',
            'userName': data['userName'] ?? 'Anonymous',
            'rating': data['rating'] ?? 0,
            'comment': data['comment'] ?? '',
            'createdAt': data['createdAt'] ?? Timestamp.now(),
          };
        }).toList());
  }

  Future<Map<String, dynamic>> getSellerReviews(String sellerId) async {
    try {
      // Get all products by this seller
      final productsSnapshot = await _storeProductsCollection
          .where('storeId', isEqualTo: sellerId)
          .get();

      List<Map<String, dynamic>> allReviews = [];
      double totalRating = 0;
      int totalReviewCount = 0;

      for (var productDoc in productsSnapshot.docs) {
        final product = StoreProduct.fromFirestore(productDoc);
        
        // Get reviews for this product
        final reviewsSnapshot = await _storeProductsCollection
            .doc(productDoc.id)
            .collection('reviews')
            .orderBy('createdAt', descending: true)
            .get();

        for (var reviewDoc in reviewsSnapshot.docs) {
          final reviewData = reviewDoc.data();
          allReviews.add({
            'id': reviewDoc.id,
            'userId': reviewData['userId'] ?? '',
            'userName': reviewData['userName'] ?? 'Anonymous',
            'rating': reviewData['rating'] ?? 0,
            'comment': reviewData['comment'] ?? '',
            'createdAt': reviewData['createdAt'] ?? Timestamp.now(),
            'productId': productDoc.id,
            'productName': product.name,
            'productImage': product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
          });
          
          totalRating += (reviewData['rating'] ?? 0).toDouble();
          totalReviewCount++;
        }
      }

      final averageRating = totalReviewCount > 0 ? totalRating / totalReviewCount : 0.0;

      return {
        'reviews': allReviews,
        'averageRating': averageRating,
        'totalReviews': totalReviewCount,
      };
    } catch (e) {
      print('Error getting seller reviews: $e');
      return {
        'reviews': <Map<String, dynamic>>[],
        'averageRating': 0.0,
        'totalReviews': 0,
      };
    }
  }

  // Update store rating and total orders
  Future<void> updateStoreStats(String storeId) async {
    try {
      final products = await _storeProductsCollection
          .where('storeId', isEqualTo: storeId)
          .where('isActive', isEqualTo: true)
          .get();
      
      int totalOrders = 0;
      double totalRating = 0;
      int ratedProducts = 0;
      
      for (var doc in products.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalOrders += data['totalOrders'] as int? ?? 0;
        if (data['rating'] != null && data['rating'] > 0) {
          totalRating += data['rating'] as double;
          ratedProducts++;
        }
      }
      
      final averageRating = ratedProducts > 0 ? totalRating / ratedProducts : 0.0;
      
      await _usersCollection.doc(storeId).update({
        'totalOrders': totalOrders,
        'rating': averageRating,
      });
    } catch (e) {
      print('Error updating store stats: $e');
      rethrow;
    }
  }

  // Update all store stats (utility function for fixing existing data)
  Future<void> updateAllStoreStats() async {
    try {
      print('Starting update of all store stats...');
      
      // Get all store users
      final storeUsersSnapshot = await _usersCollection
          .where('accountType', isEqualTo: 'store')
          .get();
      
      int updatedCount = 0;
      for (var doc in storeUsersSnapshot.docs) {
        try {
          await updateStoreStats(doc.id);
          updatedCount++;
          print('Updated store stats for: ${doc.id}');
        } catch (e) {
          print('Error updating store stats for ${doc.id}: $e');
          // Continue with next store
        }
      }
      
      print('Store stats update completed. Updated $updatedCount stores.');
    } catch (e) {
      print('Error in updateAllStoreStats: $e');
      rethrow;
    }
  }

  Stream<List<MarketplaceProduct>> getMarketplaceProducts({
    String? category,
    bool? isFreeShipping,
    String? storeId,
    int limit = 10,
  }) {
    final optimizedLimit = _getOptimizedLimit(limit);
    
    // Combine AliExpress and store products
    return CombineLatestStream.combine2(
      getAliexpressListings(
        category: category,
        limit: optimizedLimit ~/ 2,  // Split limit between both sources
      ),
      getStoreProducts(
        category: category,
        isFreeShipping: isFreeShipping,
        storeId: storeId,
        limit: optimizedLimit ~/ 2,
      ),
      (List<AliexpressProduct> aliProducts, List<StoreProduct> storeProducts) {
        final products = [
          ...aliProducts.map(MarketplaceProduct.fromAliexpress),
          ...storeProducts.map(MarketplaceProduct.fromStore),
        ];
        // Sort by totalOrders descending (most popular first)
        products.sort((a, b) => b.totalOrders.compareTo(a.totalOrders));
        return products;
      },
    );
  }

  Stream<List<MarketplaceProduct>> getRecommendedMarketplaceProducts({int limit = 10}) {
    final optimizedLimit = _getOptimizedLimit(limit);
    
    // For now, just combine recommended AliExpress products and top-rated store products
    return CombineLatestStream.combine2(
      getRecommendedListings(limit: optimizedLimit ~/ 2),
      getStoreProducts(limit: optimizedLimit ~/ 2),
      (List<AliexpressProduct> aliProducts, List<StoreProduct> storeProducts) {
        final products = [
          ...aliProducts.map(MarketplaceProduct.fromAliexpress),
          ...storeProducts.map(MarketplaceProduct.fromStore),
        ];
        
        // Sort by rating and orders
        products.sort((a, b) {
          final ratingCompare = b.rating.compareTo(a.rating);
          if (ratingCompare != 0) return ratingCompare;
          return b.totalOrders.compareTo(a.totalOrders);
        });
        
        return products;
      },
    );
  }

  Stream<List<MarketplaceProduct>> getNewMarketplaceProducts({int limit = 10}) {
    final optimizedLimit = _getOptimizedLimit(limit);
    
    // For now, just combine new AliExpress products and store products
    return CombineLatestStream.combine2(
      getAliexpressListings(limit: optimizedLimit ~/ 2),
      getStoreProducts(limit: optimizedLimit ~/ 2),
      (List<AliexpressProduct> aliProducts, List<StoreProduct> storeProducts) {
        final products = [
          ...aliProducts.map(MarketplaceProduct.fromAliexpress),
          ...storeProducts.map(MarketplaceProduct.fromStore),
        ];
        // Sort by createdAt descending (newest first)
        products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return products;
      },
    );
  }

  // Gift Operations
  Future<String> sendGift(Gift gift) async {
    final docRef = await _giftsCollection.add(gift.toFirestore());
    return docRef.id;
  }

  Future<void> updateGiftStatus(String giftId, String status) async {
    await _giftsCollection.doc(giftId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Gift>> getPendingGifts(String userId) {
    return _giftsCollection
        .where('gifteeId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList());
  }

  Stream<List<Gift>> getSentGifts(String userId) {
    return _giftsCollection
        .where('gifterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList());
  }

  Stream<List<Map<String, dynamic>>> getStoreDashboardStats(String storeId) {
    print('🔍 [DatabaseService] getStoreDashboardStats called for storeId: $storeId');
    
    return _ordersCollection
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) {
      print('🔍 [DatabaseService] getStoreDashboardStats received ${snapshot.docs.length} orders');
      
      double totalSales = 0;
      int ordersCount = 0;
      int activeOrders = 0;
      int engagementCount = 0;

      for (var doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String? ?? 'pending';
        final price = (data['productPrice'] ?? data['price'] ?? 0) as num;
        final quantity = (data['quantity'] ?? 1) as num;
        
        // Calculate total sales from shipped and delivered orders (revenue is earned when shipped)
        if (['shipped', 'delivered'].contains(status)) {
          totalSales += price * quantity;
        }
        
        // Count all orders
        ordersCount++;
        
        // Count active orders (ordered, pending, confirmed, shipped)
        if (['ordered', 'pending', 'confirmed', 'shipped'].contains(status)) {
          activeOrders++;
        }
      }

      // Use unique customers as engagement metric
      final uniqueCustomers = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['customerId'] as String?)
          .where((id) => id != null)
          .toSet()
          .length;
      engagementCount = uniqueCustomers;

      final stats = {
        'totalSales': totalSales,
        'ordersCount': ordersCount,
        'activeOrders': activeOrders,
        'engagementCount': engagementCount,
      };
      
      print('🔍 [DatabaseService] getStoreDashboardStats calculated stats: $stats');
      
      return [stats];
    }).handleError((error) {
      print('🔍 [DatabaseService] getStoreDashboardStats error: $error');
      // Return default stats on error
      return [
        {
          'totalSales': 0.0,
          'ordersCount': 0,
          'activeOrders': 0,
          'engagementCount': 0,
        }
      ];
    });
  }

  Stream<Map<String, dynamic>> getStoreSalesAnalytics(String storeId) {
    print('🔍 [DatabaseService] getStoreSalesAnalytics called for storeId: $storeId');
    
    return _ordersCollection
        .where('storeId', isEqualTo: storeId)
        .where('status', whereIn: ['shipped', 'delivered'])
        .snapshots()
        .map((snapshot) {
      print('🔍 [DatabaseService] getStoreSalesAnalytics received ${snapshot.docs.length} shipped/delivered orders');
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekAgo = today.subtract(const Duration(days: 7));
      final monthAgo = DateTime(now.year, now.month - 1, now.day);
      
      double todaySales = 0;
      double weekSales = 0;
      double monthSales = 0;
      double totalSales = 0;
      
      for (var doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final timestamp = data['timestamp'] ?? data['createdAt'];
        final createdAt = timestamp != null ? (timestamp as Timestamp).toDate() : DateTime.now();
        final price = (data['productPrice'] ?? data['price'] ?? 0) as num;
        final quantity = (data['quantity'] ?? 1) as num;
        final orderTotal = (price * quantity).clamp(0, double.infinity); // Ensure non-negative
        
        totalSales += orderTotal;
        
        // Today's sales
        if (createdAt.isAfter(today)) {
          todaySales += orderTotal;
        }
        
        // This week's sales
        if (createdAt.isAfter(weekAgo)) {
          weekSales += orderTotal;
        }
        
        // This month's sales
        if (createdAt.isAfter(monthAgo)) {
          monthSales += orderTotal;
        }
      }
      
      final analytics = {
        'todaySales': todaySales,
        'weekSales': weekSales,
        'monthSales': monthSales,
        'totalSales': totalSales,
        'orderCount': snapshot.docs.length,
      };
      
      print('🔍 [DatabaseService] getStoreSalesAnalytics calculated: $analytics');
      
      return analytics;
    }).handleError((error) {
      print('🔍 [DatabaseService] getStoreSalesAnalytics error: $error');
      return {
        'todaySales': 0.0,
        'weekSales': 0.0,
        'monthSales': 0.0,
        'totalSales': 0.0,
        'orderCount': 0,
      };
    });
  }



  Stream<Map<String, List<Map<String, dynamic>>>> getStoreSalesChartData(String storeId) {
    print('🔍 [DatabaseService] getStoreSalesChartData called for storeId: $storeId');
    
    return _ordersCollection
        .where('storeId', isEqualTo: storeId)
        .where('status', whereIn: ['shipped', 'delivered'])
        .snapshots()
        .map((snapshot) {
      print('🔍 [DatabaseService] getStoreSalesChartData received ${snapshot.docs.length} shipped/delivered orders');
      
      final now = DateTime.now();
      final Map<String, double> dailyData = {};
      final Map<String, double> weeklyData = {};
      final Map<String, double> monthlyData = {};
      
      // Initialize last 7 days (current week)
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayKey = _getDayName(day.weekday);
        dailyData[dayKey] = 0.0;
      }
      
      // Initialize last 8 weeks
      for (int i = 7; i >= 0; i--) {
        final weekStart = now.subtract(Duration(days: i * 7));
        final weekKey = 'W${(weekStart.day / 7).ceil()}';
        weeklyData[weekKey] = 0.0;
      }
      
      // Initialize last 12 months
      for (int i = 11; i >= 0; i--) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        final monthKey = _getMonthName(monthStart.month);
        monthlyData[monthKey] = 0.0;
      }
      
      for (var doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final timestamp = data['timestamp'] ?? data['createdAt'];
        final createdAt = timestamp != null ? (timestamp as Timestamp).toDate() : DateTime.now();
        final price = (data['productPrice'] ?? data['price'] ?? 0) as num;
        final quantity = (data['quantity'] ?? 1) as num;
        final orderTotal = (price * quantity).clamp(0, double.infinity); // Ensure non-negative
        
        // Daily data (current week)
        final dayKey = _getDayName(createdAt.weekday);
        if (dailyData.containsKey(dayKey)) {
          dailyData[dayKey] = (dailyData[dayKey] ?? 0) + orderTotal;
        }
        
        // Weekly data
        final weekStart = createdAt.subtract(Duration(days: createdAt.weekday - 1));
        final weekKey = 'W${(weekStart.day / 7).ceil()}';
        if (weeklyData.containsKey(weekKey)) {
          weeklyData[weekKey] = (weeklyData[weekKey] ?? 0) + orderTotal;
        }
        
        // Monthly data
        final monthKey = _getMonthName(createdAt.month);
        if (monthlyData.containsKey(monthKey)) {
          monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + orderTotal;
        }
      }
      
      final dailyChartData = dailyData.entries.map((entry) => {
        'period': entry.key,
        'sales': entry.value,
      }).toList();
      
      final weeklyChartData = weeklyData.entries.map((entry) => {
        'period': entry.key,
        'sales': entry.value,
      }).toList();
      
      final monthlyChartData = monthlyData.entries.map((entry) => {
        'period': entry.key,
        'sales': entry.value,
      }).toList();
      
      final chartData = {
        'daily': dailyChartData,
        'weekly': weeklyChartData,
        'monthly': monthlyChartData,
      };
      
      print('🔍 [DatabaseService] getStoreSalesChartData calculated: ${dailyChartData.length} days, ${weeklyChartData.length} weeks, ${monthlyChartData.length} months');
      
      return chartData;
    }).handleError((error) {
      print('🔍 [DatabaseService] getStoreSalesChartData error: $error');
      return {
        'daily': <Map<String, dynamic>>[],
        'weekly': <Map<String, dynamic>>[],
        'monthly': <Map<String, dynamic>>[],
      };
    });
  }
  
  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
  
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Stream<List<StoreProduct>> getProductsByStore(String storeId) {
    return _storeProductsCollection
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoreProduct.fromFirestore(doc))
            .toList());
  }

  // Vet and Store Location Operations
  Future<void> saveVetLocation(String placeId, double lat, double lng) async {
    try {
      final vetsDoc = _db.collection('locations').doc('vets');
      
      // Get place details first
      final details = await _getPlaceDetails(placeId);
      if (details == null) return;

      await vetsDoc.set({
        'locations': {
          placeId: {
            'location': GeoPoint(lat, lng),
            'createdAt': FieldValue.serverTimestamp(),
            'name': details['name'],
            'vicinity': details['vicinity'],
            'openingHours': details['opening_hours'],
          }
        }
      }, SetOptions(merge: true));
      
      print('Saved vet location: ${details['name']}');
    } catch (e) {
      print('Error saving vet location: $e');
      throw e;
    }
  }

  Future<void> saveStoreLocation(String placeId, double lat, double lng) async {
    try {
      final storesDoc = _db.collection('locations').doc('stores');
      
      // Get place details first
      final details = await _getPlaceDetails(placeId);
      if (details == null) return;

      await storesDoc.set({
        'locations': {
          placeId: {
            'location': GeoPoint(lat, lng),
            'createdAt': FieldValue.serverTimestamp(),
            'name': details?['name'] ?? 'Unknown Store',
            'vicinity': details?['vicinity'] ?? 'Location unavailable',
            'openingHours': details?['opening_hours'],
          }
        }
      }, SetOptions(merge: true));
      
      print('Saved store location: ${details['name']}');
    } catch (e) {
      print('Error saving store location: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>?> getVetLocation(String placeId) async {
    try {
      final doc = await _db.collection('locations').doc('vets').get();
      if (doc.exists) {
        final locations = doc.data()?['locations'] as Map<String, dynamic>?;
        return locations?[placeId] as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error getting vet location: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getStoreLocation(String placeId) async {
    try {
      final doc = await _db.collection('locations').doc('stores').get();
      if (doc.exists) {
        final locations = doc.data()?['locations'] as Map<String, dynamic>?;
        return locations?[placeId] as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error getting store location: $e');
    }
    return null;
  }

  Future<List<String>> getAllVetPlaceIds() async {
    try {
      final doc = await _vetLocationsDoc.get();
      if (!doc.exists) return [];
      
      final data = doc.data() as Map<String, dynamic>;
      final locations = data['locations'] as Map<String, dynamic>;
      return locations.keys.toList();
    } catch (e) {
      print('Error getting vet place IDs: $e');
      return [];
    }
  }

  Future<List<String>> getAllStorePlaceIds() async {
    try {
      final doc = await _storeLocationsDoc.get();
      if (!doc.exists) return [];
      
      final data = doc.data() as Map<String, dynamic>;
      final locations = data['locations'] as Map<String, dynamic>;
      return locations.keys.toList();
    } catch (e) {
      print('Error getting store place IDs: $e');
      return [];
    }
  }

  Future<Map<String, GeoPoint>> getAllVetLocations() async {
    try {
      final doc = await _vetLocationsDoc.get();
      if (!doc.exists) return {};
      
      final data = doc.data() as Map<String, dynamic>;
      final locations = data['locations'] as Map<String, dynamic>;
      
      return locations.map((placeId, locationData) {
        final location = locationData['location'] as GeoPoint;
        return MapEntry(placeId, location);
      });
    } catch (e) {
      print('Error getting all vet locations: $e');
      return {};
    }
  }

  Future<Map<String, GeoPoint>> getAllStoreLocations() async {
    try {
      final doc = await _storeLocationsDoc.get();
      if (!doc.exists) return {};
      
      final data = doc.data() as Map<String, dynamic>;
      final locations = data['locations'] as Map<String, dynamic>;
      
      return locations.map((placeId, locationData) {
        final location = locationData['location'] as GeoPoint;
        return MapEntry(placeId, location);
      });
    } catch (e) {
      print('Error getting all store locations: $e');
      return {};
    }
  }

  // Chat methods
  Future<String> sendChatMessage(String senderId, String receiverId, String message, {Map<String, dynamic>? productAttachment, bool isOrderAttachment = false}) async {
    try {
      final docRef = await _chatMessagesCollection.add({
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'productAttachment': productAttachment,
        'isOrderAttachment': isOrderAttachment,
      });

      // Send notification for chat message
      _sendChatNotification(senderId, receiverId, message);

      return docRef.id;
    } catch (e) {
      print('Error sending chat message: $e');
      throw e;
    }
  }

  // Helper method to send chat notifications
  Future<void> _sendChatNotification(String senderId, String receiverId, String message) async {
    try {
      final notificationService = NotificationService();
      
      // Get sender info
      final senderInfo = await _getUserInfo(senderId);
      
      await notificationService.sendChatMessageNotification(
        recipientId: receiverId,
        senderId: senderId,
        senderName: senderInfo?['name'],
        senderPhotoUrl: senderInfo?['photoUrl'],
        message: message,
      );
    } catch (e) {
      print('Error sending chat notification: $e');
    }
  }

  Stream<List<ChatMessage>> getChatMessages(String userId1, String userId2) {
    // Create a compound query to get messages between these two specific users
    // We need to check both directions: user1->user2 and user2->user1
    return _chatMessagesCollection
        .where('senderId', whereIn: [userId1, userId2])
        .where('receiverId', whereIn: [userId1, userId2])
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          // Filter to only include messages between these two specific users
          return snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .where((message) => 
                  (message.senderId == userId1 && message.receiverId == userId2) ||
                  (message.senderId == userId2 && message.receiverId == userId1))
              .toList();
        });
  }

  Stream<List<ChatMessage>> getIncomingMessagesForStore(String storeId) {
    return _chatMessagesCollection
        .where('receiverId', isEqualTo: storeId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getStoreConversations(String storeId) {
    return _chatMessagesCollection
        .where('receiverId', isEqualTo: storeId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      // Group messages by sender to get unique conversations
      Map<String, ChatMessage> conversations = {};
      for (var doc in snapshot.docs) {
        final message = ChatMessage.fromFirestore(doc);
        if (!conversations.containsKey(message.senderId)) {
          conversations[message.senderId] = message;
        }
      }
      
      return conversations.values.map((message) => {
        'senderId': message.senderId,
        'lastMessage': message.message,
        'timestamp': message.timestamp,
        'messageId': message.id,
      }).toList();
    });
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _chatMessagesCollection.doc(messageId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking message as read: $e');
      throw e;
    }
  }

  Future<void> markOrderAsRead(String userId, String orderId, String accountType) async {
    try {
      if (accountType == 'store') {
        await _ordersCollection
            .doc(orderId)
            .update({'isRead': true});
      } else {
        await _usersCollection
            .doc(userId)
            .collection('orders')
            .doc(orderId)
            .update({'isRead': true});
      }
    } catch (e) {
      print('Error marking order as read: $e');
    }
  }

  Future<void> updateChatMessageAttachment(String messageId, Map<String, dynamic> attachment) async {
    try {
      await _chatMessagesCollection.doc(messageId).update({
        'productAttachment': attachment,
      });
    } catch (e) {
      print('Error updating chat message attachment: $e');
      throw e;
    }
  }

  // Order Operations
  Future<String> createOrder(store_order.StoreOrder order) async {
    try {
      final orderData = order.toFirestore();
      orderData['isRead'] = false;
      final docRef = await _ordersCollection.add(orderData);
      final orderId = docRef.id;
      
      // Also create the order in user's subcollection for buyer
      await _usersCollection
          .doc(order.customerId)
          .collection('orders')
          .doc(orderId)
          .set({
        'id': orderId,
        'userId': order.customerId,
        'productId': order.productId,
        'productName': order.productName,
        'productImage': order.productImageUrl,
        'productPrice': order.price,
        'storeId': order.storeId,
        'quantity': order.quantity,
        'status': order.status,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Also create the order in store's subcollection for seller
      await _usersCollection
          .doc(order.storeId)
          .collection('orders')
          .doc(orderId)
          .set({
        'id': orderId,
        'userId': order.customerId,
        'productId': order.productId,
        'productName': order.productName,
        'productImage': order.productImageUrl,
        'productPrice': order.price,
        'storeId': order.storeId,
        'quantity': order.quantity,
        'status': order.status,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Increment totalOrders for the store product if this is a store product order
      if (order.productId.isNotEmpty) {
        final productDoc = await _storeProductsCollection.doc(order.productId).get();
        if (productDoc.exists) {
          await productDoc.reference.update({
            'totalOrders': FieldValue.increment(1),
          });
          
          // Update store's total orders in user profile
          await updateStoreStats(order.storeId);
        }
      }

      // Send order placed notification to store owner
      _sendOrderPlacedNotification(order);

      return orderId;
    } catch (e) {
      print('Error creating order: $e');
      throw e;
    }
  }

  // Helper method to send order placed notification
  Future<void> _sendOrderPlacedNotification(store_order.StoreOrder order) async {
    try {
      final notificationService = NotificationService();
      
      // Get buyer info
      final buyerInfo = await _getUserInfo(order.customerId);
      
      await notificationService.sendOrderPlacedNotification(
        recipientId: order.storeId,
        senderId: order.customerId,
        senderName: buyerInfo?['name'],
        senderPhotoUrl: buyerInfo?['photoUrl'],
        productName: order.productName,
        orderId: order.id,
      );
    } catch (e) {
      print('Error sending order placed notification: $e');
    }
  }

  // Helper method to get user info
  Future<Map<String, dynamic>?> _getUserInfo(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['displayName'] ?? 'User',
          'photoUrl': data['photoURL'],
        };
      }
      return null;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      // Update the main orders collection
      await _ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also update the order in user subcollections (for new Payment on Delivery orders)
      final orderDoc = await _ordersCollection.doc(orderId).get();
      if (orderDoc.exists) {
        final orderData = orderDoc.data() as Map<String, dynamic>;
        final customerId = orderData['customerId'];
        final storeId = orderData['storeId'];
        
        if (customerId != null && storeId != null) {
          // Update in buyer's subcollection
          await _usersCollection
              .doc(customerId)
              .collection('orders')
              .doc(orderId)
              .update({
            'status': status,
            'timestamp': FieldValue.serverTimestamp(),
          });
          
          // Update in seller's subcollection
          await _usersCollection
              .doc(storeId)
              .collection('orders')
              .doc(orderId)
              .update({
            'status': status,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }

      // If order is marked as shipped, update seller revenue and product order count
      if (status == 'shipped') {
        final orderData = orderDoc.data() as Map<String, dynamic>;
        final storeId = orderData['storeId'] as String?;
        final productId = orderData['productId'] as String?;
        final productPrice = (orderData['price'] ?? 0.0).toDouble();
        final quantity = (orderData['quantity'] ?? 1).toInt();
        final orderTotal = productPrice * quantity;
        
        if (storeId != null && orderTotal > 0) {
          print('🔍 [DatabaseService] Order marked as shipped, updating seller revenue: storeId=$storeId, amount=$orderTotal');
          await updateSellerRevenue(storeId, orderTotal);
        }
        
        // Update product's shipped orders count when order is shipped
        if (productId != null && productId.isNotEmpty) {
          final productDoc = await _storeProductsCollection.doc(productId).get();
          if (productDoc.exists) {
            await productDoc.reference.update({
              'shippedOrders': FieldValue.increment(1),
            });
            print('🔍 [DatabaseService] Updated product shipped orders count for product: $productId');
          }
        }
      }
      
      // If order is cancelled or refunded, decrement shipped orders count
      if (status == 'cancelled' || status == 'refunded') {
        final orderData = orderDoc.data() as Map<String, dynamic>;
        final productId = orderData['productId'] as String?;
        final previousStatus = orderData['status'] as String?;
        
        // Only decrement if the order was previously shipped
        if (productId != null && productId.isNotEmpty && previousStatus == 'shipped') {
          final productDoc = await _storeProductsCollection.doc(productId).get();
          if (productDoc.exists) {
            await productDoc.reference.update({
              'shippedOrders': FieldValue.increment(-1),
            });
            print('🔍 [DatabaseService] Decremented product shipped orders count for cancelled/refunded order: $productId');
          }
        }
      }

      // Update store stats when order status changes (for accurate total orders)
      final orderData = orderDoc.data() as Map<String, dynamic>;
      final storeId = orderData['storeId'] as String?;
      if (storeId != null) {
        await updateStoreStats(storeId);
      }

      // Send order status notification
      _sendOrderStatusNotification(orderId, status);
    } catch (e) {
      print('Error updating order status: $e');
      throw e;
    }
  }

  // Update seller revenue when order is shipped
  Future<void> updateSellerRevenue(String sellerId, double orderAmount) async {
    try {
      final sellerDoc = await _usersCollection.doc(sellerId).get();
      if (!sellerDoc.exists) {
        print('🔍 [DatabaseService] Seller document not found: $sellerId');
        return;
      }

      final sellerData = sellerDoc.data() as Map<String, dynamic>;
      final currentTotalRevenue = (sellerData['totalRevenue'] ?? 0.0).toDouble();
      final currentDailyRevenue = (sellerData['dailyRevenue'] ?? 0.0).toDouble();
      final lastRevenueUpdate = (sellerData['lastRevenueUpdate'] as Timestamp?)?.toDate();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Check if we need to reset daily revenue (new day)
      double newDailyRevenue = currentDailyRevenue;
      if (lastRevenueUpdate == null || 
          DateTime(lastRevenueUpdate.year, lastRevenueUpdate.month, lastRevenueUpdate.day).isBefore(today)) {
        // Reset daily revenue for new day
        newDailyRevenue = orderAmount;
        print('🔍 [DatabaseService] Resetting daily revenue for new day. Previous: $currentDailyRevenue, New: $newDailyRevenue');
      } else {
        // Add to existing daily revenue
        newDailyRevenue = currentDailyRevenue + orderAmount;
        print('🔍 [DatabaseService] Adding to existing daily revenue. Previous: $currentDailyRevenue, Adding: $orderAmount, New: $newDailyRevenue');
      }
      
      final newTotalRevenue = currentTotalRevenue + orderAmount;
      
      // Update seller revenue
      await _usersCollection.doc(sellerId).update({
        'dailyRevenue': newDailyRevenue,
        'totalRevenue': newTotalRevenue,
        'lastRevenueUpdate': FieldValue.serverTimestamp(),
      });
      
      print('🔍 [DatabaseService] Updated seller revenue for $sellerId - Daily: $newDailyRevenue, Total: $newTotalRevenue');
    } catch (e) {
      print('🔍 [DatabaseService] Error updating seller revenue: $e');
      throw e;
    }
  }

  // Helper method to send order status notifications
  Future<void> _sendOrderStatusNotification(String orderId, String status) async {
    try {
      final notificationService = NotificationService();
      
      // Get order details
      final orderDoc = await _ordersCollection.doc(orderId).get();
      if (!orderDoc.exists) return;
      
      final orderData = orderDoc.data() as Map<String, dynamic>;
      final customerId = orderData['customerId'] as String;
      final storeId = orderData['storeId'] as String;
      final productName = orderData['productName'] as String;
      
      // Get store info (sender)
      final storeInfo = await _getUserInfo(storeId);
      
      // Determine notification type
      NotificationType notificationType;
      switch (status) {
        case 'confirmed':
          notificationType = NotificationType.orderConfirmed;
          break;
        case 'shipped':
          notificationType = NotificationType.orderShipped;
          break;
        case 'delivered':
          notificationType = NotificationType.orderDelivered;
          break;
        case 'cancelled':
          notificationType = NotificationType.orderCancelled;
          break;
        default:
          return; // Don't send notification for other statuses
      }
      
      await notificationService.sendOrderStatusNotification(
        recipientId: customerId,
        senderId: storeId,
        senderName: storeInfo?['name'],
        senderPhotoUrl: storeInfo?['photoUrl'],
        statusType: notificationType,
        productName: productName,
        orderId: orderId,
      );
    } catch (e) {
      print('Error sending order status notification: $e');
    }
  }

    Stream<List<store_order.StoreOrder>> getStoreOrders(String storeId) {
    print('🔍 [DatabaseService] getStoreOrders called with storeId: $storeId');
    try {
      // Query both the main orders collection and the store owner's subcollection
      // for maximum compatibility
      return _ordersCollection
          .where('storeId', isEqualTo: storeId)
          .snapshots()
          .map((snapshot) {
            print('🔍 [DatabaseService] getStoreOrders Firestore snapshot received');
            print('🔍 [DatabaseService] getStoreOrders Snapshot docs count: ${snapshot.docs.length}');
            print('🔍 [DatabaseService] getStoreOrders Snapshot metadata: ${snapshot.metadata}');
            
            // Sort manually to avoid index issues for now
            final sortedDocs = snapshot.docs..sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aTime = aData['createdAt'] ?? aData['timestamp'];
              final bTime = bData['createdAt'] ?? bData['timestamp'];
              
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              
              final aTimestamp = aTime is Timestamp ? aTime.toDate() : DateTime.now();
              final bTimestamp = bTime is Timestamp ? bTime.toDate() : DateTime.now();
              
              return bTimestamp.compareTo(aTimestamp); // descending order
            });
            
            final orders = sortedDocs.map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                print('🔍 [DatabaseService] getStoreOrders Raw order data: $data');
                
                // Convert the order data to StoreOrder format
                final order = store_order.StoreOrder(
                  id: data['id'] ?? doc.id,
                  customerId: data['customerId'] ?? data['userId'] ?? '',
                  customerName: data['customerName'] ?? 'Customer',
                  storeId: data['storeId'] ?? storeId,
                  storeName: data['storeName'] ?? 'Store',
                  productId: data['productId'] ?? '',
                  productName: data['productName'] ?? '',
                  productImageUrl: data['productImageUrl'] ?? data['productImage'] ?? '',
                  price: (data['price'] ?? data['productPrice'] ?? 0.0).toDouble(),
                  quantity: data['quantity'] ?? 1,
                  status: data['status'] ?? 'pending',
                  createdAt: data['createdAt'] != null 
                      ? (data['createdAt'] as Timestamp).toDate()
                      : (data['timestamp'] != null 
                          ? (data['timestamp'] as Timestamp).toDate()
                          : DateTime.now()),
                  updatedAt: data['updatedAt'] != null 
                      ? (data['updatedAt'] as Timestamp).toDate()
                      : (data['timestamp'] != null 
                          ? (data['timestamp'] as Timestamp).toDate()
                          : DateTime.now()),
                  chatMessageId: data['chatMessageId'] ?? '',
                );
                
                print('🔍 [DatabaseService] getStoreOrders Successfully parsed order: ${order.id} - ${order.productName} (${order.status})');
                return order;
              } catch (e) {
                print('🔍 [DatabaseService] getStoreOrders Error parsing order document ${doc.id}: $e');
                print('🔍 [DatabaseService] getStoreOrders Document data: ${doc.data()}');
                throw e;
              }
            }).toList();
            
            print('🔍 [DatabaseService] getStoreOrders Successfully parsed ${orders.length} orders');
            return orders;
          }).handleError((error) {
            print('🔍 [DatabaseService] getStoreOrders Error in stream: $error');
            print('🔍 [DatabaseService] getStoreOrders Error type: ${error.runtimeType}');
            if (error.toString().contains('indexes?create_composite=')) {
              print('🔗 [DatabaseService] Index creation URL:');
              print('https://console.firebase.google.com/v1/r/${error.toString().split('indexes?create_composite=')[1].split("'")[0]}');
            }
            throw error;
          });
    } catch (e) {
      print('🔍 [DatabaseService] getStoreOrders Error setting up query: $e');
      rethrow;
    }
  }

  Stream<List<store_order.StoreOrder>> getUserOrders(String userId) {
    print('🔍 [DatabaseService] getUserOrders called with userId: $userId');
    try {
      // Query the user's orders subcollection for new payment on delivery orders
      return _usersCollection
          .doc(userId)
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            print('🔍 [DatabaseService] getUserOrders Firestore snapshot received');
            print('🔍 [DatabaseService] getUserOrders Snapshot docs count: ${snapshot.docs.length}');
            print('🔍 [DatabaseService] getUserOrders Snapshot metadata: ${snapshot.metadata}');
            
            final orders = snapshot.docs.map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                print('🔍 [DatabaseService] getUserOrders Raw order data: $data');
                
                // Convert the order data to StoreOrder format
                final order = store_order.StoreOrder(
                  id: data['id'] ?? doc.id,
                  customerId: data['userId'] ?? userId,
                  customerName: data['customerName'] ?? 'Customer',
                  storeId: data['storeId'] ?? '',
                  storeName: data['storeName'] ?? 'Store',
                  productId: data['productId'] ?? '',
                  productName: data['productName'] ?? '',
                  productImageUrl: data['productImage'] ?? '',
                  price: (data['productPrice'] ?? 0.0).toDouble(),
                  quantity: data['quantity'] ?? 1,
                  status: data['status'] ?? 'pending',
                  createdAt: data['timestamp'] != null 
                      ? (data['timestamp'] as Timestamp).toDate()
                      : DateTime.now(),
                  updatedAt: data['timestamp'] != null 
                      ? (data['timestamp'] as Timestamp).toDate()
                      : DateTime.now(),
                  chatMessageId: data['chatMessageId'] ?? '',
                );
                
                print('🔍 [DatabaseService] getUserOrders Successfully parsed order: ${order.id} - ${order.productName} (${order.status})');
                return order;
              } catch (e) {
                print('🔍 [DatabaseService] getUserOrders Error parsing order document ${doc.id}: $e');
                print('🔍 [DatabaseService] getUserOrders Document data: ${doc.data()}');
                throw e;
              }
            }).toList();
            
            print('🔍 [DatabaseService] getUserOrders Successfully parsed ${orders.length} orders');
            return orders;
          }).handleError((error) {
            print('🔍 [DatabaseService] getUserOrders Error in stream: $error');
            print('🔍 [DatabaseService] getUserOrders Error type: ${error.runtimeType}');
            throw error;
          });
    } catch (e) {
      print('🔍 [DatabaseService] getUserOrders Error setting up query: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getUserConversations(String userId) {
    print('🔍 [DatabaseService] getUserConversations called with userId: $userId');
    try {
      return _chatMessagesCollection
          .where('senderId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            print('🔍 [DatabaseService] getUserConversations Firestore snapshot received');
            print('🔍 [DatabaseService] getUserConversations Snapshot docs count: ${snapshot.docs.length}');
            print('🔍 [DatabaseService] getUserConversations Snapshot metadata: ${snapshot.metadata}');
            
            final conversations = <Map<String, dynamic>>[];
            final seenReceivers = <String>{};

            for (final doc in snapshot.docs) {
              try {
                final data = doc.data() as Map<String, dynamic>?;
                print('🔍 [DatabaseService] getUserConversations Processing doc ${doc.id}: $data');
                print('🔍 [DatabaseService] getUserConversations Doc data type: ${data.runtimeType}');
                print('🔍 [DatabaseService] getUserConversations Doc data keys: ${data?.keys.toList()}');
                
                final receiverId = data?['receiverId'] as String?;
                final message = data?['message'] as String?;
                final timestamp = data?['timestamp'] as Timestamp?;

                print('🔍 [DatabaseService] getUserConversations Extracted: receiverId=$receiverId, message=$message, timestamp=$timestamp');
                print('🔍 [DatabaseService] getUserConversations receiverId type: ${receiverId.runtimeType}');
                print('🔍 [DatabaseService] getUserConversations message type: ${message.runtimeType}');
                print('🔍 [DatabaseService] getUserConversations timestamp type: ${timestamp.runtimeType}');

                if (receiverId != null && message != null && timestamp != null && !seenReceivers.contains(receiverId)) {
                  seenReceivers.add(receiverId);
                  conversations.add({
                    'receiverId': receiverId,
                    'lastMessage': message,
                    'timestamp': timestamp.toDate(),
                  });
                  print('🔍 [DatabaseService] getUserConversations Added conversation with receiverId: $receiverId');
                } else {
                  print('🔍 [DatabaseService] getUserConversations Skipped doc ${doc.id}: receiverId=$receiverId, message=$message, timestamp=$timestamp, seenReceivers=$seenReceivers');
                  print('🔍 [DatabaseService] getUserConversations Skip reason: receiverId null=${receiverId == null}, message null=${message == null}, timestamp null=${timestamp == null}, already seen=${seenReceivers.contains(receiverId)}');
                }
              } catch (e) {
                print('🔍 [DatabaseService] getUserConversations Error processing doc ${doc.id}: $e');
                print('🔍 [DatabaseService] getUserConversations Error stack trace: ${StackTrace.current}');
                print('🔍 [DatabaseService] getUserConversations Document data: ${doc.data()}');
              }
            }

            print('🔍 [DatabaseService] getUserConversations Final conversations count: ${conversations.length}');
            print('🔍 [DatabaseService] getUserConversations Conversations: $conversations');
            return conversations;
          }).handleError((error) {
            print('🔍 [DatabaseService] getUserConversations Error in stream: $error');
            print('🔍 [DatabaseService] getUserConversations Error type: ${error.runtimeType}');
            throw error;
          });
    } catch (e) {
      print('🔍 [DatabaseService] getUserConversations Error setting up query: $e');
      rethrow;
    }
  }

  Stream<List<store_order.StoreOrder>> getCustomerOrders(String customerId) {
    return _ordersCollection
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => store_order.StoreOrder.fromFirestore(doc)).toList());
  }

  Stream<List<store_order.StoreOrder>> getActiveStoreOrders(String storeId) {
    return _ordersCollection
        .where('storeId', isEqualTo: storeId)
        .where('status', whereIn: ['ordered', 'pending', 'confirmed', 'shipped'])
        .snapshots()
        .map((snapshot) {
          // Sort manually to avoid index issues and handle both new and old order formats
          final sortedDocs = snapshot.docs..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['timestamp'] ?? aData['createdAt'];
            final bTime = bData['timestamp'] ?? bData['createdAt'];
            
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            
            final aTimestamp = aTime is Timestamp ? aTime.toDate() : DateTime.now();
            final bTimestamp = bTime is Timestamp ? bTime.toDate() : DateTime.now();
            
            return bTimestamp.compareTo(aTimestamp); // descending order
          });
          
          return sortedDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            // Convert new order format to StoreOrder format for compatibility
            return store_order.StoreOrder(
              id: data['id'] ?? doc.id,
              customerId: data['userId'] ?? data['customerId'] ?? '',
              customerName: 'Customer',
              storeId: data['storeId'] ?? storeId,
              storeName: 'Store',
              productId: data['productId'] ?? '',
              productName: data['productName'] ?? '',
              productImageUrl: data['productImage'] ?? data['productImageUrl'] ?? '',
              price: (data['productPrice'] ?? data['price'] ?? 0.0).toDouble(),
              quantity: data['quantity'] ?? 1,
              status: data['status'] ?? 'pending',
              createdAt: data['timestamp'] != null 
                  ? (data['timestamp'] as Timestamp).toDate()
                  : data['createdAt'] != null
                    ? (data['createdAt'] as Timestamp).toDate()
                    : DateTime.now(),
              updatedAt: data['timestamp'] != null 
                  ? (data['timestamp'] as Timestamp).toDate()
                  : data['updatedAt'] != null
                    ? (data['updatedAt'] as Timestamp).toDate()
                    : DateTime.now(),
              chatMessageId: data['chatMessageId'] ?? '',
            );
          }).toList();
        });
  }

  Future<void> updateGiftIsRead(String giftId, bool isRead) async {
    try {
      await _db.collection('gifts').doc(giftId).update({'isRead': isRead});
    } catch (e) {
      print('Error updating gift isRead: $e');
      rethrow;
    }
  }

  /// Returns the number of completed (delivered) orders for a given store product.
  Future<int> getStoreProductOrderCount(String productId) async {
    final snapshot = await _ordersCollection
        .where('productId', isEqualTo: productId)
        .where('status', isEqualTo: 'delivered')
        .get();
    return snapshot.docs.length;
  }

  /// Updates the totalOrders field for all store products to match the real order count from the orders collection.
  Future<void> syncAllStoreProductOrderCounts() async {
    final productsSnapshot = await _storeProductsCollection.get();
    for (final doc in productsSnapshot.docs) {
      final productId = doc.id;
      final realOrderCount = await getStoreProductOrderCount(productId);
      await doc.reference.update({'totalOrders': realOrderCount});
    }
  }

  /// Search marketplace products by query string
  Stream<List<MarketplaceProduct>> searchMarketplaceProducts({
    required String query,
    String? category,
    bool? freeShippingOnly,
    String sortBy = 'orders', // 'orders', 'price_low', 'price_high', 'newest'
    int limit = 50,
  }) {
    if (query.trim().isEmpty) {
      return Stream.value([]);
    }

    final searchQuery = query.toLowerCase().trim();

    return CombineLatestStream.combine2(
      getAliexpressListings(limit: limit),
      getStoreProducts(limit: limit),
      (List<AliexpressProduct> aliProducts, List<StoreProduct> storeProducts) {
        final products = [
          ...aliProducts.map(MarketplaceProduct.fromAliexpress),
          ...storeProducts.map(MarketplaceProduct.fromStore),
        ];

        // Filter by search query
        final filteredProducts = products.where((product) {
          final name = product.name.toLowerCase();
          final description = product.description.toLowerCase();
          final matchesQuery = name.contains(searchQuery) || description.contains(searchQuery);
          
          // Filter by category if specified
          final matchesCategory = category == null || product.category.toLowerCase() == category.toLowerCase();
          
          // Filter by free shipping if specified
          final matchesShipping = freeShippingOnly == null || !freeShippingOnly || product.isFreeShipping;
          
          return matchesQuery && matchesCategory && matchesShipping;
        }).toList();

        // Sort products
        switch (sortBy) {
          case 'orders':
            filteredProducts.sort((a, b) => b.totalOrders.compareTo(a.totalOrders));
            break;
          case 'price_low':
            filteredProducts.sort((a, b) => a.price.compareTo(b.price));
            break;
          case 'price_high':
            filteredProducts.sort((a, b) => b.price.compareTo(a.price));
            break;
          case 'newest':
            filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            break;
        }

        return filteredProducts.take(limit).toList();
      },
    );
  }

  // ==================== APPOINTMENT METHODS ====================

  // Create a new appointment
  Future<String> createAppointment(Appointment appointment) async {
    try {
      print('🔍 [DatabaseService] Creating appointment for ${appointment.petName} on ${appointment.appointmentDate}');
      print('🔍 [DatabaseService] VetId: ${appointment.vetId}, UserId: ${appointment.userId}, PetId: ${appointment.petId}');
      
      final appointmentData = appointment.toFirestore();
      print('🔍 [DatabaseService] Appointment data: $appointmentData');
      
      final docRef = await _appointmentsCollection.add(appointmentData);
      print('🔍 [DatabaseService] Appointment created with ID: ${docRef.id}');
      
      // Send notification to vet
      final notification = AppNotification(
        id: '',
        recipientId: appointment.vetId,
        senderId: appointment.userId,
        type: NotificationType.appointmentRequest,
        title: 'New Appointment Request',
        body: 'New appointment request for ${appointment.petName} on ${_formatDate(appointment.appointmentDate)}',
        data: {
          'appointmentId': docRef.id,
          'userId': appointment.userId,
          'petName': appointment.petName,
        },
        createdAt: DateTime.now(),
        relatedId: docRef.id,
      );
      await NotificationService().sendNotification(notification);
      print('🔍 [DatabaseService] Notification sent to vet');

      return docRef.id;
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow;
    }
  }

  // Get appointments for a vet
  Stream<List<Appointment>> getVetAppointments(String vetId, {AppointmentStatus? status}) {
    print('🔍 [DatabaseService] getVetAppointments called - vetId: $vetId, status: $status');
    
    try {
      return _appointmentsCollection
          .where('vetId', isEqualTo: vetId)
          .orderBy('appointmentDate', descending: false)
          .snapshots()
          .handleError((error) {
            print('❌ [DatabaseService] getVetAppointments ERROR: $error');
            if (error.toString().contains('indexes?create_composite=')) {
              print('🔗 [DatabaseService] Index creation URL:');
              print('https://console.firebase.google.com/v1/r/${error.toString().split('indexes?create_composite=')[1].split("'")[0]}');
            }
            throw error;
          })
          .map((snapshot) {
            print('🔍 [DatabaseService] getVetAppointments - Found ${snapshot.docs.length} appointments');
            return snapshot.docs.map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                print('🔍 [DatabaseService] Raw appointment data for ${doc.id}: $data');
                final appointment = Appointment.fromFirestore(doc);
                print('🔍 [DatabaseService] Parsed appointment: ${appointment.id} - ${appointment.status.name} - ${appointment.appointmentDate} - ${appointment.timeSlot}');
                return appointment;
              } catch (e) {
                print('🔍 [DatabaseService] Error parsing appointment ${doc.id}: $e');
                return null;
              }
            }).where((apt) => apt != null).cast<Appointment>().toList()
              .where((apt) => status == null || apt.status == status)
              .toList();
          });
    } catch (e) {
      print('❌ [DatabaseService] getVetAppointments EXCEPTION: $e');
      rethrow;
    }
  }

  // Get appointments for a user
  Stream<List<Appointment>> getUserAppointments(String userId, {AppointmentStatus? status}) {
    print('🔍 [DatabaseService] getUserAppointments called - userId: $userId, status: $status');
    
    try {
      return _appointmentsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('appointmentDate', descending: false)
          .snapshots()
          .handleError((error) {
            print('❌ [DatabaseService] getUserAppointments ERROR: $error');
            if (error.toString().contains('indexes?create_composite=')) {
              print('🔗 [DatabaseService] Index creation URL:');
              print('https://console.firebase.google.com/v1/r/${error.toString().split('indexes?create_composite=')[1].split("'")[0]}');
            }
            throw error;
          })
          .map((snapshot) {
            print('🔍 [DatabaseService] getUserAppointments - Found ${snapshot.docs.length} appointments');
            return snapshot.docs.map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                print('🔍 [DatabaseService] Raw appointment data for ${doc.id}: $data');
                final appointment = Appointment.fromFirestore(doc);
                print('🔍 [DatabaseService] Parsed appointment: ${appointment.id} - ${appointment.status.name} - ${appointment.appointmentDate} - ${appointment.timeSlot}');
                return appointment;
              } catch (e) {
                print('🔍 [DatabaseService] Error parsing appointment ${doc.id}: $e');
                return null;
              }
            }).where((apt) => apt != null).cast<Appointment>().toList()
              .where((apt) => status == null || apt.status == status)
              .toList();
          });
    } catch (e) {
      print('❌ [DatabaseService] getUserAppointments EXCEPTION: $e');
      rethrow;
    }
  }

  // Get today's appointments for a user
  Stream<List<Appointment>> getUserTodayAppointments(String userId) {
    print('🔍 [DatabaseService] getUserTodayAppointments called - userId: $userId');
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    print('🔍 [DatabaseService] Date range: $today to $tomorrow');

    try {
      return _appointmentsCollection
          .where('userId', isEqualTo: userId)
          .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
          .where('appointmentDate', isLessThan: Timestamp.fromDate(tomorrow))
          .snapshots()
          .handleError((error) {
            print('❌ [DatabaseService] getUserTodayAppointments ERROR: $error');
            if (error.toString().contains('indexes?create_composite=')) {
              print('🔗 [DatabaseService] Index creation URL:');
              print('https://console.firebase.google.com/v1/r/${error.toString().split('indexes?create_composite=')[1].split("'")[0]}');
            }
            throw error;
          })
          .map((snapshot) {
            print('🔍 [DatabaseService] getUserTodayAppointments - Found ${snapshot.docs.length} appointments in date range');
            return snapshot.docs.map((doc) {
              try {
                final appointment = Appointment.fromFirestore(doc);
                // Filter by status in memory to avoid composite index requirement
                if (appointment.status == AppointmentStatus.pending || 
                    appointment.status == AppointmentStatus.confirmed) {
                  print('🔍 [DatabaseService] Today\'s appointment: ${appointment.petName} at ${appointment.formattedTime}');
                  return appointment;
                }
                return null;
              } catch (e) {
                print('🔍 [DatabaseService] Error parsing today\'s appointment ${doc.id}: $e');
                return null;
              }
            }).where((apt) => apt != null).cast<Appointment>().toList()
              ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
          });
    } catch (e) {
      print('❌ [DatabaseService] getUserTodayAppointments EXCEPTION: $e');
      rethrow;
    }
  }

  // Update appointment
  Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _appointmentsCollection.doc(appointment.id).update(appointment.toFirestore());
      print('🔍 [DatabaseService] Appointment ${appointment.id} updated successfully');
    } catch (e) {
      print('Error updating appointment: $e');
      rethrow;
    }
  }

  // Delete appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _appointmentsCollection.doc(appointmentId).delete();
      print('🔍 [DatabaseService] Appointment $appointmentId deleted successfully');
    } catch (e) {
      print('Error deleting appointment: $e');
      rethrow;
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status, {String? vetNotes}) async {
    try {
      final updateData = {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (vetNotes != null) {
        updateData['vetNotes'] = vetNotes;
      }

      await _appointmentsCollection.doc(appointmentId).update(updateData);

      // Get appointment details for notification
      final appointmentDoc = await _appointmentsCollection.doc(appointmentId).get();
      if (appointmentDoc.exists) {
        final appointment = Appointment.fromFirestore(appointmentDoc);
        
        // Send notification to user
        String title = '';
        String body = '';
        
        switch (status) {
          case AppointmentStatus.confirmed:
            title = 'Appointment Confirmed';
            body = 'Your appointment for ${appointment.petName} has been confirmed';
            break;
          case AppointmentStatus.cancelled:
            title = 'Appointment Cancelled';
            body = 'Your appointment for ${appointment.petName} has been cancelled';
            break;
          case AppointmentStatus.completed:
            title = 'Appointment Completed';
            body = 'Your appointment for ${appointment.petName} has been completed';
            break;
          default:
            break;
        }

        if (title.isNotEmpty) {
          final notification = AppNotification(
            id: '',
            recipientId: appointment.userId,
            senderId: appointment.vetId,
            type: NotificationType.appointmentUpdate,
            title: title,
            body: body,
            data: {
              'appointmentId': appointmentId,
              'status': status.name,
            },
            createdAt: DateTime.now(),
            relatedId: appointmentId,
          );
          await NotificationService().sendNotification(notification);
        }
      }
    } catch (e) {
      print('Error updating appointment status: $e');
      rethrow;
    }
  }

  // Get available time slots for a vet on a specific date
  Future<List<TimeSlot>> getAvailableTimeSlots(String vetId, DateTime date) async {
    try {
      // Get vet's schedule
      final scheduleDoc = await _vetSchedulesCollection.doc(vetId).get();
      VetSchedule schedule;
      
      if (scheduleDoc.exists) {
        schedule = VetSchedule.fromFirestore(scheduleDoc);
      } else {
        // Create default schedule for new vet
        schedule = VetSchedule.createDefault(vetId);
        await _vetSchedulesCollection.doc(vetId).set(schedule.toFirestore());
      }

      // Check if date is blocked
      if (schedule.isDateBlocked(date)) {
        return [];
      }

      // Get time slots for the day
      final dayTimeSlots = schedule.getTimeSlotsForDate(date);
      
      // Get existing appointments for this date
      final existingAppointments = await _appointmentsCollection
          .where('vetId', isEqualTo: vetId)
          .where('appointmentDate', isEqualTo: Timestamp.fromDate(DateTime(date.year, date.month, date.day)))
          .where('status', whereIn: [AppointmentStatus.pending.name, AppointmentStatus.confirmed.name])
          .get();

      final bookedTimeSlots = existingAppointments.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['timeSlot'] as String)
          .toSet();

      // Create available time slots
      final availableSlots = <TimeSlot>[];
      for (final timeSlot in dayTimeSlots) {
        final endTime = _calculateEndTime(timeSlot, schedule.appointmentDuration);
        final slot = TimeSlot(
          id: '${vetId}_${date.millisecondsSinceEpoch}_$timeSlot',
          vetId: vetId,
          date: date,
          startTime: timeSlot,
          endTime: endTime,
          isAvailable: !bookedTimeSlots.contains('$timeSlot-$endTime'),
          duration: schedule.appointmentDuration,
        );
        
        // Only include future time slots
        if (!slot.isPast) {
          availableSlots.add(slot);
        }
      }

      return availableSlots;
    } catch (e) {
      print('Error getting available time slots: $e');
      return [];
    }
  }

  // Get or create vet schedule
  Future<VetSchedule> getVetSchedule(String vetId) async {
    try {
      final doc = await _vetSchedulesCollection.doc(vetId).get();
      if (doc.exists) {
        return VetSchedule.fromFirestore(doc);
      } else {
        // Create default schedule
        final defaultSchedule = VetSchedule.createDefault(vetId);
        await _vetSchedulesCollection.doc(vetId).set(defaultSchedule.toFirestore());
        return defaultSchedule;
      }
    } catch (e) {
      print('Error getting vet schedule: $e');
      return VetSchedule.createDefault(vetId);
    }
  }

  // Update vet schedule
  Future<void> updateVetSchedule(VetSchedule schedule) async {
    try {
      await _vetSchedulesCollection.doc(schedule.vetId).set(schedule.toFirestore());
      
      // Get all appointments for this vet
      final appointments = await _appointmentsCollection
          .where('vetId', isEqualTo: schedule.vetId)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      // Check each appointment against the new schedule
      for (final doc in appointments.docs) {
        final appointment = Appointment.fromFirestore(doc);
        final dayName = _getDayName(appointment.appointmentDate.weekday);
        final availableSlots = schedule.weeklySchedule[dayName] ?? [];

        // If the appointment time is no longer in available slots, cancel it
        if (!availableSlots.contains(appointment.timeSlot.split('-')[0])) {
          await cancelAppointment(
            doc.id,
            'Appointment cancelled due to schedule change',
            isVetCancellation: true,
          );
        }
      }
    } catch (e) {
      print('Error updating vet schedule: $e');
      rethrow;
    }
  }



  // Get vet dashboard stats with real appointment data
  Stream<List<Map<String, dynamic>>> getVetDashboardStats(String vetId) {
    return _appointmentsCollection
        .where('vetId', isEqualTo: vetId)
        .snapshots()
        .map((snapshot) {
      try {
        final appointments = snapshot.docs.map((doc) {
          try {
            final appointment = Appointment.fromFirestore(doc);
            return appointment;
          } catch (e) {
            print('🔍 [DatabaseService] Error parsing appointment ${doc.id}: $e');
            return null;
          }
        }).where((apt) => apt != null).cast<Appointment>().toList();

        // Filter appointments for this specific vet
        final vetAppointments = appointments.where((apt) => apt.vetId == vetId).toList();

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));

        // Count appointments for today
        final appointmentsToday = vetAppointments.where((apt) {
          try {
          final aptDate = DateTime(apt.appointmentDate.year, apt.appointmentDate.month, apt.appointmentDate.day);
            final isToday = aptDate.isAtSameMomentAs(today);
            final isValidStatus = apt.status == AppointmentStatus.pending || apt.status == AppointmentStatus.confirmed;
            return isToday && isValidStatus;
          } catch (e) {
            print('🔍 [DatabaseService] Error checking appointment ${apt.id}: $e');
            return false;
          }
        }).length;

        // Find next appointment
        final upcomingAppointments = vetAppointments.where((apt) {
          try {
            final isUpcoming = apt.isUpcoming;
            return isUpcoming;
          } catch (e) {
            print('🔍 [DatabaseService] Error checking if appointment ${apt.id} is upcoming: $e');
            return false;
          }
        }).toList();
        
        upcomingAppointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
        
        String nextAppointment = 'No upcoming';
        if (upcomingAppointments.isNotEmpty) {
          try {
          final next = upcomingAppointments.first;
          final nextDate = DateTime(next.appointmentDate.year, next.appointmentDate.month, next.appointmentDate.day);
          if (nextDate.isAtSameMomentAs(today)) {
            nextAppointment = 'Today at ${next.formattedTime}';
          } else if (nextDate.isAtSameMomentAs(tomorrow)) {
            nextAppointment = 'Tomorrow at ${next.formattedTime}';
          } else {
            nextAppointment = '${_formatDate(next.appointmentDate)} at ${next.formattedTime}';
            }
          } catch (e) {
            print('🔍 [DatabaseService] Error formatting next appointment: $e');
            nextAppointment = 'No upcoming';
          }
        }

        // Count total patients (unique pet IDs)
        final uniquePetIds = vetAppointments.map((apt) => apt.petId).where((id) => id.isNotEmpty).toSet();
        final patientsCount = uniquePetIds.length;

        // Calculate revenue for today from completed appointments (real-time)
        final revenueToday = vetAppointments.where((apt) {
          try {
          final aptDate = DateTime(apt.appointmentDate.year, apt.appointmentDate.month, apt.appointmentDate.day);
            final isToday = aptDate.isAtSameMomentAs(today);
            final isCompleted = apt.status == AppointmentStatus.completed;
            return isToday && isCompleted;
          } catch (e) {
            print('🔍 [DatabaseService] Error checking revenue for appointment ${apt.id}: $e');
            return false;
          }
        }).fold(0.0, (sum, apt) => sum + (apt.price ?? 0.0));

        final result = [
          {
            'nextAppointment': nextAppointment,
            'patientsCount': patientsCount,
            'appointmentsToday': appointmentsToday,
            'revenueToday': revenueToday,
          }
        ];
        
        return result;
      } catch (e) {
        print('🔍 [DatabaseService] getVetDashboardStats error: $e');
        return [
          {
            'nextAppointment': 'No upcoming',
            'patientsCount': 0,
            'appointmentsToday': 0,
            'revenueToday': 0.0,
          }
        ];
      }
    }).handleError((error) {
      if (error.toString().contains('indexes?create_composite=')) {
        print('\n🔍 [DatabaseService] Index creation URL:');
        print('https://console.firebase.google.com/v1/r/${error.toString().split('indexes?create_composite=')[1].split("'")[0]}');
      }
      print('🔍 [DatabaseService] getVetDashboardStats stream error: $error');
      return [
        {
          'nextAppointment': 'No upcoming',
          'patientsCount': 0,
          'appointmentsToday': 0,
          'revenueToday': 0.0,
        }
      ];
    });
  }

  // Helper methods
  String _calculateEndTime(String startTime, int durationMinutes) {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    final startDateTime = DateTime(2024, 1, 1, hour, minute);
    final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));
    
    return '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  // Add revenue to a specific day
  Future<void> addRevenueToDay({
    required String userId,
    required DateTime date,
    required double revenue,
  }) async {
    try {
      // Create a date string for the specific day
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Reference to the user's revenue document
      final revenueDoc = _usersCollection.doc(userId).collection('revenue').doc(dateString);
      
      // Get current revenue for this day
      final currentDoc = await revenueDoc.get();
      double currentRevenue = 0.0;
      
      if (currentDoc.exists) {
        currentRevenue = (currentDoc.data()?['total'] ?? 0.0).toDouble();
      }
      
      // Add new revenue to the total
      final newTotal = currentRevenue + revenue;
      
      // Update the document
      await revenueDoc.set({
        'date': dateString,
        'total': newTotal,
        'lastUpdated': FieldValue.serverTimestamp(),
        'transactions': FieldValue.arrayUnion([
          {
            'amount': revenue,
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'appointment_completion',
          }
        ]),
      }, SetOptions(merge: true));
      
      print('🔍 [DatabaseService] Added revenue of \$${revenue.toStringAsFixed(2)} to $dateString. New total: \$${newTotal.toStringAsFixed(2)}');
    } catch (e) {
      print('🔍 [DatabaseService] Error adding revenue: $e');
      throw e;
    }
  }

  // Get revenue for a specific day
  Future<double> getRevenueForDay(String userId, DateTime date) async {
    try {
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final revenueDoc = _usersCollection.doc(userId).collection('revenue').doc(dateString);
      final doc = await revenueDoc.get();
      
      if (doc.exists) {
        return (doc.data()?['total'] ?? 0.0).toDouble();
      }
      return 0.0;
    } catch (e) {
      print('🔍 [DatabaseService] Error getting revenue for day: $e');
      return 0.0;
    }
  }

  // Get revenue for a date range
  Future<double> getRevenueForDateRange(String userId, DateTime startDate, DateTime endDate) async {
    try {
      double totalRevenue = 0.0;
      final currentDate = DateTime(startDate.year, startDate.month, startDate.day);
      final endDateNormalized = DateTime(endDate.year, endDate.month, endDate.day);
      
      DateTime date = currentDate;
      while (!date.isAfter(endDateNormalized)) {
        totalRevenue += await getRevenueForDay(userId, date);
        date = date.add(const Duration(days: 1));
      }
      
      return totalRevenue;
    } catch (e) {
      print('🔍 [DatabaseService] Error getting revenue for date range: $e');
      return 0.0;
    }
  }

  // Get appointments for vet dashboard (all appointments, filtered by UI)
  Stream<List<Appointment>> getVetAppointmentsForDashboard(String vetId) {
    print('🔍 [DatabaseService] getVetAppointmentsForDashboard called for vetId: $vetId');

    try {
      return _appointmentsCollection
          .where('vetId', isEqualTo: vetId)
          .orderBy('appointmentDate', descending: false)
          .snapshots()
          .handleError((error) {
            print('❌ [DatabaseService] getVetAppointmentsForDashboard ERROR: $error');
            if (error.toString().contains('indexes?create_composite=')) {
              print('🔗 [DatabaseService] Index creation URL:');
              print('https://console.firebase.google.com/v1/r/${error.toString().split('indexes?create_composite=')[1].split("'")[0]}');
            }
            throw error;
          })
          .map((snapshot) {
            print('🔍 [DatabaseService] getVetAppointmentsForDashboard - Found ${snapshot.docs.length} appointments for vet');
            final appointments = snapshot.docs.map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                print('🔍 [DatabaseService] Raw appointment data for ${doc.id}: $data');
                final appointment = Appointment.fromFirestore(doc);
                print('🔍 [DatabaseService] Parsed appointment: ${appointment.id} - ${appointment.status.name} - ${appointment.appointmentDate} - ${appointment.timeSlot}');
                return appointment;
              } catch (e) {
                print('🔍 [DatabaseService] Error parsing appointment ${doc.id}: $e');
                return null;
              }
            }).where((apt) => apt != null).cast<Appointment>().toList();
            
            print('🔍 [DatabaseService] Returning ${appointments.length} valid appointments');
            return appointments;
          });
    } catch (e) {
      print('❌ [DatabaseService] getVetAppointmentsForDashboard EXCEPTION: $e');
      rethrow;
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId, String reason, {bool isVetCancellation = false}) async {
    try {
      await _appointmentsCollection.doc(appointmentId).update({
        'status': AppointmentStatus.cancelled.name,
        'vetNotes': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Get appointment details for notification
      final appointmentDoc = await _appointmentsCollection.doc(appointmentId).get();
      if (appointmentDoc.exists) {
        final appointment = Appointment.fromFirestore(appointmentDoc);
        
        // Send notification to the other party
        final recipientId = isVetCancellation ? appointment.userId : appointment.vetId;
        final title = isVetCancellation ? 'Appointment Cancelled by Vet' : 'Appointment Cancelled';
        final body = 'Appointment for ${appointment.petName} on ${_formatDate(appointment.appointmentDate)} has been cancelled';
        
        final notification = AppNotification(
          id: '',
          recipientId: recipientId,
          senderId: isVetCancellation ? appointment.vetId : appointment.userId,
          type: NotificationType.appointmentUpdate,
          title: title,
          body: body,
          data: {
            'appointmentId': appointmentId,
            'reason': reason,
          },
          createdAt: DateTime.now(),
          relatedId: appointmentId,
        );
        await NotificationService().sendNotification(notification);
      }
    } catch (e) {
      print('Error cancelling appointment: $e');
      rethrow;
    }
  }

  Future<void> updateUserPatients(String userId, List<String> patients) async {
    await _usersCollection.doc(userId).update({'patients': patients});
  }

  // Update appointment price when revenue is added
  Future<void> updateAppointmentPrice(String appointmentId, double price) async {
    try {
      await _appointmentsCollection.doc(appointmentId).update({
        'price': price,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('🔍 [DatabaseService] Updated appointment $appointmentId with price: \$${price.toStringAsFixed(2)}');
    } catch (e) {
      print('🔍 [DatabaseService] Error updating appointment price: $e');
      throw e;
    }
  }

  // Update appointment progress (start/end appointment)
  Future<void> updateAppointmentProgress({
    required String appointmentId,
    required bool isInProgress,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'isInProgress': isInProgress,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (startedAt != null) {
        updateData['startedAt'] = Timestamp.fromDate(startedAt);
      }

      if (endedAt != null) {
        updateData['endedAt'] = Timestamp.fromDate(endedAt);
      }

      await _appointmentsCollection.doc(appointmentId).update(updateData);
      
      final action = isInProgress ? 'started' : 'ended';
      print('🔍 [DatabaseService] Appointment $appointmentId $action');
    } catch (e) {
      print('🔍 [DatabaseService] Error updating appointment progress: $e');
      throw e;
    }
  }

  // Get vet analytics data
  Stream<Map<String, dynamic>> getVetAnalytics(String vetId) {
    print('🔍 [DatabaseService] getVetAnalytics called for vetId: $vetId');
    
    return _appointmentsCollection
        .where('vetId', isEqualTo: vetId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) {
          final appointments = snapshot.docs.map((doc) {
            try {
              return Appointment.fromFirestore(doc);
            } catch (e) {
              print('Error parsing appointment ${doc.id}: $e');
              return null;
            }
          }).where((apt) => apt != null).cast<Appointment>().toList();

          print('🔍 [DatabaseService] Found ${appointments.length} appointments for analytics');
          
          // Debug: Show first few appointments
          for (int i = 0; i < appointments.length && i < 5; i++) {
            final apt = appointments[i];
            print('🔍 [DatabaseService] Appointment $i: ${apt.petName} on ${apt.appointmentDate} - Status: ${apt.status} - Type: ${apt.type}');
          }

          final now = DateTime.now();
          final thisMonth = DateTime(now.year, now.month, 1);
          final lastMonth = DateTime(now.year, now.month - 1, 1);
          final thisWeek = now.subtract(Duration(days: now.weekday - 1));
          final lastWeek = thisWeek.subtract(const Duration(days: 7));

          // Filter appointments by time periods
          final thisMonthAppointments = appointments.where((apt) => 
            apt.appointmentDate.year == now.year && apt.appointmentDate.month == now.month
          ).toList();

          final lastMonthAppointments = appointments.where((apt) => 
            (apt.appointmentDate.year == now.year && apt.appointmentDate.month == now.month - 1) ||
            (now.month == 1 && apt.appointmentDate.year == now.year - 1 && apt.appointmentDate.month == 12)
          ).toList();

          final thisWeekAppointments = appointments.where((apt) => 
            apt.appointmentDate.isAfter(thisWeek.subtract(const Duration(days: 1)))
          ).toList();

          final lastWeekAppointments = appointments.where((apt) => 
            apt.appointmentDate.isAfter(lastWeek.subtract(const Duration(days: 1))) &&
            apt.appointmentDate.isBefore(thisWeek)
          ).toList();

          print('🔍 [DatabaseService] This month appointments found: ${thisMonthAppointments.length}');
          print('🔍 [DatabaseService] Last month appointments found: ${lastMonthAppointments.length}');
          print('🔍 [DatabaseService] This week appointments found: ${thisWeekAppointments.length}');
          print('🔍 [DatabaseService] Last week appointments found: ${lastWeekAppointments.length}');

          // Calculate metrics
          final totalAppointments = appointments.length;
          final completedAppointments = appointments.where((apt) => 
            apt.status == AppointmentStatus.completed
          ).length;
          final pendingAppointments = appointments.where((apt) => 
            apt.status == AppointmentStatus.pending
          ).length;
          final confirmedAppointments = appointments.where((apt) => 
            apt.status == AppointmentStatus.confirmed
          ).length;

          // Calculate unique patients (by petId)
          final uniquePetIds = appointments.map((apt) => apt.petId).toSet();
          final totalPatients = uniquePetIds.length;

          // Calculate new patients this month (pets with first appointment this month)
          final newPatientsThisMonth = uniquePetIds.where((petId) {
            final petAppointments = appointments.where((apt) => apt.petId == petId).toList();
            final firstAppointment = petAppointments.reduce((a, b) => 
              a.appointmentDate.isBefore(b.appointmentDate) ? a : b
            );
            return firstAppointment.appointmentDate.year == now.year && 
                   firstAppointment.appointmentDate.month == now.month;
          }).length;

          print('🔍 [DatabaseService] Total unique pets: ${uniquePetIds.length}');
          print('🔍 [DatabaseService] New patients this month: $newPatientsThisMonth');

          // Calculate revenue from completed appointments (real-time)
          final thisMonthRevenue = thisMonthAppointments.where((apt) => 
            apt.status == AppointmentStatus.completed
          ).fold(0.0, (sum, apt) => sum + (apt.price ?? 0.0));
          
          final lastMonthRevenue = lastMonthAppointments.where((apt) => 
            apt.status == AppointmentStatus.completed
          ).fold(0.0, (sum, apt) => sum + (apt.price ?? 0.0));
          
          final thisWeekRevenue = thisWeekAppointments.where((apt) => 
            apt.status == AppointmentStatus.completed
          ).fold(0.0, (sum, apt) => sum + (apt.price ?? 0.0));
          
          final lastWeekRevenue = lastWeekAppointments.where((apt) => 
            apt.status == AppointmentStatus.completed
          ).fold(0.0, (sum, apt) => sum + (apt.price ?? 0.0));

          // Calculate emergency cases (appointments with emergency type)
          final emergencyCases = appointments.where((apt) => 
            apt.type == AppointmentType.emergency
          ).length;

          // Calculate average appointment duration (mock data for now)
          const averageDuration = 45;

          // Calculate patient satisfaction (mock data for now)
          const patientSatisfaction = 4.8;

          final analytics = {
            'totalAppointments': totalAppointments,
            'completedAppointments': completedAppointments,
            'pendingAppointments': pendingAppointments,
            'confirmedAppointments': confirmedAppointments,
            'totalPatients': totalPatients,
            'newPatientsThisMonth': newPatientsThisMonth,
            'thisMonthRevenue': thisMonthRevenue,
            'lastMonthRevenue': lastMonthRevenue,
            'thisWeekRevenue': thisWeekRevenue,
            'lastWeekRevenue': lastWeekRevenue,
            'emergencyCases': emergencyCases,
            'averageDuration': averageDuration,
            'patientSatisfaction': patientSatisfaction,
            'thisMonthAppointments': thisMonthAppointments.length,
            'lastMonthAppointments': lastMonthAppointments.length,
            'thisWeekAppointments': thisWeekAppointments.length,
            'lastWeekAppointments': lastWeekAppointments.length,
          };

          print('🔍 [DatabaseService] Analytics calculated: $analytics');
          print('🔍 [DatabaseService] This month appointments: ${analytics['thisMonthAppointments']}');
          print('🔍 [DatabaseService] New patients this month: ${analytics['newPatientsThisMonth']}');
          print('🔍 [DatabaseService] This month revenue: ${analytics['thisMonthRevenue']}');
          print('🔍 [DatabaseService] Emergency cases: ${analytics['emergencyCases']}');
          return analytics;
        });
  }

  // Get vet revenue chart data
  Stream<Map<String, List<Map<String, dynamic>>>> getVetRevenueChartData(String vetId) {
    print('🔍 [DatabaseService] getVetRevenueChartData called for vetId: $vetId');
    
    return _appointmentsCollection
        .where('vetId', isEqualTo: vetId)
        .where('status', isEqualTo: AppointmentStatus.completed.name)
        .snapshots()
        .map((snapshot) {
      print('🔍 [DatabaseService] getVetRevenueChartData received ${snapshot.docs.length} completed appointments');
      
      final now = DateTime.now();
      final Map<String, double> dailyData = {};
      final Map<String, double> weeklyData = {};
      final Map<String, double> monthlyData = {};
      
      // Initialize last 7 days (current week)
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayKey = _getDayName(day.weekday);
        dailyData[dayKey] = 0.0;
      }
      
      // Initialize last 8 weeks
      for (int i = 7; i >= 0; i--) {
        final weekStart = now.subtract(Duration(days: i * 7));
        final weekKey = 'W${(weekStart.day / 7).ceil()}';
        weeklyData[weekKey] = 0.0;
      }
      
      // Initialize last 12 months
      for (int i = 11; i >= 0; i--) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        final monthKey = _getMonthName(monthStart.month);
        monthlyData[monthKey] = 0.0;
      }
      
      for (var doc in snapshot.docs) {
        try {
          final appointment = Appointment.fromFirestore(doc);
          final appointmentDate = appointment.appointmentDate;
          final revenue = appointment.price ?? 0.0;
          
          // Daily data (current week)
          final dayKey = _getDayName(appointmentDate.weekday);
          if (dailyData.containsKey(dayKey)) {
            dailyData[dayKey] = (dailyData[dayKey] ?? 0) + revenue;
          }
          
          // Weekly data
          final weekStart = appointmentDate.subtract(Duration(days: appointmentDate.weekday - 1));
          final weekKey = 'W${(weekStart.day / 7).ceil()}';
          if (weeklyData.containsKey(weekKey)) {
            weeklyData[weekKey] = (weeklyData[weekKey] ?? 0) + revenue;
          }
          
          // Monthly data
          final monthKey = _getMonthName(appointmentDate.month);
          if (monthlyData.containsKey(monthKey)) {
            monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + revenue;
          }
        } catch (e) {
          print('🔍 [DatabaseService] Error parsing appointment ${doc.id}: $e');
        }
      }
      
      final dailyChartData = dailyData.entries.map((entry) => {
        'period': entry.key,
        'revenue': entry.value,
      }).toList();
      
      final weeklyChartData = weeklyData.entries.map((entry) => {
        'period': entry.key,
        'revenue': entry.value,
      }).toList();
      
      final monthlyChartData = monthlyData.entries.map((entry) => {
        'period': entry.key,
        'revenue': entry.value,
      }).toList();
      
      final chartData = {
        'daily': dailyChartData,
        'weekly': weeklyChartData,
        'monthly': monthlyChartData,
      };
      
      print('🔍 [DatabaseService] getVetRevenueChartData calculated: ${dailyChartData.length} days, ${weeklyChartData.length} weeks, ${monthlyChartData.length} months');
      
      return chartData;
    }).handleError((error) {
      print('🔍 [DatabaseService] getVetRevenueChartData error: $error');
      return {
        'daily': <Map<String, dynamic>>[],
        'weekly': <Map<String, dynamic>>[],
        'monthly': <Map<String, dynamic>>[],
      };
    });
  }

  // Review and rating methods
  Future<void> submitReview({
    required String appointmentId,
    required String vetId,
    required String patientId,
    required int rating,
    required String comment,
    required String appointmentType,
  }) async {
    try {
      print('🔍 [DatabaseService] Submitting review for appointment: $appointmentId');
      print('🔍 [DatabaseService] Vet ID: $vetId, Patient ID: $patientId');
      print('🔍 [DatabaseService] Rating: $rating, Comment: $comment');

      // Skip the test step and proceed directly
      print('🔍 [DatabaseService] Proceeding with review submission...');

      // 1. Get current vet document to access existing reviews
      print('🔍 [DatabaseService] Fetching vet document...');
      final vetDoc = await _usersCollection.doc(vetId).get();
      if (!vetDoc.exists) {
        print('❌ [DatabaseService] Vet document not found: $vetId');
        throw Exception('Vet not found');
      }

      print('🔍 [DatabaseService] Vet document found, processing data...');
      final vetData = vetDoc.data() as Map<String, dynamic>;
      final existingReviews = List<Map<String, dynamic>>.from(vetData['reviews'] ?? []);
      print('🔍 [DatabaseService] Existing reviews count: ${existingReviews.length}');

      // 2. Create new review object
      final newReview = {
        'appointmentId': appointmentId,
        'vetId': vetId,
        'patientId': patientId,
        'rating': rating,
        'comment': comment,
        'appointmentType': appointmentType,
        'createdAt': FieldValue.serverTimestamp(),
      };
      print('🔍 [DatabaseService] Created new review object');

      // 3. Add new review to the list
      existingReviews.add(newReview);
      print('🔍 [DatabaseService] Added review to list, total: ${existingReviews.length}');

      // 4. Calculate new average rating
      double totalRating = 0;
      int reviewCount = 0;
      for (final review in existingReviews) {
        final reviewRating = review['rating'] as int?;
        if (reviewRating != null && reviewRating > 0) {
          totalRating += reviewRating;
          reviewCount++;
        }
      }
      final averageRating = reviewCount > 0 ? totalRating / reviewCount : 0.0;
      print('🔍 [DatabaseService] Calculated average rating: $averageRating');

      // 5. Update vet's document with new reviews and rating
      print('🔍 [DatabaseService] Updating vet document...');
      
      // Try a simpler approach first - just add the review without complex data conversion
      try {
        await _usersCollection.doc(vetId).update({
          'reviews': existingReviews,
          'rating': averageRating,
        });
        print('✅ [DatabaseService] Update successful with existingReviews');
      } catch (e) {
        print('❌ [DatabaseService] First update attempt failed: $e');
        
        // Fallback: try with converted data
        final firestoreReviews = existingReviews.map((review) {
          return {
            'appointmentId': review['appointmentId'] as String,
            'vetId': review['vetId'] as String,
            'patientId': review['patientId'] as String,
            'rating': review['rating'] as int,
            'comment': review['comment'] as String,
            'appointmentType': review['appointmentType'] as String,
            'createdAt': review['createdAt'],
          };
        }).toList();
        
        await _usersCollection.doc(vetId).update({
          'reviews': firestoreReviews,
          'rating': averageRating,
        });
        print('✅ [DatabaseService] Update successful with firestoreReviews');
      }

      print('✅ [DatabaseService] Review submitted successfully');
      print('🔍 [DatabaseService] New average rating: $averageRating');
      print('🔍 [DatabaseService] Total reviews: ${existingReviews.length}');
    } catch (e) {
      print('❌ [DatabaseService] Error submitting review: $e');
      print('❌ [DatabaseService] Error stack trace: ${StackTrace.current}');
      throw e;
    }
  }



  // Test method to verify vet document access
  Future<bool> testVetDocumentAccess(String vetId) async {
    try {
      print('🔍 [DatabaseService] Testing vet document access for: $vetId');
      
      // Test read access
      final vetDoc = await _usersCollection.doc(vetId).get();
      if (!vetDoc.exists) {
        print('❌ [DatabaseService] Vet document does not exist: $vetId');
        return false;
      }
      
      print('✅ [DatabaseService] Vet document read access successful');
      
      // Test write access with minimal data
      await _usersCollection.doc(vetId).update({
        'lastTested': FieldValue.serverTimestamp(),
      });
      
      print('✅ [DatabaseService] Vet document write access successful');
      return true;
    } catch (e) {
      print('❌ [DatabaseService] Vet document access test failed: $e');
      return false;
    }
  }

  // Direct review submission - simplified version
  Future<void> addSimpleReview({
    required String vetId,
    required int rating,
    required String comment,
  }) async {
    try {
      print('🔍 [DatabaseService] Adding simple review for vet: $vetId');
      print('🔍 [DatabaseService] Rating: $rating, Comment: $comment');
      
      // Get the vet document
      final vetDoc = await _usersCollection.doc(vetId).get();
      if (!vetDoc.exists) {
        throw Exception('Vet not found');
      }
      
      // Create a simple review object
      final review = {
        'rating': rating,
        'comment': comment,
        'timestamp': Timestamp.now(),
      };
      
      // Add the review directly to the vet document
      await _db.runTransaction((transaction) async {
        // Get the current reviews array or create a new one
        final currentData = vetDoc.data() as Map<String, dynamic>;
        final reviews = List<Map<String, dynamic>>.from(currentData['simpleReviews'] ?? []);
        
        // Add the new review
        reviews.add(review);
        
        // Update the document
        transaction.update(_usersCollection.doc(vetId), {
          'simpleReviews': reviews,
        });
      });
      
      print('✅ [DatabaseService] Simple review added successfully');
    } catch (e) {
      print('❌ [DatabaseService] Error adding simple review: $e');
      print('❌ [DatabaseService] Error details: ${e.toString()}');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getVetReviews(String vetId) async {
    try {
      print('🔍 [DatabaseService] Getting reviews for vet: $vetId');
      
      // Get vet's user document
      final vetDoc = await _usersCollection.doc(vetId).get();
      if (!vetDoc.exists) {
        print('🔍 [DatabaseService] Vet not found: $vetId');
        return [];
      }

      final vetData = vetDoc.data() as Map<String, dynamic>;
      
      // Try to get simple reviews first
      if (vetData.containsKey('simpleReviews')) {
        final simpleReviews = List<Map<String, dynamic>>.from(vetData['simpleReviews'] ?? []);
        print('🔍 [DatabaseService] Found ${simpleReviews.length} simple reviews');
        
        // Convert to the expected format
        final formattedReviews = simpleReviews.map((review) {
          return {
            'id': 'simple-review-${simpleReviews.indexOf(review)}',
            'rating': review['rating'] as int,
            'comment': review['comment'] as String,
            'appointmentType': 'Consultation',
            'createdAt': (review['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            'patientId': 'unknown',
          };
        }).toList();
        
        return formattedReviews;
      }
      
      // Fallback to old reviews format
      final reviews = List<Map<String, dynamic>>.from(vetData['reviews'] ?? []);
      
      // Sort reviews by createdAt (newest first)
      reviews.sort((a, b) {
        final aCreatedAt = a['createdAt'] as Timestamp?;
        final bCreatedAt = b['createdAt'] as Timestamp?;
        
        if (aCreatedAt == null && bCreatedAt == null) return 0;
        if (aCreatedAt == null) return 1;
        if (bCreatedAt == null) return -1;
        
        return bCreatedAt.compareTo(aCreatedAt); // Descending order
      });

      // Convert to the expected format
      final formattedReviews = reviews.map((review) {
        return {
          'id': review['appointmentId'] as String? ?? '',
          'rating': review['rating'] as int,
          'comment': review['comment'] as String,
          'appointmentType': review['appointmentType'] as String? ?? 'Consultation',
          'createdAt': (review['createdAt'] as Timestamp?)?.toDate(),
          'patientId': review['patientId'] as String? ?? 'unknown',
        };
      }).toList();

      print('🔍 [DatabaseService] Found ${formattedReviews.length} reviews for vet: $vetId');
      return formattedReviews;
    } catch (e) {
      print('❌ [DatabaseService] Error getting vet reviews: $e');
      print('❌ [DatabaseService] Error details: ${e.toString()}');
      return [];
    }
  }

  // ==================== SUBSCRIPTION METHODS ====================

  /// Create or update a user's subscription
  Future<void> createOrUpdateSubscription({
    required String userId,
    required String plan, // 'alifi verified', 'alifi affiliated', 'alifi favorite'
    required String status, // 'active', 'cancelled', 'expired', 'pending'
    required double amount,
    required String currency, // 'DZD', 'USD', etc.
    required String interval, // 'monthly', 'yearly'
    required String paymentMethod, // 'Cash payment', 'Credit Card', etc.
    DateTime? startDate,
    DateTime? nextBillingDate,
  }) async {
    try {
      print('🔍 [DatabaseService] Creating/updating subscription for user: $userId');
      print('🔍 [DatabaseService] Plan: $plan, Status: $status, Amount: $amount $currency');
      
      final now = DateTime.now();
      final subscriptionData = {
        'subscriptionPlan': plan,
        'subscriptionStatus': status,
        'subscriptionStartDate': startDate != null ? Timestamp.fromDate(startDate) : Timestamp.fromDate(now),
        'nextBillingDate': nextBillingDate != null ? Timestamp.fromDate(nextBillingDate) : Timestamp.fromDate(now.add(const Duration(days: 30))),
        'lastBillingDate': Timestamp.fromDate(now),
        'paymentMethod': paymentMethod,
        'subscriptionAmount': amount,
        'subscriptionCurrency': currency,
        'subscriptionInterval': interval,
      };

      await _usersCollection.doc(userId).update(subscriptionData);
      print('✅ [DatabaseService] Subscription created/updated successfully');
    } catch (e) {
      print('❌ [DatabaseService] Error creating/updating subscription: $e');
      throw e;
    }
  }

  /// Cancel a user's subscription
  Future<void> cancelSubscription(String userId) async {
    try {
      print('🔍 [DatabaseService] Cancelling subscription for user: $userId');
      
      await _usersCollection.doc(userId).update({
        'subscriptionStatus': 'cancelled',
        'nextBillingDate': null,
      });
      
      print('✅ [DatabaseService] Subscription cancelled successfully');
    } catch (e) {
      print('❌ [DatabaseService] Error cancelling subscription: $e');
      throw e;
    }
  }

  /// Get subscription information for a user
  Future<Map<String, dynamic>?> getSubscription(String userId) async {
    try {
      print('🔍 [DatabaseService] Getting subscription for user: $userId');
      
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        print('🔍 [DatabaseService] User not found: $userId');
        return null;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      
      // Check if user has subscription data
      if (userData['subscriptionPlan'] == null) {
        print('🔍 [DatabaseService] User has no subscription: $userId');
        return null;
      }

      return {
        'plan': userData['subscriptionPlan'],
        'status': userData['subscriptionStatus'],
        'startDate': (userData['subscriptionStartDate'] as Timestamp?)?.toDate(),
        'nextBillingDate': (userData['nextBillingDate'] as Timestamp?)?.toDate(),
        'lastBillingDate': (userData['lastBillingDate'] as Timestamp?)?.toDate(),
        'paymentMethod': userData['paymentMethod'],
        'amount': userData['subscriptionAmount'],
        'currency': userData['subscriptionCurrency'],
        'interval': userData['subscriptionInterval'],
      };
    } catch (e) {
      print('❌ [DatabaseService] Error getting subscription: $e');
      return null;
    }
  }

  /// Update next billing date (for recurring billing)
  Future<void> updateNextBillingDate(String userId, DateTime nextBillingDate) async {
    try {
      print('🔍 [DatabaseService] Updating next billing date for user: $userId');
      print('🔍 [DatabaseService] New billing date: $nextBillingDate');
      
      await _usersCollection.doc(userId).update({
        'nextBillingDate': Timestamp.fromDate(nextBillingDate),
        'lastBillingDate': Timestamp.fromDate(DateTime.now()),
      });
      
      print('✅ [DatabaseService] Next billing date updated successfully');
    } catch (e) {
      print('❌ [DatabaseService] Error updating next billing date: $e');
      throw e;
    }
  }

  /// Check if a user has an active subscription
  Future<bool> hasActiveSubscription(String userId) async {
    try {
      final subscription = await getSubscription(userId);
      if (subscription == null) return false;
      
      final status = subscription['status'] as String?;
      final nextBillingDate = subscription['nextBillingDate'] as DateTime?;
      
      // Check if subscription is active and not expired
      return status == 'active' && 
             (nextBillingDate == null || nextBillingDate.isAfter(DateTime.now()));
    } catch (e) {
      print('❌ [DatabaseService] Error checking active subscription: $e');
      return false;
    }
  }

  /// Get subscription plan details (pricing, features, etc.)
  Map<String, dynamic> getSubscriptionPlanDetails(String plan) {
    final plans = {
      'alifi verified': {
        'name': 'alifi verified',
        'price': 900.0,
        'currency': 'DZD',
        'interval': 'monthly',
        'features': [
          'Adds your clinic/store to our map',
          'Get special marking for your clinic/store in the map',
          'Get patients/customers to book appointments/find your store through the app',
          'Manage your schedule and appointments through the app',
          'Have a verification badge on your profile and on the map',
        ],
      },
      'alifi affiliated': {
        'name': 'alifi affiliated',
        'price': 1200.0,
        'currency': 'DZD',
        'interval': 'monthly',
        'features': [
          'Adds your clinic/store to our map',
          'Get the most special marking for your clinic/store in the map',
          'Get patients/customers to book appointments/find your store through the app',
          'Manage your schedule and appointments through the app',
          'Have a verification badge on your profile and on the map',
          'Appear on the homescreen when close',
          'Appear first on the search',
        ],
      },
      'alifi favorite': {
        'name': 'alifi favorite',
        'price': 2000.0,
        'currency': 'DZD',
        'interval': 'monthly',
        'features': [
          'Adds your clinic/store to our map',
          'Get the most special marking for your clinic/store in the map',
          'Get patients/customers to book appointments/find your store through the app',
          'Manage your schedule and appointments through the app',
          'Have a verification badge on your profile and on the map',
          'Appear on the homescreen when close',
          'Appear first on the search',
          'Get to post on homescreen',
        ],
      },
    };

    return plans[plan] ?? {};
  }

  /// Get all available subscription plans
  List<Map<String, dynamic>> getAvailableSubscriptionPlans() {
    return [
      getSubscriptionPlanDetails('alifi verified'),
      getSubscriptionPlanDetails('alifi affiliated'),
      getSubscriptionPlanDetails('alifi favorite'),
    ];
  }
} 