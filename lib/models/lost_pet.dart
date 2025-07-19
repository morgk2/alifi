import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'pet.dart';

class LostPet {
  final String id;
  final Pet pet;
  final latlong.LatLng location;
  final String address;
  final DateTime lastSeenDate;
  final DateTime reportedDate;
  final bool isFound;
  final String reportedByUserId;
  final String? additionalInfo;
  final List<String> contactNumbers;

  LostPet({
    required this.id,
    required this.pet,
    required this.location,
    required this.address,
    required this.lastSeenDate,
    required this.reportedDate,
    this.isFound = false,
    required this.reportedByUserId,
    this.additionalInfo,
    this.contactNumbers = const [],
  });

  static Future<LostPet?> fromFirestore(DocumentSnapshot doc, FirebaseFirestore db) async {
    final data = doc.data() as Map<String, dynamic>;
    
    // Get the pet document
    final petDoc = await db.collection('pets').doc(data['petId'].toString()).get();
    if (!petDoc.exists) return null;
    
    final pet = Pet.fromFirestore(petDoc);
    final geoPoint = data['location'] as GeoPoint;

    return LostPet(
      id: doc.id,
      pet: pet,
      location: latlong.LatLng(geoPoint.latitude, geoPoint.longitude),  // Convert GeoPoint to latlong2.LatLng
      address: data['address']?.toString() ?? '',
      lastSeenDate: (data['lastSeenDate'] as Timestamp).toDate(),
      reportedDate: (data['reportedDate'] as Timestamp).toDate(),
      isFound: data['isFound'] as bool? ?? false,
      reportedByUserId: data['reportedByUserId']?.toString() ?? '',
      additionalInfo: data['additionalInfo']?.toString(),
      contactNumbers: List<String>.from(data['contactNumbers'] ?? []),
    );
  }
}
