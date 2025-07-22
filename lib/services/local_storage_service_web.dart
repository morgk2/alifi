import 'dart:convert';
import 'dart:html' as html;

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
    html.window.localStorage[_isGuestKey] = isGuest.toString();
  }

  Future<bool> isGuestMode() async {
    final value = html.window.localStorage[_isGuestKey];
    return value == 'true';
  }

  Future<void> saveGuestPets(List<dynamic> pets) async {
    final jsonString = json.encode(pets);
    html.window.localStorage[_guestPetsKey] = jsonString;
  }

  Future<List<dynamic>> getGuestPets() async {
    final jsonString = html.window.localStorage[_guestPetsKey];
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
    final jsonString = html.window.localStorage[_recentSearchesKey];
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
    
    html.window.localStorage[_recentSearchesKey] = json.encode(searches);
  }

  Future<void> clearRecentSearches() async {
    html.window.localStorage.remove(_recentSearchesKey);
  }

  Future<void> removeRecentSearch(String searchTerm) async {
    final searches = await getRecentSearches();
    searches.remove(searchTerm);
    html.window.localStorage[_recentSearchesKey] = json.encode(searches);
  }

  // Recent profiles methods
  Future<List<dynamic>> getRecentProfiles() async {
    final jsonString = html.window.localStorage[_recentProfilesKey];
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
    
    html.window.localStorage[_recentProfilesKey] = json.encode(profiles);
  }

  // Vet Locations methods
  Future<void> saveVetLocations(List<Map<String, dynamic>> vets) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = {
      'vets': vets,
      'timestamp': timestamp,
    };
    final jsonString = json.encode(data);
    html.window.localStorage[_vetLocationsKey] = jsonString;
  }

  Future<List<Map<String, dynamic>>?> getCachedVetLocations() async {
    final jsonString = html.window.localStorage[_vetLocationsKey];
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
    html.window.localStorage.remove(_vetLocationsKey);
  }

  Future<bool> isVetCacheValid() async {
    return _isCacheValid(_vetLocationsKey);
  }

  // Store Locations methods
  Future<void> saveStoreLocations(List<Map<String, dynamic>> stores) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = {
      'stores': stores,
      'timestamp': timestamp,
    };
    final jsonString = json.encode(data);
    html.window.localStorage[_storeLocationsKey] = jsonString;
  }

  Future<List<Map<String, dynamic>>?> getCachedStoreLocations() async {
    final jsonString = html.window.localStorage[_storeLocationsKey];
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
    html.window.localStorage.remove(_storeLocationsKey);
  }

  Future<bool> isStoreCacheValid() async {
    return _isCacheValid(_storeLocationsKey);
  }

  Future<bool> _isCacheValid(String key) async {
    final jsonString = html.window.localStorage[key];
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
    html.window.localStorage.remove(_guestPetsKey);
    html.window.localStorage.remove(_isGuestKey);
  }
} 