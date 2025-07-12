import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';

class LocalStorageService {
  static const String _guestPetsKey = 'guest_pets';
  static const String _isGuestKey = 'is_guest_user';

  // Save guest mode status
  Future<void> setGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isGuestKey, isGuest);
  }

  // Check if user is in guest mode
  Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isGuestKey) ?? false;
  }

  // Save a list of pets to local storage
  Future<void> saveGuestPets(List<Pet> pets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petsJson = pets.map((pet) => pet.toFirestore()).toList();
      await prefs.setString(_guestPetsKey, jsonEncode(petsJson));
      print('Saved ${pets.length} pets to local storage');
    } catch (e) {
      print('Error saving pets to local storage: $e');
    }
  }

  // Get pets from local storage
  Future<List<Pet>> getGuestPets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petsString = prefs.getString(_guestPetsKey);
      if (petsString == null) return [];

      final petsJson = jsonDecode(petsString) as List;
      final pets = petsJson.map((petJson) {
        final map = Map<String, dynamic>.from(petJson);
        // Convert Timestamp strings back to DateTime
        map['createdAt'] = DateTime.parse(map['createdAt']);
        map['lastUpdatedAt'] = DateTime.parse(map['lastUpdatedAt']);
        return Pet(
          id: map['id'] ?? '',
          name: map['name'] ?? '',
          species: map['species'] ?? '',
          breed: map['breed'] ?? '',
          color: map['color'] ?? '',
          age: map['age'] ?? 0,
          gender: map['gender'] ?? '',
          microchipId: map['microchipId'],
          description: map['description'],
          imageUrls: List<String>.from(map['imageUrls'] ?? []),
          ownerId: 'guest',
          createdAt: map['createdAt'],
          lastUpdatedAt: map['lastUpdatedAt'],
          medicalInfo: Map<String, dynamic>.from(map['medicalInfo'] ?? {}),
          dietaryInfo: Map<String, dynamic>.from(map['dietaryInfo'] ?? {}),
          tags: List<String>.from(map['tags'] ?? []),
          isActive: map['isActive'] ?? true,
        );
      }).toList();

      print('Loaded ${pets.length} pets from local storage');
      return pets;
    } catch (e) {
      print('Error loading pets from local storage: $e');
      return [];
    }
  }

  // Add a single pet to local storage
  Future<void> addGuestPet(Pet pet) async {
    final pets = await getGuestPets();
    pets.add(pet);
    await saveGuestPets(pets);
  }

  // Update a pet in local storage
  Future<void> updateGuestPet(Pet updatedPet) async {
    final pets = await getGuestPets();
    final index = pets.indexWhere((p) => p.id == updatedPet.id);
    if (index != -1) {
      pets[index] = updatedPet;
      await saveGuestPets(pets);
    }
  }

  // Delete a pet from local storage
  Future<void> deleteGuestPet(String petId) async {
    final pets = await getGuestPets();
    pets.removeWhere((p) => p.id == petId);
    await saveGuestPets(pets);
  }

  // Clear all guest data
  Future<void> clearGuestData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestPetsKey);
    await prefs.remove(_isGuestKey);
  }
} 