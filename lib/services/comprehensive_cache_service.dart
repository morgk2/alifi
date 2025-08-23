import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

/// Comprehensive caching service for the entire app
class ComprehensiveCacheService {
  static final ComprehensiveCacheService _instance = ComprehensiveCacheService._internal();
  factory ComprehensiveCacheService() => _instance;
  ComprehensiveCacheService._internal();

  // Cache settings
  static const Duration _defaultCacheExpiry = Duration(hours: 24);
  static const Duration _shortCacheExpiry = Duration(minutes: 30);
  static const Duration _longCacheExpiry = Duration(days: 7);
  static const int _maxMemoryCacheSize = 100; // Maximum items in memory cache
  static const int _maxDiskCacheSize = 500 * 1024 * 1024; // 500MB disk cache

  // Cache directories
  Directory? _cacheDir;
  Directory? _imagesCacheDir;
  Directory? _dataCacheDir;
  Directory? _firestoreCacheDir;

  // In-memory caches
  final Map<String, _CacheEntry> _memoryCache = {};
  final Map<String, DateTime> _accessTimes = {};

  // Cache statistics
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _totalRequests = 0;

  // Initialization flag
  bool _isInitialized = false;

  /// Initialize the comprehensive cache service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Create cache directories
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/app_cache');
      _imagesCacheDir = Directory('${_cacheDir!.path}/images');
      _dataCacheDir = Directory('${_cacheDir!.path}/data');
      _firestoreCacheDir = Directory('${_cacheDir!.path}/firestore');

      // Create directories if they don't exist
      await _createDirectories();

      // Configure Firestore persistence for all platforms
      await _configureFirestorePersistence();

      // Load cache metadata
      await _loadCacheMetadata();

      // Clean old cache entries
      await _cleanCache();

      _isInitialized = true;

