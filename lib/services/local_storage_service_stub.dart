import 'dart:convert';

class LocalStorageService {
  static const String _vetLocationsKey = 'vet_locations';
  static const String _storeLocationsKey = 'store_locations';
  static const Duration _cacheValidDuration = Duration(days: 7);

  // Guest mode methods
  Future<void> setGuestMode(bool isGuest) async {
    print('setGuestMode called (stubbed)');
  }

  Future<bool> isGuestMode() async {
    print('isGuestMode called (stubbed)');
    return false;
  }

  Future<void> saveGuestPets(List<dynamic> pets) async {
    print('saveGuestPets called (stubbed)');
  }

  Future<List<dynamic>> getGuestPets() async {
    print('getGuestPets called (stubbed)');
    return [];
  }

  Future<void> addGuestPet(dynamic pet) async {
    print('addGuestPet called (stubbed)');
  }

  Future<void> updateGuestPet(dynamic pet) async {
    print('updateGuestPet called (stubbed)');
  }

  Future<void> deleteGuestPet(String petId) async {
    print('deleteGuestPet called (stubbed)');
  }

  // Recent searches methods
  Future<List<String>> getRecentSearches() async {
    print('getRecentSearches called (stubbed)');
    return [];
  }

  Future<void> addRecentSearch(String searchTerm) async {
    print('addRecentSearch called (stubbed)');
  }

  Future<void> clearRecentSearches() async {
    print('clearRecentSearches called (stubbed)');
  }

  Future<void> removeRecentSearch(String searchTerm) async {
    print('removeRecentSearch called (stubbed)');
  }

  // Recent profiles methods
  Future<List<dynamic>> getRecentProfiles() async {
    print('getRecentProfiles called (stubbed)');
    return [];
  }

  Future<void> addRecentProfile(dynamic user) async {
    print('addRecentProfile called (stubbed)');
  }

  // Vet Locations methods
  Future<void> saveVetLocations(List<Map<String, dynamic>> vets) async {
    print('saveVetLocations called (stubbed)');
  }

  Future<List<Map<String, dynamic>>?> getCachedVetLocations() async {
    print('getCachedVetLocations called (stubbed)');
    return null;
  }

  Future<void> clearCachedVetLocations() async {
    print('clearCachedVetLocations called (stubbed)');
  }

  Future<bool> isVetCacheValid() async {
    print('isVetCacheValid called (stubbed)');
    return false;
  }

  // Store Locations methods
  Future<void> saveStoreLocations(List<Map<String, dynamic>> stores) async {
    print('saveStoreLocations called (stubbed)');
  }

  Future<List<Map<String, dynamic>>?> getCachedStoreLocations() async {
    print('getCachedStoreLocations called (stubbed)');
    return null;
  }

  Future<void> clearCachedStoreLocations() async {
    print('clearCachedStoreLocations called (stubbed)');
  }

  Future<bool> isStoreCacheValid() async {
    print('isStoreCacheValid called (stubbed)');
    return false;
  }

  Future<void> clearGuestData() async {
    print('clearGuestData called (stubbed)');
  }
} 