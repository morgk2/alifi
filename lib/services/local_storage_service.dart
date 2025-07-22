import 'dart:convert';
import '../models/pet.dart';
import '../models/user.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional export for LocalStorageService implementation
export 'local_storage_service_stub.dart'
  if (dart.library.html) 'local_storage_service_web.dart'
  if (dart.library.io) 'local_storage_service_io.dart';

class LocalStorageService {
  static const String _guestPetsKey = 'guest_pets';
  static const String _isGuestKey = 'is_guest_user';
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;
  static const String _recentProfilesKey = 'recent_profiles';
  static const int _maxRecentProfiles = 10;
  static const String _vetLocationsKey = 'vet_locations';
  static const String _storeLocationsKey = 'store_locations';
  static const String _vetLocationsTimestampKey = 'vet_locations_timestamp';
  static const Duration _cacheValidDuration = Duration(days: 7); // Cache valid for 7 days

  // Save guest mode status
  Future<void> setGuestMode(bool isGuest) async {
    // This method is no longer directly dependent on SharedPreferences or dart:html
    // as it is now a conditional export.
    // If the stub implementation is used, it will do nothing.
    // If the web implementation is used, it will use SharedPreferences.
    // If the io implementation is used, it will do nothing.
    // For now, we'll keep it simple, as the stub doesn't have this functionality.
    // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
    // For now, we'll just print a message.
    print('setGuestMode called (stubbed)');
  }

  // Check if user is in guest mode
  Future<bool> isGuestMode() async {
    // This method is no longer directly dependent on SharedPreferences or dart:html
    // as it is now a conditional export.
    // If the stub implementation is used, it will return false.
    // If the web implementation is used, it will use SharedPreferences.
    // If the io implementation is used, it will do nothing.
    // For now, we'll keep it simple, as the stub doesn't have this functionality.
    // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
    // For now, we'll just print a message.
    print('isGuestMode called (stubbed)');
    return false;
  }

  // Save a list of pets to local storage
  Future<void> saveGuestPets(List<Pet> pets) async {
    // This method is no longer directly dependent on SharedPreferences or dart:html
    // as it is now a conditional export.
    // If the stub implementation is used, it will do nothing.
    // If the web implementation is used, it will use SharedPreferences.
    // If the io implementation is used, it will do nothing.
    // For now, we'll keep it simple, as the stub doesn't have this functionality.
    // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
    // For now, we'll just print a message.
    print('saveGuestPets called (stubbed)');
  }

  // Get pets from local storage
  Future<List<Pet>> getGuestPets() async {
    // This method is no longer directly dependent on SharedPreferences or dart:html
    // as it is now a conditional export.
    // If the stub implementation is used, it will return an empty list.
    // If the web implementation is used, it will use SharedPreferences.
    // If the io implementation is used, it will do nothing.
    // For now, we'll keep it simple, as the stub doesn't have this functionality.
    // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
    // For now, we'll just print a message.
    print('getGuestPets called (stubbed)');
      return [];
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
    // This method is no longer directly dependent on SharedPreferences or dart:html
    // as it is now a conditional export.
    // If the stub implementation is used, it will return an empty list.
    // If the web implementation is used, it will use SharedPreferences.
    // If the io implementation is used, it will do nothing.
    // For now, we'll keep it simple, as the stub doesn't have this functionality.
    // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
    // For now, we'll just print a message.
    print('getRecentSearches called (stubbed)');
    return [];
  }

  Future<void> addRecentSearch(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return;
    
    final searches = await getRecentSearches();
    
    // Remove if exists and add to front
    searches.remove(searchTerm);
    searches.insert(0, searchTerm);
    
    // Keep only the most recent searches
    if (searches.length > _maxRecentSearches) {
      searches.removeRange(_maxRecentSearches, searches.length);
    }
    
    // This method is no longer directly dependent on SharedPreferences or dart:html
    // as it is now a conditional export.
    // If the stub implementation is used, it will do nothing.
    // If the web implementation is used, it will use SharedPreferences.
    // If the io implementation is used, it will do nothing.
    // For now, we'll keep it simple, as the stub doesn't have this functionality.
    // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
    // For now, we'll just print a message.
    print('addRecentSearch called (stubbed)');
  }

