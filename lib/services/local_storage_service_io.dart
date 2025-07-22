import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _guestPetsKey = 'guest_pets';
  static const String _isGuestKey = 'is_guest_user';
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;
  static const String _recentProfilesKey = 'recent_profiles';
  static const int _maxRecentProfiles = 10;
  static const String _vetLocationsKey = 'vet_locations';
  static const String _storeLocationsKey = 'store_locations';
  static const Duration _cacheValidDuration = Duration(days: 7);

  // Guest mode methods
  Future<void> setGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isGuestKey, isGuest);
  }

  Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isGuestKey) ?? false;
  }

  Future<void> saveGuestPets(List<dynamic> pets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(pets);
    await prefs.setString(_guestPetsKey, jsonString);
  }

  Future<List<dynamic>> getGuestPets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_guestPetsKey);
    if (jsonString != null) {
      try {
        return json.decode(jsonString) as List<dynamic>;
      } catch (e) {
        print('Error parsing guest pets: $e');
      }
    }
    return [];
  }

  Future<void> addGuestPet(dynamic pet) async {
    final pets = await getGuestPets();
    pets.add(pet);
    await saveGuestPets(pets);
  }

  Future<void> updateGuestPet(dynamic pet) async {
    final pets = await getGuestPets();
    final index = pets.indexWhere((p) => p['id'] == pet['id']);
    if (index != -1) {
      pets[index] = pet;
      await saveGuestPets(pets);
    }
  }

  Future<void> deleteGuestPet(String petId) async {
    final pets = await getGuestPets();
    pets.removeWhere((p) => p['id'] == petId);
    await saveGuestPets(pets);
  }

  // Recent searches methods
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_recentSearchesKey);
    if (jsonString != null) {
      try {
        return List<String>.from(json.decode(jsonString));
      } catch (e) {
        print('Error parsing recent searches: $e');
      }
    }
    return [];
  }

  Future<void> addRecentSearch(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return;
    
    final searches = await getRecentSearches();
    searches.remove(searchTerm);
    searches.insert(0, searchTerm);
    
    if (searches.length > _maxRecentSearches) {
      searches.removeRange(_maxRecentSearches, searches.length);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentSearchesKey, json.encode(searches));
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }

  Future<void> removeRecentSearch(String searchTerm) async {
    final searches = await getRecentSearches();
    searches.remove(searchTerm);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentSearchesKey, json.encode(searches));
  }

  // Recent profiles methods
  Future<List<dynamic>> getRecentProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_recentProfilesKey);
    if (jsonString != null) {
      try {
        return json.decode(jsonString) as List<dynamic>;
      } catch (e) {
        print('Error parsing recent profiles: $e');
      }
    }
    return [];
  }

  Future<void> addRecentProfile(dynamic user) async {
    final profiles = await getRecentProfiles();
    profiles.removeWhere((p) => p['id'] == user['id']);
    profiles.insert(0, user);
    
    if (profiles.length > _maxRecentProfiles) {
      profiles.removeLast();
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentProfilesKey, json.encode(profiles));
  }

  // Vet Locations methods
  Future<void> saveVetLocations(List<Map<String, dynamic>> vets) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = {
      'vets': vets,
      'timestamp': timestamp,
    };
    final jsonString = json.encode(data);
    await prefs.setString(_vetLocationsKey, jsonString);
  }

  Future<List<Map<String, dynamic>>?> getCachedVetLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_vetLocationsKey);
    if (jsonString != null) {
      try {
        final data = json.decode(jsonString) as Map<String, dynamic>;
        final timestamp = data['timestamp'] as int;
        final vets = List<Map<String, dynamic>>.from(data['vets'] as List);
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (cacheAge < _cacheValidDuration.inMilliseconds) {
          return vets;
        }
      } catch (e) {
        print('Error parsing cached vet locations: $e');
      }
    }
    return null;
  }

  Future<void> clearCachedVetLocations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vetLocationsKey);
  }

  Future<bool> isVetCacheValid() async {
    return _isCacheValid(_vetLocationsKey);
  }

  // Store Locations methods
  Future<void> saveStoreLocations(List<Map<String, dynamic>> stores) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = {
      'stores': stores,
      'timestamp': timestamp,
    };
    final jsonString = json.encode(data);
    await prefs.setString(_storeLocationsKey, jsonString);
  }

  Future<List<Map<String, dynamic>>?> getCachedStoreLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storeLocationsKey);
    if (jsonString != null) {
      try {
        final data = json.decode(jsonString) as Map<String, dynamic>;
        final timestamp = data['timestamp'] as int;
        final stores = List<Map<String, dynamic>>.from(data['stores'] as List);
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (cacheAge < _cacheValidDuration.inMilliseconds) {
          return stores;
        }
      } catch (e) {
        print('Error parsing cached store locations: $e');
      }
    }
    return null;
  }

  Future<void> clearCachedStoreLocations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storeLocationsKey);
  }

  Future<bool> isStoreCacheValid() async {
    return _isCacheValid(_storeLocationsKey);
  }

  Future<bool> _isCacheValid(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      try {
        final data = json.decode(jsonString) as Map<String, dynamic>;
        final timestamp = data['timestamp'] as int;
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        return cacheAge < _cacheValidDuration.inMilliseconds;
      } catch (e) {
        print('Error checking cache validity: $e');
      }
    }
    return false;
  }

  Future<void> clearGuestData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestPetsKey);
    await prefs.remove(_isGuestKey);
  }
} 