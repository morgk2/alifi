import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/pet.dart';
import 'local_storage_service.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  final _uuid = const Uuid();

  // Collections
  CollectionReference get _usersCollection => _db.collection('users');
  CollectionReference get _petsCollection => _db.collection('pets');

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
    Query query = _usersCollection;

    // Add filters based on search criteria
    if (displayName != null && displayName.isNotEmpty) {
      final searchName = displayName.toLowerCase();
      query = query.where('displayName_lower', isGreaterThanOrEqualTo: searchName)
                  .where('displayName_lower', isLessThan: searchName + '\uf8ff');
    }

    if (username != null && username.isNotEmpty) {
      final searchUsername = username.toLowerCase();
      query = query.where('username_lower', isGreaterThanOrEqualTo: searchUsername)
                  .where('username_lower', isLessThan: searchUsername + '\uf8ff');
    }

    if (email != null && email.isNotEmpty) {
      final searchEmail = email.toLowerCase();
      query = query.where('email', isGreaterThanOrEqualTo: searchEmail)
                  .where('email', isLessThan: searchEmail + '\uf8ff');
    }

    // Apply limit and get results
    final snapshot = await query.limit(limit).get();
    return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
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
      // Soft delete by setting isActive to false
      await _petsCollection.doc(petId).update({'isActive': false});
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
} 