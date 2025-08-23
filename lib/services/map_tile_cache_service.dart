import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../config/mapbox_config.dart';

/// Service for caching map tiles to reduce API calls
class MapTileCacheService {
  static final MapTileCacheService _instance = MapTileCacheService._internal();
  factory MapTileCacheService() => _instance;
  MapTileCacheService._internal();

  // Cache settings
  static const Duration _cacheValidityDuration = Duration(days: 7);
  static const int _maxCacheSize = 500; // Maximum number of cached tiles
  static const int _maxCacheSizeBytes = 100 * 1024 * 1024; // 100MB cache limit
  
  // Cache directories
  Directory? _cacheDir;
  Directory? _tileCacheDir;
  
  // In-memory cache for frequently accessed tiles
  final Map<String, CachedTile> _memoryCache = {};
  final Map<String, DateTime> _accessTimes = {};
  
  // Cache statistics
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _totalRequests = 0;
  
  // Initialization flag
  bool _isInitialized = false;

  /// Initialize the cache service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Get cache directory
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/map_cache');
      _tileCacheDir = Directory('${_cacheDir!.path}/tiles');
      
      // Create directories if they don't exist
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
      if (!await _tileCacheDir!.exists()) {
        await _tileCacheDir!.create(recursive: true);
      }
      
      // Load cache metadata
      await _loadCacheMetadata();
      
