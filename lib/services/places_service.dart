import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;

class PlacesPrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String description;

  PlacesPrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.description,
  });
}

class LocationData {
  final String placeId;
  final LatLng location;
  final DateTime createdAt;
  final String? name;
  final String? vicinity;
  final Map<String, dynamic>? openingHours;

  LocationData({
    required this.placeId,
    required this.location,
    required this.createdAt,
    this.name,
    this.vicinity,
    this.openingHours,
  });

  Map<String, dynamic> toJson() => {
    'placeId': placeId,
    'lat': location.latitude,
    'lng': location.longitude,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'vicinity': vicinity,
    'openingHours': openingHours,
  };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
    placeId: json['placeId'],
    location: LatLng(json['lat'], json['lng']),
    createdAt: DateTime.parse(json['createdAt']),
    name: json['name'],
    vicinity: json['vicinity'],
    openingHours: json['openingHours'] != null 
      ? Map<String, dynamic>.from(json['openingHours'])
      : null,
  );

  factory LocationData.fromFirestore(String placeId, Map<String, dynamic> data) {
    final geoPoint = data['location'] as GeoPoint;
    return LocationData(
      placeId: placeId,
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      name: data['name'],
      vicinity: data['vicinity'],
      openingHours: data['openingHours'],
    );
  }

  Map<String, dynamic> toPlaceResult() => {
    'place_id': placeId,
    'name': name,
    'vicinity': vicinity,
    'geometry': {
      'location': {
        'lat': location.latitude,
        'lng': location.longitude,
      }
    },
    'opening_hours': openingHours,
  };
}

class PlacesService {
  static const String _apiKey = 'AlzaSylphbmAZJYT82Ie_cY1MVEbiQ4NRUxaqIo';
  
  // Cache keys
  static const String _vetCacheKey = 'vet_locations_cache_v2';
  static const String _storeCacheKey = 'store_locations_cache_v2';
  static const String _lastUpdateKey = 'locations_last_update_v2';
  static const Duration _cacheValidityDuration = Duration(hours: 1);
  
  // In-memory cache
  static Map<String, LocationData>? _cachedVetLocations;
  static Map<String, LocationData>? _cachedStoreLocations;
  static bool _isInitialized = false;
  static DateTime? _lastUpdateTime;
  
  // Spatial index for quick radius search
  static Map<String, List<LocationData>> _vetSpatialIndex = {};
  static Map<String, List<LocationData>> _storeSpatialIndex = {};
  static const double _gridSize = 0.1; // Grid size in degrees

  // Firestore references
  static final _firestore = FirebaseFirestore.instance;
  static final _vetsDoc = _firestore.collection('locations').doc('vets');
  static final _storesDoc = _firestore.collection('locations').doc('stores');