      if (kDebugMode) {
        print('🗄️ [ComprehensiveCache] Initialized successfully');
        print('🗄️ [ComprehensiveCache] Cache directories created');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Initialization error: $e');
      }
    }
  }

  /// Configure Firestore persistence for all platforms
  Future<void> _configureFirestorePersistence() async {
    try {
      // Configure Firestore settings for optimal caching
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        sslEnabled: true,
      );

      // Enable persistence for web
      if (kIsWeb) {
        await FirebaseFirestore.instance.enablePersistence(
          const PersistenceSettings(synchronizeTabs: true),
        );
      }

      if (kDebugMode) {
        print('🗄️ [ComprehensiveCache] Firestore persistence configured');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Firestore persistence error: $e');
      }
    }
  }

  /// Create cache directories
  Future<void> _createDirectories() async {
    final directories = [_cacheDir!, _imagesCacheDir!, _dataCacheDir!, _firestoreCacheDir!];
    
    for (final dir in directories) {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
  }

  /// Cache data with automatic expiry
  Future<void> cacheData(String key, dynamic data, {Duration? expiry}) async {
    if (!_isInitialized) await initialize();

    try {
      final cacheEntry = _CacheEntry(
        data: data,
        timestamp: DateTime.now(),
        expiry: expiry ?? _defaultCacheExpiry,
      );

      // Add to memory cache
      _memoryCache[key] = cacheEntry;
      _accessTimes[key] = DateTime.now();

      // Save to disk cache
      await _saveToDiskCache(key, cacheEntry);

      // Enforce memory cache limits
      await _enforceMemoryCacheLimits();

      if (kDebugMode) {
        print('🗄️ [ComprehensiveCache] Cached data: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error caching data: $e');
      }
    }
  }

  /// Get cached data
  dynamic getCachedData(String key) {
    if (!_isInitialized) return null;

    try {
      // Check memory cache first
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null && memoryEntry.isValid) {
        _cacheHits++;
        _accessTimes[key] = DateTime.now();
        
        if (kDebugMode) {
          print('🗄️ [ComprehensiveCache] Memory cache HIT: $key');
        }
        
        return memoryEntry.data;
      }

      // Check disk cache
      final diskEntry = _loadFromDiskCache(key);
      if (diskEntry != null && diskEntry.isValid) {
        _cacheHits++;
        
        // Add back to memory cache
        _memoryCache[key] = diskEntry;
        _accessTimes[key] = DateTime.now();
        
        if (kDebugMode) {
          print('🗄️ [ComprehensiveCache] Disk cache HIT: $key');
        }
        
        return diskEntry.data;
      }

      _cacheMisses++;
      
      if (kDebugMode) {
        print('🗄️ [ComprehensiveCache] Cache MISS: $key');
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error getting cached data: $e');
      }
      return null;
    }
  }

  /// Cache image with automatic optimization
  Future<void> cacheImage(String imageUrl, {Duration? expiry}) async {
    if (!_isInitialized) await initialize();

    try {
      final imageKey = _generateImageKey(imageUrl);
      final imageFile = File('${_imagesCacheDir!.path}/$imageKey.jpg');

      // Check if already cached
      if (await imageFile.exists()) {
        if (kDebugMode) {
          print('🗄️ [ComprehensiveCache] Image already cached: $imageUrl');
        }
        return;
      }

      // Download and cache image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await imageFile.writeAsBytes(response.bodyBytes);
        
        // Add to memory cache metadata
        final cacheEntry = _CacheEntry(
          data: imageFile.path,
          timestamp: DateTime.now(),
          expiry: expiry ?? _longCacheExpiry,
        );
        
        _memoryCache[imageKey] = cacheEntry;
        _accessTimes[imageKey] = DateTime.now();

        if (kDebugMode) {
          print('🗄️ [ComprehensiveCache] Image cached: $imageUrl');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error caching image: $e');
      }
    }
  }

  /// Get cached image path
  String? getCachedImagePath(String imageUrl) {
    if (!_isInitialized) return null;

    try {
      final imageKey = _generateImageKey(imageUrl);
      final imageFile = File('${_imagesCacheDir!.path}/$imageKey.jpg');

      if (imageFile.existsSync()) {
        final cacheEntry = _memoryCache[imageKey];
        if (cacheEntry != null && cacheEntry.isValid) {
          _cacheHits++;
          _accessTimes[imageKey] = DateTime.now();
          
          if (kDebugMode) {
            print('🗄️ [ComprehensiveCache] Image cache HIT: $imageUrl');
          }
          
          return imageFile.path;
        }
      }

      _cacheMisses++;
      
      if (kDebugMode) {
        print('🗄️ [ComprehensiveCache] Image cache MISS: $imageUrl');
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error getting cached image: $e');
      }
      return null;
    }
  }

  /// Cache Firestore query results
  Future<void> cacheFirestoreQuery(String collection, Map<String, dynamic> query, List<dynamic> results, {Duration? expiry}) async {
    if (!_isInitialized) await initialize();

    try {
      final queryKey = _generateFirestoreQueryKey(collection, query);
      await cacheData(queryKey, results, expiry: expiry ?? _shortCacheExpiry);
      
      if (kDebugMode) {
        print('🗄️ [ComprehensiveCache] Firestore query cached: $collection');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error caching Firestore query: $e');
      }
    }
  }

  /// Get cached Firestore query results
  List<dynamic>? getCachedFirestoreQuery(String collection, Map<String, dynamic> query) {
    if (!_isInitialized) return null;

    try {
      final queryKey = _generateFirestoreQueryKey(collection, query);
      final results = getCachedData(queryKey);
      
      if (results != null) {
        if (kDebugMode) {
          print('🗄️ [ComprehensiveCache] Firestore query cache HIT: $collection');
        }
        return results as List<dynamic>;
      }
      
      if (kDebugMode) {
        print('🗄️ [ComprehensiveCache] Firestore query cache MISS: $collection');
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error getting cached Firestore query: $e');
      }
      return null;
    }
  }

  /// Preload frequently accessed data
  Future<void> preloadFrequentData() async {
    if (!_isInitialized) await initialize();

    try {
      // Preload user preferences
      final prefs = await SharedPreferences.getInstance();
      final userPrefs = {
        'language': prefs.getString('user_language'),
        'currency': prefs.getString('user_currency'),
        'notifications': prefs.getBool('notifications_enabled'),
      };
      await cacheData('user_preferences', userPrefs, expiry: _longCacheExpiry);

      // Preload app settings
      final appSettings = {
        'last_update': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
      await cacheData('app_settings', appSettings, expiry: _longCacheExpiry);

      if (kDebugMode) {
        print('🗄️ [ComprehensiveCache] Frequent data preloaded');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error preloading frequent data: $e');
      }
    }
  }

  /// Save to disk cache
  Future<void> _saveToDiskCache(String key, _CacheEntry entry) async {
    try {
      final cacheFile = File('${_dataCacheDir!.path}/$key.json');
      final cacheData = {
        'data': entry.data,
        'timestamp': entry.timestamp.toIso8601String(),
        'expiry': entry.expiry.inMilliseconds,
      };
      
      await cacheFile.writeAsString(json.encode(cacheData));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error saving to disk cache: $e');
      }
    }
  }

  /// Load from disk cache
  _CacheEntry? _loadFromDiskCache(String key) {
    try {
      final cacheFile = File('${_dataCacheDir!.path}/$key.json');
      if (!cacheFile.existsSync()) return null;

      final cacheData = json.decode(cacheFile.readAsStringSync());
      return _CacheEntry(
        data: cacheData['data'],
        timestamp: DateTime.parse(cacheData['timestamp']),
        expiry: Duration(milliseconds: cacheData['expiry']),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error loading from disk cache: $e');
      }
      return null;
    }
  }

  /// Load cache metadata
  Future<void> _loadCacheMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cacheHits = prefs.getInt('cache_hits') ?? 0;
      _cacheMisses = prefs.getInt('cache_misses') ?? 0;
      _totalRequests = prefs.getInt('total_requests') ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error loading cache metadata: $e');
      }
    }
  }

  /// Save cache metadata
  Future<void> _saveCacheMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cache_hits', _cacheHits);
      await prefs.setInt('cache_misses', _cacheMisses);
      await prefs.setInt('total_requests', _totalRequests);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error saving cache metadata: $e');
      }
    }
  }

  /// Clean old cache entries
  Future<void> _cleanCache() async {
    try {
      final now = DateTime.now();
      final keysToRemove = <String>[];

      // Clean memory cache
      for (final entry in _memoryCache.entries) {
        if (!entry.value.isValid) {
          keysToRemove.add(entry.key);
        }
      }

      for (final key in keysToRemove) {
        _memoryCache.remove(key);
        _accessTimes.remove(key);
      }

      // Clean disk cache
      await _cleanDiskCache();

      if (kDebugMode && keysToRemove.isNotEmpty) {
        print('🗄️ [ComprehensiveCache] Cleaned ${keysToRemove.length} expired entries');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error cleaning cache: $e');
      }
    }
  }

  /// Clean disk cache
  Future<void> _cleanDiskCache() async {
    try {
      final dataDir = _dataCacheDir!;
      if (!await dataDir.exists()) return;

      final files = await dataDir.list().toList();
      int totalSize = 0;
      final fileSizes = <File, int>{};

      // Calculate total size
      for (final file in files) {
        if (file is File) {
          final size = await file.length();
          totalSize += size;
          fileSizes[file] = size;
        }
      }

      // If total size exceeds limit, remove oldest files
      if (totalSize > _maxDiskCacheSize) {
        final sortedFiles = fileSizes.entries.toList()
          ..sort((a, b) => a.key.lastModifiedSync().compareTo(b.key.lastModifiedSync()));

        int currentSize = totalSize;
        for (final entry in sortedFiles) {
          if (currentSize <= _maxDiskCacheSize) break;
          
          await entry.key.delete();
          currentSize -= entry.value;
        }

        if (kDebugMode) {
          print('🗄️ [ComprehensiveCache] Disk cache cleaned, freed ${totalSize - currentSize} bytes');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error cleaning disk cache: $e');
      }
    }
  }

  /// Enforce memory cache limits
  Future<void> _enforceMemoryCacheLimits() async {
    try {
      if (_memoryCache.length > _maxMemoryCacheSize) {
        final sortedKeys = _accessTimes.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

        final keysToRemove = sortedKeys
            .take(_memoryCache.length - _maxMemoryCacheSize)
            .map((e) => e.key)
            .toList();

        for (final key in keysToRemove) {
          _memoryCache.remove(key);
          _accessTimes.remove(key);
        }

        if (kDebugMode) {
          print('🗄️ [ComprehensiveCache] Memory cache cleaned, removed ${keysToRemove.length} items');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error enforcing memory cache limits: $e');
      }
    }
  }

  /// Generate image cache key
  String _generateImageKey(String imageUrl) {
    final bytes = utf8.encode(imageUrl);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate Firestore query cache key
  String _generateFirestoreQueryKey(String collection, Map<String, dynamic> query) {
    final queryString = '$collection:${json.encode(query)}';
    final bytes = utf8.encode(queryString);
    final digest = sha256.convert(bytes);
    return 'firestore_${digest.toString()}';
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheHits': _cacheHits,
      'cacheMisses': _cacheMisses,
      'totalRequests': _totalRequests,
      'hitRate': _totalRequests > 0 ? (_cacheHits / _totalRequests * 100).toStringAsFixed(2) : '0.00',
      'memoryCacheSize': _memoryCache.length,
      'diskCacheSize': _getDiskCacheSize(),
    };
  }

  /// Get disk cache size
  int _getDiskCacheSize() {
    try {
      if (_dataCacheDir == null || !_dataCacheDir!.existsSync()) return 0;
      
      int totalSize = 0;
      final files = _dataCacheDir!.listSync();
      
      for (final file in files) {
        if (file is File) {
          totalSize += file.lengthSync();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      // Clear memory cache
      _memoryCache.clear();
      _accessTimes.clear();

      // Clear disk cache
      if (_dataCacheDir != null && await _dataCacheDir!.exists()) {
        await _dataCacheDir!.delete(recursive: true);
        await _dataCacheDir!.create();
      }

      // Clear image cache
      if (_imagesCacheDir != null && await _imagesCacheDir!.exists()) {
        await _imagesCacheDir!.delete(recursive: true);
        await _imagesCacheDir!.create();
      }

      // Reset statistics
      _cacheHits = 0;
      _cacheMisses = 0;
      _totalRequests = 0;

      await _saveCacheMetadata();

      if (kDebugMode) {
        print('🗄️ [ComprehensiveCache] All cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error clearing cache: $e');
      }
    }
  }

  /// Dispose and cleanup
  Future<void> dispose() async {
    try {
      await _saveCacheMetadata();
      await _cleanCache();
      
      if (kDebugMode) {
        print('🗄️ [ComprehensiveCache] Disposed and cleaned up');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ComprehensiveCache] Error during disposal: $e');
      }
    }
  }
}

/// Cache entry class
class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration expiry;

  _CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiry,
  });

  bool get isValid {
    return DateTime.now().difference(timestamp) < expiry;
  }
}



