import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String color;
  final int age;
  final String gender;
  final String? microchipId;
  final String? description;
  final List<String> imageUrls;
  final String ownerId;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final Map<String, dynamic> medicalInfo;
  final Map<String, dynamic> dietaryInfo;
  final List<String> tags;
  final bool isActive;
  final double? weight; // Added weight property

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.color,
    required this.age,
    required this.gender,
    this.microchipId,
    this.description,
    required this.imageUrls,
    required this.ownerId,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.medicalInfo,
    required this.dietaryInfo,
    required this.tags,
    this.isActive = true,
    this.weight, // Added weight parameter
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'color': color,
      'age': age,
      'gender': gender,
      'microchipId': microchipId,
      'description': description,
      'imageUrls': imageUrls,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
      'medicalInfo': medicalInfo,
      'dietaryInfo': dietaryInfo,
      'tags': tags,
      'isActive': isActive,
      'weight': weight, // Added weight to Firestore data
    };
  }

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Helper function to safely convert timestamps
    DateTime getTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    // Helper function to safely convert maps
    Map<String, dynamic> getMap(dynamic value) {
      if (value == null) return {};
      if (value is Map) {
        // Convert LinkedMap to regular Map
        return Map<String, dynamic>.from(value.map((key, val) => MapEntry(key.toString(), val)));
      }
      return {};
    }

    // Helper function to safely convert lists
    List<String> getStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) return List<String>.from(value.map((e) => e.toString()));
      return [];
    }

    return Pet(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      species: data['species']?.toString() ?? '',
      breed: data['breed']?.toString() ?? '',
      color: data['color']?.toString() ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      gender: data['gender']?.toString() ?? '',
      microchipId: data['microchipId']?.toString(),
      description: data['description']?.toString(),
      imageUrls: getStringList(data['imageUrls']),
      ownerId: data['ownerId']?.toString() ?? '',
      createdAt: getTimestamp(data['createdAt']),
      lastUpdatedAt: getTimestamp(data['lastUpdatedAt']),
      medicalInfo: getMap(data['medicalInfo']),
      dietaryInfo: getMap(data['dietaryInfo']),
      tags: getStringList(data['tags']),
      isActive: data['isActive'] as bool? ?? true,
      weight: (data['weight'] as num?)?.toDouble(), // Added weight from Firestore data
    );
  }

  Pet copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    String? color,
    int? age,
    String? gender,
    String? microchipId,
    String? description,
    List<String>? imageUrls,
    String? ownerId,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    Map<String, dynamic>? medicalInfo,
    Map<String, dynamic>? dietaryInfo,
    List<String>? tags,
    bool? isActive,
    double? weight, // Added weight to copyWith
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      color: color ?? this.color,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      microchipId: microchipId ?? this.microchipId,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      dietaryInfo: dietaryInfo ?? this.dietaryInfo,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      weight: weight ?? this.weight, // Added weight to new instance
    );
  }
} 