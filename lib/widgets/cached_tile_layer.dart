import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../services/map_tile_cache_service.dart';

/// Custom TileLayer that uses cached tiles
class CachedTileLayer extends TileLayer {
  final MapTileCacheService _cacheService = MapTileCacheService();
  bool _isInitialized = false;

  CachedTileLayer({
    super.key,
    super.keepBuffer,
    super.errorTileCallback,
    super.userAgentPackageName,
    super.maxZoom,
    super.minZoom,
    super.tileSize,
    super.zoomOffset,
    super.retinaMode,
  }) : super(
    urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYW5vdGhlcm1vdW1lbiIsImEiOiJjbWN2N3p4bmQwN3ozMmtzODk1OWJ0czVjIn0.2ldwbXN-1qo8o7rtO2X4Uw',
    tileProvider: _CachedTileProvider(MapTileCacheService()),
  );
}

/// Custom TileProvider that uses cached tiles
class _CachedTileProvider extends TileProvider {
  final MapTileCacheService _cacheService;

  _CachedTileProvider(this._cacheService);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = _cacheService.getTileUrl(
      coordinates.z.round(),
      coordinates.x.round(),
      coordinates.y.round(),
    );
    
    if (url.startsWith('file://')) {
      // Return cached file
      return FileImage(File(url.substring(7)));
    } else {
      // Return network image for uncached tiles
      return NetworkImage(url);
    }
  }
}