      // Clean old cache entries
      await _cleanCache();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('🗺️ [MapTileCache] Initialized with ${_memoryCache.length} cached tiles');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MapTileCache] Initialization error: $e');
      }
    }
  }

  /// Get tile URL with caching
  String getTileUrl(int z, int x, int y) {
    final tileKey = _generateTileKey(z, x, y);
    
    // Check if tile is in memory cache
    if (_memoryCache.containsKey(tileKey)) {
      _cacheHits++;
      _accessTimes[tileKey] = DateTime.now();
      
      if (kDebugMode) {
        print('🗺️ [MapTileCache] Cache HIT for tile $z/$x/$y');
      }
      
      // Return cached tile path
      final cachedTile = _memoryCache[tileKey]!;
      if (cachedTile.isValid) {
        return 'file://${cachedTile.filePath}';
      }
    }
    
    _cacheMisses++;
    
    if (kDebugMode) {
      print('🗺️ [MapTileCache] Cache MISS for tile $z/$x/$y');
    }
    
    // Return API URL for uncached tiles
    return _getMapboxTileUrl(z, x, y);
  }

  /// Preload tiles for a specific area
  Future<void> preloadTiles({
    required int minZoom,
    required int maxZoom,
    required double centerLat,
    required double centerLng,
    required double radiusKm,
  }) async {
    if (!_isInitialized) await initialize();
    
    try {
      final tiles = _calculateTilesForArea(
        minZoom: minZoom,
        maxZoom: maxZoom,
        centerLat: centerLat,
        centerLng: centerLng,
        radiusKm: radiusKm,
      );
      
      if (kDebugMode) {
        print('🗺️ [MapTileCache] Preloading ${tiles.length} tiles for area');
      }
      
      // Download tiles in batches
      const batchSize = 10;
      for (int i = 0; i < tiles.length; i += batchSize) {
        final batch = tiles.skip(i).take(batchSize);
        await Future.wait(
          batch.map((tile) => _downloadAndCacheTile(
            tile['z'] as int, 
            tile['x'] as int, 
            tile['y'] as int
          ))
        );
        
        // Small delay to avoid overwhelming the API
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      if (kDebugMode) {
        print('🗺️ [MapTileCache] Preloading completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MapTileCache] Preloading error: $e');
      }
    }
  }

  /// Download and cache a single tile
  Future<void> _downloadAndCacheTile(int z, int x, int y) async {
    final tileKey = _generateTileKey(z, x, y);
    
    // Skip if already cached
    if (_memoryCache.containsKey(tileKey)) {
      final cachedTile = _memoryCache[tileKey]!;
      if (cachedTile.isValid) return;
    }
    
    try {
      final url = _getMapboxTileUrl(z, x, y);
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final tileData = response.bodyBytes;
        await _saveTileToCache(tileKey, tileData, z, x, y);
        
        if (kDebugMode) {
          print('🗺️ [MapTileCache] Cached tile $z/$x/$y (${tileData.length} bytes)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MapTileCache] Failed to download tile $z/$x/$y: $e');
      }
    }
  }

  /// Save tile to cache
  Future<void> _saveTileToCache(String tileKey, Uint8List tileData, int z, int x, int y) async {
    try {
      // Create directory structure
      final tileDir = Directory('${_tileCacheDir!.path}/$z/$x');
      if (!await tileDir.exists()) {
        await tileDir.create(recursive: true);
      }
      
      // Save tile file
      final tileFile = File('${tileDir.path}/$y.png');
      await tileFile.writeAsBytes(tileData);
      
      // Create cache entry
      final cachedTile = CachedTile(
        filePath: tileFile.path,
        size: tileData.length,
        timestamp: DateTime.now(),
        zoom: z,
        x: x,
        y: y,
      );
      
      // Add to memory cache
      _memoryCache[tileKey] = cachedTile;
      _accessTimes[tileKey] = DateTime.now();
      
      // Save metadata
      await _saveCacheMetadata();
      
      // Check cache size limits
      await _enforceCacheLimits();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MapTileCache] Failed to save tile to cache: $e');
      }
    }
  }

  /// Load cache metadata
  Future<void> _loadCacheMetadata() async {
    try {
      final metadataFile = File('${_cacheDir!.path}/metadata.json');
      if (await metadataFile.exists()) {
        final jsonData = await metadataFile.readAsString();
        final metadata = json.decode(jsonData) as Map<String, dynamic>;
        
        // Load cached tiles info
        final tilesData = metadata['tiles'] as Map<String, dynamic>? ?? {};
        for (final entry in tilesData.entries) {
          final tileData = entry.value as Map<String, dynamic>;
          final cachedTile = CachedTile.fromJson(tileData);
          _memoryCache[entry.key] = cachedTile;
          _accessTimes[entry.key] = cachedTile.timestamp;
        }
        
        // Load statistics
        _cacheHits = metadata['cacheHits'] ?? 0;
        _cacheMisses = metadata['cacheMisses'] ?? 0;
        _totalRequests = metadata['totalRequests'] ?? 0;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MapTileCache] Failed to load metadata: $e');
      }
    }
  }

  /// Save cache metadata
  Future<void> _saveCacheMetadata() async {
    try {
      final metadata = {
        'tiles': _memoryCache.map((key, tile) => MapEntry(key, tile.toJson())),
        'cacheHits': _cacheHits,
        'cacheMisses': _cacheMisses,
        'totalRequests': _totalRequests,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      final metadataFile = File('${_cacheDir!.path}/metadata.json');
      await metadataFile.writeAsString(json.encode(metadata));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MapTileCache] Failed to save metadata: $e');
      }
    }
  }

  /// Clean old cache entries
  Future<void> _cleanCache() async {
    try {
      final now = DateTime.now();
      final keysToRemove = <String>[];
      
      for (final entry in _memoryCache.entries) {
        final tile = entry.value;
        if (now.difference(tile.timestamp) > _cacheValidityDuration) {
          keysToRemove.add(entry.key);
        }
      }
      
      for (final key in keysToRemove) {
        await _removeTileFromCache(key);
      }
      
      if (kDebugMode && keysToRemove.isNotEmpty) {
        print('🗺️ [MapTileCache] Cleaned ${keysToRemove.length} expired tiles');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MapTileCache] Cache cleanup error: $e');
      }
    }
  }

  /// Enforce cache size limits
  Future<void> _enforceCacheLimits() async {
    try {
      // Check tile count limit
      if (_memoryCache.length > _maxCacheSize) {
        final sortedKeys = _accessTimes.entries
            .toList()
            ..sort((a, b) => a.value.compareTo(b.value));
        
        final keysToRemove = sortedKeys
            .take(_memoryCache.length - _maxCacheSize)
            .map((e) => e.key)
            .toList();
        
        for (final key in keysToRemove) {
          await _removeTileFromCache(key);
        }
        
        if (kDebugMode) {
          print('🗺️ [MapTileCache] Enforced tile count limit, removed ${keysToRemove.length} tiles');
        }
      }
      
      // Check size limit
      int totalSize = 0;
      for (final tile in _memoryCache.values) {
        totalSize += tile.size;
      }
      
      if (totalSize > _maxCacheSizeBytes) {
        final sortedKeys = _memoryCache.entries
            .toList()
            ..sort((a, b) => a.value.size.compareTo(b.value.size));
        
        final keysToRemove = <String>[];
        int currentSize = totalSize;
        
        for (final entry in sortedKeys) {
          if (currentSize <= _maxCacheSizeBytes) break;
          keysToRemove.add(entry.key);
          currentSize -= entry.value.size;
        }
        
        for (final key in keysToRemove) {
          await _removeTileFromCache(key);
        }
        
        if (kDebugMode) {
          print('🗺️ [MapTileCache] Enforced size limit, removed ${keysToRemove.length} tiles');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MapTileCache] Cache limit enforcement error: $e');
      }
    }
  }

  /// Remove tile from cache
  Future<void> _removeTileFromCache(String tileKey) async {
    try {
      final tile = _memoryCache[tileKey];
      if (tile != null) {
        // Delete file
        final file = File(tile.filePath);
        if (await file.exists()) {
          await file.delete();
        }
        
        // Remove from memory
        _memoryCache.remove(tileKey);
        _accessTimes.remove(tileKey);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MapTileCache] Failed to remove tile from cache: $e');
      }
    }
  }

  /// Generate tile key
  String _generateTileKey(int z, int x, int y) {
    return '${z}_${x}_${y}';
  }

  /// Get Mapbox tile URL
  String _getMapboxTileUrl(int z, int x, int y) {
    return 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/$z/$x/$y@2x?access_token=${MapboxConfig.mapboxAccessToken}';
  }

  /// Calculate tiles for a specific area
  List<Map<String, int>> _calculateTilesForArea({
    required int minZoom,
    required int maxZoom,
    required double centerLat,
    required double centerLng,
    required double radiusKm,
  }) {
    final tiles = <Map<String, int>>[];
    
    for (int zoom = minZoom; zoom <= maxZoom; zoom++) {
      final centerTile = _latLngToTile(centerLat, centerLng, zoom);
      final radiusTiles = (radiusKm / _getTileSizeKm(zoom)).ceil();
      
      for (int dx = -radiusTiles; dx <= radiusTiles; dx++) {
        for (int dy = -radiusTiles; dy <= radiusTiles; dy++) {
          final x = centerTile['x']! + dx;
          final y = centerTile['y']! + dy;
          
          if (x >= 0 && y >= 0 && x < (1 << zoom) && y < (1 << zoom)) {
            tiles.add({'z': zoom, 'x': x, 'y': y});
          }
        }
      }
    }
    
    return tiles;
  }

  /// Convert lat/lng to tile coordinates
  Map<String, int> _latLngToTile(double lat, double lng, int zoom) {
    final n = 1 << zoom;
    final xtile = ((lng + 180) / 360 * n).floor();
    final ytile = ((1 - log(tan(radians(lat)) + 1 / cos(radians(lat))) / pi) / 2 * n).floor();
    return {'x': xtile, 'y': ytile};
  }

  /// Get tile size in kilometers at a given zoom level
  double _getTileSizeKm(int zoom) {
    return 40075.0 / (1 << zoom); // Approximate tile size in km
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheHits': _cacheHits,
      'cacheMisses': _cacheMisses,
      'totalRequests': _totalRequests,
      'hitRate': _totalRequests > 0 ? (_cacheHits / _totalRequests * 100).toStringAsFixed(2) : '0.00',
      'cachedTiles': _memoryCache.length,
      'cacheSizeBytes': _memoryCache.values.fold(0, (sum, tile) => sum + tile.size),
    };
  }

  /// Clear all cache
  Future<void> clearCache() async {
    try {
      _memoryCache.clear();
      _accessTimes.clear();
      
      if (_tileCacheDir != null && await _tileCacheDir!.exists()) {
        await _tileCacheDir!.delete(recursive: true);
        await _tileCacheDir!.create();
      }
      
      await _saveCacheMetadata();
      
      if (kDebugMode) {
        print('🗺️ [MapTileCache] Cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MapTileCache] Failed to clear cache: $e');
      }
    }
  }
}

/// Cached tile data
class CachedTile {
  final String filePath;
  final int size;
  final DateTime timestamp;
  final int zoom;
  final int x;
  final int y;

  CachedTile({
    required this.filePath,
    required this.size,
    required this.timestamp,
    required this.zoom,
    required this.x,
    required this.y,
  });

  bool get isValid {
    final file = File(filePath);
    return file.existsSync() && 
           DateTime.now().difference(timestamp) < const Duration(days: 7);
  }

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'size': size,
      'timestamp': timestamp.toIso8601String(),
      'zoom': zoom,
      'x': x,
      'y': y,
    };
  }

  factory CachedTile.fromJson(Map<String, dynamic> json) {
    return CachedTile(
      filePath: json['filePath'],
      size: json['size'],
      timestamp: DateTime.parse(json['timestamp']),
      zoom: json['zoom'],
      x: json['x'],
      y: json['y'],
    );
  }
}

// Helper functions
double radians(double degrees) => degrees * pi / 180;
double log(double x) => log(x);
double cos(double x) => cos(x);
double tan(double x) => tan(x);
