class LostPet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String color;
  final int age;
  final String gender;
  final String description;
  final List<String> imageUrls;
  final DateTime lastSeen;
  final Map<String, double> lastLocation; // {latitude, longitude}
  final String ownerName;
  final String ownerContact;
  final String status; // 'lost', 'found', 'reunited'
  final List<String> tags;

  const LostPet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.color,
    required this.age,
    required this.gender,
    required this.description,
    required this.imageUrls,
    required this.lastSeen,
    required this.lastLocation,
    required this.ownerName,
    required this.ownerContact,
    required this.status,
    required this.tags,
  });

  // Mock data for development
  static List<LostPet> get mockPets => [
        LostPet(
          id: 'pet_001',
          name: 'Max',
          species: 'Dog',
          breed: 'Golden Retriever',
          color: 'Golden',
          age: 3,
          gender: 'Male',
          description: 'Friendly golden retriever with a red collar',
          imageUrls: ['assets/images/pet1.jpg'],
          lastSeen: DateTime.now().subtract(const Duration(days: 2)),
          lastLocation: {'latitude': 36.7538, 'longitude': 3.0588},
          ownerName: 'John Smith',
          ownerContact: '+213 555 123 456',
          status: 'lost',
          tags: ['dog', 'golden retriever', 'friendly'],
        ),
        LostPet(
          id: 'pet_002',
          name: 'Luna',
          species: 'Cat',
          breed: 'Siamese',
          color: 'White and Brown',
          age: 2,
          gender: 'Female',
          description: 'Siamese cat with blue eyes and brown points',
          imageUrls: ['assets/images/pet2.jpg'],
          lastSeen: DateTime.now().subtract(const Duration(days: 1)),
          lastLocation: {'latitude': 36.7525, 'longitude': 3.0420},
          ownerName: 'Sarah Johnson',
          ownerContact: '+213 555 789 012',
          status: 'lost',
          tags: ['cat', 'siamese', 'blue eyes'],
        ),
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'species': species,
        'breed': breed,
        'color': color,
        'age': age,
        'gender': gender,
        'description': description,
        'imageUrls': imageUrls,
        'lastSeen': lastSeen.toIso8601String(),
        'lastLocation': lastLocation,
        'ownerName': ownerName,
        'ownerContact': ownerContact,
        'status': status,
        'tags': tags,
      };

  factory LostPet.fromJson(Map<String, dynamic> json) => LostPet(
        id: json['id'] as String,
        name: json['name'] as String,
        species: json['species'] as String,
        breed: json['breed'] as String,
        color: json['color'] as String,
        age: json['age'] as int,
        gender: json['gender'] as String,
        description: json['description'] as String,
        imageUrls: (json['imageUrls'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        lastSeen: DateTime.parse(json['lastSeen'] as String),
        lastLocation: Map<String, double>.from(json['lastLocation'] as Map),
        ownerName: json['ownerName'] as String,
        ownerContact: json['ownerContact'] as String,
        status: json['status'] as String,
        tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      );
}
