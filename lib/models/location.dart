import 'package:latlong2/latlong.dart';

class Location {
  final String id;
  final String name;
  final String type; // 'vet' or 'store'
  final String address;
  final String? phone;
  final String? website;
  final String? description;
  final String? imageUrl;
  final LatLng coordinates;
  final String wilaya;
  final bool isVerified;
  final Map<String, dynamic>? operatingHours;

  const Location({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.coordinates,
    required this.wilaya,
    this.phone,
    this.website,
    this.description,
    this.imageUrl,
    this.isVerified = false,
    this.operatingHours,
  });
}

// Static data class to hold all locations
class LocationData {
  static const List<Location> locations = [
    // Veterinary Clinics
    Location(
      id: 'vet1',
      name: 'Clinique Vétérinaire El Hayet',
      type: 'vet',
      address: 'Rue Didouche Mourad, Alger Centre',
      coordinates: LatLng(36.7762, 3.0595),
      wilaya: 'Alger',
      phone: '+213 21 63 54 21',
      isVerified: true,
      operatingHours: {
        'monday': '09:00-17:00',
        'tuesday': '09:00-17:00',
        'wednesday': '09:00-17:00',
        'thursday': '09:00-17:00',
        'friday': '09:00-12:00',
        'saturday': '09:00-15:00',
        'sunday': 'Closed',
      },
    ),
    Location(
      id: 'vet2',
      name: 'Cabinet Vétérinaire Dr. Benali',
      type: 'vet',
      address: 'Boulevard Zirout Youcef, Oran',
      coordinates: LatLng(35.6969, -0.6331),
      wilaya: 'Oran',
      phone: '+213 41 32 45 67',
      isVerified: true,
      operatingHours: {
        'monday': '08:30-16:30',
        'tuesday': '08:30-16:30',
        'wednesday': '08:30-16:30',
        'thursday': '08:30-16:30',
        'friday': '08:30-12:00',
        'saturday': '09:00-14:00',
        'sunday': 'Closed',
      },
    ),
    Location(
      id: 'vet3',
      name: 'Clinique Vétérinaire Constantine',
      type: 'vet',
      address: 'Avenue de l\'ALN, Constantine',
      coordinates: LatLng(36.3650, 6.6147),
      wilaya: 'Constantine',
      phone: '+213 31 92 45 78',
      isVerified: true,
      operatingHours: {
        'monday': '09:00-17:00',
        'tuesday': '09:00-17:00',
        'wednesday': '09:00-17:00',
        'thursday': '09:00-17:00',
        'friday': '09:00-12:00',
        'saturday': '09:00-15:00',
        'sunday': 'Closed',
      },
    ),

    // Pet Stores
    Location(
      id: 'store1',
      name: 'Animalerie Royal',
      type: 'store',
      address: 'Centre Commercial Bab Ezzouar, Alger',
      coordinates: LatLng(36.7213, 3.1873),
      wilaya: 'Alger',
      phone: '+213 21 24 56 78',
      website: 'www.animalerieroyal.dz',
      description: 'Large pet store with wide selection of supplies and accessories',
      isVerified: true,
      operatingHours: {
        'monday': '10:00-20:00',
        'tuesday': '10:00-20:00',
        'wednesday': '10:00-20:00',
        'thursday': '10:00-20:00',
        'friday': '14:00-20:00',
        'saturday': '10:00-20:00',
        'sunday': '10:00-18:00',
      },
    ),
    Location(
      id: 'store2',
      name: 'Pet Shop Oran',
      type: 'store',
      address: 'Rue Larbi Ben M\'Hidi, Oran',
      coordinates: LatLng(35.6987, -0.6349),
      wilaya: 'Oran',
      phone: '+213 41 36 78 90',
      description: 'Specialized in pet food and accessories',
      isVerified: true,
      operatingHours: {
        'monday': '09:00-19:00',
        'tuesday': '09:00-19:00',
        'wednesday': '09:00-19:00',
        'thursday': '09:00-19:00',
        'friday': '14:00-19:00',
        'saturday': '09:00-19:00',
        'sunday': 'Closed',
      },
    ),
    Location(
      id: 'store3',
      name: 'Animal House',
      type: 'store',
      address: 'Route de Sétif, Constantine',
      coordinates: LatLng(36.3716, 6.6153),
      wilaya: 'Constantine',
      phone: '+213 31 87 65 43',
      description: 'Complete pet supplies and grooming services',
      isVerified: true,
      operatingHours: {
        'monday': '09:00-18:00',
        'tuesday': '09:00-18:00',
        'wednesday': '09:00-18:00',
        'thursday': '09:00-18:00',
        'friday': '14:00-18:00',
        'saturday': '09:00-18:00',
        'sunday': 'Closed',
      },
    ),
  ];

  // Helper method to get locations by type
  static List<Location> getLocationsByType(String type) {
    return locations.where((location) => location.type == type).toList();
  }

  // Helper method to get locations by wilaya
  static List<Location> getLocationsByWilaya(String wilaya) {
    return locations.where((location) => location.wilaya == wilaya).toList();
  }

  // Helper method to get all unique wilayas
  static List<String> getAllWilayas() {
    return locations.map((location) => location.wilaya).toSet().toList()..sort();
  }

  // Helper method to search locations by name or address
  static List<Location> searchLocations(String query) {
    final lowercaseQuery = query.toLowerCase();
    return locations.where((location) {
      return location.name.toLowerCase().contains(lowercaseQuery) ||
          location.address.toLowerCase().contains(lowercaseQuery) ||
          location.wilaya.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
} 