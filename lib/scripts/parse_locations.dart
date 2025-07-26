import 'dart:convert';
import 'dart:io';

void main() {
  try {
    // Read stores data
    final storesFile = File('assets/data/stores.txt');
    final storesContent = storesFile.readAsStringSync();
    final storesMap = parseLocations(storesContent);
    
    // Read vets data
    final vetsFile = File('assets/data/vets.txt');
    final vetsContent = vetsFile.readAsStringSync();
    final vetsMap = parseLocations(vetsContent);
    
    // Create locations data structure
    final locationsData = {
      'stores': storesMap,
      'vets': vetsMap,
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    // Create assets/data directory if it doesn't exist
    final directory = Directory('assets/data');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    // Write to JSON file
    final file = File('assets/data/locations.json');
    file.writeAsStringSync(
      JsonEncoder.withIndent('  ').convert(locationsData),
      flush: true,
    );

    print('Successfully created locations.json');
    print('JSON structure:');
    print('- stores: ${storesMap.length} locations');
    print('- vets: ${vetsMap.length} locations');

  } catch (e) {
    print('Error creating JSON: $e');
    print('Stack trace:');
    print(StackTrace.current);
  }
}

Map<String, Map<String, dynamic>> parseLocations(String content) {
  final lines = content.split('\n');
  final locations = <String, Map<String, dynamic>>{};
  
  String? currentPlaceId;
  double? lat;
  double? lng;
  DateTime? createdAt;
  
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    
    if (line.startsWith('ChIJ')) {
      currentPlaceId = line.trim();
    } else if (line.contains('createdAt')) {
      // Skip createdAt line, we'll use current timestamp
      continue;
    } else if (line.contains('°')) {
      // Parse coordinates
      final coords = line.replaceAll('[', '').replaceAll(']', '').split(',');
      if (coords.length == 2) {
        lat = double.tryParse(coords[0].replaceAll('° N', '').trim());
        lng = double.tryParse(coords[1].replaceAll('° E', '').replaceAll('° W', '').trim());
        if (coords[1].contains('° W')) {
          lng = -lng!;
        }
      }
      
      // If we have all data, add the location
      if (currentPlaceId != null && lat != null && lng != null) {
        locations[currentPlaceId] = {
          'location': {
            'latitude': lat,
            'longitude': lng,
          },
          'createdAt': DateTime.now().toIso8601String(),
        };
        
        // Reset for next location
        currentPlaceId = null;
        lat = null;
        lng = null;
      }
    }
  }
  
  return locations;
} 