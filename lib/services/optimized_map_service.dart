import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/places_service.dart';

/// Optimized map service with caching, viewport-based loading, and performance enhancements
class OptimizedMapService {
  static final OptimizedMapService _instance = OptimizedMapService._internal();
  factory OptimizedMapService() => _instance;
  OptimizedMapService._internal();

  // Cache and performance settings
  static const Duration _cacheValidityDuration = Duration(hours: 6);
  static const int _maxMarkersInViewport = 200;
  static const double _clusterDistance = 50.0; // pixels
  static const int _debounceDelayMs = 300;

  // Services
  final PlacesService _placesService = PlacesService();

  // Cache for markers
  final Map<String, CachedMarkerData> _markerCache = {};
  final Map<String, List<Marker>> _viewportCache = {};
  
  // Debounce timer
  Timer? _debounceTimer;
  
  // Viewport tracking
  LatLngBounds? _lastViewport;
  double _lastZoom = 0;

  /// Get optimized tile layer with caching
  TileLayer getCachedTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.alifi.app',
      // Performance optimizations
      keepBuffer: 2,
      errorTileCallback: (tile, error, stackTrace) {
        if (kDebugMode) {
          print('Tile error: $error');
        }
      },
    );
  }

  /// Load markers optimized for current viewport
  Future<List<Marker>> getOptimizedMarkers({
    required LatLngBounds viewport,
    required double zoom,
    required bool showVets,
    required bool showStores,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _generateCacheKey(viewport, zoom, showVets, showStores);
    
    // Check cache first
    if (!forceRefresh && _viewportCache.containsKey(cacheKey)) {
      final cached = _viewportCache[cacheKey]!;
      if (cached.isNotEmpty) {
        return cached;
      }
    }

    // Load markers for viewport
    final markers = <Marker>[];
    
    if (showVets) {
      final vetMarkers = await _getVetMarkersInViewport(viewport, zoom);
      markers.addAll(vetMarkers);
    }
    
    if (showStores) {
      final storeMarkers = await _getStoreMarkersInViewport(viewport, zoom);
      markers.addAll(storeMarkers);
    }

    // Apply clustering if needed
    final optimizedMarkers = _applySmartClustering(markers, zoom);
    
    // Cache the results
    _viewportCache[cacheKey] = optimizedMarkers;
    
    // Clean old cache entries
    _cleanCache();
    
    return optimizedMarkers;
  }

  /// Get vet markers within viewport with smart loading
  Future<List<Marker>> _getVetMarkersInViewport(
    LatLngBounds viewport,
    double zoom,
  ) async {
    try {
      // Load from cache first
      final cachedVets = await _getCachedVets(viewport);
      if (cachedVets.isNotEmpty) {
        return cachedVets.map((data) => _createOptimizedVetMarker(data)).toList();
      }

      // Load from service if not in cache
      final vets = await _placesService.getVetsInBounds(
        viewport.southWest,
        viewport.northEast,
        maxResults: _maxMarkersInViewport,
      );

      // Cache the data
      for (final vet in vets) {
        final cacheData = CachedMarkerData.fromVet(vet);
        _markerCache[cacheData.id] = cacheData;
      }

      return vets.map((vet) => _createOptimizedVetMarker(
        CachedMarkerData.fromVet(vet)
      )).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading vet markers: $e');
      }
      return [];
    }
  }

  /// Get store markers within viewport with smart loading
  Future<List<Marker>> _getStoreMarkersInViewport(
    LatLngBounds viewport,
    double zoom,
  ) async {
    try {
      // Load from cache first
      final cachedStores = await _getCachedStores(viewport);
      if (cachedStores.isNotEmpty) {
        return cachedStores.map((data) => _createOptimizedStoreMarker(data)).toList();
      }

      // Load from service if not in cache
      final stores = await _placesService.getStoresInBounds(
        viewport.southWest,
        viewport.northEast,
        maxResults: _maxMarkersInViewport,
      );

      // Cache the data
      for (final store in stores) {
        final cacheData = CachedMarkerData.fromStore(store);
        _markerCache[cacheData.id] = cacheData;
      }

      return stores.map((store) => _createOptimizedStoreMarker(
        CachedMarkerData.fromStore(store)
      )).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading store markers: $e');
      }
      return [];
    }
  }

  /// Create optimized vet marker with RepaintBoundary
  Marker _createOptimizedVetMarker(CachedMarkerData data) {
    return Marker(
      key: ValueKey('vet_${data.id}'),
      point: data.location,
      width: 24,
      height: 24,
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: () => data.onTap?.call(),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_hospital,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// Create optimized store marker with RepaintBoundary
  Marker _createOptimizedStoreMarker(CachedMarkerData data) {
    return Marker(
      key: ValueKey('store_${data.id}'),
      point: data.location,
      width: 24,
      height: 24,
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: () => data.onTap?.call(),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.store,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// Apply smart clustering based on zoom level and marker density
  List<Marker> _applySmartClustering(List<Marker> markers, double zoom) {
    if (zoom >= 12 || markers.length <= 50) {
      return markers;
    }

    final clusters = <Marker>[];
    final processed = <int>{};
    final clusterDistance = _clusterDistance / pow(2, zoom - 8);

    for (var i = 0; i < markers.length; i++) {
      if (processed.contains(i)) continue;

      final marker = markers[i];
      final nearbyMarkers = [marker];
      processed.add(i);

      // Find nearby markers for clustering
      for (var j = i + 1; j < markers.length; j++) {
        if (processed.contains(j)) continue;

        final other = markers[j];
        final distance = _calculatePixelDistance(marker.point, other.point, zoom);

        if (distance < clusterDistance) {
          nearbyMarkers.add(other);
          processed.add(j);
        }
      }

      if (nearbyMarkers.length == 1) {
        clusters.add(marker);
      } else {
        clusters.add(_createClusterMarker(nearbyMarkers, zoom));
      }
    }

    return clusters;
  }

  /// Create cluster marker for grouped markers
  Marker _createClusterMarker(List<Marker> markers, double zoom) {
    final centerLat = markers.map((m) => m.point.latitude).reduce((a, b) => a + b) / markers.length;
    final centerLng = markers.map((m) => m.point.longitude).reduce((a, b) => a + b) / markers.length;
    final count = markers.length;

    return Marker(
      key: ValueKey('cluster_${centerLat}_${centerLng}_$count'),
      point: LatLng(centerLat, centerLng),
      width: 36,
      height: 36,
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: () {
            // Zoom in on cluster tap
            // This will be handled by the parent widget
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1976D2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Debounced viewport update
  void updateViewport(
    LatLngBounds viewport,
    double zoom,
    VoidCallback onUpdate,
  ) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: _debounceDelayMs), () {
      if (_hasViewportChanged(viewport, zoom)) {
        _lastViewport = viewport;
        _lastZoom = zoom;
        onUpdate();
      }
    });
  }

  /// Check if viewport has significantly changed
  bool _hasViewportChanged(LatLngBounds viewport, double zoom) {
    if (_lastViewport == null) return true;
    
    const threshold = 0.001; // Degrees
    return (viewport.center.latitude - _lastViewport!.center.latitude).abs() > threshold ||
           (viewport.center.longitude - _lastViewport!.center.longitude).abs() > threshold ||
           (zoom - _lastZoom).abs() > 0.5;
  }

  /// Calculate pixel distance between two points
  double _calculatePixelDistance(LatLng point1, LatLng point2, double zoom) {
    const earthRadius = 6371000; // meters
    final scale = pow(2, zoom);
    
    final lat1Rad = point1.latitude * pi / 180;
    final lat2Rad = point2.latitude * pi / 180;
    final deltaLatRad = (point2.latitude - point1.latitude) * pi / 180;
    final deltaLngRad = (point2.longitude - point1.longitude) * pi / 180;

    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    return distance * scale / 156543.03392; // Convert to pixels
  }

  /// Get cached vets for viewport
  Future<List<CachedMarkerData>> _getCachedVets(LatLngBounds viewport) async {
    final result = <CachedMarkerData>[];
    
    for (final cached in _markerCache.values) {
      if (cached.type == MarkerType.vet && 
          cached.isInBounds(viewport) && 
          !cached.isExpired) {
        result.add(cached);
      }
    }
    
    return result;
  }

  /// Get cached stores for viewport
  Future<List<CachedMarkerData>> _getCachedStores(LatLngBounds viewport) async {
    final result = <CachedMarkerData>[];
    
    for (final cached in _markerCache.values) {
      if (cached.type == MarkerType.store && 
          cached.isInBounds(viewport) && 
          !cached.isExpired) {
        result.add(cached);
      }
    }
    
    return result;
  }

  /// Generate cache key for viewport
  String _generateCacheKey(
    LatLngBounds viewport,
    double zoom,
    bool showVets,
    bool showStores,
  ) {
    final lat = viewport.center.latitude.toStringAsFixed(3);
    final lng = viewport.center.longitude.toStringAsFixed(3);
    final z = zoom.toStringAsFixed(1);
    final flags = '${showVets ? 'v' : ''}${showStores ? 's' : ''}';
    return '${lat}_${lng}_${z}_$flags';
  }

  /// Clean old cache entries
  void _cleanCache() {
    if (_viewportCache.length > 20) {
      final keys = _viewportCache.keys.toList();
      for (var i = 0; i < 10; i++) {
        _viewportCache.remove(keys[i]);
      }
    }

    _markerCache.removeWhere((key, value) => value.isExpired);
  }

  /// Clear all caches
  void clearCache() {
    _markerCache.clear();
    _viewportCache.clear();
    _lastViewport = null;
    _lastZoom = 0;
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    clearCache();
  }
}

/// Cached marker data class
class CachedMarkerData {
  final String id;
  final LatLng location;
  final String name;
  final String? vicinity;
  final MarkerType type;
  final DateTime cachedAt;
  final VoidCallback? onTap;

  CachedMarkerData({
    required this.id,
    required this.location,
    required this.name,
    this.vicinity,
    required this.type,
    required this.cachedAt,
    this.onTap,
  });

  factory CachedMarkerData.fromVet(Map<String, dynamic> vet) {
    final location = vet['location'] ?? vet['geometry']?['location'];
    final lat = (location['lat'] ?? location['latitude']) as double;
    final lng = (location['lng'] ?? location['longitude']) as double;

    return CachedMarkerData(
      id: vet['place_id'] as String,
      location: LatLng(lat, lng),
      name: vet['name'] as String? ?? 'Vet Clinic',
      vicinity: vet['vicinity'] as String?,
      type: MarkerType.vet,
      cachedAt: DateTime.now(),
    );
  }

  factory CachedMarkerData.fromStore(Map<String, dynamic> store) {
    final location = store['location'] ?? store['geometry']?['location'];
    final lat = (location['lat'] ?? location['latitude']) as double;
    final lng = (location['lng'] ?? location['longitude']) as double;

    return CachedMarkerData(
      id: store['place_id'] as String,
      location: LatLng(lat, lng),
      name: store['name'] as String? ?? 'Pet Store',
      vicinity: store['vicinity'] as String?,
      type: MarkerType.store,
      cachedAt: DateTime.now(),
    );
  }

  bool get isExpired {
    return DateTime.now().difference(cachedAt) > OptimizedMapService._cacheValidityDuration;
  }

  bool isInBounds(LatLngBounds bounds) {
    return bounds.contains(location);
  }
}

enum MarkerType { vet, store }
