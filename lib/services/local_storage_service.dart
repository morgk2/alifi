import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../models/user.dart';

class LocalStorageService {
  static const String _guestPetsKey = 'guest_pets';
  static const String _isGuestKey = 'is_guest_user';
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;
  static const String _recentProfilesKey = 'recent_profiles';
  static const int _maxRecentProfiles = 10;

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
      final petsJson = pets.map((pet) => jsonEncode(pet.toFirestore())).toList();
      await prefs.setStringList(_guestPetsKey, petsJson);
      print('Saved ${pets.length} pets to local storage');
    } catch (e) {
      print('Error saving pets to local storage: $e');
    }
  }

  // Get pets from local storage
  Future<List<Pet>> getGuestPets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petsJson = prefs.getStringList(_guestPetsKey) ?? [];

      final pets = petsJson.map((json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        // Convert timestamps to DateTime
        if (map['createdAt'] != null) {
          map['createdAt'] = (map['createdAt'] as Map<String, dynamic>)['_seconds'];
          map['createdAt'] = DateTime.fromMillisecondsSinceEpoch(map['createdAt'] * 1000);
        }
        if (map['lastUpdatedAt'] != null) {
          map['lastUpdatedAt'] = (map['lastUpdatedAt'] as Map<String, dynamic>)['_seconds'];
          map['lastUpdatedAt'] = DateTime.fromMillisecondsSinceEpoch(map['lastUpdatedAt'] * 1000);
        }
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
          createdAt: map['createdAt'] ?? DateTime.now(),
          lastUpdatedAt: map['lastUpdatedAt'] ?? DateTime.now(),
          medicalInfo: Map<String, dynamic>.from(map['medicalInfo'] ?? {}),
          dietaryInfo: Map<String, dynamic>.from(map['dietaryInfo'] ?? {}),
          tags: List<String>.from(map['tags'] ?? []),
          isActive: map['isActive'] ?? true,
          weight: (map['weight'] as num?)?.toDouble(),
        );
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by creation time, newest first

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

  // Recent searches methods
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSearchesKey) ?? [];
  }

  Future<void> addRecentSearch(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final searches = await getRecentSearches();
    
    // Remove if exists and add to front
    searches.remove(searchTerm);
    searches.insert(0, searchTerm);
    
    // Keep only the most recent searches
    if (searches.length > _maxRecentSearches) {
      searches.removeRange(_maxRecentSearches, searches.length);
    }
    
    await prefs.setStringList(_recentSearchesKey, searches);
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }

  Future<void> removeRecentSearch(String searchTerm) async {
    final prefs = await SharedPreferences.getInstance();
    final searches = await getRecentSearches();
    searches.remove(searchTerm);
    await prefs.setStringList(_recentSearchesKey, searches);
  }

  // Recent profiles methods
  Future<List<User>> getRecentProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getStringList(_recentProfilesKey) ?? [];
    
    return profilesJson.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return User(
        id: map['id'] ?? '',
        email: map['email'] ?? '',
        displayName: map['displayName'],
        username: map['username'],
        photoURL: map['photoURL'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
        lastLoginAt: DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'] ?? DateTime.now().millisecondsSinceEpoch),
        linkedAccounts: Map<String, bool>.from(map['linkedAccounts'] ?? {}),
        followers: List<String>.from(map['followers'] ?? []),
        following: List<String>.from(map['following'] ?? []),
        followersCount: map['followersCount'] ?? 0,
        followingCount: map['followingCount'] ?? 0,
        pets: List<String>.from(map['pets'] ?? []),
        level: map['level'] ?? 1,
        petsRescued: map['petsRescued'] ?? 0,
      );
    }).toList();
  }

  Future<void> addRecentProfile(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await getRecentProfiles();
    
    // Remove if exists (to move it to front)
    profiles.removeWhere((p) => p.id == user.id);
    
    // Add to front
    profiles.insert(0, user);
    
    // Keep only the most recent profiles
    if (profiles.length > _maxRecentProfiles) {
      profiles.removeRange(_maxRecentProfiles, profiles.length);
    }
    
    // Convert to JSON and save
    final profilesJson = profiles.map((user) => jsonEncode({
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'username': user.username,
      'photoURL': user.photoURL,
      'createdAt': user.createdAt.millisecondsSinceEpoch,
      'lastLoginAt': user.lastLoginAt.millisecondsSinceEpoch,
      'linkedAccounts': user.linkedAccounts,
      'followers': user.followers,
      'following': user.following,
      'followersCount': user.followersCount,
      'followingCount': user.followingCount,
      'pets': user.pets,
      'level': user.level,
      'petsRescued': user.petsRescued,
    })).toList();
    
    await prefs.setStringList(_recentProfilesKey, profilesJson);
  }

  @override
  Future<void> clearGuestData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestPetsKey);
    await prefs.remove(_isGuestKey);
    await prefs.remove(_recentSearchesKey);
    await prefs.remove(_recentProfilesKey);
  }
} 