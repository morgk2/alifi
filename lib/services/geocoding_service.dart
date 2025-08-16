import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeocodingService {
  static const String _userAgent = 'AlifiPetApp/1.0';
  
  /// Get address from coordinates with fallback mechanisms
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // Try primary geocoding service (Google/Apple)
      final address = await _getAddressFromPrimaryService(latitude, longitude);
      if (address.isNotEmpty) {
        return address;
      }
    } catch (e) {
      print('Primary geocoding service failed: $e');
    }
    
    try {
      // Try fallback geocoding service (OpenStreetMap)
      final address = await _getAddressFromFallbackService(latitude, longitude);
      if (address.isNotEmpty) {
        return address;
      }
    } catch (e) {
      print('Fallback geocoding service failed: $e');
    }
    
    // Return a generic message if all services fail
    return 'Location found (address unavailable)';
  }
  
  /// Primary geocoding service using the geocoding package
  static Future<String> _getAddressFromPrimaryService(double latitude, double longitude) async {
    try {
      print('Attempting to get address for coordinates: $latitude, $longitude');
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      print('Received ${placemarks.length} placemarks');
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        print('Full placemark data:');
        print('  - Locality: ${place.locality}');
        print('  - Administrative Area: ${place.administrativeArea}');
        print('  - Country: ${place.country}');
        print('  - SubLocality: ${place.subLocality}');
        print('  - Thoroughfare: ${place.thoroughfare}');
        print('  - SubThoroughfare: ${place.subThoroughfare}');
        print('  - Postal Code: ${place.postalCode}');
        
        String address = '';
        
        // Try different combinations to get a meaningful address
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += place.locality!;
        } else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += place.subLocality!;
        }
        
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }
        
        if (address.isEmpty && place.country != null) {
          address = place.country!;
        }
        
        // If still empty, try street address
        if (address.isEmpty) {
          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
            address += place.thoroughfare!;
          }
          if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
            if (address.isNotEmpty) address += ', ';
            address += place.subThoroughfare!;
          }
        }
        
        print('Final address: "$address"');
        return address;
      }
      
      return '';
    } catch (e) {
      print('Error getting address from primary service: $e');
      print('Error type: ${e.runtimeType}');
      
      // Handle specific geocoding errors
      if (e.toString().contains('Service not Available')) {
        print('Geocoding service is currently unavailable. This may be due to:');
        print('- Network connectivity issues');
        print('- Service temporarily down');
        print('- Rate limiting');
        print('- Region-specific service limitations');
      } else if (e.toString().contains('IO_ERROR')) {
        print('Network error occurred during geocoding');
      } else if (e.toString().contains('ZERO_RESULTS')) {
        print('No address data available for these coordinates');
      }
      
      rethrow;
    }
  }
  
  /// Fallback geocoding service using OpenStreetMap Nominatim
  static Future<String> _getAddressFromFallbackService(double latitude, double longitude) async {
    try {
      print('Attempting fallback geocoding service...');
      
      // Try using OpenStreetMap Nominatim service as fallback
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json'
        '&lat=$latitude'
        '&lon=$longitude'
        '&zoom=10'
        '&addressdetails=1'
      );
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': _userAgent,
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['display_name'] != null) {
          final displayName = data['display_name'] as String;
          
          // Extract meaningful parts of the address
          final parts = displayName.split(', ');
          if (parts.length >= 2) {
            // Take the first two parts (usually city and region)
            return parts.take(2).join(', ');
          } else {
            return displayName;
          }
        }
      }
      
      return '';
    } catch (e) {
      print('Fallback geocoding error: $e');
      return '';
    }
  }
  
  /// Get coordinates from address (forward geocoding)
  static Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        return {
          'latitude': locations[0].latitude,
          'longitude': locations[0].longitude,
        };
      }
      
      return null;
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return null;
    }
  }
}


