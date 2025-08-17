import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart' as latlong;

class AdoptionListing {
  final String id;
  final String petId;
  final String ownerId;
  final String title;
  final String description;
  final double adoptionFee;
  final List<String> imageUrls;
  final String contactNumber;
  final String location;
  final latlong.LatLng coordinates;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final bool isActive;
  final List<String> requirements;
  final String petType;
  final String breed;
  final int age;
  final String gender;
  final String color;

  AdoptionListing({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.adoptionFee,
    required this.imageUrls,
    required this.contactNumber,
    required this.location,
    required this.coordinates,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.isActive,
    required this.requirements,
    required this.petType,
    required this.breed,
    required this.age,
    required this.gender,
    required this.color,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'adoptionFee': adoptionFee,
      'imageUrls': imageUrls,
      'contactNumber': contactNumber,
      'location': location,
      'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
      'isActive': isActive,
      'requirements': requirements,
      'petType': petType,
      'breed': breed,
      'age': age,
      'gender': gender,
      'color': color,
    };
  }

  factory AdoptionListing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final geoPoint = data['coordinates'] as GeoPoint;
    
    return AdoptionListing(
      id: doc.id,
      petId: data['petId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      adoptionFee: (data['adoptionFee'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      contactNumber: data['contactNumber'] ?? '',
      location: data['location'] ?? '',
      coordinates: latlong.LatLng(geoPoint.latitude, geoPoint.longitude),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      requirements: List<String>.from(data['requirements'] ?? []),
      petType: data['petType'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      color: data['color'] ?? '',
    );
  }

  AdoptionListing copyWith({
    String? id,
    String? petId,
    String? ownerId,
    String? title,
    String? description,
    double? adoptionFee,
    List<String>? imageUrls,
    String? contactNumber,
    String? location,
    latlong.LatLng? coordinates,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    bool? isActive,
    List<String>? requirements,
    String? petType,
    String? breed,
    int? age,
    String? gender,
    String? color,
  }) {
    return AdoptionListing(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      adoptionFee: adoptionFee ?? this.adoptionFee,
      imageUrls: imageUrls ?? this.imageUrls,
      contactNumber: contactNumber ?? this.contactNumber,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isActive: isActive ?? this.isActive,
      requirements: requirements ?? this.requirements,
      petType: petType ?? this.petType,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      color: color ?? this.color,
    );
  }
}