  // Major cities in Algeria with their coordinates
  static List<Map<String, dynamic>> get algeriaCities => [
    // Northern Cities
    {'name': 'Alger', 'lat': 36.7538, 'lng': 3.0588},
    {'name': 'Oran', 'lat': 35.6987, 'lng': -0.6349},
    {'name': 'Constantine', 'lat': 36.3650, 'lng': 6.6147},
    {'name': 'Annaba', 'lat': 36.9000, 'lng': 7.7667},
    {'name': 'Batna', 'lat': 35.5552, 'lng': 6.1742},
    {'name': 'Setif', 'lat': 36.1898, 'lng': 5.4108},
    {'name': 'Blida', 'lat': 36.4722, 'lng': 2.8333},
    {'name': 'Bejaia', 'lat': 36.7511, 'lng': 5.0642},
    {'name': 'Tlemcen', 'lat': 34.8884, 'lng': -1.3150},
    {'name': 'Bordj Bou Arreridj', 'lat': 36.0730, 'lng': 4.7630},
    {'name': 'Skikda', 'lat': 36.8715, 'lng': 6.9090},
    {'name': 'Chlef', 'lat': 36.1644, 'lng': 1.3317},
    {'name': 'Tizi Ouzou', 'lat': 36.7166, 'lng': 4.0497},
    {'name': 'Jijel', 'lat': 36.8206, 'lng': 5.7662},
    {'name': 'Msila', 'lat': 35.7000, 'lng': 4.5333},
    
    // High Plateaus
    {'name': 'Biskra', 'lat': 34.8500, 'lng': 5.7333},
    {'name': 'Tebessa', 'lat': 35.4000, 'lng': 8.1167},
    {'name': 'Djelfa', 'lat': 34.6667, 'lng': 3.2500},
    {'name': 'El Bayadh', 'lat': 33.6833, 'lng': 1.0167},
    {'name': 'Khenchela', 'lat': 35.4167, 'lng': 7.1333},
    {'name': 'Laghouat', 'lat': 33.8000, 'lng': 2.8833},
    {'name': 'Oum El Bouaghi', 'lat': 35.8667, 'lng': 7.1167},
    
    // Saharan Cities
    {'name': 'Ouargla', 'lat': 31.9500, 'lng': 5.3333},
    {'name': 'Ghardaia', 'lat': 32.4833, 'lng': 3.6667},
    {'name': 'Bechar', 'lat': 31.6167, 'lng': -2.2167},
    {'name': 'Adrar', 'lat': 27.8667, 'lng': -0.2833},
    {'name': 'Tamanrasset', 'lat': 22.7850, 'lng': 5.5228},
    {'name': 'El Oued', 'lat': 33.3680, 'lng': 6.8515},
    {'name': 'Illizi', 'lat': 26.5000, 'lng': 8.4833},
    {'name': 'Tindouf', 'lat': 27.6731, 'lng': -8.1283},
    {'name': 'Djanet', 'lat': 24.5500, 'lng': 9.4833},
    {'name': 'In Salah', 'lat': 27.1967, 'lng': 2.4833},
    {'name': 'Hassi Messaoud', 'lat': 31.6833, 'lng': 6.0667},
    {'name': 'Touggourt', 'lat': 33.1000, 'lng': 6.0667},
    {'name': 'El Meniaa', 'lat': 30.5789, 'lng': 2.8789},
    
    // Additional medium-sized cities
    {'name': 'Ain Defla', 'lat': 36.2641, 'lng': 1.9679},
    {'name': 'Mascara', 'lat': 35.4000, 'lng': 0.1333},
    {'name': 'Medea', 'lat': 36.2675, 'lng': 2.7500},
    {'name': 'Mostaganem', 'lat': 35.9333, 'lng': 0.0833},
    {'name': 'Relizane', 'lat': 35.7373, 'lng': 0.5558},
    {'name': 'Saida', 'lat': 34.8333, 'lng': 0.1500},
    {'name': 'Souk Ahras', 'lat': 36.2864, 'lng': 7.9511},
    {'name': 'Tiaret', 'lat': 35.3667, 'lng': 1.3167},
  ];

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('Initializing PlacesService...');
    
