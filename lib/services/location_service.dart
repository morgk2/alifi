import 'package:latlong2/latlong.dart';

class LocationService {
  // Static list of all wilayas in Algeria
  static const List<String> wilayas = [
    'Adrar', 'Chlef', 'Laghouat', 'Oum El Bouaghi', 'Batna', 'Béjaïa', 'Biskra',
    'Béchar', 'Blida', 'Bouira', 'Tamanrasset', 'Tébessa', 'Tlemcen', 'Tiaret',
    'Tizi Ouzou', 'Alger', 'Djelfa', 'Jijel', 'Sétif', 'Saïda', 'Skikda',
    'Sidi Bel Abbès', 'Annaba', 'Guelma', 'Constantine', 'Médéa', 'Mostaganem',
    'M\'Sila', 'Mascara', 'Ouargla', 'Oran', 'El Bayadh', 'Illizi',
    'Bordj Bou Arréridj', 'Boumerdès', 'El Tarf', 'Tindouf', 'Tissemsilt',
    'El Oued', 'Khenchela', 'Souk Ahras', 'Tipaza', 'Mila', 'Aïn Defla',
    'Naâma', 'Aïn Témouchent', 'Ghardaïa', 'Relizane', 'Timimoun',
    'Bordj Badji Mokhtar', 'Ouled Djellal', 'Béni Abbès', 'In Salah',
    'In Guezzam', 'Touggourt', 'Djanet', 'El M\'Ghair', 'El Meniaa'
  ];

  // Static list of veterinary clinics
  static final List<Map<String, dynamic>> vetClinics = [
    {
      'id': 'vet1',
      'name': 'Clinique Vétérinaire El Hayet',
      'address': 'Rue Didouche Mourad, Alger Centre',
      'wilaya': 'Alger',
      'coordinates': const LatLng(36.7762, 3.0595),
      'phone': '+213 21 63 54 21',
      'isVerified': true,
      'operatingHours': {
        'monday': '09:00-17:00',
        'tuesday': '09:00-17:00',
        'wednesday': '09:00-17:00',
        'thursday': '09:00-17:00',
        'friday': '09:00-12:00',
        'saturday': '09:00-15:00',
        'sunday': 'Closed',
      },
    },
    {
      'id': 'vet2',
      'name': 'Cabinet Vétérinaire Dr. Benali',
      'address': 'Boulevard Zirout Youcef, Oran',
      'wilaya': 'Oran',
      'coordinates': const LatLng(35.6969, -0.6331),
      'phone': '+213 41 32 45 67',
      'isVerified': true,
      'operatingHours': {
        'monday': '08:30-16:30',
        'tuesday': '08:30-16:30',
        'wednesday': '08:30-16:30',
        'thursday': '08:30-16:30',
        'friday': '08:30-12:00',
        'saturday': '09:00-14:00',
        'sunday': 'Closed',
      },
    },
    // Add more vet clinics here
  ];

  // Static list of pet stores
  static final List<Map<String, dynamic>> petStores = [
    {
      'id': 'store1',
      'name': 'Animalerie Royal',
      'address': 'Centre Commercial Bab Ezzouar, Alger',
      'wilaya': 'Alger',
      'coordinates': const LatLng(36.7213, 3.1873),
      'phone': '+213 21 24 56 78',
      'website': 'www.animalerieroyal.dz',
      'description': 'Large pet store with wide selection of supplies and accessories',
      'isVerified': true,
      'operatingHours': {
        'monday': '10:00-20:00',
        'tuesday': '10:00-20:00',
        'wednesday': '10:00-20:00',
        'thursday': '10:00-20:00',
        'friday': '14:00-20:00',
        'saturday': '10:00-20:00',
        'sunday': '10:00-18:00',
      },
    },
    {
      'id': 'store2',
      'name': 'Pet Shop Oran',
      'address': 'Rue Larbi Ben M\'Hidi, Oran',
      'wilaya': 'Oran',
      'coordinates': const LatLng(35.6987, -0.6349),
      'phone': '+213 41 36 78 90',
      'description': 'Specialized in pet food and accessories',
      'isVerified': true,
      'operatingHours': {
        'monday': '09:00-19:00',
        'tuesday': '09:00-19:00',
        'wednesday': '09:00-19:00',
        'thursday': '09:00-19:00',
        'friday': '14:00-19:00',
        'saturday': '09:00-19:00',
        'sunday': 'Closed',
      },
    },
    // Add more pet stores here
  ];

