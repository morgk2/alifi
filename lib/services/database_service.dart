import 'dart:math' show pi, cos;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../models/user.dart';
import '../models/pet.dart';
import '../models/lost_pet.dart';
import '../models/store_product.dart';
import 'local_storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:latlong2/latlong.dart';
import '../models/aliexpress_product.dart';
import '../models/marketplace_product.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  final _uuid = const Uuid();

  // Collections
  CollectionReference get _usersCollection => _db.collection('users');
  CollectionReference get _petsCollection => _db.collection('pets');
  CollectionReference get _lostPetsCollection => _db.collection('lost_pets');
  CollectionReference get _storeProductsCollection => _db.collection('storeproducts');
  CollectionReference get _vetLocationsCollection => _db.collection('vet_locations');
  CollectionReference get _storeLocationsCollection => _db.collection('store_locations');

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
    print('Starting user counts migration...');
    // Get all users
    final snapshot = await _usersCollection.get();
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Get the actual arrays
      final followers = List<String>.from(data['followers'] ?? []);
      final following = List<String>.from(data['following'] ?? []);
      
      // Get the current counts
      final currentFollowersCount = data['followersCount'] ?? 0;
      final currentFollowingCount = data['followingCount'] ?? 0;
      
      // Check if counts need updating
      if (currentFollowersCount != followers.length || currentFollowingCount != following.length) {
        print('Updating counts for user ${doc.id}:');
        print('- Followers: $currentFollowersCount -> ${followers.length}');
        print('- Following: $currentFollowingCount -> ${following.length}');
        
        await doc.reference.update({
          'followersCount': followers.length,
          'followingCount': following.length,
        });
      }
    }
    print('User counts migration completed');
  }

  Future<void> updateUserVerificationStatus(String userId, bool isVerified) async {
    await _usersCollection.doc(userId).update({
      'isVerified': isVerified,
    });
  }

  Future<void> updateUserAccountType(String userId, String accountType) async {
    if (!['normal', 'store', 'vet'].contains(accountType)) {
      throw ArgumentError('Invalid account type. Must be one of: normal, store, vet');
    }
    await _usersCollection.doc(userId).update({
      'accountType': accountType,
    });
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
    final doc = await _usersCollection.doc(userId).get();
    return doc.exists ? User.fromFirestore(doc) : null;
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

    // Update user document with search tokens
    await _usersCollection.doc(userId).update({
      'searchTokens': tokens.toList(),
    });
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
      
      // Add to arrays if not already present
      if (!following.contains(targetUserId)) {
        following.add(targetUserId);
      }
      if (!followers.contains(currentUserId)) {
        followers.add(currentUserId);
      }
      
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
      await _petsCollection.doc(petId).delete();
    }
  }

  Stream<List<Pet>> getUserPets(String userId, {bool isGuest = false}) {
    if (isGuest) {
      return Stream.fromFuture(_localStorage.getGuestPets());
    } else {
      return _petsCollection
          .where('ownerId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList());
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
  }) async {
    try {
      // First create a new pet
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
      final petId = petDocRef.id;

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

  // Get nearby lost pets
  Stream<List<LostPet>> getNearbyLostPets({
    required latlong.LatLng userLocation,
    double radiusInKm = 10,
  }) {
    return _lostPetsCollection
        .where('isFound', isEqualTo: false)
        .snapshots()
        .asyncMap((snapshot) async {
          final pets = <LostPet>[];
          for (var doc in snapshot.docs) {
            try {
            final lostPet = await LostPet.fromFirestore(doc, _db);
            if (lostPet != null) {
                // Calculate distance
                final distance = const Distance().as(
                  LengthUnit.Kilometer,
                  userLocation,
                  lostPet.location,
                );
                if (distance <= radiusInKm) {
                  pets.add(lostPet);
                }
              }
            } catch (e) {
              print('Error converting lost pet doc ${doc.id}: $e'); // Debug log
            }
          }
          return pets;
        });
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
    print('Fetching AliExpress listings with filters:');
    print('- Category: ${category ?? 'All'}');
    print('- Free Shipping Only: $isFreeShipping');
    print('- Discounted Only: $onlyDiscounted');

    Query query = _db.collection('aliexpresslistings');

    if (category != null && category != 'All') {
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
        .map((snapshot) {
          print('Found ${snapshot.docs.length} listings');
          return snapshot.docs.map((doc) {
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
        });
  }

  Stream<List<AliexpressProduct>> getRecommendedListings({int limit = 10}) {
    return _db
        .collection('aliexpresslistings')
        .orderBy('orders', descending: true)
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

  Stream<List<StoreProduct>> getStoreProducts({
    String? category,
    bool? isFreeShipping,
    String? storeId,
    int limit = 10,
  }) {
    Query query = _storeProductsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (isFreeShipping != null) {
      query = query.where('isFreeShipping', isEqualTo: isFreeShipping);
    }

    if (storeId != null) {
      query = query.where('storeId', isEqualTo: storeId);
    }

    return query
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoreProduct.fromFirestore(doc))
            .toList());
  }

  Stream<List<StoreProduct>> getPopularStoreProducts({int limit = 10}) {
    return _storeProductsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('totalOrders', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoreProduct.fromFirestore(doc))
            .toList());
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

  Stream<List<MarketplaceProduct>> getMarketplaceProducts({
    String? category,
    bool? isFreeShipping,
    String? storeId,
    int limit = 10,
  }) {
    // Combine AliExpress and store products
    return CombineLatestStream.combine2(
      getAliexpressListings(
        category: category,
        limit: limit ~/ 2,  // Split limit between both sources
      ),
      getStoreProducts(
        category: category,
        isFreeShipping: isFreeShipping,
        storeId: storeId,
        limit: limit ~/ 2,
      ),
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

  Stream<List<MarketplaceProduct>> getRecommendedMarketplaceProducts({int limit = 10}) {
    // For now, just combine recommended AliExpress products and top-rated store products
    return CombineLatestStream.combine2(
      getRecommendedListings(limit: limit ~/ 2),
      getStoreProducts(limit: limit ~/ 2),
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
    // For now, just combine new AliExpress products and store products
    return CombineLatestStream.combine2(
      getAliexpressListings(limit: limit ~/ 2),
      getStoreProducts(limit: limit ~/ 2),
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

  // Vet and Store Location Operations
  Future<void> saveVetLocation(String placeId, double lat, double lng) async {
    try {
      await _vetLocationsCollection.doc(placeId).set({
        'location': GeoPoint(lat, lng),
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Saved vet location: $placeId at $lat, $lng');
    } catch (e) {
      print('Error saving vet location: $e');
      rethrow;
    }
  }

  Future<void> saveStoreLocation(String placeId, double lat, double lng) async {
    try {
      await _storeLocationsCollection.doc(placeId).set({
        'location': GeoPoint(lat, lng),
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Saved store location: $placeId at $lat, $lng');
    } catch (e) {
      print('Error saving store location: $e');
      rethrow;
    }
  }

  Future<Map<String, GeoPoint>?> getVetLocation(String placeId) async {
    try {
      final doc = await _vetLocationsCollection.doc(placeId).get();
      if (!doc.exists) return null;
      
      final data = doc.data() as Map<String, dynamic>;
      final location = data['location'];
      if (location == null || location is! GeoPoint) {
        print('Invalid location data for vet $placeId: $location');
        return null;
      }
      
      return {placeId: location};
    } catch (e) {
      print('Error getting vet location: $e');
      return null;
    }
  }

  Future<Map<String, GeoPoint>?> getStoreLocation(String placeId) async {
    try {
      final doc = await _storeLocationsCollection.doc(placeId).get();
      if (!doc.exists) return null;
      
      final data = doc.data() as Map<String, dynamic>;
      final location = data['location'];
      if (location == null || location is! GeoPoint) {
        print('Invalid location data for store $placeId: $location');
        return null;
      }
      
      return {placeId: location};
    } catch (e) {
      print('Error getting store location: $e');
      return null;
    }
  }

  Future<List<String>> getAllVetPlaceIds() async {
    try {
      final snapshot = await _vetLocationsCollection.get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting vet place IDs: $e');
      return [];
    }
  }

  Future<List<String>> getAllStorePlaceIds() async {
    try {
      final snapshot = await _storeLocationsCollection.get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting store place IDs: $e');
      return [];
    }
  }
} 