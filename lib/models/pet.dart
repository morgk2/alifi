import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String id;
  final String name;
  final String species; // 'dog', 'cat', etc.
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
  final Map<String, dynamic> medicalInfo; // vaccinations, conditions, etc.
  final Map<String, dynamic> dietaryInfo; // food preferences, allergies, etc.
  final List<String> tags;
  final bool isActive; // to soft delete pets

  const Pet({
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
    required this.isActive,
  });

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pet(
      id: doc.id,
      name: data['name'] ?? '',
      species: data['species'] ?? '',
      breed: data['breed'] ?? '',
      color: data['color'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      microchipId: data['microchipId'],
      description: data['description'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      ownerId: data['ownerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp).toDate(),
      medicalInfo: Map<String, dynamic>.from(data['medicalInfo'] ?? {}),
      dietaryInfo: Map<String, dynamic>.from(data['dietaryInfo'] ?? {}),
      tags: List<String>.from(data['tags'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }

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
    };
  }

  Pet copyWith({
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
    DateTime? lastUpdatedAt,
    Map<String, dynamic>? medicalInfo,
    Map<String, dynamic>? dietaryInfo,
    List<String>? tags,
    bool? isActive,
  }) {
    return Pet(
      id: id,
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
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      dietaryInfo: dietaryInfo ?? this.dietaryInfo,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
    );
  }
} 