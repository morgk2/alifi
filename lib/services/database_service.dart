import 'dart:math' show pi, cos;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../models/user.dart';
import '../models/pet.dart';
import '../models/lost_pet.dart';
import 'local_storage_service.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  final _uuid = const Uuid();

  // Collections
  CollectionReference get _usersCollection => _db.collection('users');
  CollectionReference get _petsCollection => _db.collection('pets');
  CollectionReference get _lostPetsCollection => _db.collection('lost_pets');

  // User Operations
  Future<void> createUser(User user) async {
    await _usersCollection.doc(user.id).set(user.toFirestore());
  }

  Future<void> updateUser(User user) async {
    await _usersCollection.doc(user.id).set(user.toFirestore(), SetOptions(merge: true));
  }

  Future<User?> getUser(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    return doc.exists ? User.fromFirestore(doc) : null;
  }

  Stream<User?> getUserStream(String userId) {
    return _usersCollection
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? User.fromFirestore(doc) : null);
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
      // If no search criteria, return recent users
      final snapshot = await _usersCollection
          .orderBy('lastLoginAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    }

    // Get all users that match any of the search criteria
    final searchTerm = (displayName ?? username ?? email ?? '').toLowerCase();
    if (searchTerm.isEmpty) return [];

    // Query for users where any of the searchable fields match
    final displayNameQuery = _usersCollection
        .where('displayName_lower', isGreaterThanOrEqualTo: searchTerm)
        .where('displayName_lower', isLessThan: searchTerm + '\uf8ff')
        .limit(limit);

    final usernameQuery = _usersCollection
        .where('username_lower', isGreaterThanOrEqualTo: searchTerm)
        .where('username_lower', isLessThan: searchTerm + '\uf8ff')
        .limit(limit);

    final emailQuery = _usersCollection
        .where('email', isGreaterThanOrEqualTo: searchTerm)
        .where('email', isLessThan: searchTerm + '\uf8ff')
        .limit(limit);

    // Execute all queries in parallel
    final results = await Future.wait([
      displayNameQuery.get(),
      usernameQuery.get(),
      emailQuery.get(),
    ]);

    // Combine results and remove duplicates
    final Set<String> seenIds = {};
    final List<User> users = [];

    for (final querySnapshot in results) {
      for (final doc in querySnapshot.docs) {
        if (seenIds.add(doc.id)) { // Only add if ID hasn't been seen
          users.add(User.fromFirestore(doc));
        }
      }
    }

    // Sort by relevance (exact matches first, then partial matches)
    users.sort((a, b) {
      final aName = a.displayName?.toLowerCase() ?? '';
      final bName = b.displayName?.toLowerCase() ?? '';
      final aUsername = a.username?.toLowerCase() ?? '';
      final bUsername = b.username?.toLowerCase() ?? '';
      
      // Exact matches first
      if (aName == searchTerm && bName != searchTerm) return -1;
      if (bName == searchTerm && aName != searchTerm) return 1;
      if (aUsername == searchTerm && bUsername != searchTerm) return -1;
      if (bUsername == searchTerm && aUsername != searchTerm) return 1;
      
      // Then sort by how close the match is
      final aNameMatch = aName.startsWith(searchTerm) ? 0 : 1;
      final bNameMatch = bName.startsWith(searchTerm) ? 0 : 1;
      if (aNameMatch != bNameMatch) return aNameMatch - bNameMatch;
      
      final aUsernameMatch = aUsername.startsWith(searchTerm) ? 0 : 1;
      final bUsernameMatch = bUsername.startsWith(searchTerm) ? 0 : 1;
      if (aUsernameMatch != bUsernameMatch) return aUsernameMatch - bUsernameMatch;
      
      // Finally sort by name
      return aName.compareTo(bName);
    });

    // Return limited results
    return users.take(limit).toList();
  }

  Future<List<User>> getAllUsers({int limit = 50}) async {
    final snapshot = await _usersCollection
        .orderBy('lastLoginAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
  }

  Future<List<User>> getRecentUsers({int limit = 10}) async {
    final snapshot = await _usersCollection
        .orderBy('lastLoginAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
  }

  // User Follow/Unfollow Operations
  Future<void> followUser(String currentUserId, String targetUserId) async {
    // Add targetUser to currentUser's following list
    await _usersCollection.doc(currentUserId).update({
      'following': FieldValue.arrayUnion([targetUserId])
    });

    // Add currentUser to targetUser's followers list
    await _usersCollection.doc(targetUserId).update({
      'followers': FieldValue.arrayUnion([currentUserId])
    });
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    // Remove targetUser from currentUser's following list
    await _usersCollection.doc(currentUserId).update({
      'following': FieldValue.arrayRemove([targetUserId])
    });

    // Remove currentUser from targetUser's followers list
    await _usersCollection.doc(targetUserId).update({
      'followers': FieldValue.arrayRemove([currentUserId])
    });
  }

  // Check if user is following another user
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    final currentUser = await getUser(currentUserId);
    return currentUser?.following.contains(targetUserId) ?? false;
  }

  // Get user's followers count
  Future<int> getFollowersCount(String userId) async {
    final user = await getUser(userId);
    return user?.followers.length ?? 0;
  }

  // Get user's following count
  Future<int> getFollowingCount(String userId) async {
    final user = await getUser(userId);
    return user?.following.length ?? 0;
  }

  // Get user's followers
  Future<List<User>> getFollowers(String userId) async {
    final user = await getUser(userId);
    if (user == null || user.followers.isEmpty) return [];

    final snapshot = await _usersCollection
        .where(FieldPath.documentId, whereIn: user.followers)
        .get();
    return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
  }

  // Get user's following
  Future<List<User>> getFollowing(String userId) async {
    final user = await getUser(userId);
    if (user == null || user.following.isEmpty) return [];

    final snapshot = await _usersCollection
        .where(FieldPath.documentId, whereIn: user.following)
        .get();
    return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
  }

  // Pet Operations
  Future<String> createPet(Pet pet, {bool isGuest = false}) async {
    if (isGuest) {
      // For guest mode, generate a local ID and save to local storage
      final localPet = pet.copyWith(
        id: _uuid.v4(),
        ownerId: 'guest',
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
      );
      await _localStorage.addGuestPet(localPet);
      return localPet.id;
    } else {
      // For authenticated users, save to Firestore
      final docRef = await _petsCollection.add(pet.toFirestore());
      return docRef.id;
    }
  }

  // Pet Operations with Images
  Future<String> createPetWithImages(Pet pet, List<String> localImagePaths, {bool isGuest = false}) async {
    if (isGuest) {
      // For guest mode, store images locally and save pet to local storage
      final localPet = pet.copyWith(
        id: _uuid.v4(),
        ownerId: 'guest',
        imageUrls: localImagePaths, // Store local paths directly
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
      );
      await _localStorage.addGuestPet(localPet);
      return localPet.id;
    } else {
      // For authenticated users, still store images locally for now
      final petWithLocalImages = pet.copyWith(
        imageUrls: localImagePaths, // Store local paths directly
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
      );

      // Save pet to Firestore with local image paths
      final docRef = await _petsCollection.add(petWithLocalImages.toFirestore());
      return docRef.id;
    }
  }

  Future<void> updatePet(Pet pet, {bool isGuest = false}) async {
    if (isGuest) {
      await _localStorage.updateGuestPet(pet);
    } else {
      await _petsCollection.doc(pet.id).update(pet.toFirestore());
    }
  }

  Future<void> deletePet(String petId, {bool isGuest = false}) async {
    if (isGuest) {
      await _localStorage.deleteGuestPet(petId);
    } else {
      // Hard delete: remove the document from Firestore
      await _petsCollection.doc(petId).delete();
    }
  }

  Future<Pet?> getPet(String petId, {bool isGuest = false}) async {
    if (isGuest) {
      final pets = await _localStorage.getGuestPets();
      return pets.firstWhere((p) => p.id == petId, orElse: () => null as Pet);
    } else {
      final doc = await _petsCollection.doc(petId).get();
      return doc.exists ? Pet.fromFirestore(doc) : null;
    }
  }

  Stream<List<Pet>> getUserPets(String userId, {bool isGuest = false}) {
    if (isGuest) {
      // For guest mode, create a stream from local storage
      return Stream.fromFuture(_localStorage.getGuestPets());
    } else {
      // For authenticated users, use Firestore stream
      return _petsCollection
          .where('ownerId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)  // Order by creation time, newest first
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList());
    }
  }

  // Search pets
  Future<List<Pet>> searchPets({
    String? species,
    String? breed,
    int? maxAge,
    List<String>? tags,
    bool isGuest = false,
  }) async {
    if (isGuest) {
      // Search in local storage
      final allPets = await _localStorage.getGuestPets();
      return allPets.where((pet) {
        bool matches = true;
        if (species != null) matches = matches && pet.species == species;
        if (breed != null) matches = matches && pet.breed == breed;
        if (maxAge != null) matches = matches && pet.age <= maxAge;
        if (tags != null && tags.isNotEmpty) {
          matches = matches && tags.any((tag) => pet.tags.contains(tag));
        }
        return matches;
      }).toList();
    } else {
      // Search in Firestore
      Query query = _petsCollection.where('isActive', isEqualTo: true);

      if (species != null) {
        query = query.where('species', isEqualTo: species);
      }
      if (breed != null) {
        query = query.where('breed', isEqualTo: breed);
      }
      if (maxAge != null) {
        query = query.where('age', isLessThanOrEqualTo: maxAge);
      }
      if (tags != null && tags.isNotEmpty) {
        query = query.where('tags', arrayContainsAny: tags);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
    }
  }

  // Get recently added pets
  Future<List<Pet>> getRecentPets({int limit = 10, bool isGuest = false}) async {
    if (isGuest) {
      final pets = await _localStorage.getGuestPets();
      pets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return pets.take(limit).toList();
    } else {
      final snapshot = await _petsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
    }
  }

  // Transfer guest pets to authenticated user
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

  // Lost Pet Operations
  Future<String> reportLostPet({
    required Pet pet,
    required latlong.LatLng location,
    required String address,
    required DateTime lastSeenDate,
    required String reportedByUserId,
    String? additionalInfo,
    List<String> contactNumbers = const [],
    String? reward,
  }) async {
    final lostPet = {
      'petId': pet.id,
      'location': GeoPoint(location.latitude, location.longitude),  // Convert to GeoPoint
      'address': address,
      'lastSeenDate': Timestamp.fromDate(lastSeenDate),
      'reportedDate': Timestamp.fromDate(DateTime.now()),
      'isFound': false,
      'reportedByUserId': reportedByUserId,
      'additionalInfo': additionalInfo,
      'contactNumbers': contactNumbers,
      'reward': reward,
    };

    final docRef = await _lostPetsCollection.add(lostPet);
    return docRef.id;
  }

  Future<void> markPetAsFound(String lostPetId) async {
    await _lostPetsCollection.doc(lostPetId).update({'isFound': true});
  }

  Stream<List<LostPet>> getNearbyLostPets({
    required latlong.LatLng userLocation,
    double radiusInKm = 10,
  }) {
    // Convert km to degrees (rough approximation)
    final latDegrees = radiusInKm / 111.0;
    final lonDegrees = radiusInKm / (111.0 * cos(userLocation.latitude * pi / 180));

    final minLat = userLocation.latitude - latDegrees;
    final maxLat = userLocation.latitude + latDegrees;
    final minLon = userLocation.longitude - lonDegrees;
    final maxLon = userLocation.longitude + lonDegrees;

    return _lostPetsCollection
        .where('isFound', isEqualTo: false)
        .where('location',
            isGreaterThan: GeoPoint(minLat, minLon),
            isLessThan: GeoPoint(maxLat, maxLon))
        .orderBy('location')
        .orderBy('lastSeenDate', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final lostPets = <LostPet>[];
          for (var doc in snapshot.docs) {
            final lostPet = await LostPet.fromFirestore(doc, _db);
            if (lostPet != null) {
              lostPets.add(lostPet);
            }
          }
          return lostPets;
        });
  }

  Stream<List<LostPet>> getRecentLostPets({int limit = 10}) {
    return _lostPetsCollection
        .where('isFound', isEqualTo: false)
        .orderBy('reportedDate', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
          final lostPets = <LostPet>[];
          for (var doc in snapshot.docs) {
            final lostPet = await LostPet.fromFirestore(doc, _db);
            if (lostPet != null) {
              lostPets.add(lostPet);
            }
          }
          return lostPets;
        });
  }

  Future<LostPet?> getLostPet(String lostPetId) async {
    final doc = await _lostPetsCollection.doc(lostPetId).get();
    if (!doc.exists) return null;
    return LostPet.fromFirestore(doc, _db);
  }

  Stream<List<LostPet>> getUserLostPets(String userId) {
    return _lostPetsCollection
        .where('reportedByUserId', isEqualTo: userId)
        .orderBy('reportedDate', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final lostPets = <LostPet>[];
          for (var doc in snapshot.docs) {
            final lostPet = await LostPet.fromFirestore(doc, _db);
            if (lostPet != null) {
              lostPets.add(lostPet);
            }
          }
          return lostPets;
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

  Future<int> getUserRank(String userId) async {
    // Get all users ordered by level and pets rescued
    final snapshot = await _usersCollection
        .orderBy('level', descending: true)
        .orderBy('petsRescued', descending: true)
        .get();
    
    // Find the index of the user
    final index = snapshot.docs.indexWhere((doc) => doc.id == userId);
    return index + 1; // Add 1 because rank starts from 1, not 0
  }

  Future<bool> isUsernameTaken(String username) async {
    final query = await _usersCollection
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }
} 