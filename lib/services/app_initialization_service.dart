import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'map_tile_cache_service.dart';
import 'location_service.dart';
import 'comprehensive_cache_service.dart';
import 'supabase_notification_bridge.dart';

/// Service to handle app initialization tasks
class AppInitializationService {
  static final AppInitializationService _instance = AppInitializationService._internal();
  factory AppInitializationService() => _instance;
  AppInitializationService._internal();

  final MapTileCacheService _tileCacheService = MapTileCacheService();
  final ComprehensiveCacheService _comprehensiveCacheService = ComprehensiveCacheService();
  SupabaseNotificationBridge? _notificationBridge;
  bool _isInitialized = false;

  /// Initialize all app services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kDebugMode) {
        print('🚀 [AppInit] Starting app initialization...');
      }

      // Initialize comprehensive cache service
      await _initializeComprehensiveCache();
      
      // Initialize map tile cache service
      await _initializeMapTileCache();

      // Initialize Supabase notification bridge
      await _initializeNotificationBridge();

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ [AppInit] App initialization completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AppInit] App initialization failed: $e');
      }
      // Don't rethrow - we want the app to continue even if initialization fails
    }
  }

  /// Initialize comprehensive cache service
  Future<void> _initializeComprehensiveCache() async {
    try {
      // Initialize the comprehensive cache service
      await _comprehensiveCacheService.initialize();

      // Preload frequently accessed data
      await _comprehensiveCacheService.preloadFrequentData();

      if (kDebugMode) {
        final stats = _comprehensiveCacheService.getCacheStats();
        print('🗄️ [AppInit] Comprehensive cache initialized: ${stats['memoryCacheSize']} items in memory');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AppInit] Failed to initialize comprehensive cache: $e');
      }
    }
  }

  /// Initialize map tile cache with default area
  Future<void> _initializeMapTileCache() async {
    try {
      // Initialize the cache service
      await _tileCacheService.initialize();

      // Preload tiles for major Algerian cities
      await _preloadTilesForAlgerianCities();

      if (kDebugMode) {
        final stats = _tileCacheService.getCacheStats();
        print('🗺️ [AppInit] Map tile cache initialized: ${stats['cachedTiles']} tiles cached');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AppInit] Failed to initialize map tile cache: $e');
      }
    }
  }

  /// Preload tiles for major Algerian cities
  Future<void> _preloadTilesForAlgerianCities() async {
    // Major Algerian cities with their coordinates
    final cities = [
      {'name': 'Algiers', 'lat': 36.7538, 'lng': 3.0588},
      {'name': 'Oran', 'lat': 35.6969, 'lng': -0.6331},
      {'name': 'Constantine', 'lat': 36.3650, 'lng': 6.6147},
      {'name': 'Annaba', 'lat': 36.9000, 'lng': 7.7667},
      {'name': 'Batna', 'lat': 35.5500, 'lng': 6.1667},
      {'name': 'Setif', 'lat': 36.1900, 'lng': 5.4100},
      {'name': 'Blida', 'lat': 36.4700, 'lng': 2.8300},
      {'name': 'Tlemcen', 'lat': 34.8783, 'lng': -1.3150},
      {'name': 'Bejaia', 'lat': 36.7500, 'lng': 5.0833},
      {'name': 'Mostaganem', 'lat': 35.9333, 'lng': 0.0833},
    ];

    for (final city in cities) {
      try {
        await _tileCacheService.preloadTiles(
          minZoom: 10,
          maxZoom: 14,
          centerLat: city['lat'] as double,
          centerLng: city['lng'] as double,
          radiusKm: 5.0, // Smaller radius for cities to avoid too many tiles
        );

        if (kDebugMode) {
          print('🗺️ [AppInit] Preloaded tiles for ${city['name']}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ [AppInit] Failed to preload tiles for ${city['name']}: $e');
        }
      }
    }
  }

  /// Initialize Supabase notification bridge
  Future<void> _initializeNotificationBridge() async {
    try {
      // Get Supabase configuration from environment variables
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      
      if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
        _notificationBridge = SupabaseNotificationBridge(
          supabaseUrl: supabaseUrl,
          supabaseAnonKey: supabaseAnonKey,
        );
        
        _notificationBridge!.initialize();
        
        if (kDebugMode) {
          print('🔔 [AppInit] Supabase notification bridge initialized');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ [AppInit] Supabase credentials not found, skipping notification bridge');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AppInit] Failed to initialize notification bridge: $e');
      }
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return _tileCacheService.getCacheStats();
  }

  /// Clear all cache
  Future<void> clearCache() async {
    await _tileCacheService.clearCache();
  }

  /// Get notification bridge instance
  SupabaseNotificationBridge? get notificationBridge => _notificationBridge;

  /// Check if initialization is complete
  bool get isInitialized => _isInitialized;
}