    try {
      // First try to load from bundled JSON
      await _loadFromJson();
      
      // Build spatial index
      _buildSpatialIndex();
      
      _isInitialized = true;
      print('PlacesService initialized successfully');
      print('Loaded ${_cachedVetLocations?.length ?? 0} vets');
      print('Loaded ${_cachedStoreLocations?.length ?? 0} stores');
      
    } catch (e) {
      print('Error loading from JSON: $e');
      throw Exception('Failed to load locations from JSON: $e');
    }
  }

  static Future<void> _loadFromJson() async {
    try {
      print('\n=== Starting JSON Loading Process ===');
      print('Loading locations from bundled JSON...');
      
      final jsonString = await rootBundle.loadString('assets/data/locations.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Initialize cache maps if they don't exist
      _cachedVetLocations ??= {};
      _cachedStoreLocations ??= {};
      
      // Load stores
      if (jsonData.containsKey('stores')) {
        final stores = jsonData['stores'] as Map<String, dynamic>;
        stores.forEach((placeId, data) {
          if (data is Map<String, dynamic> && data.containsKey('location')) {
            final location = data['location'] as Map<String, dynamic>;
            _cachedStoreLocations![placeId] = LocationData(
              placeId: placeId,
              location: LatLng(
                location['latitude'] as double,
                location['longitude'] as double
              ),
              createdAt: DateTime.now(), // Use current date instead of future date
              name: data['name'] as String?,
              vicinity: data['vicinity'] as String?,
              openingHours: data['opening_hours'] as Map<String, dynamic>?,
            );
          }
        });
      }
      
      // Load vets
      if (jsonData.containsKey('vets')) {
        final vets = jsonData['vets'] as Map<String, dynamic>;
        vets.forEach((placeId, data) {
          if (data is Map<String, dynamic> && data.containsKey('location')) {
            final location = data['location'] as Map<String, dynamic>;
            _cachedVetLocations![placeId] = LocationData(
              placeId: placeId,
              location: LatLng(
                location['latitude'] as double,
                location['longitude'] as double
              ),
              createdAt: DateTime.now(), // Use current date instead of future date
              name: data['name'] as String?,
              vicinity: data['vicinity'] as String?,
              openingHours: data['opening_hours'] as Map<String, dynamic>?,
            );
          }
        });
      }
      
      print('Successfully loaded ${_cachedStoreLocations?.length ?? 0} stores and ${_cachedVetLocations?.length ?? 0} vets');
      _lastUpdateTime = DateTime.now();
      
    } catch (e, stackTrace) {
      print('Error loading from JSON: $e');
      print('Stack trace: $stackTrace');
      // Don't throw, just log the error and continue with empty caches
      _cachedStoreLocations = {};
      _cachedVetLocations = {};
    }
  }

  static void _initializeWithData(Map<String, dynamic> data) {
    _cachedVetLocations = {};
    _cachedStoreLocations = {};
    print('Initialized with empty location caches');
  }
  
  static Future<void> _loadFromLocalStorage() async {
    try {
      print('Loading from local storage (fallback)...');
      final prefs = await SharedPreferences.getInstance();
      
      // Check last update time
      final lastUpdateStr = prefs.getString(_lastUpdateKey);
      if (lastUpdateStr != null) {
        _lastUpdateTime = DateTime.parse(lastUpdateStr);
      }
      
      // Load vet locations
      final vetCacheStr = prefs.getString(_vetCacheKey);
      if (vetCacheStr != null) {
        final vetCache = json.decode(vetCacheStr) as Map<String, dynamic>;
        _cachedVetLocations = vetCache.map((key, value) => MapEntry(
          key, 
          LocationData.fromJson(value as Map<String, dynamic>),
        ));
        print('Loaded ${_cachedVetLocations?.length ?? 0} vet locations from local storage');
      } else {
        _cachedVetLocations = {};
      }
      
      // Load store locations
      final storeCacheStr = prefs.getString(_storeCacheKey);
      if (storeCacheStr != null) {
        final storeCache = json.decode(storeCacheStr) as Map<String, dynamic>;
        _cachedStoreLocations = storeCache.map((key, value) => MapEntry(
          key, 
          LocationData.fromJson(value as Map<String, dynamic>),
        ));
        print('Loaded ${_cachedStoreLocations?.length ?? 0} store locations from local storage');
      } else {
        _cachedStoreLocations = {};
      }
    } catch (e) {
      print('Error loading from local storage: $e');
      _cachedVetLocations = {};
      _cachedStoreLocations = {};
    }
  }
  
  static Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save vet locations
      if (_cachedVetLocations != null) {
        final vetCache = _cachedVetLocations!.map((key, value) => 
          MapEntry(key, value.toJson()));
        await prefs.setString(_vetCacheKey, json.encode(vetCache));
      }
      
      // Save store locations
      if (_cachedStoreLocations != null) {
        final storeCache = _cachedStoreLocations!.map((key, value) => 
          MapEntry(key, value.toJson()));
        await prefs.setString(_storeCacheKey, json.encode(storeCache));
      }
      
      // Save update time
      if (_lastUpdateTime != null) {
        await prefs.setString(_lastUpdateKey, _lastUpdateTime!.toIso8601String());
      }
      
      print('Saved locations to local storage');
    } catch (e) {
      print('Error saving to local storage: $e');
    }
  }
  
  static void _buildSpatialIndex() {
    try {
      print('Building spatial index...');
      _vetSpatialIndex.clear();
      _storeSpatialIndex.clear();
      
      // Index vet locations
      if (_cachedVetLocations != null) {
        for (final location in _cachedVetLocations!.values) {
          try {
            if (location.location != null) {
              final gridKey = _getGridKey(location.location.latitude, location.location.longitude);
              _vetSpatialIndex.putIfAbsent(gridKey, () => []).add(location);
            }
          } catch (e, stackTrace) {
            print('Error indexing vet location: $e');
            print('Stack trace: $stackTrace');
          }
        }
        print('Indexed ${_cachedVetLocations!.length} vet locations into ${_vetSpatialIndex.length} grids');
      }
      
      // Index store locations
      if (_cachedStoreLocations != null) {
        for (final location in _cachedStoreLocations!.values) {
          try {
            if (location.location != null) {
              final gridKey = _getGridKey(location.location.latitude, location.location.longitude);
              _storeSpatialIndex.putIfAbsent(gridKey, () => []).add(location);
            }
          } catch (e, stackTrace) {
            print('Error indexing store location: $e');
            print('Stack trace: $stackTrace');
          }
        }
        print('Indexed ${_cachedStoreLocations!.length} store locations into ${_storeSpatialIndex.length} grids');
      }
    } catch (e, stackTrace) {
      print('Error building spatial index: $e');
      print('Stack trace: $stackTrace');
      // Initialize empty indices if indexing fails
      _vetSpatialIndex = {};
      _storeSpatialIndex = {};
    }
  }

  static String _getGridKey(double lat, double lng) {
    try {
      final gridLat = (lat / _gridSize).floor();
      final gridLng = (lng / _gridSize).floor();
      return '$gridLat:$gridLng';
    } catch (e) {
      print('Error generating grid key for lat: $lat, lng: $lng - $e');
      // Return a default grid key that won't affect real data
      return '0:0';
    }
  }

  static List<LocationData> _getLocationsInRadius(
    double lat, 
    double lng, 
    double radiusKm,
    bool isVet,
  ) {
    try {
      final results = <LocationData>{};
      final distance = const Distance();
      
      // Calculate grid cells to check based on radius
      final gridRadius = (radiusKm / 11.0).ceil(); // Convert km to grid cells
      final centerGridLat = (lat / _gridSize).floor();
      final centerGridLng = (lng / _gridSize).floor();
      
      for (var i = -gridRadius; i <= gridRadius; i++) {
        for (var j = -gridRadius; j <= gridRadius; j++) {
          try {
            final gridKey = '${centerGridLat + i}:${centerGridLng + j}';
            final locations = isVet 
              ? _vetSpatialIndex[gridKey] ?? []
              : _storeSpatialIndex[gridKey] ?? [];
            
            for (final location in locations) {
              if (location.location != null) {
                final dist = distance.as(
                  LengthUnit.Kilometer,
                  LatLng(lat, lng),
                  location.location,
                );
                
                if (dist <= radiusKm) {
                  results.add(location);
                }
              }
            }
          } catch (e) {
            print('Error processing grid cell: $e');
          }
        }
      }
      
      return results.toList();
    } catch (e, stackTrace) {
      print('Error getting locations in radius: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Convert searchNearbyVets to use Stream for progressive loading
  static Stream<Map<String, dynamic>> searchNearbyVets(
    double lat,
    double lng, {
    int radius = 50000,
    bool forceApiSearch = false,
  }) async* {
    await initialize();
    
    final processedIds = <String>{};
    final radiusKm = radius / 1000;
    
    try {
      // Get locations from spatial index
      final locations = _getLocationsInRadius(lat, lng, radiusKm, true);
      
      // Yield cached results first (instant results)
      for (final location in locations) {
        yield {
          'place_id': location.placeId,
          'geometry': {
            'location': {
              'lat': location.location.latitude,
              'lng': location.location.longitude,
            },
          },
        };
        processedIds.add(location.placeId);
      }
      
      print('Found ${locations.length} vets within ${radiusKm}km radius');
      
      // Only proceed with API search if forced
      if (forceApiSearch) {
        final apiResults = await _searchNearbyVetsFromApi(lat, lng, radius);
        for (final result in apiResults) {
          final placeId = result['place_id'] as String;
          if (!processedIds.contains(placeId)) {
            yield result;
            processedIds.add(placeId);
          }
        }
      }
    } catch (e) {
      print('Error in searchNearbyVets: $e');
    }
  }

  // Make API search methods return Lists instead of Streams
  static Future<List<Map<String, dynamic>>> _searchNearbyVetsFromApi(
    double lat,
    double lng,
    int radius,
  ) async {
    try {
      final url = Uri.https('maps.googleapis.com', '/maps/api/place/nearbysearch/json', {
        'location': '$lat,$lng',
        'radius': radius.toString(),
        'type': 'veterinary_care',
        'key': _apiKey,
      });

      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      
      if (data['status'] != 'OK') {
        print('API Error: ${data['status']} - ${data['error_message']}');
        return [];
      }

      return (data['results'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error searching vets from API: $e');
      return [];
    }
  }

  static Stream<Map<String, dynamic>> searchNearbyStores(
    double lat,
    double lng, {
    int radius = 50000,
    bool forceApiSearch = false,
  }) async* {
    await initialize();
    
    final processedIds = <String>{};
    final radiusKm = radius / 1000;
    
    try {
      // Get locations from spatial index
      final locations = _getLocationsInRadius(lat, lng, radiusKm, false);
      
      // Yield cached results first (instant results)
      for (final location in locations) {
        yield {
          'place_id': location.placeId,
          'geometry': {
            'location': {
              'lat': location.location.latitude,
              'lng': location.location.longitude,
            },
          },
        };
        processedIds.add(location.placeId);
      }
      
      print('Found ${locations.length} stores within ${radiusKm}km radius');
      
      // Only proceed with API search if forced
      if (forceApiSearch) {
        final apiResults = await _searchNearbyStoresFromApi(lat, lng, radius);
        for (final result in apiResults) {
          final placeId = result['place_id'] as String;
          if (!processedIds.contains(placeId)) {
            yield result;
            processedIds.add(placeId);
          }
        }
      }
    } catch (e) {
      print('Error in searchNearbyStores: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> _searchNearbyStoresFromApi(
    double lat,
    double lng,
    int radius,
  ) async {
    try {
      final url = Uri.https('maps.googleapis.com', '/maps/api/place/nearbysearch/json', {
        'location': '$lat,$lng',
        'radius': radius.toString(),
        'type': 'pet_store',
        'key': _apiKey,
      });

      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      
      if (data['status'] != 'OK') {
        print('API Error: ${data['status']} - ${data['error_message']}');
        return [];
      }

      return (data['results'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error searching stores from API: $e');
      return [];
    }
  }

  static bool isSaharanRegion(double lat, double lng) {
    return lat < 34.0;
  }

  Future<List<PlacesPrediction>> getPlacePredictions(String input) async {
    // Add "Algeria" to the query if not already present
    final searchQuery = input.toLowerCase().contains('algeria') ? input : '$input, Algeria';
    
    final url = Uri.parse(
      'https://maps.gomaps.pro/maps/api/place/autocomplete/json'
      '?input=$searchQuery'
      '&key=$_apiKey'
      '&components=country:dz'
      '&types=establishment|geocode'
    );

    try {
      print('Searching for: $searchQuery');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return (data['predictions'] as List).map((prediction) {
            final structuredFormatting = prediction['structured_formatting'];
            return PlacesPrediction(
              placeId: prediction['place_id'],
              mainText: structuredFormatting['main_text'] ?? '',
              secondaryText: structuredFormatting['secondary_text'] ?? '',
              description: prediction['description'] ?? '',
            );
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting place predictions: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchStoresInAllCities() async {
    final allResults = <Map<String, dynamic>>[];
    final processedPlaceIds = <String>{};

    // First search in major cities
    for (final city in algeriaCities) {
      try {
        print('Searching stores in ${city['name']}');
        await for (final store in searchNearbyStores(
          city['lat'], 
          city['lng'],
          forceApiSearch: true,
        )) {
          final placeId = store['place_id'] as String;
          if (!processedPlaceIds.contains(placeId)) {
            processedPlaceIds.add(placeId);
            allResults.add(store);
          }
        }

        // For Saharan cities, also search in surrounding areas
        if (isSaharanRegion(city['lat'], city['lng'])) {
          for (var latOffset = -0.5; latOffset <= 0.5; latOffset += 0.5) {
            for (var lngOffset = -0.5; lngOffset <= 0.5; lngOffset += 0.5) {
              if (latOffset == 0 && lngOffset == 0) continue;
              
              final lat = city['lat'] + latOffset;
              final lng = city['lng'] + lngOffset;
              
              await for (final store in searchNearbyStores(lat, lng, forceApiSearch: true)) {
                final placeId = store['place_id'] as String;
                if (!processedPlaceIds.contains(placeId)) {
                  processedPlaceIds.add(placeId);
                  allResults.add(store);
                }
              }
            }
          }
        }
      } catch (e) {
        print('Error searching stores in ${city['name']}: $e');
      }
    }

    return allResults;
  }

  // Get all vet clinics from the cache
  Future<List<Map<String, dynamic>>> getAllVetClinics() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _cachedVetLocations?.values.map((data) => data.toPlaceResult()).toList() ?? [];
  }

  // Get all pet stores from the cache
  Future<List<Map<String, dynamic>>> getAllPetStores() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _cachedStoreLocations?.values.map((data) => data.toPlaceResult()).toList() ?? [];
  }

  static Future<void> _startBackgroundSync() async {
    try {
      print('Starting background Firestore sync...');
      
      // Get vet locations
      final vetsDoc = await _vetsDoc.get();
      if (vetsDoc.exists) {
        final locations = vetsDoc.data()?['locations'] as Map<String, dynamic>? ?? {};
        _cachedVetLocations = {};
        
        for (final entry in locations.entries) {
          try {
            _cachedVetLocations![entry.key] = LocationData.fromFirestore(
              entry.key,
              entry.value as Map<String, dynamic>,
            );
          } catch (e, stackTrace) {
            print('Error parsing vet location ${entry.key}: $e');
            print('Stack trace: $stackTrace');
          }
        }
        print('Synced ${_cachedVetLocations!.length} vet locations from Firestore');
      }
      
      // Get store locations
      final storesDoc = await _storesDoc.get();
      if (storesDoc.exists) {
        final locations = storesDoc.data()?['locations'] as Map<String, dynamic>? ?? {};
        _cachedStoreLocations = {};
        
        for (final entry in locations.entries) {
          try {
            _cachedStoreLocations![entry.key] = LocationData.fromFirestore(
              entry.key,
              entry.value as Map<String, dynamic>,
            );
          } catch (e, stackTrace) {
            print('Error parsing store location ${entry.key}: $e');
            print('Stack trace: $stackTrace');
          }
        }
        print('Synced ${_cachedStoreLocations!.length} store locations from Firestore');
      }
      
      // Update last sync time
      _lastUpdateTime = DateTime.now();
      
      // Rebuild spatial index with new data
      _buildSpatialIndex();
      
      // Save to local storage
      await _saveToLocalStorage();
      
      print('Background sync completed successfully');
    } catch (e, stackTrace) {
      print('Error in background sync: $e');
      print('Stack trace: $stackTrace');
    }
  }
} 