import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String color;
  final int age;
  final String gender;
  final List<String> imageUrls;
  final String ownerId;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final Map<String, dynamic> medicalInfo;
  final Map<String, dynamic> dietaryInfo;
  final List<String> tags;
  final bool isActive;
  final bool isForAdoption;
  final double? weight;
  final String? microchipId;
  final String? description;
  List<Map<String, dynamic>>? vaccines;
  List<Map<String, dynamic>>? illnesses;

  String? get photoURL => imageUrls.isNotEmpty ? imageUrls.first : null;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.color,
    required this.age,
    required this.gender,
    required this.imageUrls,
    required this.ownerId,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.medicalInfo,
    required this.dietaryInfo,
    required this.tags,
    required this.isActive,
    this.isForAdoption = false,
    this.weight,
    this.microchipId,
    this.description,
    this.vaccines,
    this.illnesses,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'color': color,
      'age': age,
      'gender': gender,
      'imageUrls': imageUrls,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
      'medicalInfo': medicalInfo,
      'dietaryInfo': dietaryInfo,
      'tags': tags,
      'isActive': isActive,
      'isForAdoption': isForAdoption,
      'weight': weight,
      'microchipId': microchipId,
      'description': description,
      if (vaccines != null) 'vaccines': vaccines,
      if (illnesses != null) 'illnesses': illnesses,
    };
  }

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    try {
      print('Converting document ${doc.id} to Pet');
      final data = doc.data() as Map<String, dynamic>;
      print('Document data: $data');
    
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

      // Helper function to safely get string value
      String getString(dynamic value, String defaultValue) {
        if (value == null) return defaultValue;
        return value.toString();
      }

      // Helper function to safely get int value
      int getInt(dynamic value, int defaultValue) {
        if (value == null) return defaultValue;
        if (value is num) return value.toInt();
        try {
          return int.parse(value.toString());
        } catch (e) {
          return defaultValue;
        }
      }

      // Helper function to safely get bool value
      bool getBool(dynamic value, bool defaultValue) {
        if (value == null) return defaultValue;
        if (value is bool) return value;
        return defaultValue;
      }

      // Helper function to safely get double value
      double? getDouble(dynamic value) {
        if (value == null) return null;
        if (value is num) return value.toDouble();
        try {
          return double.parse(value.toString());
        } catch (e) {
          return null;
        }
      }

      final pet = Pet(
        id: doc.id,
        name: getString(data['name'], ''),
        species: getString(data['species'], ''),
        breed: getString(data['breed'], ''),
        color: getString(data['color'], ''),
        age: getInt(data['age'], 0),
        gender: getString(data['gender'], ''),
        imageUrls: getStringList(data['imageUrls']),
        ownerId: getString(data['ownerId'], ''),
        createdAt: getTimestamp(data['createdAt']),
        lastUpdatedAt: getTimestamp(data['lastUpdatedAt']),
        medicalInfo: getMap(data['medicalInfo']),
        dietaryInfo: getMap(data['dietaryInfo']),
        tags: getStringList(data['tags']),
        isActive: getBool(data['isActive'], true),
        isForAdoption: getBool(data['isForAdoption'], false),
        weight: getDouble(data['weight']),
        microchipId: data['microchipId']?.toString(),
        description: data['description']?.toString(),
        vaccines: (data['vaccines'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList(),
        illnesses: (data['illnesses'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      print('Successfully converted to Pet: ${pet.name}');
      return pet;
    } catch (e, stackTrace) {
      print('Error converting document to Pet: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Pet copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    String? color,
    int? age,
    String? gender,
    List<String>? imageUrls,
    String? ownerId,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    Map<String, dynamic>? medicalInfo,
    Map<String, dynamic>? dietaryInfo,
    List<String>? tags,
    bool? isActive,
    bool? isForAdoption,
    double? weight,
    String? microchipId,
    String? description,
    List<Map<String, dynamic>>? vaccines,
    List<Map<String, dynamic>>? illnesses,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      color: color ?? this.color,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      imageUrls: imageUrls ?? this.imageUrls,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      dietaryInfo: dietaryInfo ?? this.dietaryInfo,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      isForAdoption: isForAdoption ?? this.isForAdoption,
      weight: weight ?? this.weight,
      microchipId: microchipId ?? this.microchipId,
      description: description ?? this.description,
      vaccines: vaccines ?? this.vaccines,
      illnesses: illnesses ?? this.illnesses,
    );
  }
} 