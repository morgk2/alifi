import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../config/mapbox_config.dart';

class PlaceSearchResult {
  final String name;
  final String address;
  final LatLng location;
  final String? distance;
  final String? placeType;
  final Map<String, dynamic> properties;

  PlaceSearchResult({
    required this.name,
    required this.address,
    required this.location,
    this.distance,
    this.placeType,
    required this.properties,
  });

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) {
    final coordinates = json['geometry']['coordinates'] as List;
    return PlaceSearchResult(
      name: json['text'] ?? '',
      address: json['place_name'] ?? '',
      location: LatLng(coordinates[1], coordinates[0]),
      placeType: json['properties']['category'],
      properties: json['properties'] ?? {},
    );
  }
}

class PlacesService {
  static const String _baseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';

  Future<List<PlaceSearchResult>> searchNearby({
    required String query,
    required LatLng location,
    double radiusKm = 10,
    int limit = 10,
  }) async {
    try {
      final bbox = _calculateBoundingBox(location, radiusKm);
      final encodedQuery = Uri.encodeComponent('$query veterinary');
      
      final url = '$_baseUrl/$encodedQuery.json'
          '?access_token=${MapboxConfig.accessToken}'
          '&proximity=${location.longitude},${location.latitude}'
          '&bbox=${bbox.join(',')}'
          '&limit=$limit'
          '&types=poi'
          '&language=en';

      print('Searching with URL: $url'); // Debug log

      final response = await http.get(Uri.parse(url));
      
      print('Response status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        
        print('Found ${features.length} results'); // Debug log

        if (features.isEmpty) {
          // Try a broader search without the "veterinary" keyword
          return await searchNearbyBroad(query: query, location: location, radiusKm: radiusKm, limit: limit);
        }

        return features.map((feature) {
          final result = PlaceSearchResult.fromJson(feature);
          // Calculate distance
          final distance = const Distance().as(
            LengthUnit.Kilometer,
            location,
            result.location,
          );
          return PlaceSearchResult(
            name: result.name,
            address: result.address,
            location: result.location,
            distance: _formatDistance(distance),
            placeType: result.placeType,
            properties: result.properties,
          );
        }).toList();
      }
      print('Non-200 response code: ${response.statusCode}'); // Debug log
      return [];
    } catch (e, stackTrace) {
      print('Error searching places: $e'); // Debug log
      print('Stack trace: $stackTrace'); // Debug log
      return [];
    }
  }

  // Add a broader search method that doesn't restrict to veterinary
  Future<List<PlaceSearchResult>> searchNearbyBroad({
    required String query,
    required LatLng location,
    double radiusKm = 10,
    int limit = 10,
  }) async {
    try {
      final bbox = _calculateBoundingBox(location, radiusKm);
      final encodedQuery = Uri.encodeComponent(query);
      
      final url = '$_baseUrl/$encodedQuery.json'
          '?access_token=${MapboxConfig.accessToken}'
          '&proximity=${location.longitude},${location.latitude}'
          '&bbox=${bbox.join(',')}'
          '&limit=$limit'
          '&types=poi,place'
          '&language=en';

      print('Trying broader search with URL: $url'); // Debug log

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        
        print('Found ${features.length} results in broad search'); // Debug log

        return features.map((feature) {
          final result = PlaceSearchResult.fromJson(feature);
          final distance = const Distance().as(
            LengthUnit.Kilometer,
            location,
            result.location,
          );
          return PlaceSearchResult(
            name: result.name,
            address: result.address,
            location: result.location,
            distance: _formatDistance(distance),
            placeType: result.placeType,
            properties: result.properties,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error in broad search: $e'); // Debug log
      return [];
    }
  }

  List<double> _calculateBoundingBox(LatLng center, double radiusKm) {
    const double kmInDegree = 111.32; // Approximate km per degree at equator
    
    double latChange = radiusKm / kmInDegree;
    double lonChange = radiusKm / (kmInDegree * cos(center.latitude * pi / 180));
    
    return [
      center.longitude - lonChange, // min lon
      center.latitude - latChange,  // min lat
      center.longitude + lonChange, // max lon
      center.latitude + latChange,  // max lat
    ];
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    }
    return '${distanceKm.toStringAsFixed(1)}km';
  }
} 