  Future<void> clearRecentSearches() async {
    // This method is no longer directly dependent on SharedPreferences or dart:html
    // as it is now a conditional export.
    // If the stub implementation is used, it will do nothing.
    // If the web implementation is used, it will use SharedPreferences.
    // If the io implementation is used, it will do nothing.
    // For now, we'll keep it simple, as the stub doesn't have this functionality.
    // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
    // For now, we'll just print a message.
    print('clearRecentSearches called (stubbed)');
  }

  Future<void> removeRecentSearch(String searchTerm) async {
    final searches = await getRecentSearches();
    searches.remove(searchTerm);
    // This method is no longer directly dependent on SharedPreferences or dart:html
    // as it is now a conditional export.
    // If the stub implementation is used, it will do nothing.
    // If the web implementation is used, it will use SharedPreferences.
    // If the io implementation is used, it will do nothing.
    // For now, we'll keep it simple, as the stub doesn't have this functionality.
    // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
    // For now, we'll just print a message.
    print('removeRecentSearch called (stubbed)');
  }

  // Recent profiles methods
  Future<List<User>> getRecentProfiles() async {
    // This method is no longer directly dependent on SharedPreferences or dart:html
    // as it is now a conditional export.
    // If the stub implementation is used, it will return an empty list.
    // If the web implementation is used, it will use SharedPreferences.
    // If the io implementation is used, it will do nothing.
    // For now, we'll keep it simple, as the stub doesn't have this functionality.
    // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
    // For now, we'll just print a message.
    print('getRecentProfiles called (stubbed)');
    return [];
  }

  Future<void> addRecentProfile(User user) async {
    final profiles = await getRecentProfiles();
    
    // Remove if already exists
    profiles.removeWhere((p) => p.id == user.id);
    
    // Add to front
    profiles.insert(0, user);
    
    // Keep only last 10
    if (profiles.length > 10) {
      profiles.removeLast();
    }
    
    // This method is no longer directly dependent on SharedPreferences or dart:html
    // as it is now a conditional export.
    // If the stub implementation is used, it will do nothing.
    // If the web implementation is used, it will use SharedPreferences.
    // If the io implementation is used, it will do nothing.
    // For now, we'll keep it simple, as the stub doesn't have this functionality.
    // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
    // For now, we'll just print a message.
    print('addRecentProfile called (stubbed)');
  }

  // Vet Locations methods
  Future<void> saveVetLocations(List<Map<String, dynamic>> vets) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = {
      'vets': vets,
      'timestamp': timestamp,
    };
    final jsonString = json.encode(data);

