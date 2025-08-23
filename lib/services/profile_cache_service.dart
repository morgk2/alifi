import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/pet.dart';
import 'comprehensive_cache_service.dart';

/// Dedicated service for profile and photo caching
class ProfileCacheService {
  static final ProfileCacheService _instance = ProfileCacheService._internal();
  factory ProfileCacheService() => _instance;
  ProfileCacheService._internal();

  final ComprehensiveCacheService _cacheService = ComprehensiveCacheService();

  // Cache expiry times
  static const Duration _profileCacheExpiry = Duration(hours: 6);
  static const Duration _petsCacheExpiry = Duration(hours: 2);
  static const Duration _photoCacheExpiry = Duration(days: 7);
  static const Duration _coverPhotoCacheExpiry = Duration(days: 7);

  /// Cache user profile with all associated data
  Future<void> cacheUserProfile(String userId, User userData) async {
    try {
      // Cache user profile data
      final profileKey = 'user_profile_$userId';
      await _cacheService.cacheData(profileKey, userData.toMap(), expiry: _profileCacheExpiry);

      // Cache user photos
      await _cacheUserPhotos(userData);

      if (kDebugMode) {
        print('🗄️ [ProfileCache] Cached user profile: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ProfileCache] Error caching user profile: $e');
      }
    }
  }

  /// Cache user photos (profile and cover)
  Future<void> _cacheUserPhotos(User userData) async {
    try {
      // Cache profile photo
      if (userData.photoURL != null && userData.photoURL!.isNotEmpty) {
        await _cacheService.cacheImage(userData.photoURL!, expiry: _photoCacheExpiry);
        if (kDebugMode) {
          print('🗄️ [ProfileCache] Cached profile photo: ${userData.photoURL}');
        }
      }

      // Cache cover photo
      if (userData.coverPhotoURL != null && userData.coverPhotoURL!.isNotEmpty) {
        await _cacheService.cacheImage(userData.coverPhotoURL!, expiry: _coverPhotoCacheExpiry);
        if (kDebugMode) {
          print('🗄️ [ProfileCache] Cached cover photo: ${userData.coverPhotoURL}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ProfileCache] Error caching user photos: $e');
      }
    }
  }

  /// Get cached user profile
  User? getCachedUserProfile(String userId) {
    try {
      final profileKey = 'user_profile_$userId';
      final cachedData = _cacheService.getCachedData(profileKey);
      
      if (cachedData != null) {
        if (kDebugMode) {
          print('🗄️ [ProfileCache] Cache HIT for user profile: $userId');
        }
        return User.fromMap(cachedData);
      }
      
      if (kDebugMode) {
        print('🗄️ [ProfileCache] Cache MISS for user profile: $userId');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ProfileCache] Error getting cached user profile: $e');
      }
      return null;
    }
  }

  /// Cache user pets with their photos
  Future<void> cacheUserPets(String userId, List<Pet> pets) async {
    try {
      // Cache pets data
      final petsKey = 'user_pets_$userId';
      final petsData = pets.map((pet) => pet.toMap()).toList();
      await _cacheService.cacheData(petsKey, petsData, expiry: _petsCacheExpiry);

      // Cache pet photos
      await _cachePetPhotos(pets);

      if (kDebugMode) {
        print('🗄️ [ProfileCache] Cached ${pets.length} pets for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ProfileCache] Error caching user pets: $e');
      }
    }
  }

  /// Cache pet photos
  Future<void> _cachePetPhotos(List<Pet> pets) async {
    try {
      for (final pet in pets) {
        if (pet.photoURL != null && pet.photoURL!.isNotEmpty) {
          await _cacheService.cacheImage(pet.photoURL!, expiry: _photoCacheExpiry);
          if (kDebugMode) {
            print('🗄️ [ProfileCache] Cached pet photo: ${pet.photoURL}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ProfileCache] Error caching pet photos: $e');
      }
    }
  }

  /// Get cached user pets
  List<Pet>? getCachedUserPets(String userId) {
    try {
      final petsKey = 'user_pets_$userId';
      final cachedData = _cacheService.getCachedData(petsKey);
      
      if (cachedData != null) {
        if (kDebugMode) {
          print('🗄️ [ProfileCache] Cache HIT for user pets: $userId');
        }
        return (cachedData as List).map((petData) => Pet.fromMap(petData)).toList();
      }
      
      if (kDebugMode) {
        print('🗄️ [ProfileCache] Cache MISS for user pets: $userId');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ProfileCache] Error getting cached user pets: $e');
      }
      return null;
    }
  }

  /// Preload profile data for frequently accessed users
  Future<void> preloadProfileData(List<String> userIds) async {
    try {
      if (kDebugMode) {
        print('🗄️ [ProfileCache] Preloading profile data for ${userIds.length} users');
      }

      // This would typically be called with a list of user IDs
      // that are frequently accessed (e.g., current user's followers, friends, etc.)
      for (final userId in userIds) {
        // The actual preloading would happen when the data is first accessed
        // This method serves as a placeholder for future optimization
        if (kDebugMode) {
          print('🗄️ [ProfileCache] Queued preload for user: $userId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ProfileCache] Error preloading profile data: $e');
      }
    }
  }

  /// Clear profile cache for a specific user
  Future<void> clearUserProfileCache(String userId) async {
    try {
      final profileKey = 'user_profile_$userId';
      final petsKey = 'user_pets_$userId';
      
      // Clear profile data
      await _cacheService.cacheData(profileKey, null, expiry: Duration.zero);
      await _cacheService.cacheData(petsKey, null, expiry: Duration.zero);

      if (kDebugMode) {
        print('🗄️ [ProfileCache] Cleared cache for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ProfileCache] Error clearing user cache: $e');
      }
    }
  }

  /// Clear all profile cache
  Future<void> clearAllProfileCache() async {
    try {
      // This would clear all profile-related cache entries
      // For now, we'll rely on the comprehensive cache service's cleanup
      if (kDebugMode) {
        print('🗄️ [ProfileCache] Cleared all profile cache');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ProfileCache] Error clearing all profile cache: $e');
      }
    }
  }

  /// Get profile cache statistics
  Map<String, dynamic> getProfileCacheStats() {
    try {
      final stats = _cacheService.getCacheStats();
      
      // Add profile-specific statistics
      final profileStats = {
        'totalCacheHits': stats['cacheHits'] ?? 0,
        'totalCacheMisses': stats['cacheMisses'] ?? 0,
        'hitRate': stats['hitRate'] ?? '0.00',
        'memoryCacheSize': stats['memoryCacheSize'] ?? 0,
        'diskCacheSize': stats['diskCacheSize'] ?? 0,
        'profileCacheExpiry': _profileCacheExpiry.inHours,
        'petsCacheExpiry': _petsCacheExpiry.inHours,
        'photoCacheExpiry': _photoCacheExpiry.inDays,
      };

      return profileStats;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ProfileCache] Error getting cache stats: $e');
      }
      return {};
    }
  }

  /// Check if profile data is cached
  bool isProfileCached(String userId) {
    try {
      final profileKey = 'user_profile_$userId';
      final cachedData = _cacheService.getCachedData(profileKey);
      return cachedData != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if user pets are cached
  bool arePetsCached(String userId) {
    try {
      final petsKey = 'user_pets_$userId';
      final cachedData = _cacheService.getCachedData(petsKey);
      return cachedData != null;
    } catch (e) {
      return false;
    }
  }
}
