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
    await _usersCollection.doc(user.id).update(user.toFirestore());
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