import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/pet.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
  Future<String> createPet(Pet pet) async {
    final docRef = await _petsCollection.add(pet.toFirestore());
    return docRef.id;
  }

  Future<void> updatePet(Pet pet) async {
    await _petsCollection.doc(pet.id).update(pet.toFirestore());
  }

  Future<void> deletePet(String petId) async {
    // Soft delete by setting isActive to false
    await _petsCollection.doc(petId).update({'isActive': false});
  }

  Future<Pet?> getPet(String petId) async {
    final doc = await _petsCollection.doc(petId).get();
    return doc.exists ? Pet.fromFirestore(doc) : null;
  }

  Stream<Pet?> getPetStream(String petId) {
    return _petsCollection
        .doc(petId)
        .snapshots()
        .map((doc) => doc.exists ? Pet.fromFirestore(doc) : null);
  }

  // Get all active pets for a user
  Stream<List<Pet>> getUserPets(String userId) {
    return _petsCollection
        .where('ownerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList());
  }

  // Search pets by various criteria
  Future<List<Pet>> searchPets({
    String? species,
    String? breed,
    int? maxAge,
    List<String>? tags,
  }) async {
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

  // Get recently added pets
  Future<List<Pet>> getRecentPets({int limit = 10}) async {
    final snapshot = await _petsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
  }

  // Create indexes for common queries
  Future<void> createIndexes() async {
    // Note: This is just a reminder - actual index creation should be done
    // through the Firebase Console or Firebase CLI
    
    // Recommended indexes:
    // 1. Collection: pets
    //    Fields: ownerId (Ascending), isActive (Ascending), createdAt (Descending)
    
    // 2. Collection: pets
    //    Fields: species (Ascending), isActive (Ascending), createdAt (Descending)
    
    // 3. Collection: pets
    //    Fields: breed (Ascending), isActive (Ascending), createdAt (Descending)
    
    // 4. Collection: pets
    //    Fields: tags (Array), isActive (Ascending), createdAt (Descending)
  }
} 