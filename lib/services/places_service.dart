import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:isolate';
import 'package:flutter/foundation.dart';

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

class PlacesService {
  static const String _apiKey = 'AlzaSy8GCoFh_rNeeXKWnVnqeCauTmWq3i85B6H';
  
  // Cache for stored locations
  static Map<String, LatLng>? _cachedVetLocations;
  static Map<String, LatLng>? _cachedStoreLocations;
  static bool _isInitialized = false;
  static DateTime? _lastUpdateTime;
  static const String _vetCacheKey = 'vet_locations_cache';
  static const String _storeCacheKey = 'store_locations_cache';
  static const String _lastUpdateKey = 'locations_last_update';
  static const Duration _cacheValidityDuration = Duration(days: 7); // Cache valid for 7 days
  
  // Initialize cache from local storage first, then update from Firestore in background
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('Initializing PlacesService cache...');
    
    // Load from local storage first (fast)
    await _loadFromLocalStorage();
    
    // Start background Firestore sync if needed
    _startBackgroundSync();
    
    _isInitialized = true;
  }
  
  static Future<void> _loadFromLocalStorage() async {
    try {
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
        _cachedVetLocations = vetCache.map((key, value) {
          final coords = (value as List<dynamic>).cast<double>();
          return MapEntry(key, LatLng(coords[0], coords[1]));
        });
        print('Loaded ${_cachedVetLocations?.length ?? 0} vet locations from local storage');
      }
      
      // Load store locations
      final storeCacheStr = prefs.getString(_storeCacheKey);
      if (storeCacheStr != null) {
        final storeCache = json.decode(storeCacheStr) as Map<String, dynamic>;
        _cachedStoreLocations = storeCache.map((key, value) {
          final coords = (value as List<dynamic>).cast<double>();
          return MapEntry(key, LatLng(coords[0], coords[1]));
        });
        print('Loaded ${_cachedStoreLocations?.length ?? 0} store locations from local storage');
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
          MapEntry(key, [value.latitude, value.longitude]));
        await prefs.setString(_vetCacheKey, json.encode(vetCache));
      }
      
      // Save store locations
      if (_cachedStoreLocations != null) {
        final storeCache = _cachedStoreLocations!.map((key, value) => 
          MapEntry(key, [value.latitude, value.longitude]));
        await prefs.setString(_storeCacheKey, json.encode(storeCache));
      }
      
      // Save update time
      _lastUpdateTime = DateTime.now();
      await prefs.setString(_lastUpdateKey, _lastUpdateTime!.toIso8601String());
      
      print('Saved locations to local storage');
    } catch (e) {
      print('Error saving to local storage: $e');
    }
  }
  
  static void _startBackgroundSync() async {
    // Skip sync if cache is still valid
    if (_lastUpdateTime != null && 
        DateTime.now().difference(_lastUpdateTime!) < _cacheValidityDuration) {
      print('Cache is still valid, skipping Firestore sync');
      return;
    }
    
    print('Starting background Firestore sync...');
    
    // Use compute for background processing
    compute(_syncWithFirestore, null).then((_) {
      print('Background sync completed');
    }).catchError((e) {
      print('Error in background sync: $e');
    });
  }
  
  static Future<void> _syncWithFirestore(void _) async {
    final dbService = DatabaseService();
    final newVetLocations = <String, LatLng>{};
    final newStoreLocations = <String, LatLng>{};
    
    try {
      // Load vet locations
      final vetIds = await dbService.getAllVetPlaceIds();
      for (final id in vetIds) {
        final locationData = await dbService.getVetLocation(id);
        if (locationData != null) {
          final geoPoint = locationData[id]!;
          newVetLocations[id] = LatLng(geoPoint.latitude, geoPoint.longitude);
        }
      }
      
      // Load store locations
      final storeIds = await dbService.getAllStorePlaceIds();
      for (final id in storeIds) {
        final locationData = await dbService.getStoreLocation(id);
        if (locationData != null) {
          final geoPoint = locationData[id]!;
          newStoreLocations[id] = LatLng(geoPoint.latitude, geoPoint.longitude);
        }
      }
      
      // Update cache
      _cachedVetLocations = newVetLocations;
      _cachedStoreLocations = newStoreLocations;
      
      // Save to local storage
      await _saveToLocalStorage();
      
      print('Synced ${newVetLocations.length} vets and ${newStoreLocations.length} stores from Firestore');
    } catch (e) {
      print('Error syncing with Firestore: $e');
    }
  }

  Future<List<PlacesPrediction>> getPlacePredictions(String input) async {
    // Add "Algeria" to the query if not already present
    final searchQuery = input.toLowerCase().contains('algeria') ? input : '$input, Algeria';
    
    final url = Uri.parse(
      'https://maps.gomaps.pro/maps/api/place/autocomplete/json'
      '?input=$searchQuery'
      '&key=$_apiKey'
      '&components=country:dz'
      '&types=establishment|geocode'  // Added types to get both businesses and addresses
    );

    try {
      print('Searching for: $searchQuery');
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
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
        } else {
          print('Places API error: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
        }
      }
      return [];
    } catch (e) {
      print('Error getting place predictions: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchNearbyVets(
    double lat,
    double lng, {
    int radius = 50000,
    bool forceApiSearch = false,
  }) async {
    final results = <Map<String, dynamic>>[];
    final processedIds = <String>{};
    
    try {
      print('Searching for vets at $lat, $lng (radius: ${radius}m)');
      
      // Check cached locations first
      if (_cachedVetLocations != null) {
        _cachedVetLocations!.forEach((placeId, location) {
          final distance = const Distance().as(
            LengthUnit.Kilometer,
            LatLng(lat, lng),
            location,
          );
          
          final adjustedRadius = PlacesService.isSaharanRegion(lat, lng) ? 100 : 50;
          if (distance <= adjustedRadius) {
            results.add({
              'place_id': placeId,
              'geometry': {
                'location': {
                  'lat': location.latitude,
                  'lng': location.longitude,
                }
              }
            });
            processedIds.add(placeId);
          }
        });
        
        print('Found ${results.length} vets from cache within radius');
        
        // Return cache results unless forced API search
        if (!forceApiSearch && results.isNotEmpty) {
          return results;
        }
      }
      
      // Only proceed with API search if forced or no results found
      if (forceApiSearch || results.isEmpty) {
    final adjustedRadius = PlacesService.isSaharanRegion(lat, lng) ? 100000 : 50000;
    
    final url = Uri.parse(
      'https://maps.gomaps.pro/maps/api/place/nearbysearch/json'
      '?location=$lat,$lng'
      '&radius=$adjustedRadius'
      '&keyword=veterinaire|veterinary|clinique veterinaire|عيادة بيطرية|طبيب بيطري|vétérinaire|clinique animaux|animal clinic|pet clinic'
      '&key=$_apiKey'
    );

        print('Fetching additional vets from Places API...');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
            final apiResults = List<Map<String, dynamic>>.from(data['results']);
            print('Found ${apiResults.length} vets from API');
            
            for (final result in apiResults) {
              try {
                final placeId = result['place_id'] as String;
                if (processedIds.contains(placeId)) continue;
                
                final location = result['geometry']['location'];
                final lat = location['lat'] as double;
                final lng = location['lng'] as double;
                
                await DatabaseService().saveVetLocation(placeId, lat, lng);
                results.add(result);
                processedIds.add(placeId);
              } catch (e) {
                print('Error processing API vet result: $e');
                continue;
              }
            }
        } else {
          print('Places API error: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
          }
        }
      }
    } catch (e) {
      print('Error in searchNearbyVets: $e');
    }
    
    print('Returning ${results.length} total vets');
    return results;
  }

  Stream<Map<String, dynamic>> searchNearbyStoresByType(
    double lat,
    double lng, {
    bool forceApiSearch = false,
  }) async* {
    final processedIds = <String>{};
    
    try {
      print('Searching for stores by type at $lat, $lng');
      
      // Check cached locations first
      if (_cachedStoreLocations != null) {
        for (final entry in _cachedStoreLocations!.entries) {
          if (processedIds.contains(entry.key)) continue;
          
          final distance = const Distance().as(
            LengthUnit.Kilometer,
            LatLng(lat, lng),
            entry.value,
          );
          
          final adjustedRadius = PlacesService.isSaharanRegion(lat, lng) ? 100 : 50;
          if (distance <= adjustedRadius) {
            processedIds.add(entry.key);
            yield {
              'place_id': entry.key,
              'geometry': {
                'location': {
                  'lat': entry.value.latitude,
                  'lng': entry.value.longitude,
                }
              }
            };
          }
        }
      }
      
      // Only proceed with API search if forced
      if (forceApiSearch) {
    final adjustedRadius = PlacesService.isSaharanRegion(lat, lng) ? 100000 : 50000;
    
    final typeUrl = Uri.parse(
      'https://maps.gomaps.pro/maps/api/place/nearbysearch/json'
      '?location=$lat,$lng'
      '&radius=$adjustedRadius'
      '&type=pet_store|store'
      '&key=$_apiKey'
    );

        print('Fetching additional stores from Places API...');
      final response = await http.get(typeUrl);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = List<Map<String, dynamic>>.from(data['results']);
            print('Found ${results.length} stores from API');
            
          for (final result in results) {
              try {
                final placeId = result['place_id'] as String;
                if (processedIds.contains(placeId)) continue;
                
                final location = result['geometry']['location'];
                final lat = location['lat'] as double;
                final lng = location['lng'] as double;
                
                await DatabaseService().saveStoreLocation(placeId, lat, lng);
                processedIds.add(placeId);
            yield result;
              } catch (e) {
                print('Error processing API store result: $e');
                continue;
              }
            }
          } else {
            print('Places API error: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
          }
        }
      }
    } catch (e) {
      print('Error in searchNearbyStoresByType: $e');
    }
  }

  Stream<Map<String, dynamic>> searchNearbyStoresByKeyword(
    double lat,
    double lng, {
    bool forceApiSearch = false,
  }) async* {
    final processedIds = <String>{};
    
    try {
      print('Searching for stores by keyword at $lat, $lng');
      
      // Check cached locations first
      if (_cachedStoreLocations != null) {
        for (final entry in _cachedStoreLocations!.entries) {
          if (processedIds.contains(entry.key)) continue;
          
          final distance = const Distance().as(
            LengthUnit.Kilometer,
            LatLng(lat, lng),
            entry.value,
          );
          
          final adjustedRadius = PlacesService.isSaharanRegion(lat, lng) ? 100 : 50;
          if (distance <= adjustedRadius) {
            processedIds.add(entry.key);
            yield {
              'place_id': entry.key,
              'geometry': {
                'location': {
                  'lat': entry.value.latitude,
                  'lng': entry.value.longitude,
                }
              }
            };
          }
        }
      }
      
      // Only proceed with API search if forced
      if (forceApiSearch) {
    final adjustedRadius = PlacesService.isSaharanRegion(lat, lng) ? 100000 : 50000;
    
    final keywordUrl = Uri.parse(
      'https://maps.gomaps.pro/maps/api/place/nearbysearch/json'
      '?location=$lat,$lng'
      '&radius=$adjustedRadius'
      '&keyword=animalerie|pet|pets|animal|animaux|animal shop|oasis|petshop|مستلزمات الحيوانات | حيوانات'
      '&key=$_apiKey'
    );

        print('Fetching additional stores from Places API...');
      final response = await http.get(keywordUrl);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = List<Map<String, dynamic>>.from(data['results']);
            print('Found ${results.length} stores from API');
            
          for (final result in results) {
              try {
                final placeId = result['place_id'] as String;
                if (processedIds.contains(placeId)) continue;
                
                final location = result['geometry']['location'];
                final lat = location['lat'] as double;
                final lng = location['lng'] as double;
                
                await DatabaseService().saveStoreLocation(placeId, lat, lng);
                processedIds.add(placeId);
            yield result;
              } catch (e) {
                print('Error processing API store result: $e');
                continue;
              }
            }
          } else {
            print('Places API error: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
          }
        }
      }
    } catch (e) {
      print('Error in searchNearbyStoresByKeyword: $e');
    }
  }

  Stream<Map<String, dynamic>> searchNearbyStoresByText(double lat, double lng) async* {
    final adjustedRadius = PlacesService.isSaharanRegion(lat, lng) ? 100000 : 50000;
    
    final textUrl = Uri.parse(
      'https://maps.gomaps.pro/maps/api/place/textsearch/json'
      '?location=$lat,$lng'
      '&radius=$adjustedRadius'
      '&query=animalerie OR pet shop OR pet store OR magasin animaux'
      '&key=$_apiKey'
    );

    try {
      print('Searching for stores by text at $lat, $lng');
      final response = await http.get(textUrl);
      print('Text search response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = List<Map<String, dynamic>>.from(data['results']);
          print('Found ${results.length} stores by text search');
          for (final result in results) {
            yield result;
          }
        }
      }
    } catch (e) {
      print('Error in text search: $e');
    }
  }

  // Keep the old method for backward compatibility but implement it using the new streaming methods
  Future<List<Map<String, dynamic>>> searchNearbyStores(double lat, double lng, {int radius = 50000}) async {
    final List<Map<String, dynamic>> allResults = [];
    final Set<String> processedPlaceIds = {};

    try {
      await for (final result in searchNearbyStoresByType(lat, lng)) {
        final placeId = result['place_id'] as String;
        if (!processedPlaceIds.contains(placeId)) {
          processedPlaceIds.add(placeId);
          allResults.add(result);
        }
      }

      await for (final result in searchNearbyStoresByKeyword(lat, lng)) {
        final placeId = result['place_id'] as String;
        if (!processedPlaceIds.contains(placeId)) {
          processedPlaceIds.add(placeId);
          allResults.add(result);
        }
      }

      await for (final result in searchNearbyStoresByText(lat, lng)) {
        final placeId = result['place_id'] as String;
        if (!processedPlaceIds.contains(placeId)) {
          processedPlaceIds.add(placeId);
          allResults.add(result);
        }
      }

      print('Found ${allResults.length} total unique stores');
      return allResults;
    } catch (e) {
      print('Error searching nearby stores: $e');
      return [];
    }
  }

  static bool isSaharanRegion(double lat, double lng) {
    // Approximate boundary for Saharan region in Algeria
    return lat < 34.0;
  }

  // Major cities in Algeria with their coordinates
  static final List<Map<String, dynamic>> algeriaCities = [
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

  Future<List<Map<String, dynamic>>> searchVetsInAllCities() async {
    final allResults = <Map<String, dynamic>>[];
    final processedPlaceIds = <String>{};

    // First search in major cities
    for (final city in algeriaCities) {
      try {
        print('Searching vets in ${city['name']}');
        final results = await searchNearbyVets(
          city['lat'], 
          city['lng'],
        );
        
        for (final result in results) {
          final placeId = result['place_id'] as String;
          if (!processedPlaceIds.contains(placeId)) {
            processedPlaceIds.add(placeId);
            allResults.add(result);
            print('Found vet in ${city['name']}: ${result['name']}');
          }
        }

        // For Saharan cities, also search in surrounding areas
        if (PlacesService.isSaharanRegion(city['lat'], city['lng'])) {
          // Search in a grid around the city to cover more area
          for (var latOffset = -0.5; latOffset <= 0.5; latOffset += 0.5) {
            for (var lngOffset = -0.5; lngOffset <= 0.5; lngOffset += 0.5) {
              if (latOffset == 0 && lngOffset == 0) continue; // Skip center point as it's already searched
              
              final lat = city['lat'] + latOffset;
              final lng = city['lng'] + lngOffset;
              
              print('Searching additional area near ${city['name']}: $lat, $lng');
              final additionalResults = await searchNearbyVets(lat, lng);
              
              for (final result in additionalResults) {
                final placeId = result['place_id'] as String;
                if (!processedPlaceIds.contains(placeId)) {
                  processedPlaceIds.add(placeId);
                  allResults.add(result);
                  print('Found vet in extended area near ${city['name']}: ${result['name']}');
                }
              }
            }
          }
        }
      } catch (e) {
        print('Error searching vets in ${city['name']}: $e');
      }
    }

    return allResults;
  }

  Future<List<Map<String, dynamic>>> searchStoresInAllCities() async {
    final allResults = <Map<String, dynamic>>[];
    final processedPlaceIds = <String>{};

    // First search in major cities
    for (final city in algeriaCities) {
      try {
        print('Searching stores in ${city['name']}');
        final results = await searchNearbyStores(
          city['lat'], 
          city['lng'],
        );
        
        for (final result in results) {
          final placeId = result['place_id'] as String;
          if (!processedPlaceIds.contains(placeId)) {
            processedPlaceIds.add(placeId);
            allResults.add(result);
            print('Found store in ${city['name']}: ${result['name']}');
          }
        }

        // For Saharan cities, also search in surrounding areas
        if (PlacesService.isSaharanRegion(city['lat'], city['lng'])) {
          // Search in a grid around the city to cover more area
          for (var latOffset = -0.5; latOffset <= 0.5; latOffset += 0.5) {
            for (var lngOffset = -0.5; lngOffset <= 0.5; lngOffset += 0.5) {
              if (latOffset == 0 && lngOffset == 0) continue;
              
              final lat = city['lat'] + latOffset;
              final lng = city['lng'] + lngOffset;
              
              print('Searching additional area near ${city['name']}: $lat, $lng');
              final additionalResults = await searchNearbyStores(lat, lng);
              
              for (final result in additionalResults) {
                final placeId = result['place_id'] as String;
                if (!processedPlaceIds.contains(placeId)) {
                  processedPlaceIds.add(placeId);
                  allResults.add(result);
                  print('Found store in extended area near ${city['name']}: ${result['name']}');
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
} 