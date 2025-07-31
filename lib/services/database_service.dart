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
import 'dart:convert'; // Added for json.decode
import 'package:http/http.dart' as http; // Added for http.get
import 'package:alifi/models/gift.dart';
import '../models/chat_message.dart';
import '../models/order.dart' as store_order;
import 'notification_service.dart';
import '../models/notification.dart';

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
  CollectionReference get _giftsCollection => _db.collection('gifts');
  CollectionReference get _chatMessagesCollection => _db.collection('chatMessages');
  CollectionReference get _ordersCollection => _db.collection('orders');

  // Single document for all locations in 'locations' collection
  DocumentReference get _vetLocationsDoc => _db.collection('locations').doc('vets');
  DocumentReference get _storeLocationsDoc => _db.collection('locations').doc('stores');

  // Add migration method for locations
  Future<void> migrateLocations() async {
    try {
      print('Starting location migration...');
      
      // Create batch for atomic operations
      var batch = _db.batch();
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
        (existingVetsDoc.data()?['locations'] as Map<String, dynamic>?) ?? {};
      Map<String, dynamic> existingStoreLocations = 
        (existingStoresDoc.data()?['locations'] as Map<String, dynamic>?) ?? {};
      
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
        // Sort by totalOrders descending (most popular first)
        products.sort((a, b) => b.totalOrders.compareTo(a.totalOrders));
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
        final price = (data['price'] ?? 0) as num;
        final quantity = (data['quantity'] ?? 1) as num;
        
        // Calculate total sales from completed orders
        if (status == 'delivered') {
          totalSales += price * quantity;
        }
        
        // Count all orders
        ordersCount++;
        
        // Count active orders (pending, confirmed, shipped)
        if (['pending', 'confirmed', 'shipped'].contains(status)) {
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
        .where('status', isEqualTo: 'delivered')
        .snapshots()
        .map((snapshot) {
      print('🔍 [DatabaseService] getStoreSalesAnalytics received ${snapshot.docs.length} delivered orders');
      
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
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final price = (data['price'] ?? 0) as num;
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

  Stream<List<Map<String, dynamic>>> getVetDashboardStats(String vetId) {
    print('🔍 [DatabaseService] getVetDashboardStats called for vetId: $vetId');
    
    // For now, return mock data since vet appointments collection doesn't exist yet
    // TODO: Implement actual vet appointments collection and logic
    return Stream.value([
      {
        'nextAppointment': 'Tomorrow',
        'patientsCount': 45,
        'appointmentsToday': 8,
        'revenueToday': 1250.00,
      }
    ]).asBroadcastStream().handleError((error) {
      print('🔍 [DatabaseService] getVetDashboardStats error: $error');
      // Return default stats on error
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

  Stream<Map<String, List<Map<String, dynamic>>>> getStoreSalesChartData(String storeId) {
    print('🔍 [DatabaseService] getStoreSalesChartData called for storeId: $storeId');
    
    return _ordersCollection
        .where('storeId', isEqualTo: storeId)
        .where('status', isEqualTo: 'delivered')
        .snapshots()
        .map((snapshot) {
      print('🔍 [DatabaseService] getStoreSalesChartData received ${snapshot.docs.length} delivered orders');
      
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
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final price = (data['price'] ?? 0) as num;
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
      final docRef = await _ordersCollection.add(order.toFirestore());
      // Increment totalOrders for the store product if this is a store product order
      if (order.productId.isNotEmpty) {
        final productDoc = await _storeProductsCollection.doc(order.productId).get();
        if (productDoc.exists) {
          await productDoc.reference.update({
            'totalOrders': FieldValue.increment(1),
          });
        }
      }

      // Send order placed notification to store owner
      _sendOrderPlacedNotification(order);

      return docRef.id;
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
      await _ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send order status notification
      _sendOrderStatusNotification(orderId, status);
    } catch (e) {
      print('Error updating order status: $e');
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
      return _ordersCollection
          .where('storeId', isEqualTo: storeId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            print('🔍 [DatabaseService] Firestore snapshot received');
            print('🔍 [DatabaseService] Snapshot docs count: ${snapshot.docs.length}');
            print('🔍 [DatabaseService] Snapshot metadata: ${snapshot.metadata}');
            
            final orders = snapshot.docs.map((doc) {
              try {
                final order = store_order.StoreOrder.fromFirestore(doc);
                print('🔍 [DatabaseService] Successfully parsed order: ${order.id} - ${order.productName} (${order.status})');
                return order;
              } catch (e) {
                print('🔍 [DatabaseService] Error parsing order document ${doc.id}: $e');
                print('🔍 [DatabaseService] Document data: ${doc.data()}');
                throw e;
              }
            }).toList();
            
            print('🔍 [DatabaseService] Successfully parsed ${orders.length} orders');
            return orders;
          }).handleError((error) {
            print('🔍 [DatabaseService] Error in getStoreOrders stream: $error');
            print('🔍 [DatabaseService] Error type: ${error.runtimeType}');
            throw error;
          });
    } catch (e) {
      print('🔍 [DatabaseService] Error setting up getStoreOrders query: $e');
      rethrow;
    }
  }

  Stream<List<store_order.StoreOrder>> getUserOrders(String userId) {
    print('🔍 [DatabaseService] getUserOrders called with userId: $userId');
    try {
      return _ordersCollection
          .where('customerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            print('🔍 [DatabaseService] getUserOrders Firestore snapshot received');
            print('🔍 [DatabaseService] getUserOrders Snapshot docs count: ${snapshot.docs.length}');
            print('🔍 [DatabaseService] getUserOrders Snapshot metadata: ${snapshot.metadata}');
            
            final orders = snapshot.docs.map((doc) {
              try {
                final order = store_order.StoreOrder.fromFirestore(doc);
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
        .where('status', whereIn: ['pending', 'confirmed', 'shipped'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => store_order.StoreOrder.fromFirestore(doc)).toList());
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
} 