  // Get all vet clinics
  Future<List<Map<String, dynamic>>> getAllVetClinics() async {
    try {
      final results = <Map<String, dynamic>>[];
      for (final vet in vetClinics) {
        final coordinates = vet['coordinates'] as LatLng;
        results.add({
          'place_id': vet['id'],
          'location': {
            'latitude': coordinates.latitude,
            'longitude': coordinates.longitude,
          },
          'name': vet['name'],
          'address': vet['address'],
          'opening_hours': vet['operatingHours'],
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
      return results;
    } catch (e) {
      print('Error in getAllVetClinics: $e');
      return [];
    }
  }

  // Get all pet stores
  Future<List<Map<String, dynamic>>> getAllPetStores() async {
    try {
      final results = <Map<String, dynamic>>[];
      for (final store in petStores) {
        final coordinates = store['coordinates'] as LatLng;
        results.add({
          'place_id': store['id'],
          'location': {
            'latitude': coordinates.latitude,
            'longitude': coordinates.longitude,
          },
          'name': store['name'],
          'address': store['address'],
          'opening_hours': store['operatingHours'],
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
      return results;
    } catch (e) {
      print('Error in getAllPetStores: $e');
      return [];
    }
  }

  // Get locations by wilaya
  List<Map<String, dynamic>> getLocationsByWilaya(String wilaya, {String? type}) {
    if (type == 'vet') {
      return vetClinics.where((vet) => vet['wilaya'] == wilaya).toList();
    } else if (type == 'store') {
      return petStores.where((store) => store['wilaya'] == wilaya).toList();
    } else {
      return [
        ...vetClinics.where((vet) => vet['wilaya'] == wilaya),
        ...petStores.where((store) => store['wilaya'] == wilaya),
      ];
    }
  }

  // Search locations by name or address
  List<Map<String, dynamic>> searchLocations(String query, {String? type}) {
    final lowercaseQuery = query.toLowerCase();
    
    if (type == 'vet') {
      return vetClinics.where((vet) =>
        vet['name'].toLowerCase().contains(lowercaseQuery) ||
        vet['address'].toLowerCase().contains(lowercaseQuery)
      ).toList();
    } else if (type == 'store') {
      return petStores.where((store) =>
        store['name'].toLowerCase().contains(lowercaseQuery) ||
        store['address'].toLowerCase().contains(lowercaseQuery)
      ).toList();
    } else {
      return [
        ...vetClinics.where((vet) =>
          vet['name'].toLowerCase().contains(lowercaseQuery) ||
          vet['address'].toLowerCase().contains(lowercaseQuery)
        ),
        ...petStores.where((store) =>
          store['name'].toLowerCase().contains(lowercaseQuery) ||
          store['address'].toLowerCase().contains(lowercaseQuery)
        ),
      ];
    }
  }

  // Get nearby locations within a radius (in kilometers)
  List<Map<String, dynamic>> getNearbyLocations(LatLng userLocation, double radiusKm, {String? type}) {
    final distance = const Distance();
    
    if (type == 'vet') {
      return vetClinics.where((vet) {
        final distanceInKm = distance.as(
          LengthUnit.Kilometer,
          userLocation,
          vet['coordinates'] as LatLng,
        );
        return distanceInKm <= radiusKm;
      }).toList();
    } else if (type == 'store') {
      return petStores.where((store) {
        final distanceInKm = distance.as(
          LengthUnit.Kilometer,
          userLocation,
          store['coordinates'] as LatLng,
        );
        return distanceInKm <= radiusKm;
      }).toList();
    } else {
      return [
        ...vetClinics.where((vet) {
          final distanceInKm = distance.as(
            LengthUnit.Kilometer,
            userLocation,
            vet['coordinates'] as LatLng,
          );
          return distanceInKm <= radiusKm;
        }),
        ...petStores.where((store) {
          final distanceInKm = distance.as(
            LengthUnit.Kilometer,
            userLocation,
            store['coordinates'] as LatLng,
          );
          return distanceInKm <= radiusKm;
        }),
      ];
    }
  }
} 