    if (kIsWeb) {
      // This method is no longer directly dependent on SharedPreferences or dart:html
      // as it is now a conditional export.
      // If the stub implementation is used, it will do nothing.
      // If the web implementation is used, it will use dart:html.
      // If the io implementation is used, it will do nothing.
      // For now, we'll keep it simple, as the stub doesn't have this functionality.
      // If the stub were to be updated, it would need to be passed a mock or actual dart:html.
      // For now, we'll just print a message.
      print('saveVetLocations called (stubbed)');
    } else {
      // This method is no longer directly dependent on SharedPreferences or dart:html
      // as it is now a conditional export.
      // If the stub implementation is used, it will do nothing.
      // If the web implementation is used, it will use SharedPreferences.
      // If the io implementation is used, it will do nothing.
      // For now, we'll keep it simple, as the stub doesn't have this functionality.
      // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
      // For now, we'll just print a message.
      print('saveVetLocations called (stubbed)');
    }
  }

  // Get cached vet locations
  Future<List<Map<String, dynamic>>?> getCachedVetLocations() async {
    String? jsonString;
    
    if (kIsWeb) {
      // This method is no longer directly dependent on SharedPreferences or dart:html
      // as it is now a conditional export.
      // If the stub implementation is used, it will do nothing.
      // If the web implementation is used, it will use dart:html.
      // If the io implementation is used, it will do nothing.
      // For now, we'll keep it simple, as the stub doesn't have this functionality.
      // If the stub were to be updated, it would need to be passed a mock or actual dart:html.
      // For now, we'll just print a message.
      print('getCachedVetLocations called (stubbed)');
    } else {
      // This method is no longer directly dependent on SharedPreferences or dart:html
      // as it is now a conditional export.
      // If the stub implementation is used, it will do nothing.
      // If the web implementation is used, it will use SharedPreferences.
      // If the io implementation is used, it will do nothing.
      // For now, we'll keep it simple, as the stub doesn't have this functionality.
      // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
      // For now, we'll just print a message.
      print('getCachedVetLocations called (stubbed)');
    }
    return null;
  }

  // Clear cached vet locations
  Future<void> clearCachedVetLocations() async {
    if (kIsWeb) {
      // This method is no longer directly dependent on SharedPreferences or dart:html
      // as it is now a conditional export.
      // If the stub implementation is used, it will do nothing.
      // If the web implementation is used, it will use dart:html.
      // If the io implementation is used, it will do nothing.
      // For now, we'll keep it simple, as the stub doesn't have this functionality.
      // If the stub were to be updated, it would need to be passed a mock or actual dart:html.
      // For now, we'll just print a message.
      print('clearCachedVetLocations called (stubbed)');
    } else {
      // This method is no longer directly dependent on SharedPreferences or dart:html
      // as it is now a conditional export.
      // If the stub implementation is used, it will do nothing.
      // If the web implementation is used, it will use SharedPreferences.
      // If the io implementation is used, it will do nothing.
      // For now, we'll keep it simple, as the stub doesn't have this functionality.
      // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
      // For now, we'll just print a message.
      print('clearCachedVetLocations called (stubbed)');
    }
  }

  // Check if cache is valid
  Future<bool> isCacheValid() async {
    String? jsonString;
    
    if (kIsWeb) {
      // This method is no longer directly dependent on SharedPreferences or dart:html
      // as it is now a conditional export.
      // If the stub implementation is used, it will do nothing.
      // If the web implementation is used, it will use dart:html.
      // If the io implementation is used, it will do nothing.
      // For now, we'll keep it simple, as the stub doesn't have this functionality.
      // If the stub were to be updated, it would need to be passed a mock or actual dart:html.
      // For now, we'll just print a message.
      print('isCacheValid called (stubbed)');
    } else {
      // This method is no longer directly dependent on SharedPreferences or dart:html
      // as it is now a conditional export.
      // If the stub implementation is used, it will do nothing.
      // If the web implementation is used, it will use SharedPreferences.
      // If the io implementation is used, it will do nothing.
      // For now, we'll keep it simple, as the stub doesn't have this functionality.
      // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
      // For now, we'll just print a message.
      print('isCacheValid called (stubbed)');
    }
    return false;
  }

  // Store Locations methods
  Future<void> saveStoreLocations(List<Map<String, dynamic>> stores) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = {
      'stores': stores,
      'timestamp': timestamp,
    };
    final jsonString = json.encode(data);

    if (kIsWeb) {
      print('saveStoreLocations called (web)');
    } else {
      print('saveStoreLocations called (io)');
    }
  }

  Future<List<Map<String, dynamic>>?> getCachedStoreLocations() async {
    String? jsonString;
    
    if (kIsWeb) {
      print('getCachedStoreLocations called (web)');
    } else {
      print('getCachedStoreLocations called (io)');
    }
    return null;
  }

  Future<void> clearCachedStoreLocations() async {
    if (kIsWeb) {
      print('clearCachedStoreLocations called (web)');
    } else {
      print('clearCachedStoreLocations called (io)');
    }
  }

  Future<bool> isStoreCacheValid() async {
    if (kIsWeb) {
      print('isStoreCacheValid called (web)');
    } else {
      print('isStoreCacheValid called (io)');
    }
    return false;
  }

  @override
  Future<void> clearGuestData() async {
    // This method is no longer directly dependent on SharedPreferences or dart:html
    // as it is now a conditional export.
    // If the stub implementation is used, it will do nothing.
    // If the web implementation is used, it will use SharedPreferences.
    // If the io implementation is used, it will do nothing.
    // For now, we'll keep it simple, as the stub doesn't have this functionality.
    // If the stub were to be updated, it would need to be passed a mock or actual SharedPreferences.
    // For now, we'll just print a message.
    print('clearGuestData called (stubbed)');
  }
} 