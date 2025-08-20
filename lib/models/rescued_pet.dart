import 'package:cloud_firestore/cloud_firestore.dart';

class RescuedPet {
  final String id;
  final String rescuerId;
  final String petOwnerId;
  final String petId;
  final String petName;
  final String petBreed;
  final List<String> petImageUrls;
  final DateTime rescueDate;
  final String? meetingId;
  final String? rescueLocation;
  final String? rescueStory;

  RescuedPet({
    required this.id,
    required this.rescuerId,
    required this.petOwnerId,
    required this.petId,
    required this.petName,
    required this.petBreed,
    required this.petImageUrls,
    required this.rescueDate,
    this.meetingId,
    this.rescueLocation,
    this.rescueStory,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'rescuerId': rescuerId,
      'petOwnerId': petOwnerId,
      'petId': petId,
      'petName': petName,
      'petBreed': petBreed,
      'petImageUrls': petImageUrls,
      'rescueDate': Timestamp.fromDate(rescueDate),
      'meetingId': meetingId,
      'rescueLocation': rescueLocation,
      'rescueStory': rescueStory,
    };
  }

  factory RescuedPet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RescuedPet(
      id: doc.id,
      rescuerId: data['rescuerId'] ?? '',
      petOwnerId: data['petOwnerId'] ?? '',
      petId: data['petId'] ?? '',
      petName: data['petName'] ?? '',
      petBreed: data['petBreed'] ?? '',
      petImageUrls: List<String>.from(data['petImageUrls'] ?? []),
      rescueDate: (data['rescueDate'] as Timestamp).toDate(),
      meetingId: data['meetingId'],
      rescueLocation: data['rescueLocation'],
      rescueStory: data['rescueStory'],
    );
  }
}
